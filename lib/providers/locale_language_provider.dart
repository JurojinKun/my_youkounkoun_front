import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/libraries/sync_shared_prefs_lib.dart';

final localeLanguageNotifierProvider =
    StateNotifierProvider<LocaleLanguageProvider, Locale>(
        (ref) => LocaleLanguageProvider());

class LocaleLanguageProvider extends StateNotifier<Locale> {
  LocaleLanguageProvider() : super(const Locale('en', ''));

  Future<void> setLocaleLanguage() async {
    Locale localeLanguage;
    String? languePrefs = SyncSharedPrefsLib().prefs!.getString("langue");
    if (languePrefs != null) {
      localeLanguage = Locale(languePrefs, '');
    } else {
      if (Platform.localeName.split("_")[0] == "en" ||
          Platform.localeName.split("_")[0] == "fr") {
        localeLanguage = Locale(Platform.localeName.split("_")[0], '');
      } else {
        localeLanguage = const Locale('en', '');
      }
    }
    state = localeLanguage;
  }

  Future<void> updateLocaleLanguage(Locale localeLanguage) async {
    await SyncSharedPrefsLib().prefs!.setString("langue", localeLanguage.languageCode);
    state = localeLanguage;
  }
}