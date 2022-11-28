import 'package:flutter_riverpod/flutter_riverpod.dart';

final localeLanguageNotifierProvider =
    StateNotifierProvider<LocaleLanguageProvider, String>(
        (ref) => LocaleLanguageProvider());

class LocaleLanguageProvider extends StateNotifier<String> {
  LocaleLanguageProvider() : super("en");

  setLocaleLanguage(String localeLanguage) {
    state = localeLanguage;
  }
}
