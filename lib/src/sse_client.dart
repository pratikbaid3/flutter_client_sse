import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'constants/sse_request_type_enum.dart';
import 'sse_event_model.dart';

class SSEClient {
  static http.Client _client = http.Client();
  static final _lineRegex = RegExp(r'^([^:]*)(?::)?(?: )?(.*)?$');

  ///def: Subscribes to SSE
  ///param:
  ///[method]->Request method ie: GET/POST
  ///[url]->URl of the SSE api
  ///[header]->Map<String,String>, key value pair of the request header
  static Stream<SSEModel> subscribeToSSE({
    required String url,
    required Map<String, String> header,
    SSERequestType method = SSERequestType.GET,
    Map<String, dynamic>? body,
  }) {
    // ignore: close_sinks
    final streamController = StreamController<SSEModel>();
    debugPrint("--SUBSCRIBING TO SSE---");
    try {
      _client = http.Client();
      final request = http.Request(
        method == SSERequestType.GET ? "GET" : "POST",
        Uri.parse(url),
      );

      ///Adding headers to the request
      header.forEach((key, value) {
        request.headers[key] = value;
      });

      ///Adding body to the request if exists
      if (body != null) {
        request.body = jsonEncode(body);
      }

      Future<http.StreamedResponse> response = _client.send(request);

      ///Listening to the response as a stream
      response.asStream().listen(
        (data) => _handleResponseStream(data, streamController),
        onError: (e, s) {
          debugPrint('---ERROR---');
          debugPrint(e);
          streamController.addError(e, s);
        },
      );
    } catch (e, s) {
      debugPrint('---ERROR---');
      debugPrint(e.toString());
      streamController.addError(e, s);
    }

    return streamController.stream;
  }

  static void unsubscribeFromSSE() {
    _client.close();
  }

  static void _handleResponseStream(
    http.StreamedResponse data,
    StreamController<SSEModel> streamController,
  ) {
    var currentSSEModel = SSEModel();

    data.stream
        .transform(const Utf8Decoder())
        .transform(const LineSplitter())
        .listen(
      (dataLine) {
        if (dataLine.isEmpty) {
          ///This means that the complete event set has been read.
          ///We then add the event to the stream
          streamController.add(currentSSEModel);
          currentSSEModel = SSEModel();
          return;
        }

        ///Get the match of each line through the regex
        final match = _lineRegex.firstMatch(dataLine)!;
        final field = match.group(1) ?? "";
        if (field.isEmpty) {
          return;
        }
        var value = '';
        if (field == 'data') {
          //If the field is data, we get the data through the substring
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
            currentSSEModel.data = '${currentSSEModel.data ?? ''}$value\n';
            break;
          case 'id':
            currentSSEModel.id = value;
            break;
          case 'retry':
            break;
        }
      },
      onError: (e, s) {
        debugPrint('---ERROR---');
        debugPrint(e);
        streamController.addError(e, s);
      },
    );
  }
}
