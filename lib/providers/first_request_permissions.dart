import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/libraries/sync_shared_prefs_lib.dart';

//to know if first request permissions android 13
final firstRequestPermissionsNotifierProvider =
    StateNotifierProvider<FirstRequestPermissions, bool>(
        (ref) => FirstRequestPermissions());

class FirstRequestPermissions extends StateNotifier<bool> {
  FirstRequestPermissions() : super(true);

  void setRequestPermissions(bool newState) {
    state = newState;
  }

  Future<void> updateRequestPermissions(bool newState) async {
    await SyncSharedPrefsLib().prefs!.setBool("firstRequest", newState);
    state = newState;
  }
}
