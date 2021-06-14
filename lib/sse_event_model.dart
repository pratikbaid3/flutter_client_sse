part of flutter_client_sse;

class SSEModel {
  //Id of the event
  String? id = '';
  //Event name
  String? event = '';
  //Event data
  String? data = '';
  SSEModel({required this.data, required this.id, required this.event});
  SSEModel.fromData(String data) {
    id = data.split("\n")[0].split('id:')[1];
    event = data.split("\n")[1].split('event:')[1];
    this.data = data.split("\n")[2].split('data:')[1];
  }
}
