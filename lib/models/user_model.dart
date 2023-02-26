//datas mockés recent searches users
List<UserModel> recentSearchesDatasMockes = [
  UserModel(
      id: 45,
      token: "",
      email: "test1@gmail.com",
      pseudo: "Kev",
      gender: "Male",
      birthday: "1992-06-06 00:00",
      nationality: "CA",
      profilePictureUrl:
          "https://animeholicph.files.wordpress.com/2008/10/lalouch-mask.png",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
  UserModel(
      id: 186,
      token: "",
      email: "test2@gmail.com",
      pseudo: "Rimbaud",
      gender: "Female",
      birthday: "2002-06-06 00:00",
      nationality: "FR",
      profilePictureUrl:
          "https://w0.peakpx.com/wallpaper/291/730/HD-wallpaper-death-note-kira.jpg",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
  UserModel(
      id: 4,
      token: "",
      email: "test3@gmail.com",
      pseudo: "Destin",
      gender: "Male",
      birthday: "1995-02-06 00:00",
      nationality: "FR",
      profilePictureUrl: "",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
];

//datas mockés possible results possible on search user
List<UserModel> potentialsResultsSearchDatasMockes = [
  UserModel(
      id: 45,
      token: "",
      email: "test1@gmail.com",
      pseudo: "Kev",
      gender: "Male",
      birthday: "1992-06-06 00:00",
      nationality: "CA",
      profilePictureUrl:
          "https://animeholicph.files.wordpress.com/2008/10/lalouch-mask.png",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
  UserModel(
      id: 1,
      token: "tokenTest1234",
      email: "ccommunay@gmail.com",
      pseudo: "0ruj",
      gender: "Male",
      birthday: "1997-06-06 00:00",
      nationality: "FR",
      profilePictureUrl: "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
  UserModel(
      id: 186,
      token: "",
      email: "test2@gmail.com",
      pseudo: "Rimbaud",
      gender: "Female",
      birthday: "2002-06-06 00:00",
      nationality: "FR",
      profilePictureUrl:
          "https://w0.peakpx.com/wallpaper/291/730/HD-wallpaper-death-note-kira.jpg",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
  UserModel(
      id: 4,
      token: "",
      email: "test3@gmail.com",
      pseudo: "Destin",
      gender: "Male",
      birthday: "1995-02-06 00:00",
      nationality: "FR",
      profilePictureUrl: "",
      validCGU: true,
      validPrivacyPolicy: true,
      validEmail: false),
];

class UserModel {
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

  UserModel(
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

  UserModel.fromJSON(Map<String, dynamic> jsonMap)
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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "id": id,
      "token": token,
      "email": email,
      "pseudo": pseudo,
      "gender": gender,
      "birthday": birthday,
      "nationality": nationality,
      "profilePictureUrl": profilePictureUrl,
      "validCGU": validCGU,
      "validPrivacyPolicy": validPrivacyPolicy,
      "validEmail": validEmail
    };

    return map;
  }

  UserModel copy() {
    return UserModel(
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
