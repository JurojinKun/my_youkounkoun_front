import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Welcome extends ConsumerStatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  WelcomeState createState() => WelcomeState();
}

class WelcomeState extends ConsumerState<Welcome> {
  String version = "";

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 0), () async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        version = packageInfo.version;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/images/ic_app.png", height: 125, width: 125),
                    const SizedBox(
                      height: 25.0,
                    ),
                    Text("My youkounkoun",
                        style: textStyleCustomBold(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            33),
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.0),
                  ],
                ),
              ),
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width - 55,
                    child: ElevatedButton(
                        onPressed: () =>
                            navNonAuthKey.currentState!.pushNamed(login),
                        child: Text(
                            AppLocalization.of(context)
                                .translate("welcome_screen", "login"),
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                20),
                            textScaleFactor: 1.0)),
                  ),
                  const SizedBox(
                    height: 55.0,
                  ),
                  SizedBox(
                    height: 50.0,
                    width: MediaQuery.of(context).size.width - 55,
                    child: ElevatedButton(
                        onPressed: () =>
                            navNonAuthKey.currentState!.pushNamed(register),
                        child: Text(
                            AppLocalization.of(context)
                                .translate("welcome_screen", "register"),
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                20),
                            textScaleFactor: 1.0)),
                  )
                ],
              )),
              Container(
                height: 40.0,
                alignment: Alignment.center,
                child: RichText(
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                    text: TextSpan(
                        text: AppLocalization.of(context)
                            .translate("welcome_screen", "consult"),
                        style: textStyleCustomMedium(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            12),
                        children: [
                          TextSpan(
                              text: AppLocalization.of(context)
                                  .translate("welcome_screen", "cgu"),
                              style: textStyleCustomMedium(cBlue, 12),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  //change url google to url cgu
                                  Helpers.launchMyUrl("https://www.google.fr/");
                                }),
                          TextSpan(
                            text: AppLocalization.of(context)
                                .translate("welcome_screen", "and"),
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                12),
                          ),
                          TextSpan(
                              text: AppLocalization.of(context).translate(
                                  "welcome_screen", "privacy_policy"),
                              style: textStyleCustomMedium(cBlue, 12),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  //change url google to url privacy policy
                                  Helpers.launchMyUrl("https://www.google.fr/");
                                }),
                          TextSpan(
                            text: AppLocalization.of(context)
                                .translate("welcome_screen", "youkounkoun"),
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                12),
                          )
                        ])),
              ),
              Container(
                height: 60.0,
                alignment: Alignment.center,
                child: Text(
                    AppLocalization.of(context)
                            .translate("welcome_screen", "version") +
                        version,
                    textAlign: TextAlign.center,
                    style: textStyleCustomMedium(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        11),
                    textScaleFactor: 1.0),
              )
            ],
          ),
        ),
      ),
    );
  }
}
