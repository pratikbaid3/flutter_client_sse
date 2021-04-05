# CLIENT SSE

Dart package to help consume Server Sent Events

## EXAMPLE
```
SSEClient.subscribeToSSE(url,token)
        .listen((event) {
      print('Id: ' + event.id);
      print('Event: ' + event.event);
      print('Data: ' + event.data);
    });
```
