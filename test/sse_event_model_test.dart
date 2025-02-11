import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:flutter_test/flutter_test.dart';

main() {
  test('SSE Event Model Test', () {
    final sseModel = SSEModel(data: 'data', id: 'id', event: 'event');
    expect(sseModel.id, 'id');
    expect(sseModel.event, 'event');
    expect(sseModel.data, 'data');
  });
  test('SSE Event Model Test', () {
    final sseModel = SSEModel.fromData('id: id\nevent: event\ndata: data');
    expect(sseModel.id, ' id');
    expect(sseModel.event, ' event');
    expect(sseModel.data, ' data');
  });
}
