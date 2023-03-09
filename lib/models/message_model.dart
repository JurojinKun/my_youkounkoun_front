//conv with user id 186 datas mockés
List<MessageModel> listMessagesWith186DatasMockes = [
  MessageModel(
      id: 1,
      idReceiver: 186,
      idSender: 1,
      type: "text",
      message: "Salut",
      isRead: true,
      timestamp: "1674384936000"),
  MessageModel(
      id: 2,
      idReceiver: 186,
      idSender: 1,
      type: "text",
      message: "Tu vas bien ?",
      isRead: true,
      timestamp: "1674384936000"),
  MessageModel(
      id: 3,
      idReceiver: 1,
      idSender: 186,
      type: "text",
      message: "Ça va et toi ?",
      isRead: true,
      timestamp: "1674384936000"),
  MessageModel(
      id: 4,
      idReceiver: 186,
      idSender: 1,
      type: "text",
      message: "Tranquille hein",
      isRead: true,
      timestamp: "1674384936000"),
  MessageModel(
      id: 5,
      idReceiver: 1,
      idSender: 186,
      type: "image",
      message: "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
      isRead: true,
      timestamp: "1674384936000"),
  MessageModel(
      id: 6,
      idReceiver: 1,
      idSender: 186,
      type: "text",
      message: "Quoi de beau aujourd'hui ?",
      isRead: false,
      timestamp: "1674386763000")
];

//conv with user id 4 datas mockés
List<MessageModel> listMessagesWith4DatasMockes = [
  MessageModel(
      id: 1,
      idReceiver: 1,
      idSender: 4,
      type: "text",
      message: "Je suis occupé, je te répond après !",
      isRead: true,
      timestamp: "1674385020000"),
  MessageModel(
      id: 2,
      idReceiver: 1,
      idSender: 4,
      type: "gif",
      message:
          "https://media4.giphy.com/media/Q7ozWVYCR0nyW2rvPW/giphy.gif?cid=a2943b1c7le2u2cxb6v8gcr37w7hf4lt0jxdpw52jrrp3dis&rid=giphy.gif&ct=g",
      isRead: true,
      timestamp: "1674385020100"),
  MessageModel(
      id: 3,
      idReceiver: 4,
      idSender: 1,
      type: "image",
      message:
          "https://rare-gallery.com/uploads/posts/574997-Code-geass-Lelouch.jpg",
      isRead: true,
      timestamp: "1674902409000"),
  MessageModel(
      id: 4,
      idReceiver: 4,
      idSender: 1,
      type: "gif",
      message:
          "https://media0.giphy.com/media/OmK8lulOMQ9XO/giphy.gif?cid=a2943b1cy1sq3ah5hu2zokosdig8xevq9dnoxet58ago7cxf&rid=giphy.gif&ct=g",
      isRead: true,
      timestamp: "1674933244000"),
  MessageModel(
      id: 5,
      idReceiver: 4,
      idSender: 1,
      type: "text",
      message:
          "J'adore ta photo de profil ! Tu regardes d'autres mangas à part celui-là ?",
      isRead: true,
      timestamp: "1675378161000"),
];

class MessageModel {
  int id;
  int idReceiver;
  int idSender;
  String type;
  String message;
  bool isRead;
  String timestamp;

  MessageModel(
      {required this.id,
      required this.idReceiver,
      required this.idSender,
      required this.type,
      required this.message,
      required this.isRead,
      required this.timestamp});

  MessageModel.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? 0,
        idReceiver = jsonMap["idReceiver"] ?? 0,
        idSender = jsonMap["idSender"] ?? 0,
        type = jsonMap["type"] ?? "",
        message = jsonMap["message"] ?? "",
        isRead = jsonMap["isRead"] ?? true,
        timestamp = jsonMap["timestamp"] ?? "";

  MessageModel copy() {
    return MessageModel(
        id: id,
        idReceiver: idReceiver,
        idSender: idSender,
        type: type,
        message: message,
        isRead: isRead,
        timestamp: timestamp);
  }
}
