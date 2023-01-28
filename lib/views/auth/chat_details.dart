import 'dart:io';
import 'dart:ui';

import 'package:age_calculator/age_calculator.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/message_model.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

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

  late ScrollController _scrollChatController;
  bool _scrollDown = false;

  late TextEditingController _chatController;
  late FocusNode _chatFocusNode;

  List<MessageModel> messagesUsers = [];

  void _scrollChatListener() {
    if (_scrollChatController.position.pixels >=
            _scrollChatController.position.minScrollExtent + 100 &&
        !_scrollDown) {
      setState(() {
        _scrollDown = true;
      });
    } else if (_scrollChatController.position.pixels <
            _scrollChatController.position.minScrollExtent + 100 &&
        _scrollDown) {
      setState(() {
        _scrollDown = false;
      });
    }
  }

  void _scrollToDownChat() {
    _scrollChatController.animateTo(
        _scrollChatController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn);
  }

  //fake fct => get datas mockés switch id user
  List<MessageModel> getListMessagesUsers() {
    List<MessageModel> messages = [];

    switch (widget.user.id) {
      case 186:
        messages = [...listMessagesWith186DatasMockes];
        break;
      case 4:
        messages = [...listMessagesWith4DatasMockes];
        break;
      default:
        messages = [];
        break;
    }

    messages.sort(
        (a, b) => int.parse(a.timestamp).compareTo(int.parse(b.timestamp)));

    return messages;
  }

  @override
  void initState() {
    super.initState();

    messagesUsers = getListMessagesUsers();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(inChatDetailsNotifierProvider.notifier).inChatDetails(
            context.widget.toString(), widget.user.id.toString());
      });
    }

    _scrollChatController = ScrollController();
    _scrollChatController.addListener(_scrollChatListener);

    _chatController = TextEditingController();
    _chatFocusNode = FocusNode();
  }

  @override
  void deactivate() {
    _scrollChatController.removeListener(_scrollChatListener);
    super.deactivate();
  }

  @override
  void dispose() {
    _chatFocusNode.dispose();
    _chatController.dispose();
    _scrollChatController.dispose();
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
          resizeToAvoidBottomInset: true,
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
            child: Stack(
              children: [
                messages(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_scrollDown)
                      GestureDetector(
                        onTap: () => _scrollToDownChat(),
                        child: Container(
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                    color: cBlue,
                                    blurRadius: 6,
                                    spreadRadius: 2)
                              ]),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_downward,
                            color: cBlue,
                            size: 23,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    writeMessage()
                  ],
                )
              ],
            ),
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

  Widget messages() {
    return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            10.0,
            MediaQuery.of(context).padding.top +
                appBar.preferredSize.height +
                20.0,
            10.0,
            MediaQuery.of(context).padding.bottom + 70.0),
        controller: _scrollChatController,
        reverse: true,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            seeProfile(),
            const SizedBox(height: 20.0),
            listMessages()
          ],
        ));
  }

  Widget seeProfile() {
    return Center(
      child: Column(
        children: [
          widget.user.profilePictureUrl.trim() == ""
              ? Container(
                  height: 145,
                  width: 145,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cBlue),
                    color: cGrey.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.person, color: cBlue, size: 55),
                )
              : CachedNetworkImageCustom(
                  profilePictureUrl: widget.user.profilePictureUrl,
                  heightContainer: 145,
                  widthContainer: 145,
                  iconSize: 55),
          const SizedBox(
            height: 15.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.user.pseudo,
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    23),
                textScaleFactor: 1.0,
                textAlign: TextAlign.center,
              ),
              Flag.flagsCode.contains(widget.user.nationality.toUpperCase())
                  ? Flag.fromString(
                      widget.user.nationality.toUpperCase(),
                      height: 25,
                      width: 50,
                      fit: BoxFit.contain,
                      replacement: const SizedBox(),
                    )
                  : Flag.flagsCode
                          .contains(widget.user.nationality.toLowerCase())
                      ? Flag.fromString(
                          widget.user.nationality.toLowerCase(),
                          height: 25,
                          width: 50,
                          fit: BoxFit.contain,
                          replacement: const SizedBox(),
                        )
                      : const SizedBox()
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.user.gender == "Male" ? Icons.male : Icons.female,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite),
              Text(
                " - ",
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    18),
              ),
              Text(
                  AgeCalculator.age(Helpers.convertStringToDateTime(
                              widget.user.birthday))
                          .years
                          .toString() +
                      AppLocalization.of(context)
                          .translate("user_profile_screen", "years_old"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      18.0))
            ],
          ),
          const SizedBox(height: 10.0),
          SizedBox(
              height: 30.0,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: cBlue,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
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
                  child: Text("Voir profil",
                      style: textStyleCustomMedium(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          18),
                      textScaleFactor: 1.0)))
        ],
      ),
    );
  }

  Widget listMessages() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: messagesUsers.length,
      itemBuilder: (context, index) {
        MessageModel message = messagesUsers[index];

        return messageItem(messagesUsers, message, index);
      },
    );
  }

  Widget messageItem(
      List<MessageModel> messagesUsers, MessageModel message, int index) {
    return message.idSender != ref.read(userNotifierProvider).id
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (messagesUsers.length == index + 1 ||
                  messagesUsers[index + 1].idSender ==
                      ref.read(userNotifierProvider).id)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: widget.user.profilePictureUrl.trim() == ""
                      ? Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cBlue),
                            color: cGrey.withOpacity(0.2),
                          ),
                          child:
                              const Icon(Icons.person, color: cBlue, size: 15),
                        )
                      : CachedNetworkImageCustom(
                          profilePictureUrl: widget.user.profilePictureUrl,
                          heightContainer: 25,
                          widthContainer: 25,
                          iconSize: 15),
                ),
              message.type == "text"
                  ? Container(
                      constraints: BoxConstraints(
                          minWidth: 0,
                          maxWidth: MediaQuery.of(context).size.width / 1.5),
                      margin: EdgeInsets.symmetric(
                          horizontal: messagesUsers.length != index + 1 &&
                                  messagesUsers[index + 1].idSender !=
                                      ref.read(userNotifierProvider).id
                              ? 35.0
                              : 10.0,
                          vertical: 5.0),
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: cBlue),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Text(
                        message.message,
                        style: textStyleCustomRegular(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            14),
                        textScaleFactor: 1.0,
                      ),
                    )
                  : Container(
                      height: 200,
                      width: 150,
                      margin: EdgeInsets.symmetric(
                          horizontal: messagesUsers.length != index + 1 &&
                                  messagesUsers[index + 1].idSender !=
                                      ref.read(userNotifierProvider).id
                              ? 35.0
                              : 10.0,
                          vertical: 5.0),
                      decoration: BoxDecoration(
                          color: cGrey.withOpacity(0.2),
                          border: Border.all(color: cBlue),
                          borderRadius: BorderRadius.circular(10.0)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Image.network(
                          message.message,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? cBlack
                                    : cWhite,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ))
            ],
          )
        : Align(
            alignment: Alignment.centerRight,
            child: message.type == "text"
                ? Container(
                    constraints: BoxConstraints(
                        minWidth: 0,
                        maxWidth: MediaQuery.of(context).size.width / 1.5),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                        color: cBlue,
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Text(
                      message.message,
                      style: textStyleCustomRegular(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          14),
                      textScaleFactor: 1.0,
                    ),
                  )
                : Container(
                    height: 200,
                    width: 150,
                    margin: EdgeInsets.symmetric(
                        horizontal: messagesUsers.length != index + 1 &&
                                messagesUsers[index + 1].idSender !=
                                    ref.read(userNotifierProvider).id
                            ? 35.0
                            : 10.0,
                        vertical: 5.0),
                    decoration: BoxDecoration(
                        color: cGrey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.0)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.network(
                        message.message,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? cBlack
                                  : cWhite,
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    )),
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
