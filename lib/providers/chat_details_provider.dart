import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_picker/giphy_picker.dart';

final toolsStayHideNotifierProvider =
    StateNotifierProvider<ToolsStaHideProvider, bool>(
        (ref) => ToolsStaHideProvider());
final showEmotionsNotifierProvider =
    StateNotifierProvider<ShowEmotionsProvider, bool>(
        (ref) => ShowEmotionsProvider());
final gifTrendingsNotifierProvider =
    StateNotifierProvider<GifTrendingsProvider, GiphyCollection?>(
        (ref) => GifTrendingsProvider());

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

class GifTrendingsProvider extends StateNotifier<GiphyCollection?> {
  GifTrendingsProvider() : super(null);

  setGifTrendings(GiphyCollection newState) {
    state = newState;
  }
}
