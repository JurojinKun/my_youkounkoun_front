class MentionModel {
  String pseudo;
  String encryptedUserDatas;

  MentionModel({required this.pseudo, required this.encryptedUserDatas});

  MentionModel.fromJSON(Map<String, dynamic> jsonMap)
      : pseudo = jsonMap["pseudo"] ?? "",
        encryptedUserDatas = jsonMap["encryptedUserDatas"] ?? "";

  MentionModel copy() {
    return MentionModel(pseudo: pseudo, encryptedUserDatas: encryptedUserDatas);
  }
}