import 'package:flutter_riverpod/flutter_riverpod.dart';

final pushTokenNotifierProvider =
    StateNotifierProvider<PushTokenProvider, String>(
        (ref) => PushTokenProvider());

class PushTokenProvider extends StateNotifier<String> {
  PushTokenProvider() : super("");

  void updatePushToken(String newState) {
    state = newState;
  }

  void clearPushToken() {
    state = "";
  }
}