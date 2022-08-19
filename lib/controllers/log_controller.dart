import 'package:flutter/material.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/router.dart';

class LogController extends StatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  State<LogController> createState() => _LogControllerState();
}

class _LogControllerState extends State<LogController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        child: Navigator(
          key: navAuthKey,
          initialRoute: bottomNav,
          onGenerateRoute: (settings) => generateRouteAuth(settings, context),
        ),
        onWillPop: () async {
          return !(await navAuthKey.currentState!.maybePop());
        },
      ),
    );
  }
}
