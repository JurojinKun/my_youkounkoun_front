import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';

final conversationsNotifierProvider =
    StateNotifierProvider<ConversationsProvider, List<ConversationModel>?>(
        (ref) => ConversationsProvider());

class ConversationsProvider extends StateNotifier<List<ConversationModel>?> {
  ConversationsProvider() : super(null);

  void setConversations(List<ConversationModel> conversations) {
    state = [...conversations];
  }

  void addNewConversation(ConversationModel conversation) {
    List<ConversationModel> newState = [conversation, ...state!];
    state = newState;
  }

  void removeConversation(ConversationModel conversation) {
    List<ConversationModel> newState = [...state!];
    newState.removeWhere((element) => element.id == conversation.id);
    state = [...newState];
  }

  void muteConversation(String idConv, int indexUserConv, bool muteConv) {
    List<ConversationModel> newState = [...state!];
    ConversationModel? conversation;
    int? indexConv;

    for (var conv in newState) {
      if (conv.id == idConv) {
        conversation = conv;
        indexConv = newState.indexOf(conv);
      }
    }

    if (conversation != null && indexConv != null) {
      conversation.users[indexUserConv]["convMute"] = muteConv;
      newState[indexConv] = conversation;
    }

    state = [...newState];
  }

  void readOneConversation(ConversationModel conversation) {
    List<ConversationModel> newState = [...state!];

    for (var conv in newState) {
      if (conv.id == conversation.id && !conv.isLastMessageRead) {
        conv.isLastMessageRead = true;
      }
    }

    state = [...newState];
  }

  void newThemeConversation(String idConv, List<String> newStateTheme) {
    List<ConversationModel> newState = [...state!];
    ConversationModel? conversation;
    int? indexConv;

    for (var conv in newState) {
      if (conv.id == idConv) {
        conversation = conv;
        indexConv = newState.indexOf(conv);
      }
    }

    if (conversation != null && indexConv != null) {
      conversation.themeConv = [...newStateTheme];
      newState[indexConv] = conversation;
    }

    state = [...newState];
  }
}
