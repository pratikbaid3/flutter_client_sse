part of flutter_client_sse;

/// Model for representing an SSE event.
class SSEModel {
  /// ID of the event.
  String? id = '';

  /// Event name.
  String? event = '';

  /// Event data.
  String? data = '';

  /// Constructor for [SSEModel].
  SSEModel({this.data, this.id, this.event});

  /// Constructs an [SSEModel] from a data string.
  SSEModel.fromData(String data) {
    id = data.split("\n")[0].split('id:')[1];
    event = data.split("\n")[1].split('event:')[1];
    this.data = data.split("\n")[2].split('data:')[1];
  }
}
