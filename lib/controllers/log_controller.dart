import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/router.dart';

class LogController extends ConsumerStatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  LogControllerState createState() => LogControllerState();
}

class LogControllerState extends ConsumerState<LogController> {
  User? user;
  late HeroController _heroController;

  @override
  void initState() {
    super.initState();

    _heroController = HeroController();
  }

  @override
  Widget build(BuildContext context) {
    user = ref.watch(userNotifierProvider);

    return user!.token.trim() != ""
        ? WillPopScope(
            child: Navigator(
              key: navAuthKey,
              initialRoute: bottomNav,
              observers: [_heroController],
              onGenerateRoute: (settings) =>
                  generateRouteAuth(settings, context),
            ),
            onWillPop: () async {
              if (ref.read(inChatDetailsNotifierProvider)["screen"] ==
                  "ChatDetails") {
                ref
                    .read(inChatDetailsNotifierProvider.notifier)
                    .outChatDetails("", "");
              } else if (ref.read(inChatDetailsNotifierProvider)["screen"] ==
                  "UserProfile") {
                ref.read(inChatDetailsNotifierProvider.notifier).inChatDetails(
                    "ChatDetails",
                    ref.read(inChatDetailsNotifierProvider)["userID"]);
              }

              if (ref.read(afterChatDetailsNotifierProvider)) {
                ref
                    .read(afterChatDetailsNotifierProvider.notifier)
                    .clearAfterChat();
              }
              
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
