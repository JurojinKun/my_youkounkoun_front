import "package:flutter_riverpod/flutter_riverpod.dart";

final themeAppNotifierProvider = StateNotifierProvider<ThemeAppProvider, String>((ref) => ThemeAppProvider());

class ThemeAppProvider extends StateNotifier<String> {
  ThemeAppProvider() : super("");

  Future<void> setThemeApp(String theme) async {
    state = theme;
  }
}