class Notification {
  int id;
  String type;
  String content;

  Notification({required this.id, required this.type, required this.content});

  Notification.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? 0,
        type = jsonMap["type"] ?? "",
        content = jsonMap["content"] ?? "";

  Notification copy() {
    return Notification(id: id, type: type, content: content);
  }
}