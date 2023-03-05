import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_picker/giphy_picker.dart';

final currentChatUserIdNotifierProvider =
    StateNotifierProvider<CurrentChatUserIdProvider, int>(
        (ref) => CurrentChatUserIdProvider());

final toolsStayHideNotifierProvider =
    StateNotifierProvider<ToolsStaHideProvider, bool>(
        (ref) => ToolsStaHideProvider());
final showEmotionsNotifierProvider =
    StateNotifierProvider<ShowEmotionsProvider, bool>(
        (ref) => ShowEmotionsProvider());
final gifTrendingsNotifierProvider =
    StateNotifierProvider<GifTrendingsProvider, GiphyCollection?>(
        (ref) => GifTrendingsProvider());
final showPicturesNotifierProvider =
    StateNotifierProvider<ShowPicturesProvider, bool>(
        (ref) => ShowPicturesProvider());

class CurrentChatUserIdProvider extends StateNotifier<int> {
  CurrentChatUserIdProvider() : super(0);

  setChatUserId(int newState) {
    state = newState;
  }
}

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

class ShowPicturesProvider extends StateNotifier<bool> {
  ShowPicturesProvider() : super(false);

  void updateShowPictures(bool newState) {
    state = newState;
  }

  void clearShowPictures() {
    state = false;
  }
}
