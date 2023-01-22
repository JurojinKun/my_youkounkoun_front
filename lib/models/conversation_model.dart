// id users = 186, 45, 4
//id mine = 1
List<ConversationModel> conversationsDatasMockes = [
  ConversationModel(
      id: 1,
      usersId: [186, 1],
      lastMessageUserId: 186,
      lastMessage: "Quoi de beau aujourd'hui ?",
      isLastMessageRead: false,
      timestampLastMessage: "1674386763000"),
  ConversationModel(
      id: 2,
      usersId: [1, 4],
      lastMessageUserId: 1,
      lastMessage: "J'adore ta photo de profil ! Tu regardes d'autres mangas à part celui-là ?",
      isLastMessageRead: false,
      timestampLastMessage: "1674385020000"), 
];

class ConversationModel {
  int id;
  List<int> usersId;
  int lastMessageUserId;
  String lastMessage;
  bool isLastMessageRead;
  String timestampLastMessage;

  ConversationModel(
      {required this.id,
      required this.usersId,
      required this.lastMessageUserId,
      required this.lastMessage,
      required this.isLastMessageRead,
      required this.timestampLastMessage});

  ConversationModel.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? 0,
        usersId = jsonMap["usersId"] ?? [],
        lastMessageUserId = jsonMap["lastMessageUserId"] ?? 0,
        lastMessage = jsonMap["lastMessage"] ?? "",
        isLastMessageRead = jsonMap["isLastMessageRead"] ?? true,
        timestampLastMessage = jsonMap["timestamp"] ?? "";

  ConversationModel copy() {
    return ConversationModel(
        id: id,
        usersId: usersId,
        lastMessageUserId: lastMessageUserId,
        lastMessage: lastMessage,
        isLastMessageRead: isLastMessageRead,
        timestampLastMessage: timestampLastMessage);
  }
}
