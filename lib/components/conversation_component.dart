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
  final int index;

  const ConversationComponent(
      {Key? key, required this.conversation, required this.index})
      : super(key: key);

  @override
  ConversationComponentState createState() => ConversationComponentState();
}

class ConversationComponentState extends ConsumerState<ConversationComponent> {
  late UserModel userConv;

  Future<void> setUserConv() async {
    int userId = widget.conversation.usersId
        .firstWhere((element) => element != ref.read(userNotifierProvider).id);
    userConv = potentialsResultsSearchDatasMockes
        .firstWhere((element) => element.id == userId);
  }

  @override
  void initState() {
    super.initState();

    setUserConv();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slidable(
          key: UniqueKey(),
          endActionPane: ActionPane(
              motion: const DrawerMotion(),
              dismissible: DismissiblePane(onDismissed: () {}),
              children: [
                SlidableAction(
                  onPressed: (context) {},
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
                  .pushNamed(chatDetails, arguments: [userConv, false]);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 60.0,
                    width: 60.0,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: userConv.profilePictureUrl.trim() == ""
                              ? Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cBlue),
                                    color: cGrey.withOpacity(0.2),
                                  ),
                                  child: const Icon(Icons.person,
                                      color: cBlue, size: 30),
                                )
                              : CachedNetworkImageCustom(
                                  profilePictureUrl: userConv.profilePictureUrl,
                                  heightContainer: 50,
                                  widthContainer: 50,
                                  iconSize: 30),
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
                        Text(userConv.pseudo,
                            style: textStyleCustomBold(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                16),
                            textScaleFactor: 1.0),
                        Row(
                          children: [
                            Expanded(
                              child: Text(widget.conversation.lastMessage,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textStyleCustomMedium(
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? cBlack
                                          : cWhite,
                                      14),
                                  textScaleFactor: 1.0),
                            ),
                            const SizedBox(width: 5.0),
                            Text(
                                Helpers.readTimeStamp(
                                    context,
                                    int.parse(widget
                                        .conversation.timestampLastMessage)),
                                style: textStyleCustomMedium(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    12),
                                textScaleFactor: 1.0),
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
        if (widget.index != ref.read(conversationsNotifierProvider)!.length - 1)
          const Divider(thickness: 1, color: cGrey)
      ],
    );
  }
}
