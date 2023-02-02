// id users = 186, 45, 4
//id mine = 1
List<ConversationModel> conversationsDatasMockes = [
  ConversationModel(
      id: 1,
      users: [
        {"id": 186, "convMute": false},
        {"id": 1, "convMute": true}
      ],
      lastMessageUserId: 186,
      lastMessage: "Quoi de beau aujourd'hui ?",
      isLastMessageRead: false,
      timestampLastMessage: "1674386763000",
      typeLastMessage: "text"),
  ConversationModel(
      id: 2,
      users: [
        {"id": 1, "convMute": false},
        {"id": 4, "convMute": false}
      ],
      lastMessageUserId: 1,
      lastMessage:
          "J'adore ta photo de profil ! Tu regardes d'autres mangas à part celui-là ?",
      isLastMessageRead: false,
      timestampLastMessage: "1675378161000",
      typeLastMessage: "text"),
];

class ConversationModel {
  int id;
  List users;
  int lastMessageUserId;
  String lastMessage;
  bool isLastMessageRead;
  String timestampLastMessage;
  String typeLastMessage;

  ConversationModel(
      {required this.id,
      required this.users,
      required this.lastMessageUserId,
      required this.lastMessage,
      required this.isLastMessageRead,
      required this.timestampLastMessage,
      required this.typeLastMessage});

  ConversationModel.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? 0,
        users = jsonMap["users"] ?? [],
        lastMessageUserId = jsonMap["lastMessageUserId"] ?? 0,
        lastMessage = jsonMap["lastMessage"] ?? "",
        isLastMessageRead = jsonMap["isLastMessageRead"] ?? true,
        timestampLastMessage = jsonMap["timestamp"] ?? "",
        typeLastMessage = jsonMap["typeLastMessage"] ?? "";

  ConversationModel copy() {
    return ConversationModel(
        id: id,
        users: users,
        lastMessageUserId: lastMessageUserId,
        lastMessage: lastMessage,
        isLastMessageRead: isLastMessageRead,
        timestampLastMessage: timestampLastMessage,
        typeLastMessage: typeLastMessage);
  }
}
