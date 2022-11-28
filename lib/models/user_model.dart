class User {
  int id;
  String token;
  String email;
  String pseudo;
  String gender;
  String birthday;
  String nationality;
  String profilePictureUrl;
  bool validCGU;
  bool validPrivacyPolicy;
  bool validEmail;

  User(
      {required this.id,
      required this.token,
      required this.email,
      required this.pseudo,
      required this.gender,
      required this.birthday,
      required this.nationality,
      required this.profilePictureUrl,
      required this.validCGU,
      required this.validPrivacyPolicy,
      required this.validEmail});

  User.fromJSON(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"] ?? 0,
        token = jsonMap["token"] ?? "",
        email = jsonMap["email"] ?? "",
        pseudo = jsonMap["pseudo"] ?? "",
        gender = jsonMap["gender"] ?? "",
        birthday = jsonMap["birthday"] ?? "",
        nationality = jsonMap["nationality"] ?? "",
        profilePictureUrl = jsonMap["profilePictureUrl"] ?? "",
        validCGU = jsonMap["validCGU"] ?? false,
        validPrivacyPolicy = jsonMap["validPrivacyPolicy"] ?? false,
        validEmail = jsonMap["validEmail"] ?? false;

  User copy() {
    return User(
        id: id,
        token: token,
        email: email,
        pseudo: pseudo,
        gender: gender,
        birthday: birthday,
        nationality: nationality,
        profilePictureUrl: profilePictureUrl,
        validCGU: validCGU,
        validPrivacyPolicy: validPrivacyPolicy,
        validEmail: validEmail);
  }
}
