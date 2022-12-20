import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class NewConversation extends ConsumerStatefulWidget {
  const NewConversation({Key? key}) : super(key: key);

  @override
  NewConversationState createState() => NewConversationState();
}

class NewConversationState extends ConsumerState<NewConversation> {
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: Theme.of(context).brightness == Brightness.light
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
        title: Text(
          AppLocalization.of(context).translate("new_conversation_screen", "new_conversation"),
          style: textStyleCustomBold(
              Theme.of(context).brightness == Brightness.light
                  ? cBlack
                  : cWhite,
              20),
        ),
        centerTitle: false,
        actions: [
          IconButton(
              onPressed: () => navAuthKey.currentState!.pop(),
              icon: Icon(
                Icons.clear,
                color: Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite,
              ))
        ],
      ),
    );
  }
}
