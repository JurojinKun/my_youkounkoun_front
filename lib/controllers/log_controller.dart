import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/models/user_model.dart';
import 'package:my_boilerplate/providers/user_provider.dart';
import 'package:my_boilerplate/router.dart';

class LogController extends ConsumerStatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  LogControllerState createState() => LogControllerState();
}

class LogControllerState extends ConsumerState<LogController> {
  User? user;

  @override
  Widget build(BuildContext context) {
    user = ref.watch(userNotifierProvider);

    return user!.token.trim() != ""
        ? WillPopScope(
            child: Navigator(
              key: navAuthKey,
              initialRoute: bottomNav,
              onGenerateRoute: (settings) =>
                  generateRouteAuth(settings, context),
            ),
            onWillPop: () async {
              return !(await navAuthKey.currentState!.maybePop());
            },
          )
        : WillPopScope(
            child: Navigator(
              key: navNonAuthKey,
              initialRoute: welcome,
              onGenerateRoute: (settings) =>
                  generateRouteNonAuth(settings, context),
            ),
            onWillPop: () async {
              return !(await navNonAuthKey.currentState!.maybePop());
            },
          );
  }
}
