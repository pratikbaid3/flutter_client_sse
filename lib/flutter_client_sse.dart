library flutter_client_sse;

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
part 'sse_event_model.dart';

class SSEClient {
  
  static http.Client _client = http.Client();
  
  static Stream<SSEModel> subscribeToSSE(String url, String token) {
    
    // the regexes we will use later
    RegExp lineRegex = new RegExp(r"^([^:]*)(?::)?(?: )?(.*)?$");
    RegExp removeEndingNewlineRegex = new RegExp(r"^((?:.|\n)*)\n$");
    
    //Creating a instance of the SSEModel
    var currentSSEModel = SSEModel(data: '', id: '', event: '');
    
    // ignore: close_sinks
    StreamController<SSEModel> streamController = new StreamController();
    print("--SUBSCRIBING TO SSE---");
    
    while (true) {
      try {
        _client = http.Client();
        var request = new http.Request("GET", Uri.parse(url));
        request.headers["Cache-Control"] = "no-cache";
        request.headers["Accept"] = "text/event-stream";
        request.headers["Cookie"] = token;
        Future<http.StreamedResponse> response = _client.send(request);
        
        //Listening to the response as a stream
        response.asStream().listen((data) {
          //Applying transforms and listening to it
          data.stream
            .transform(Utf8Decoder())
            .transform(LineSplitter())
            .listen((line) {
              if (line.isEmpty) {
                // event is done
                // strip ending newline from data
                if (currentSSEModel.data != null) {
                  var match = removeEndingNewlineRegex.firstMatch(currentSSEModel.data ?? "");
                  currentSSEModel.data = match?.group(1);
                }
                streamController.add(currentSSEModel);
                currentSSEModel = SSEModel(data: '', id: '', event: '');
                return;
              }
              
              // match the line prefix and the value using the regex
              Match match = lineRegex.firstMatch(line)!;
              String field = match.group(1)!;
              String value = match.group(2) ?? "";
              if (field.isEmpty) {
                // lines starting with a colon are to be ignored
                return;
              }
              switch (field) {
                case "event":
                  currentSSEModel.event = value;
                  break;
                case "data":
                  currentSSEModel.data = (currentSSEModel.data ?? "") + value + "\n";
                  break;
                case "id":
                  currentSSEModel.id = value;
                  break;
                case "retry":
                  break;
              }
              
            }, onDone: () {
              Future.delayed(Duration(seconds: 2), (){
                print("## Reconnecting to SSE");
                subscribeToSSE(url, token);
              });
            });
        });
        return streamController.stream;
      } catch (e) {
        print('---ERROR---');
        print(e);
        streamController.add(SSEModel(data: '', id: '', event: ''));
      }
    }
  }

  static void unsubscribeFromSSE() {
    _client.close();
  }
}
