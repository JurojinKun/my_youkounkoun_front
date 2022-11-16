import "package:flutter_riverpod/flutter_riverpod.dart";

final themeAppNotifierProvider = StateNotifierProvider<ThemeAppProvider, String>((ref) => ThemeAppProvider());

class ThemeAppProvider extends StateNotifier<String> {
  ThemeAppProvider() : super("");

  setThemeApp(String theme) {
    state = theme;
  }
}