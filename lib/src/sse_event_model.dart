class SSEModel {
  //Id of the event
  String? id;

  //Event name
  String? event;

  //Event data
  String? data;

  SSEModel({
    this.data = '',
    this.id = '',
    this.event = '',
  });

  factory SSEModel.fromData(String data) => SSEModel(
        id: data.split("\n")[0].split('id:')[1],
        event: data.split("\n")[1].split('event:')[1],
        data: data.split("\n")[2].split('data:')[1],
      );
}
