class User {
  int id;
  String token;
  String email;
  String pseudo;
  String gender;
  int age;
  String nationality;
  String profilePictureUrl;

  User(
      {required this.id,
      required this.token,
      required this.email,
      required this.pseudo,
      required this.gender,
      required this.age,
      required this.nationality,
      required this.profilePictureUrl});

  User.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? 0,
        token = jsonMap["token"] ?? "",
        email = jsonMap["email"] ?? "",
        pseudo = jsonMap["pseudo"] ?? "",
        gender = jsonMap["gender"] ?? "",
        age = jsonMap["age"] ?? "",
        nationality = jsonMap["nationality"] ?? "",
        profilePictureUrl = jsonMap["profilePictureUrl"];

  User copy() {
    return User(
        id: id,
        token: token,
        email: email,
        pseudo: pseudo,
        gender: gender,
        age: age,
        nationality: nationality,
        profilePictureUrl: profilePictureUrl);
  }
}
