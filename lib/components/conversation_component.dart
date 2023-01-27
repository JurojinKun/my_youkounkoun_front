import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/chat_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class ConversationComponent extends ConsumerStatefulWidget {
  final ConversationModel conversation;
  final int indexConversations;
  final UserModel userConv;
  final int indexUserConv;

  const ConversationComponent(
      {Key? key,
      required this.conversation,
      required this.indexConversations,
      required this.userConv,
      required this.indexUserConv})
      : super(key: key);

  @override
  ConversationComponentState createState() => ConversationComponentState();
}

class ConversationComponentState extends ConsumerState<ConversationComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slidable(
          key: UniqueKey(),
          endActionPane: ActionPane(
              extentRatio: 0.6,
              motion: const DrawerMotion(),
              children: [
                SlidableAction(
                  spacing: 6,
                  onPressed: (context) {
                    if (widget.conversation.users[widget.indexUserConv]
                        ["convMute"]) {
                      ref
                          .read(conversationsNotifierProvider.notifier)
                          .muteConversation(widget.conversation.id,
                              widget.indexUserConv, false);
                    } else {
                      ref
                          .read(conversationsNotifierProvider.notifier)
                          .muteConversation(widget.conversation.id,
                              widget.indexUserConv, true);
                    }
                  },
                  autoClose: true,
                  flex: 1,
                  backgroundColor: cBlue,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                  icon: widget.conversation.users[widget.indexUserConv]
                          ["convMute"]
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_off_outlined,
                  label: widget.conversation.users[widget.indexUserConv]
                          ["convMute"]
                      ? AppLocalization.of(context)
                          .translate("activities_screen", "unmute")
                      : AppLocalization.of(context)
                          .translate("activities_screen", "mute"),
                ),
                SlidableAction(
                  spacing: 6,
                  onPressed: (context) {
                    ref
                        .read(conversationsNotifierProvider.notifier)
                        .removeConversation(widget.conversation);
                  },
                  autoClose: true,
                  flex: 1,
                  backgroundColor: cRed,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                  icon: Icons.delete_forever_outlined,
                  label: AppLocalization.of(context)
                      .translate("activities_screen", "delete"),
                )
              ]),
          child: InkWell(
            onTap: () {
              navAuthKey.currentState!
                  .pushNamed(chatDetails, arguments: [widget.userConv, false]);
              if (!widget.conversation.isLastMessageRead &&
                  widget.conversation.lastMessageUserId !=
                      ref.read(userNotifierProvider).id) {
                ref
                    .read(conversationsNotifierProvider.notifier)
                    .readOneConversation(widget.conversation);
              }
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: widget.userConv.profilePictureUrl.trim() == ""
                              ? Container(
                                  height: 45,
                                  width: 45,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cBlue),
                                    color: cGrey.withOpacity(0.2),
                                  ),
                                  child: const Icon(Icons.person,
                                      color: cBlue, size: 28),
                                )
                              : CachedNetworkImageCustom(
                                  profilePictureUrl:
                                      widget.userConv.profilePictureUrl,
                                  heightContainer: 45,
                                  widthContainer: 45,
                                  iconSize: 28),
                        ),
                        if (widget.conversation.lastMessageUserId !=
                                ref.read(userNotifierProvider).id &&
                            !widget.conversation.isLastMessageRead)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              height: 7.5,
                              width: 7.5,
                              decoration: const BoxDecoration(
                                color: cBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(widget.userConv.pseudo,
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    16),
                                textScaleFactor: 1.0),
                            const SizedBox(width: 5.0),
                            if (widget.conversation.users[widget.indexUserConv]
                                ["convMute"])
                              const Icon(Icons.notifications_off,
                                  color: cBlue, size: 20)
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(widget.conversation.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: widget.conversation
                                                  .lastMessageUserId !=
                                              ref
                                                  .read(userNotifierProvider)
                                                  .id &&
                                          !widget.conversation.isLastMessageRead
                                      ? textStyleCustomBold(
                                          Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? cBlack
                                              : cWhite,
                                          14)
                                      : textStyleCustomRegular(cGrey, 14),
                                  textScaleFactor: 1.0),
                            ),
                            const SizedBox(width: 5.0),
                            StreamBuilder(
                                stream: Stream<String>.periodic(
                                    const Duration(minutes: 1),
                                    ((computationCount) {
                                  return Helpers.readTimeStamp(
                                      context,
                                      int.parse(widget
                                          .conversation.timestampLastMessage));
                                })),
                                builder: (context, snapshot) {
                                  if (snapshot.data == null) {
                                    return Text(
                                        Helpers.readTimeStamp(
                                            context,
                                            int.parse(widget.conversation
                                                .timestampLastMessage)),
                                        style: textStyleCustomMedium(
                                            widget.conversation
                                                            .lastMessageUserId !=
                                                        ref
                                                            .read(
                                                                userNotifierProvider)
                                                            .id &&
                                                    !widget.conversation
                                                        .isLastMessageRead
                                                ? Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? cBlack
                                                    : cWhite
                                                : cGrey,
                                            12),
                                        textScaleFactor: 1.0);
                                  } else {
                                    return Text(snapshot.data.toString(),
                                        style: textStyleCustomMedium(
                                            widget.conversation
                                                            .lastMessageUserId !=
                                                        ref
                                                            .read(
                                                                userNotifierProvider)
                                                            .id &&
                                                    !widget.conversation
                                                        .isLastMessageRead
                                                ? Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? cBlack
                                                    : cWhite
                                                : cGrey,
                                            12),
                                        textScaleFactor: 1.0);
                                  }
                                }),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.indexConversations !=
            ref.read(conversationsNotifierProvider)!.length - 1)
          const Divider(thickness: 1, color: cGrey)
      ],
    );
  }
}