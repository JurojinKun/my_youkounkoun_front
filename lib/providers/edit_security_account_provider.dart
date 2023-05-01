import 'package:flutter_riverpod/flutter_riverpod.dart';

final editMailUserNotifierProvider = StateNotifierProvider.autoDispose<EditMailUserProvider, bool>((ref) => EditMailUserProvider());
final editPasswordUserNotifierProvider = StateNotifierProvider.autoDispose<EditPasswordUserProvider, bool>((ref) => EditPasswordUserProvider());

class EditMailUserProvider extends StateNotifier<bool> {
  EditMailUserProvider() : super(false);

  void updateEditMail(bool newState) {
    state = newState;
  }

  void clearEditMail() {
    state = false;
  }
}

class EditPasswordUserProvider extends StateNotifier<bool> {
  EditPasswordUserProvider() : super(false);

  void updateEditPassword(bool newState) {
    state = newState;
  }

  void clearEditPassword() {
    state = false;
  }
}