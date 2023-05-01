import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/models/user_model.dart';

final userNotifierProvider =
    StateNotifierProvider<UserProvider, UserModel>((ref) => UserProvider());
final profilePictureAlreadyLoadedNotifierProvider =
    StateNotifierProvider<ProfilePictureAlreadyLoaded, bool>(
        (ref) => ProfilePictureAlreadyLoaded());

class UserProvider extends StateNotifier<UserModel> {
  UserProvider()
      : super(UserModel(
            id: 0,
            token: "",
            email: "",
            pseudo: "",
            gender: "",
            birthday: "",
            nationality: "",
            profilePictureUrl: "",
            followers: [],
            followings: [],
            bio: "",
            validCGU: false,
            validPrivacyPolicy: false,
            validEmail: false));

  void setUser(UserModel user) {
    state = user;
  }

  void addFollowing(int idUser) {
    UserModel newState = state.copy();
    newState.followings.add(idUser);
    state = newState;
  }

  void removeFollowing(int idUser) {
    UserModel newState = state.copy();
    newState.followings.removeWhere((element) => element == idUser);
    state = newState;
  }

  void clearUser() {
    state = UserModel(
        id: 0,
        token: "",
        email: "",
        pseudo: "",
        gender: "",
        birthday: "",
        nationality: "",
        profilePictureUrl: "",
        followers: [],
        followings: [],
        bio: "",
        validCGU: false,
        validPrivacyPolicy: false,
        validEmail: false);
  }
}

class ProfilePictureAlreadyLoaded extends StateNotifier<bool> {
  ProfilePictureAlreadyLoaded() : super(false);

  void profilePictureLoaded(bool newState) {
    state = newState;
  }

  void clearProfilePicture() {
    state = false;
  }
}
