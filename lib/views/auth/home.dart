import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/providers/token_notifications_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> with AutomaticKeepAliveClientMixin {
  String tokenNotif = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    tokenNotif = ref.watch(tokenNotificationsNotifierProvider);

    return Scaffold(
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
            AppLocalization.of(context).translate("home_screen", "home"),
            style: textStyleCustomBold(
                Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite,
                20),
            textScaleFactor: 1.0),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
          child: Column(
            children: [
              Text(
                  AppLocalization.of(context)
                      .translate("home_screen", "push_token"),
                  style: textStyleCustomMedium(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      14),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0),
              const SizedBox(
                height: 15.0,
              ),
              tokenNotif.trim() != ""
                  ? SelectableText(
                      tokenNotif,
                      style: textStyleCustomMedium(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          14),
                      textAlign: TextAlign.center,
                    )
                  : Text(
                      AppLocalization.of(context)
                          .translate("home_screen", "no_token"),
                      style: textStyleCustomMedium(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          14),
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.0),
            ],
          )),
    );
  }
}
