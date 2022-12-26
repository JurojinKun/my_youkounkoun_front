class Conversation {
  int id;
  int lastMessageUserId;
  String lastMessage;
  bool isLastMessageRead;
  String timestamp;

  Conversation(
      {required this.id,
      required this.lastMessageUserId,
      required this.lastMessage,
      required this.isLastMessageRead,
      required this.timestamp});

  Conversation.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? 0,
        lastMessageUserId = jsonMap["lastMessageUserId"] ?? 0,
        lastMessage = jsonMap["lastMessage"] ?? "",
        isLastMessageRead = jsonMap["isLastMessageRead"] ?? false,
        timestamp = jsonMap["timestamp"] ?? "";

  Conversation copy() {
    return Conversation(
        id: id,
        lastMessageUserId: lastMessageUserId,
        lastMessage: lastMessage,
        isLastMessageRead: isLastMessageRead,
        timestamp: timestamp);
  }
}
