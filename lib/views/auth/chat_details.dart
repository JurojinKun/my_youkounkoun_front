import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';

import '../../models/user_model.dart';

class ChatDetails extends ConsumerStatefulWidget {
  final User user;
  final bool openWithModal;

  const ChatDetails({Key? key, required this.user, required this.openWithModal})
      : super(key: key);

  @override
  ChatDetailsState createState() => ChatDetailsState();
}

class ChatDetailsState extends ConsumerState<ChatDetails> {
  AppBar appBar = AppBar();

  @override
  void initState() {
    super.initState();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(inChatDetailsNotifierProvider.notifier).inChatDetails(
            context.widget.toString(), widget.user.id.toString());
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20.0,
                    MediaQuery.of(context).padding.top +
                        appBar.preferredSize.height +
                        20.0,
                    20.0,
                    MediaQuery.of(context).padding.bottom + 20.0),
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                child: const SizedBox()),
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
                                : CachedNetworkImage(
                                    imageUrl: widget.user.profilePictureUrl,
                                    imageBuilder: ((context, imageProvider) {
                                      return Container(
                                          height: 45,
                                          width: 45,
                                          foregroundDecoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(color: cBlue),
                                              image: DecorationImage(
                                                  image: imageProvider,
                                                  fit: BoxFit.cover)),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(color: cBlue),
                                            color: cGrey.withOpacity(0.2),
                                          ),
                                          child: const Icon(Icons.person,
                                              color: cBlue, size: 23));
                                    }),
                                    progressIndicatorBuilder:
                                        (context, url, downloadProgress) {
                                      return Container(
                                        height: 45,
                                        width: 45,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: cBlue),
                                          color: cGrey.withOpacity(0.2),
                                        ),
                                        child: const Icon(Icons.person,
                                            color: cBlue, size: 23),
                                      );
                                    },
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      height: 45,
                                      width: 45,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: cBlue),
                                        color: cGrey.withOpacity(0.2),
                                      ),
                                      child: const Icon(Icons.person,
                                          color: cBlue, size: 23),
                                    ),
                                  ),
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
}
