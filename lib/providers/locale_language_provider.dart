import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeLanguageNotifierProvider =
    StateNotifierProvider<LocaleLanguageProvider, Locale>(
        (ref) => LocaleLanguageProvider());

class LocaleLanguageProvider extends StateNotifier<Locale> {
  LocaleLanguageProvider() : super(const Locale('en', ''));

  setLocaleLanguage(SharedPreferences prefs) {
    Locale localeLanguage;
    String? languePrefs = prefs.getString("langue");
    if (languePrefs != null) {
      localeLanguage = Locale(languePrefs, '');
    } else {
      if (Platform.localeName.split("_")[0] == "en" || Platform.localeName.split("_")[0] == "fr") {
        localeLanguage = Locale(Platform.localeName.split("_")[0], '');
      } else {
        localeLanguage = const Locale('en', '');
      }
    }
    state = localeLanguage;
  }

  updateLocaleLanguage(Locale localeLanguage) {
    state = localeLanguage;
  }
}
