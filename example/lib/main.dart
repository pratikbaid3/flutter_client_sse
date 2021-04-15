import 'package:flutter_client_sse/flutter_client_sse.dart';

void main() {
  SSEClient.subscribeToSSE(
          'http://192.168.43.251:3000/api/activity-stream?historySnapshot=FIVE_MINUTE',
          'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2MTg0NzQwNTcsImV4cCI6MTYxOTA3ODg1N30.LTh1P4D1ZNTVCzF2NRUun_nQ9N-_x-ATYAc5jqjlI_Y; Path=/; Expires=Thu, 22 Apr 2021 08:07:37 GMT; HttpOnly; SameSite=Strict')
      .listen((event) {
    print('Id: ' + event.id);
    print('Event: ' + event.event);
    print('Data: ' + event.data);
  });
}
