import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';

final currentChatUserIdNotifierProvider =
    StateNotifierProvider<CurrentChatUserIdProvider, int>(
        (ref) => CurrentChatUserIdProvider());
final currentConvNotifierProvider =
    StateNotifierProvider<CurrentConvProvider, ConversationModel>(
        (ref) => CurrentConvProvider());

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

class CurrentConvProvider extends StateNotifier<ConversationModel> {
  CurrentConvProvider()
      : super(ConversationModel(
            id: "",
            users: [],
            lastMessageUserId: 0,
            lastMessage: "",
            isLastMessageRead: false,
            timestampLastMessage: "",
            typeLastMessage: "",
            themeConv: []));

  void setCurrentConv(ConversationModel newState) {
    state = newState;
  }

  void muteConversation(int indexUserConv, bool muteConv) {
    ConversationModel newState = state.copy();
    newState.users[indexUserConv]["convMute"] = muteConv;

    state = newState;
  }

  void newThemeConversation(List<String> newStateTheme) {
    ConversationModel newState = state.copy();
    newState.themeConv = [...newStateTheme];

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
