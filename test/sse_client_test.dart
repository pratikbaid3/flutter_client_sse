import 'dart:async';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  // Define the URL of your SSE endpoint
  final String testUrl = 'http://localhost:3000';
  final SSEClient sseClient = new SSEClient(
    new http.Client(),
  );

  test('SSEClient should receive events correctly from infinite stream',
      () async {
    final events = <SSEModel>[];

    // Subscribe to SSE
    final stream = sseClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: '$testUrl/sse',
      header: {},
    );

    // Collect events
    final completer = Completer<void>();
    stream.listen((event) {
      if (event.data != null && event.data!.isNotEmpty) {
        events.add(event);
      }
      if (events.length == 10) {
        // Adjust based on expected number of events
        completer.complete();
      }
    }, onError: (error) {
      completer.completeError(error);
    });

    // Wait for events or error
    await completer.future;

    expect(events.length, 10);
    for (var event in events) {
      expect(event.data, contains('world'));
    }
  });

  test('SSEClient should receive events and complete stream', () async {
    final List<SSEModel> events = [];

    // Subscribe to SSE
    final stream = sseClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: '$testUrl/sse-limited',
      header: {},
    );

    final timeout = Duration(seconds: 10);

    bool isCompleted = false;

    final subscription = stream.listen(
      (event) {
        print(event.data);
        if (event.data != null && event.data!.isNotEmpty) {
          events.add(event);
        }
      },
      onError: (error) {
        if (!isCompleted) {
          isCompleted = true;
        }
      },
      onDone: () {
        if (!isCompleted) {
          isCompleted = true;
        }
      },
    );

    await Future.any([
      Future.delayed(timeout, () {
        subscription.cancel();
        if (!isCompleted) {
          throw TimeoutException('Stream did not complete in time');
        }
      }),
      subscription.asFuture(),
    ]);

    expect(events.length, 3);
    for (var event in events) {
      expect(event.data, contains('world'));
    }
  });

  test('SSEClient should infinitely retry', () async {
    final List<SSEModel> events = [];

    // Subscribe to SSE
    final stream = sseClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: '$testUrl/sse-error',
      header: {},
    );

    // TODO
  });
}
