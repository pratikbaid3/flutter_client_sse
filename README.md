# CLIENT SSE

Dart package to help consume Server Sent Events

### Features:
* Consumes server sent events
* Returns parsed model of the event, id and the data

## Getting Started


### Import
Add the following import in the ```pubspec.yaml``` file
```yaml
client_sse:
    git:
      url: https://github.com/pratikbaid3/client_sse
      path:
```

### Example
```dart
SSEClient.subscribeToSSE(url,token)
        .listen((event) {
      print('Id: ' + event.id);
      print('Event: ' + event.event);
      print('Data: ' + event.data);
    });
```
