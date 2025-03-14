library flutter_client_sse;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:http/http.dart' as http;

part 'sse_event_model.dart';

class SSEClient {
  static http.Client _client = http.Client();

  static void _retryConnection({
    required SSERequestType method,
    required String url,
    required Map<String, String> header,
    required StreamController<SSEModel> streamController,
    Map<String, dynamic>? body,
    int? retriesLeft,
    required int maxRetries,
  }) {
    if (retriesLeft == null || retriesLeft <= 0) {
      print('---MAX RETRY LIMIT REACHED---');
      streamController.addError('Erro: Max retry limit reached');
      streamController.close();
      _client.close();
      return;
    }

    print('---RETRY CONNECTION ($retriesLeft retries left)---');
    Future.delayed(Duration(seconds: 5), () {
      subscribeToSSE(
        method: method,
        url: url,
        header: header,
        body: body,
        oldStreamController: streamController,
        maxRetries: maxRetries,
        retriesLeft: retriesLeft - 1,
      );
    });
  }

  static Stream<SSEModel> subscribeToSSE({
    required SSERequestType method,
    required String url,
    required Map<String, String> header,
    StreamController<SSEModel>? oldStreamController,
    Map<String, dynamic>? body,
    int maxRetries = 5,
    int? retriesLeft,
  }) {
    StreamController<SSEModel> streamController = oldStreamController ?? StreamController();
    retriesLeft ??= maxRetries;

    var lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');
    var currentSSEModel = SSEModel(data: '', id: '', event: '');
    print("--SUBSCRIBING TO SSE---");

    try {
      _client = http.Client();
      var request = http.Request(
        method == SSERequestType.GET ? "GET" : "POST",
        Uri.parse(url),
      );

      header.forEach((key, value) {
        request.headers[key] = value;
      });

      if (body != null) {
        request.body = jsonEncode(body);
      }

      Future<http.StreamedResponse> response = _client.send(request);

      response.asStream().listen((data) {
        data.stream.transform(Utf8Decoder()).transform(LineSplitter()).listen(
          (dataLine) {
            if (dataLine.isEmpty) {
              streamController.add(currentSSEModel);
              currentSSEModel = SSEModel(data: '', id: '', event: '');
              return;
            }

            Match? match = lineRegex.firstMatch(dataLine);
            if (match == null) return;
            var field = match.group(1);
            if (field == null || field.isEmpty) return;
            var value = match.group(2) ?? '';

            switch (field) {
              case 'event':
                currentSSEModel.event = value;
                break;
              case 'data':
                currentSSEModel.data = (currentSSEModel.data ?? '') + value + '\n';
                break;
              case 'id':
                currentSSEModel.id = value;
                break;
              default:
                print('---ERROR---');
                print(dataLine);
                _retryConnection(
                  method: method,
                  url: url,
                  header: header,
                  streamController: streamController,
                  body: body,
                  retriesLeft: retriesLeft,
                  maxRetries: maxRetries,
                );
            }
          },
          onError: (e, s) {
            print('---ERROR---');
            print(e);
            _retryConnection(
              method: method,
              url: url,
              header: header,
              body: body,
              streamController: streamController,
              retriesLeft: retriesLeft,
              maxRetries: maxRetries,
            );
          },
        );
      }, onError: (e, s) {
        print('---ERROR---');
        print(e);
        _retryConnection(
          method: method,
          url: url,
          header: header,
          body: body,
          streamController: streamController,
          retriesLeft: retriesLeft,
          maxRetries: maxRetries,
        );
      });
    } catch (e) {
      print('---ERROR---');
      print(e);
      _retryConnection(
        method: method,
        url: url,
        header: header,
        body: body,
        streamController: streamController,
        retriesLeft: retriesLeft,
        maxRetries: maxRetries,
      );
    }

    return streamController.stream;
  }

  static void unsubscribeFromSSE() {
    _client.close();
  }
}
