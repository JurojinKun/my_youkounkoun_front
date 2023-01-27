import 'dart:io';
import 'dart:ui';

import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';

import '../../models/user_model.dart';

class ChatDetails extends ConsumerStatefulWidget {
  final UserModel user;
  final bool openWithModal;

  const ChatDetails({Key? key, required this.user, required this.openWithModal})
      : super(key: key);

  @override
  ChatDetailsState createState() => ChatDetailsState();
}

class ChatDetailsState extends ConsumerState<ChatDetails> {
  AppBar appBar = AppBar();

  late TextEditingController _chatController;
  late FocusNode _chatFocusNode;

  @override
  void initState() {
    super.initState();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(inChatDetailsNotifierProvider.notifier).inChatDetails(
            context.widget.toString(), widget.user.id.toString());
      });
    }

    _chatController = TextEditingController();
    _chatFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _chatFocusNode.dispose();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: GestureDetector(
        onTap: () => Helpers.hideKeyboard(context),
        onHorizontalDragUpdate: (details) {
          int sensitivity = 8;
          if (Platform.isIOS &&
              details.delta.dx > sensitivity &&
              details.globalPosition.dx <= 70) {
            if (ref.read(inChatDetailsNotifierProvider)["screen"] ==
                "ChatDetails") {
              ref
                  .read(inChatDetailsNotifierProvider.notifier)
                  .outChatDetails("", "");
            }
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _customAppBarDetailsChat(),
          body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: Theme.of(context).brightness == Brightness.light
                ? Platform.isIOS
                    ? SystemUiOverlayStyle.dark
                    : const SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: Brightness.dark)
                : Platform.isIOS
                    ? SystemUiOverlayStyle.light
                    : const SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: Brightness.light),
            child: SizedBox.expand(
                child: Stack(
              children: [
                SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20.0,
                        MediaQuery.of(context).padding.top +
                            appBar.preferredSize.height +
                            20.0,
                        20.0,
                        MediaQuery.of(context).padding.bottom + 80.0),
                    physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics()),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      color: cBlue.withOpacity(0.5),
                    )),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: writeMessage(),
                )
              ],
            )),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _customAppBarDetailsChat() {
    return PreferredSize(
      preferredSize:
          Size(MediaQuery.of(context).size.width, appBar.preferredSize.height),
      child: ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.openWithModal
                      ? const SizedBox()
                      : Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: IconButton(
                              onPressed: () {
                                ref
                                    .read(
                                        inChatDetailsNotifierProvider.notifier)
                                    .outChatDetails("", "");
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? cBlack
                                      : cWhite)),
                        ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: widget.openWithModal ? 15.0 : 0.0),
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(afterChatDetailsNotifierProvider.notifier)
                              .updateAfterChat(true);
                          ref
                              .read(inChatDetailsNotifierProvider.notifier)
                              .outChatDetails(
                                  "UserProfile", widget.user.id.toString());
                          navAuthKey.currentState!.pushNamed(userProfile,
                              arguments: [widget.user, false]);
                        },
                        child: Row(
                          children: [
                            widget.user.profilePictureUrl.trim() == ""
                                ? Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue),
                                      color: cGrey.withOpacity(0.2),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: cBlue, size: 23),
                                  )
                                : CachedNetworkImageCustom(
                                    profilePictureUrl:
                                        widget.user.profilePictureUrl,
                                    heightContainer: 45,
                                    widthContainer: 45,
                                    iconSize: 23),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Text(widget.user.pseudo,
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    20),
                                textScaleFactor: 1.0)
                          ],
                        ),
                      ),
                    ),
                  ),
                  widget.openWithModal
                      ? Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: IconButton(
                              onPressed: () {
                                ref
                                    .read(
                                        inChatDetailsNotifierProvider.notifier)
                                    .outChatDetails("", "");
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? cBlack
                                    : cWhite,
                                size: 30,
                              )),
                        )
                      : const SizedBox()
                ],
              ),
            )),
      ),
    );
  }

  Widget writeMessage() {
    return ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _chatFocusNode.hasFocus || _chatController.text.isNotEmpty
                      ? Container(
                          height: 40,
                          width: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                    color: cBlue,
                                    blurRadius: 6,
                                    spreadRadius: 2)
                              ]),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: cBlue,
                            size: 20,
                          ),
                        )
                      : Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              margin:
                                  const EdgeInsets.only(left: 10.0, right: 7.5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: cBlue,
                                        blurRadius: 6,
                                        spreadRadius: 2)
                                  ]),
                              child: const Icon(
                                Icons.add,
                                color: cBlue,
                                size: 20,
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              margin:
                                  const EdgeInsets.only(left: 7.5, right: 10.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: cBlue,
                                        blurRadius: 6,
                                        spreadRadius: 2)
                                  ]),
                              child: const Icon(
                                Icons.mic_rounded,
                                color: cBlue,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                          minLines: 1,
                          maxLines: 3,
                          controller: _chatController,
                          focusNode: _chatFocusNode,
                          cursorColor: cBlue,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.multiline,
                          onChanged: (val) {
                            setState(() {
                              val = _chatController.text;
                            });
                          },
                          onSubmitted: (val) {
                            Helpers.hideKeyboard(context);
                          },
                          style: textStyleCustomBold(
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                              12 / MediaQuery.of(context).textScaleFactor),
                          decoration: InputDecoration(
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            filled: true,
                            contentPadding:
                                const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            hintText: "Écrire un message...",
                            hintStyle: textStyleCustomBold(cGrey,
                                12 / MediaQuery.of(context).textScaleFactor),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color:
                                      _chatFocusNode.hasFocus ? cBlue : cGrey,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color:
                                      _chatFocusNode.hasFocus ? cBlue : cGrey,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color:
                                      _chatFocusNode.hasFocus ? cBlue : cGrey,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color:
                                      _chatFocusNode.hasFocus ? cBlue : cGrey,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            suffixIcon: Icon(
                              Icons.emoji_emotions,
                              color: _chatFocusNode.hasFocus ? cBlue : cGrey,
                            ),
                          )),
                    ),
                  ),
                  if (_chatController.text.isNotEmpty)
                    Container(
                      height: 40,
                      width: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                                color: cBlue, blurRadius: 6, spreadRadius: 2)
                          ]),
                      child: const Icon(
                        Icons.send,
                        color: cBlue,
                        size: 20,
                      ),
                    ),
                ],
              ),
            )));
  }
}
