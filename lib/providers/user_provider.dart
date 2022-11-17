import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/models/user_model.dart';

final userNotifierProvider =
    StateNotifierProvider<UserProvider, User>((ref) => UserProvider());

class UserProvider extends StateNotifier<User> {
  UserProvider()
      : super(User(
            id: 0,
            token: "",
            email: "",
            pseudo: "",
            gender: "",
            age: 0,
            nationality: "",
            profilePictureUrl: "",
            validCGU: false,
            validPrivacyPolicy: false,
            validEmail: false));

  void initUser(User user) {
    state = user;
  }

  void clearUser() {
    state = User(
        id: 0,
        token: "",
        email: "",
        pseudo: "",
        gender: "",
        age: 0,
        nationality: "",
        profilePictureUrl: "",
        validCGU: false,
        validPrivacyPolicy: false,
        validEmail: false);
  }
}
