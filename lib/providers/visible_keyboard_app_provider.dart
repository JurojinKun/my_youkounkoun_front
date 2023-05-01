import 'package:flutter_riverpod/flutter_riverpod.dart';

final visibleKeyboardAppNotifierProvider =
    StateNotifierProvider<VisibleKeyboardAppProvider, bool>(
        (ref) => VisibleKeyboardAppProvider());

class VisibleKeyboardAppProvider extends StateNotifier<bool> {
  VisibleKeyboardAppProvider() : super(false);

  void setVisibleKeyboard(bool newState) {
    state = newState;
  }

  void clearVisibleKeyboard() {
    state = false;
  }
}
