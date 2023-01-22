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

  void readOneConversation(ConversationModel conversation) {
    List<ConversationModel> newState = [...state!];

    for (var conv in newState) {
      if (conv.id == conversation.id && !conv.isLastMessageRead) {
        conv.isLastMessageRead = true;
      }
    }

    state = [...newState];
  }
}
