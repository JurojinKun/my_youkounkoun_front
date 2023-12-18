import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/components/conversation_component.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/chat_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/route_observer.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/auth/new_conversation.dart';

class Chat extends ConsumerStatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  ChatState createState() => ChatState();
}

class ChatState extends ConsumerState<Chat> with AutomaticKeepAliveClientMixin {
  List<ConversationModel>? listConversations;

  Future _newConversationBottomSheet(BuildContext context) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: false,
        builder: (context) {
          return const RouteObserverWidget(
              name: newConversation, child: NewConversation());
        });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    listConversations = ref.watch(conversationsNotifierProvider);

    return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            10.0,
            MediaQuery.of(context).padding.top + 20.0,
            10.0,
            MediaQuery.of(context).padding.bottom + 90.0),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: listConversations == null
            ? SizedBox(
                height: MediaQuery.of(context).size.height -
                    (MediaQuery.of(context).padding.top +
                        20.0 +
                        MediaQuery.of(context).padding.bottom +
                        90.0),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: cBlue,
                    strokeWidth: 1.0,
                  ),
                ))
            : listConversations!.isEmpty
                ? emptyChat()
                : conversations());
  }

  Widget emptyChat() {
    return SizedBox(
      height: MediaQuery.of(context).size.height -
          (MediaQuery.of(context).padding.top +
              20.0 +
              MediaQuery.of(context).padding.bottom +
              90.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.send,
            color: Helpers.uiApp(context),
            size: 40,
          ),
          const SizedBox(height: 15.0),
          Text(
            AppLocalization.of(context)
                .translate("activities_screen", "no_chat"),
            style: textStyleCustomMedium(Helpers.uiApp(context), 14),
            textAlign: TextAlign.center,
            textScaler: const TextScaler.linear(1.0),
          )
        ],
      ),
    );
  }

  Widget conversations() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalization.of(context)
                  .translate("activities_screen", "chat"),
              style: textStyleCustomBold(Helpers.uiApp(context), 20),
              textScaler: const TextScaler.linear(1.0),
            ),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: IconButton(
                  onPressed: () =>
                      _newConversationBottomSheet(navAuthKey.currentContext!),
                  icon: Icon(Icons.edit_note,
                      color: Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      size: 33)),
            )
          ],
        ),
        ...listConversations!.map((conversation) {
          late int userId;
          late UserModel userConv;
          late int indexUserConv;
          late int indexOtherUserConv;
          int index = listConversations!.indexOf(conversation);

          for (var user in conversation.users) {
            if (user["id"] != ref.read(userNotifierProvider).id) {
              userId = user["id"];
              indexOtherUserConv = conversation.users.indexOf(user);
            } else {
              indexUserConv = conversation.users.indexOf(user);
            }
          }
          userConv = potentialsResultsSearchDatasMockes
              .firstWhere((element) => element.id == userId);

          return ConversationComponent(
            conversation: conversation,
            indexConversations: index,
            userConv: userConv,
            indexUserConv: indexUserConv,
            indexOtherUserConv: indexOtherUserConv,
          );
        })
      ],
    );
  }
}
