import 'package:flutter_riverpod/flutter_riverpod.dart';

final toolsStayHideNotifierProvider =
    StateNotifierProvider<ToolsStaHideProvider, bool>(
        (ref) => ToolsStaHideProvider());

class ToolsStaHideProvider extends StateNotifier<bool> {
  ToolsStaHideProvider() : super(true);

  void updateStayHide(bool newState) {
    state = newState;
  }
}
