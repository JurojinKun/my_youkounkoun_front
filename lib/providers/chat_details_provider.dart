import 'package:flutter_riverpod/flutter_riverpod.dart';

final toolsStayHideNotifierProvider =
    StateNotifierProvider<ToolsStaHideProvider, bool>(
        (ref) => ToolsStaHideProvider());
final showEmotionsNotifierProvider =
    StateNotifierProvider<ShowEmotionsProvider, bool>(
        (ref) => ShowEmotionsProvider());

class ToolsStaHideProvider extends StateNotifier<bool> {
  ToolsStaHideProvider() : super(true);

  void updateStayHide(bool newState) {
    state = newState;
  }

  void clearStayHide() {
    state = true;
  }
}

class ShowEmotionsProvider extends StateNotifier<bool> {
  ShowEmotionsProvider() : super(false);

  void updateShowEmotions(bool newState) {
    state = newState;
  }

  void clearShowEmotions() {
    state = false;
  }
}
