import 'package:flutter_riverpod/flutter_riverpod.dart';

final checkValidUserNotifierProvider = StateNotifierProvider<CheckValidUserProvider, bool>((ref) => CheckValidUserProvider());

class CheckValidUserProvider extends StateNotifier<bool> {
  CheckValidUserProvider() : super(false);

  checkValidUser() {
    state = true;
  }
}