import 'package:flutter_client_sse/flutter_client_sse.dart';

void main() {
  SSEClient.subscribeToSSE(
      url:
          'http://192.168.1.2:3000/api/activity-stream?historySnapshot=FIVE_MINUTE',
      header: {
        "Cookie":
            'jwt=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6InRlc3QiLCJpYXQiOjE2NDMyMTAyMzEsImV4cCI6MTY0MzgxNTAzMX0.U0aCAM2fKE1OVnGFbgAU_UVBvNwOMMquvPY8QaLD138; Path=/; Expires=Wed, 02 Feb 2022 15:17:11 GMT; HttpOnly; SameSite=Strict',
        "Accept": "text/event-stream",
        "Cache-Control": "no-cache",
      }).listen((event) {
    print('Id: ' + event.id!);
    print('Event: ' + event.event!);
    print('Data: ' + event.data!);
  });
}
