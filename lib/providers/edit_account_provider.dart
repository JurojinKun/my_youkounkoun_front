import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/helpers/helpers.dart';
import 'package:my_boilerplate/providers/user_provider.dart';

final editProfilePictureUserNotifierProvider = StateNotifierProvider.autoDispose<EditProfilePictureUserProvider, File?>((ref) => EditProfilePictureUserProvider());
final editPseudoUserNotifierProvider = StateNotifierProvider.autoDispose<EditProfilePseudoUserProvider, bool>((ref) => EditProfilePseudoUserProvider());
final editGenderUserNotifierProvider = StateNotifierProvider.autoDispose<EditProfileGenderUserProvider, String>((ref) => EditProfileGenderUserProvider());
final editBirthdayUserNotifierProvider = StateNotifierProvider.autoDispose<EditProfileBirthdayUserProvider, DateTime?>((ref) => EditProfileBirthdayUserProvider());
final editNationalityUserNotifierProvider = StateNotifierProvider.autoDispose<EditProfileNationalityUserProvider, String>((ref) => EditProfileNationalityUserProvider());

final editProfileNotifierProvider = FutureProvider.autoDispose<bool>((ref) {
  final profilePicture =
      ref.watch(editProfilePictureUserNotifierProvider);
  final pseudo = ref.watch(editPseudoUserNotifierProvider);
  final gender = ref.watch(editGenderUserNotifierProvider);
  final birthday = ref.watch(editBirthdayUserNotifierProvider);
  final nationality = ref.watch(editNationalityUserNotifierProvider);
  

  if (profilePicture != null || pseudo || gender != ref.read(userNotifierProvider).gender || birthday != Helpers.convertStringToDateTime(
        ref.read(userNotifierProvider).birthday) || nationality != ref.read(userNotifierProvider).nationality) {
    return true;
  } else {
    return false;
  }
});

class EditProfilePictureUserProvider extends StateNotifier<File?> {
  EditProfilePictureUserProvider() : super(null);

  void editProfilePicture(File newFile) {
    state = newFile;
  }

  void clearEditProfilePicture() {
    state = null;
  }
}

class EditProfilePseudoUserProvider extends StateNotifier<bool> {
  EditProfilePseudoUserProvider() : super(false);

  void editPseudo(bool newState) {
    state = newState;
  }

  void clearPseudo() {
    state = false;
  }
}

class EditProfileGenderUserProvider extends StateNotifier<String> {
  EditProfileGenderUserProvider() : super("");

  void initGender(String genderActual) {
    state = genderActual;
  }

  void updateGender(String newGender) {
    state = newGender;
  }

  void clearGender(String genderActual) {
    state = genderActual;
  }
}

class EditProfileBirthdayUserProvider extends StateNotifier<DateTime?> {
  EditProfileBirthdayUserProvider() : super(null);

  void initBirthday(DateTime actualState) {
    state = actualState;
  }

  void updateBirthday(DateTime newState) {
    state = newState;
  }

  void clearBirthday(DateTime actualState) {
    state = actualState;
  }
}

class EditProfileNationalityUserProvider extends StateNotifier<String> {
  EditProfileNationalityUserProvider() : super("");

  void initNationality(String actualNationality) {
    state = actualNationality;
  }

  void updateNationality(String newState) {
    state = newState;
  }

   void clearNationality(String actualNationality) {
    state = actualNationality;
   }
}