import 'package:flutter_riverpod/flutter_riverpod.dart';

final versionAppNotifierProvider =
    StateNotifierProvider<VersionAppProvider, String>(
        (ref) => VersionAppProvider());

class VersionAppProvider extends StateNotifier<String> {
  VersionAppProvider() : super("");

  void setVersionApp(String newState) {
    state = newState;
  }
}
