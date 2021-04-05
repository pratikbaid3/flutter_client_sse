library client_sse;

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

class SSEResponse {
  String id = '';
  String event = '';
  String data = '';
  SSEResponse({@required this.data, @required this.id, @required this.event});
}

class SSEClient {
  SSEResponse sseResponse = new SSEResponse(data: '', id: '', event: '');
  static http.Client _client;
  static void subscribeToSSE(BuildContext context, String url, String token) {
    print("--SUBSCRIBING TO SSE---");
    try {
      _client = http.Client();
      var request = new http.Request("GET", Uri.parse(url));
      request.headers["Cache-Control"] = "no-cache";
      request.headers["Accept"] = "text/event-stream";
      request.headers["Cookie"] = token;
      Future<http.StreamedResponse> response = _client.send(request);
      response.asStream().listen((streamedResponse) {
        streamedResponse.stream.listen((data) {
          final rawData = utf8.decode(data);
          final event = rawData.split("\n")[1];
          if (event != null && event != '') {
            print(rawData);
            SSEResponse(
                id: rawData.split("\n")[0],
                event: rawData.split("\n")[1],
                data: rawData.split("\n")[2]);
          }
        });
      });
    } catch (e) {
      print('---ERROR---');
      print(e);
    }
  }

  static void unsubscribeFromSSE() {
    _client.close();
  }
}
