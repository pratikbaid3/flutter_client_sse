# CLIENT SSE

Dart package to help consume Server Sent Events

### IMPORT
Add the following import in the ```pubspec.yaml``` file
```
client_sse:
    git:
      url: https://github.com/pratikbaid3/client_sse
      path:
```

### EXAMPLE
```
SSEClient.subscribeToSSE(url,token)
        .listen((event) {
      print('Id: ' + event.id);
      print('Event: ' + event.event);
      print('Data: ' + event.data);
    });
```
