import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: const SizedBox(),
      ),
    );
  }

  PreferredSizeWidget _customAppBarDetailsChat() {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 60),
      child: ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  widget.openWithModal
                      ? const SizedBox()
                      : IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.arrow_back_ios,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? cBlack
                                  : cWhite)),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: widget.openWithModal ? 15.0 : 0.0),
                      child: GestureDetector(
                        onTap: () => navAuthKey.currentState!
                            .pushNamed(userProfile, arguments: [widget.user]),
                        child: Row(
                          children: [
                            widget.user.profilePictureUrl.trim() != ""
                                ? Container(
                                    height: 40,
                                    width: 40,
                                    foregroundDecoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: cBlue),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                widget.user.profilePictureUrl),
                                            fit: BoxFit.cover)),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue),
                                      color: cGrey.withOpacity(0.2),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: cBlue, size: 30),
                                  )
                                : Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue),
                                      color: cGrey.withOpacity(0.2),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: cBlue, size: 20),
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
                      ? IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.clear,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? cBlack
                                  : cWhite))
                      : const SizedBox()
                ],
              ),
            )),
      ),
    );
  }
}
