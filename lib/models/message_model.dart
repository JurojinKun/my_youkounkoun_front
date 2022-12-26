class Message {
  int id;
  int idReceiver;
  int idSender;
  String type;
  String message;
  bool isRead;
  String timestamp;

  Message(
      {required this.id,
      required this.idReceiver,
      required this.idSender,
      required this.type,
      required this.message,
      required this.isRead,
      required this.timestamp});

  Message.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? 0,
        idReceiver = jsonMap["idReceiver"] ?? 0,
        idSender = jsonMap["idSender"] ?? 0,
        type = jsonMap["type"] ?? "",
        message = jsonMap["message"] ?? "",
        isRead = jsonMap["isRead"] ?? false,
        timestamp = jsonMap["timestamp"] ?? "";

  Message copy() {
    return Message(
        id: id,
        idReceiver: idReceiver,
        idSender: idSender,
        type: type,
        message: message,
        isRead: isRead,
        timestamp: timestamp);
  }
}
