import 'dart:convert';
import 'dart:io';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

class MockHttp extends Mock implements http.Client {}

void main() {
  group('SSE Client', () {
    setUpAll(() {
      registerFallbackValue(
          http.Request('GET', Uri.parse('http://localhost:3001')));
    });

    test('GET', () async {
      var mockHttp = MockHttp();
      var elements = [
        utf8.encode('id: 1\nevent: message\ndata: Hello\n\n'),
        utf8.encode('id: 2\nevent: message\ndata: World\n\n'),
        utf8.encode('id: 3\nevent: message\ndata: World\n\n'),
      ];

      when(() => mockHttp.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(Stream.fromIterable(elements), 200,
            headers: {
              HttpHeaders.contentTypeHeader: 'text/event-stream',
              HttpHeaders.cacheControlHeader: 'no-cache',
              HttpHeaders.connectionHeader: 'keep-alive',
            });
      });
      int lines = 0;
      SSEClient.subscribeToSSE(
          client: mockHttp,
          method: SSERequestType.GET,
          url: 'http://localhost:3001',
          header: {
            "Cookie":
                'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2NDMyMTAyMzEsImV4cCI6MTY0MzgxNTAzMX0.U0aCAM2fKE1OVnGFbgAU_UVBvNwOMMquvPY8QaLD138; Path=/; Expires=Wed, 02 Feb 2022 15:17:11 GMT; HttpOnly; SameSite=Strict',
            "Accept": "text/event-stream",
            "Cache-Control": "no-cache",
          }).listen(
        (event) {
          lines++;
          print('Id: ' + (event.id ?? ""));
          print('Event: ' + (event.event ?? ""));
          print('Data: ' + (event.data ?? ""));
        },
      );
      await Future.delayed(const Duration(seconds: 1));
      expect(lines, 3);
    });
    test('POST', () async {
      int lines = 0;

      var mockHttp = MockHttp();
      var elements = [
        utf8.encode('id: 1\nevent: message\ndata: Hello\n\n'),
        utf8.encode('id: 2\nevent: message\ndata: World\n\n'),
      ];

      when(() => mockHttp.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(Stream.fromIterable(elements), 200,
            headers: {
              HttpHeaders.contentTypeHeader: 'text/event-stream',
              HttpHeaders.cacheControlHeader: 'no-cache',
              HttpHeaders.connectionHeader: 'keep-alive',
            });
      });
      SSEClient.subscribeToSSE(
          client: mockHttp,
          method: SSERequestType.POST,
          url:
              'http://192.168.1.2:3000/api/activity-stream?historySnapshot=FIVE_MINUTE',
          header: {
            "Cookie":
                'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2NDMyMTAyMzEsImV4cCI6MTY0MzgxNTAzMX0.U0aCAM2fKE1OVnGFbgAU_UVBvNwOMMquvPY8QaLD138; Path=/; Expires=Wed, 02 Feb 2022 15:17:11 GMT; HttpOnly; SameSite=Strict',
            "Accept": "text/event-stream",
            "Cache-Control": "no-cache",
          },
          body: {
            "name": "Hello",
            "customerInfo": {"age": 25, "height": 168}
          }).listen(
        (event) {
          lines++;
          print('Id: ' + event.id!);
          print('Event: ' + event.event!);
          print('Data: ' + event.data!);
        },
      );
      await Future.delayed(const Duration(seconds: 2));
      expect(lines, 2);
    });
    test('Should retry when receive field undefined', () async {
      var mockHttp = MockHttp();
      var elements = [
        utf8.encode('anothe: 1\n\n'),
        utf8.encode('id: 3\nevent: message\ndata: World\n\n'),
      ];

      when(() => mockHttp.send(any())).thenAnswer((_) async {
        return http.StreamedResponse(Stream.fromIterable(elements), 200,
            headers: {
              HttpHeaders.contentTypeHeader: 'text/event-stream',
              HttpHeaders.cacheControlHeader: 'no-cache',
              HttpHeaders.connectionHeader: 'keep-alive',
            });
      });
      int lines = 0;
      SSEClient.subscribeToSSE(
          client: mockHttp,
          method: SSERequestType.GET,
          url: 'http://localhost:3001',
          header: {
            "Cookie":
                'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2NDMyMTAyMzEsImV4cCI6MTY0MzgxNTAzMX0.U0aCAM2fKE1OVnGFbgAU_UVBvNwOMMquvPY8QaLD138; Path=/; Expires=Wed, 02 Feb 2022 15:17:11 GMT; HttpOnly; SameSite=Strict',
            "Accept": "text/event-stream",
            "Cache-Control": "no-cache",
          }).listen(
        (event) {
          lines++;
          print('Id: ' + (event.id ?? ""));
          print('Event: ' + (event.event ?? ""));
          print('Data: ' + (event.data ?? ""));
        },
      );
      await Future.delayed(const Duration(seconds: 7));
      expect(lines, 2);
    });

    test('Should retry when throw exception the client', () async {
      var mockHttpExpection = MockHttp();

      when(() => mockHttpExpection.send(any())).thenThrow(Exception());
      int lines = 0;
      SSEClient.subscribeToSSE(
          client: mockHttpExpection,
          method: SSERequestType.GET,
          url: 'http://localhost:3001',
          header: {
            "Cookie":
                'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2NDMyMTAyMzEsImV4cCI6MTY0MzgxNTAzMX0.U0aCAM2fKE1OVnGFbgAU_UVBvNwOMMquvPY8QaLD138; Path=/; Expires=Wed, 02 Feb 2022 15:17:11 GMT; HttpOnly; SameSite=Strict',
            "Accept": "text/event-stream",
            "Cache-Control": "no-cache",
          }).listen(
        (event) {
          lines++;
          print('Id: ' + (event.id ?? ""));
          print('Event: ' + (event.event ?? ""));
          print('Data: ' + (event.data ?? ""));
        },
      );
      await Future.delayed(const Duration(seconds: 7));
      expect(lines, 0);
    });
  });
}
