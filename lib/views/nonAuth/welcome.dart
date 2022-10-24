import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';

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
                        "Connexion",
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
                        "Inscription",
                        style: textStyleCustomMedium(Colors.white, 23),
                      )),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }
}
