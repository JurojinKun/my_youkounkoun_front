import "package:flutter_riverpod/flutter_riverpod.dart";

final newMajInfosNotifierProvider =
    StateNotifierProvider<NewMajInfosProvider, Map<String, dynamic>>(
        (ref) => NewMajInfosProvider());
final newMajInfosAlreadySeenNotifierProvider =
    StateNotifierProvider<NewMajInfosAlreadySeen, bool>(
        (ref) => NewMajInfosAlreadySeen());

class NewMajInfosProvider extends StateNotifier<Map<String, dynamic>> {
  NewMajInfosProvider()
      : super({
          "newMajAvailable": false,
          "newMajRequired": false,
          "linkAndroid": "",
          "linkIOS": ""
        });

  void setNewMajInfos(Map<String, dynamic> newState) {
    state = newState;
  }
}

class NewMajInfosAlreadySeen extends StateNotifier<bool> {
  NewMajInfosAlreadySeen() : super(false);

  void newMajInfosAlreadySeen() {
    state = true;
  }
}
