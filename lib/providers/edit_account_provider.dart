import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditProfilePictureUserProvider extends StateNotifier<File?> {
  EditProfilePictureUserProvider() : super(null);

  void editProfilePicture(File newFile) {
    state = newFile;
  }

  void clearEditProfilePicture() {
    state = null;
  }
}