import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/helpers/helpers.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';

class Welcome extends ConsumerStatefulWidget {
  const Welcome({Key? key}) : super(key: key);

  @override
  WelcomeState createState() => WelcomeState();
}

class WelcomeState extends ConsumerState<Welcome> {
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
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/ic_splash.png"),
                  const SizedBox(
                    height: 25.0,
                  ),
                  Text(
                    "My boilerplate",
                    style: textStyleCustomBold(Colors.black, 33),
                    textAlign: TextAlign.center,
                  ),
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
                        style: textStyleCustomMedium(Colors.white, 23),
                      )),
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
                        style: textStyleCustomMedium(Colors.white, 23),
                      )),
                )
              ],
            )),
            Container(
              height: 50.0,
              alignment: Alignment.center,
              child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: AppLocalization.of(context)
                          .translate("welcome_screen", "consult"),
                      style: textStyleCustomMedium(Colors.black, 12),
                      children: [
                        TextSpan(
                            text: AppLocalization.of(context)
                                .translate("welcome_screen", "cgu"),
                            style: textStyleCustomMedium(Colors.blue, 12),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                //change url google to url cgu
                                Helpers.launchMyUrl("https://www.google.fr/");
                              }),
                        TextSpan(
                          text: AppLocalization.of(context)
                              .translate("welcome_screen", "and"),
                          style: textStyleCustomMedium(Colors.black, 12),
                        ),
                        TextSpan(
                            text: AppLocalization.of(context)
                                .translate("welcome_screen", "privacy_policy"),
                            style: textStyleCustomMedium(Colors.blue, 12),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                //change url google to url privacy policy
                                Helpers.launchMyUrl("https://www.google.fr/");
                              }),
                        TextSpan(
                          text: AppLocalization.of(context)
                              .translate("welcome_screen", "boilerplate"),
                          style: textStyleCustomMedium(Colors.black, 12),
                        )
                      ])),
            )
          ],
        ),
      ),
    );
  }
}
