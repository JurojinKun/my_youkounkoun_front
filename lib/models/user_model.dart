class User {
  int id;
  String token;
  String email;
  String pseudo;
  String gender;
  int age;

  User(
      {required this.id,
      required this.token,
      required this.email,
      required this.pseudo,
      required this.gender,
      required this.age});

  User.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? 0,
        token = jsonMap["token"] ?? "",
        email = jsonMap["email"] ?? "",
        pseudo = jsonMap["pseudo"] ?? "",
        gender = jsonMap["gender"] ?? "",
        age = jsonMap["age"] ?? "";

  User copy() {
    return User(
      id: id,
      token: token,
      email: email,
      pseudo: pseudo,
      gender: gender,
      age: age,
    );
  }
}
