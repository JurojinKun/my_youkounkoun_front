// id users = 186, 45, 4
//id mine = 1
List<ConversationModel> conversationsDatasMockes = [
  ConversationModel(
      id: "1",
      users: [
        {"id": 186, "convMute": false, "isTyping": true},
        {"id": 1, "convMute": true, "isTyping": false}
      ],
      lastMessageUserId: 186,
      lastMessage: "Quoi de beau aujourd'hui ?",
      isLastMessageRead: false,
      timestampLastMessage: "1674386763000",
      typeLastMessage: "text",
      themeConv: ["#4284C4", "#00A9BC"]),
  ConversationModel(
      id: "2",
      users: [
        {"id": 1, "convMute": false, "isTyping": false},
        {"id": 4, "convMute": false, "isTyping": false}
      ],
      lastMessageUserId: 1,
      lastMessage:
          "J'adore ta photo de profil ! Tu regardes d'autres mangas à part celui-là ?",
      isLastMessageRead: false,
      timestampLastMessage: "1675378161000",
      typeLastMessage: "text",
      themeConv: ["#4284C4", "#00A9BC"]),
];

class ConversationModel {
  String id;
  List users;
  int lastMessageUserId;
  String lastMessage;
  bool isLastMessageRead;
  String timestampLastMessage;
  String typeLastMessage;
  List<String> themeConv;

  ConversationModel(
      {required this.id,
      required this.users,
      required this.lastMessageUserId,
      required this.lastMessage,
      required this.isLastMessageRead,
      required this.timestampLastMessage,
      required this.typeLastMessage,
      required this.themeConv});

  ConversationModel.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? "",
        users = jsonMap["users"] ?? [],
        lastMessageUserId = jsonMap["lastMessageUserId"] ?? 0,
        lastMessage = jsonMap["lastMessage"] ?? "",
        isLastMessageRead = jsonMap["isLastMessageRead"] ?? true,
        timestampLastMessage = jsonMap["timestamp"] ?? "",
        typeLastMessage = jsonMap["typeLastMessage"] ?? "",
        themeConv = jsonMap["themeConv"] ?? [];

  ConversationModel copy() {
    return ConversationModel(
        id: id,
        users: users,
        lastMessageUserId: lastMessageUserId,
        lastMessage: lastMessage,
        isLastMessageRead: isLastMessageRead,
        timestampLastMessage: timestampLastMessage,
        typeLastMessage: typeLastMessage,
        themeConv: themeConv);
  }
}
