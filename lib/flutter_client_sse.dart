library flutter_client_sse;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/retry_options.dart';
import 'package:flutter_client_sse/utils.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

part 'sse_event_model.dart';

/// A client for subscribing to Server-Sent Events (SSE).
class SSEClient {
  static http.Client _client = new http.Client();
  static final _log = Logger('SSEClient');
  static bool _stopSignal = false;

  /// Retry the SSE connection after a delay.
  ///
  /// [method] is the request method (GET or POST).
  /// [url] is the URL of the SSE endpoint.
  /// [header] is a map of request headers.
  /// [body] is an optional request body for POST requests.
  /// [streamController] is required to persist the stream from the old connection
  /// [retryOptions] is the options for retrying the connection.
  /// [currentRetry] is the current retry count.
  ///
  static void _retryConnection({
    required SSERequestType method,
    required String url,
    required Map<String, String> header,
    required StreamController<SSEModel> streamController,
    Map<String, dynamic>? body,
    required RetryOptions retryOptions,
    required int currentRetry,
  }) {
    if (_stopSignal) {
      _log.info('---NO RETRY: STOP SIGNAL RECEIVED---');
      streamController.close();
      return;
    }

    _log.finest('$currentRetry retry of  ${retryOptions.maxRetry} retries');

    if (retryOptions.maxRetry != 0 && currentRetry >= retryOptions.maxRetry) {
      _log.info('---MAX RETRY REACHED---');
      retryOptions.limitReachedCallback?.call();
      streamController.close();
      return;
    }
    _log.info('---RETRY CONNECTION---');
    int delay = _delay(
        currentRetry, retryOptions.minRetryTime, retryOptions.maxRetryTime);
    _log.finest('waiting for $delay ms');

    Future.delayed(Duration(milliseconds: delay), () {
      subscribeToSSE(
        method: method,
        url: url,
        header: header,
        body: body,
        oldStreamController: streamController,
        retryOptions: retryOptions,
        retryCount: currentRetry + 1,
      );
    });
  }

  static int _delay(int currentRetry, int minRetryTime, int retryTime) {
    return Utils.expBackoff(
        minRetryTime, retryTime, currentRetry, _defaultJitterFn);
  }

  static int _defaultJitterFn(int num) {
    var randomFactor = 0.26;

    return Utils.jitter(num, randomFactor);
  }

  /// Subscribe to Server-Sent Events.
  ///
  /// [method] is the request method (GET or POST).
  /// [url] is the URL of the SSE endpoint.
  /// [header] is a map of request headers.
  /// [body] is an optional request body for POST requests.
  /// [oldStreamController] stream controller, used to retry to persist the
  /// stream from the old connection.
  /// [client] is an optional http client used for testing purpose
  /// or custom client.
  /// [retryOptions] is the options for retrying the connection.
  /// [retryCount] is the current retry count.
  ///
  /// Returns a [Stream] of [SSEModel] representing the SSE events.
  static Stream<SSEModel> subscribeToSSE({
    required SSERequestType method,
    required String url,
    required Map<String, String> header,
    StreamController<SSEModel>? oldStreamController,
    http.Client? client,
    Map<String, dynamic>? body,
    RetryOptions? retryOptions,
    int retryCount = 0,
  }) {
    RetryOptions _retryOptions = retryOptions ?? RetryOptions();
    StreamController<SSEModel> streamController = StreamController();
    if (oldStreamController != null) {
      streamController = oldStreamController;
    }
    var lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');
    var currentSSEModel = SSEModel(data: '', id: '', event: '');
    _log.info("--SUBSCRIBING TO SSE---");
    while (true) {
      try {
        _client = client ?? http.Client();
        var request = new http.Request(
          method == SSERequestType.GET ? "GET" : "POST",
          Uri.parse(url),
        );

        /// Adding headers to the request
        header.forEach((key, value) {
          request.headers[key] = value;
        });

        /// Adding body to the request if exists
        if (body != null) {
          request.body = jsonEncode(body);
        }

        Future<http.StreamedResponse> response = _client.send(request);

        /// Listening to the response as a stream
        response.asStream().listen((data) {
          if (data.statusCode != 200) {
            _log.severe('---ERROR CODE ${data.statusCode}---');
            _retryConnection(
              method: method,
              url: url,
              header: header,
              body: body,
              streamController: streamController,
              retryOptions: _retryOptions,
              currentRetry: retryCount,
            );
            return;
          }

          /// Applying transforms and listening to it
          data.stream
            ..transform(Utf8Decoder()).transform(LineSplitter()).listen(
              (dataLine) {
                if (dataLine.isEmpty) {
                  /// This means that the complete event set has been read.
                  /// We then add the event to the stream
                  streamController.add(currentSSEModel);
                  currentSSEModel = SSEModel(data: '', id: '', event: '');
                  return;
                }

                /// Get the match of each line through the regex
                Match match = lineRegex.firstMatch(dataLine)!;
                var field = match.group(1);
                if (field!.isEmpty) {
                  return;
                }
                var value = '';
                if (field == 'data') {
                  // If the field is data, we get the data through the substring
                  value = dataLine.substring(
                    5,
                  );
                } else {
                  value = match.group(2) ?? '';
                }
                switch (field) {
                  case 'event':
                    currentSSEModel.event = value;
                    break;
                  case 'data':
                    currentSSEModel.data =
                        (currentSSEModel.data ?? '') + value + '\n';
                    break;
                  case 'id':
                    currentSSEModel.id = value;
                    break;
                  case 'retry':
                    break;
                  default:
                    _log.severe('---ERROR---');
                    _log.severe(dataLine);
                    _retryConnection(
                      method: method,
                      url: url,
                      header: header,
                      streamController: streamController,
                      retryOptions: _retryOptions,
                      currentRetry: retryCount,
                    );
                }
              },
              onError: (e, s) {
                _log.severe('---ERROR---');
                _log.severe(e);
                _retryConnection(
                  method: method,
                  url: url,
                  header: header,
                  body: body,
                  streamController: streamController,
                  currentRetry: retryCount,
                  retryOptions: _retryOptions,
                );
              },
            );
        }, onError: (e, s) {
          _log.severe('---ERROR---');
          _log.severe(e);
          _retryConnection(
            method: method,
            url: url,
            header: header,
            body: body,
            streamController: streamController,
            retryOptions: _retryOptions,
            currentRetry: retryCount,
          );
        });
      } catch (e) {
        _log.severe('---ERROR---');
        _log.severe(e);
        _retryConnection(
          method: method,
          url: url,
          header: header,
          body: body,
          streamController: streamController,
          retryOptions: _retryOptions,
          currentRetry: retryCount,
        );
      }
      return streamController.stream;
    }
  }

  /// Unsubscribe from the SSE.
  static void unsubscribeFromSSE() {
    _stopSignal = true;
    _client.close();
  }
}
