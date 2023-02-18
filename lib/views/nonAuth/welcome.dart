import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/providers/version_app_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class Welcome extends ConsumerStatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  WelcomeState createState() => WelcomeState();
}

class WelcomeState extends ConsumerState<Welcome> {
  String versionApp = "";

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
    versionApp = ref.watch(versionAppNotifierProvider);

    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Helpers.uiOverlayApp(context),
        child: SafeArea(
          left: false,
          right: false,
          child: Center(
            child: Column(
              children: [
                Expanded(child: _assetTitle()),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: _btnsUser()),
                    Expanded(child: _infosApp())
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _assetTitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/ic_app.png", height: 125, width: 125),
        const SizedBox(
          height: 25.0,
        ),
        Text("My youkounkoun",
            style: textStyleCustomBold(Helpers.uiApp(context), 33),
            textAlign: TextAlign.center,
            textScaleFactor: 1.0),
      ],
    );
  }

  Widget _btnsUser() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 50.0,
          width: MediaQuery.of(context).size.width - 55,
          child: ElevatedButton(
              onPressed: () => navNonAuthKey.currentState!.pushNamed(login),
              child: Text(
                  AppLocalization.of(context)
                      .translate("welcome_screen", "login"),
                  style: textStyleCustomMedium(Helpers.uiApp(context), 20),
                  textScaleFactor: 1.0)),
        ),
        const SizedBox(
          height: 55.0,
        ),
        SizedBox(
          height: 50.0,
          width: MediaQuery.of(context).size.width - 55,
          child: ElevatedButton(
              onPressed: () => navNonAuthKey.currentState!.pushNamed(register),
              child: Text(
                  AppLocalization.of(context)
                      .translate("welcome_screen", "register"),
                  style: textStyleCustomMedium(Helpers.uiApp(context), 20),
                  textScaleFactor: 1.0)),
        ),
      ],
    );
  }

  Widget _infosApp() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RichText(
            textAlign: TextAlign.center,
            textScaleFactor: 1.0,
            text: TextSpan(
                text: AppLocalization.of(context)
                    .translate("welcome_screen", "consult"),
                style: textStyleCustomMedium(Helpers.uiApp(context), 12),
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
                    style: textStyleCustomMedium(Helpers.uiApp(context), 12),
                  ),
                  TextSpan(
                      text: AppLocalization.of(context)
                          .translate("welcome_screen", "privacy_policy"),
                      style: textStyleCustomMedium(cBlue, 12),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          //change url google to url privacy policy
                          Helpers.launchMyUrl("https://www.google.fr/");
                        }),
                  TextSpan(
                    text: AppLocalization.of(context)
                        .translate("welcome_screen", "youkounkoun"),
                    style: textStyleCustomMedium(Helpers.uiApp(context), 12),
                  )
                ])),
        const SizedBox(height: 20.0),
        Text(
            AppLocalization.of(context).translate("welcome_screen", "version") +
                versionApp,
            textAlign: TextAlign.center,
            style: textStyleCustomMedium(Helpers.uiApp(context), 11),
            textScaleFactor: 1.0)
      ],
    );
  }
}
