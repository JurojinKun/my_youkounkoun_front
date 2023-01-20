//datas mockés liste notifications informatives
List<NotificationModel> notificationsInformatives = [
  NotificationModel(
      id: 1,
      type: "I",
      title: "Test notif title 1",
      body: "Ceci est le body de la test notif 1",
      timestamp: "1672872739000",
      isRead: false),
  NotificationModel(
      id: 2,
      type: "I",
      title: "Test notif title 2",
      body: "Ceci est le body de la test notif 2",
      timestamp: "1672873319000",
      isRead: false),
  NotificationModel(
      id: 3,
      type: "I",
      title: "Test notif title 3",
      body: "Ceci est le body de la test notif 3",
      timestamp: "1672853619000",
      isRead: true),
  NotificationModel(
      id: 4,
      type: "I",
      title: "Test notif title 4",
      body: "Ceci est le body de la test notif 4",
      timestamp: "1672553619000",
      isRead: false),
  NotificationModel(
      id: 5,
      type: "I",
      title: "Test notif title 5",
      body: "Ceci est le body de la test notif 5",
      timestamp: "1662553619000",
      isRead: false),
  NotificationModel(
      id: 6,
      type: "I",
      title: "Test notif title 6",
      body: "Ceci est le body de la test notif 6",
      timestamp: "1632553619000",
      isRead: true),
  NotificationModel(
      id: 7,
      type: "I",
      title: "Test notif title 7",
      body: "Ceci est le body de la test notif 7",
      timestamp: "1672873319000",
      isRead: true),
  NotificationModel(
      id: 8,
      type: "I",
      title: "Test notif title 8",
      body: "Ceci est le body de la test notif 8",
      timestamp: "1672872739000",
      isRead: true),
  NotificationModel(
      id: 9,
      type: "I",
      title: "Test notif title 9",
      body: "Ceci est le body de la test notif 9",
      timestamp: "1661553619000",
      isRead: false),
  NotificationModel(
      id: 10,
      type: "I",
      title: "Test notif title 10",
      body: "Ceci est le body de la test notif 10",
      timestamp: "1662553619000",
      isRead: true),
  NotificationModel(
      id: 11,
      type: "I",
      title: "Test notif title 11",
      body: "Ceci est le body de la test notif 11",
      timestamp: "1661553619000",
      isRead: true),
  NotificationModel(
      id: 12,
      type: "I",
      title: "Test notif title 12",
      body: "Ceci est le body de la test notif 12",
      timestamp: "1672872739000",
      isRead: false),
  NotificationModel(
      id: 13,
      type: "I",
      title: "Test notif title 13",
      body: "Ceci est le body de la test notif 13",
      timestamp: "1672873580000",
      isRead: true),
  NotificationModel(
      id: 14,
      type: "I",
      title: "Test notif title 14",
      body: "Ceci est le body de la test notif 14",
      timestamp: "1672872739000",
      isRead: false),
  NotificationModel(
      id: 15,
      type: "I",
      title: "Test notif title 15",
      body: "Ceci est le body de la test notif 15",
      timestamp: "1674238895000",
      isRead: false),
];

class NotificationModel {
  int id;
  String type;
  String title;
  String body;
  String timestamp;
  bool isRead;

  NotificationModel(
      {required this.id,
      required this.type,
      required this.title,
      required this.body,
      required this.timestamp,
      required this.isRead});

  NotificationModel.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? 0,
        type = jsonMap["type"] ?? "",
        title = jsonMap["title"] ?? "",
        body = jsonMap["body"] ?? "",
        timestamp = jsonMap["timestamp"] ?? "",
        isRead = jsonMap["isRead"] ?? true;

  NotificationModel copy() {
    return NotificationModel(
        id: id,
        type: type,
        title: title,
        body: body,
        timestamp: timestamp,
        isRead: isRead);
  }
}
