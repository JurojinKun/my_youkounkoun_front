import 'package:flutter_riverpod/flutter_riverpod.dart';

final inChatDetailsNotifierProvider =
    StateNotifierProvider<InChatDetailsProvider, Map<String, dynamic>>(
        (ref) => InChatDetailsProvider());
final afterChatDetailsNotifierProvider =
    StateNotifierProvider<AfterChatDetailsProvider, bool>(
        (ref) => AfterChatDetailsProvider());

class InChatDetailsProvider extends StateNotifier<Map<String, dynamic>> {
  InChatDetailsProvider() : super({});

  void inChatDetails(String screen, String userID) {
    Map<String, dynamic> newState = {};
    newState = {"screen": screen, "userID": userID};

    state = newState;
    print("in chat");
    print(state);
  }

  void outChatDetails(String screen, String userID) {
    Map<String, dynamic> newState = {};

    if (screen.isNotEmpty &&
        screen.trim() != "" &&
        userID.isNotEmpty &&
        userID.trim() != "") {
      newState = {"screen": screen, "userID": userID};
    }

    state = newState;
    print("out chat");
    print(state);
  }
}

class AfterChatDetailsProvider extends StateNotifier<bool> {
  AfterChatDetailsProvider() : super(false);

  void updateAfterChat(bool newState) {
    state = newState;
  }

  void clearAfterChat() {
    state = false;
  }
}
