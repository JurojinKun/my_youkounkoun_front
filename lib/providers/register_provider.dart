import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final genderRegisterNotifierProvider =
    StateNotifierProvider<GenderRegisterProvider, String>(
        (ref) => GenderRegisterProvider());
final birthdayRegisterNotifierProvider =
    StateNotifierProvider<BirthdayRegisterProvider, bool>(
        (ref) => BirthdayRegisterProvider());
final profilePictureRegisterNotifierProvider =
    StateNotifierProvider<ProfilePictureRegisterProvider, File?>(
        (ref) => ProfilePictureRegisterProvider());

class GenderRegisterProvider extends StateNotifier<String> {
  GenderRegisterProvider() : super("");

  void choiceGender(String gender) {
    state = gender;
  }

  void clearGender() {
    state = "";
  }
}

class BirthdayRegisterProvider extends StateNotifier<bool> {
  BirthdayRegisterProvider() : super(false);

  void updateBirthday(bool newState) {
    state = newState;
  }

  void clearBirthday() {
    state = false;
  }
}

class ProfilePictureRegisterProvider extends StateNotifier<File?> {
  ProfilePictureRegisterProvider() : super(null);

  void addNewProfilePicture(File newFile) {
    state = newFile;
  }

  void clearProfilePicture() {
    state = null;
  }
}
