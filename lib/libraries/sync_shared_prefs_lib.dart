import 'package:shared_preferences/shared_preferences.dart';

class SyncSharedPrefsLib {
  static final SyncSharedPrefsLib _singleton = SyncSharedPrefsLib._internal();

  SharedPreferences? prefs;

  factory SyncSharedPrefsLib() {
    if (_singleton.prefs == null) {
      SharedPreferences.getInstance().then((value) => {
            _singleton.prefs = value,
          });
    }
    return _singleton;
  }

  SyncSharedPrefsLib._internal();

  SharedPreferences? getSyncPrefs() {
    return prefs;
  }
}
