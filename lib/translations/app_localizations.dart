import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  late final Locale _locale;
  AppLocalization(this._locale);

  static AppLocalization of(BuildContext context) {
    return Localizations.of<AppLocalization>(context, AppLocalization)!;
  }

  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();

  late Map<String, dynamic> _localizedValues;

  Future<bool> loadLanguage() async {
    String value = await rootBundle
        .loadString("lib/translations/locales/${_locale.languageCode}.json");
    Map<String, dynamic> jsonMap = json.decode(value);
    _localizedValues = jsonMap.map((key, value) => MapEntry(key, value));
    return true;
  }

  String translate(String parentKey, String childKey) {
    if (parentKey == "") {
      return _localizedValues[childKey];
    } else {
      return _localizedValues[parentKey][childKey];
    }
  }
}

class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  @override
  bool isSupported(Locale locale) {
    return ["en", "fr"].contains(locale.languageCode);
  }

  @override
  Future<AppLocalization> load(Locale locale) async {
    AppLocalization appLocalization = AppLocalization(locale);
    await appLocalization.loadLanguage();
    return appLocalization;
  }

  @override
  bool shouldReload(_AppLocalizationDelegate old) => false;
}
