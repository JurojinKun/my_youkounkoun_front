import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/snack_bar_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
import 'package:myyoukounkoun/providers/current_route_app_provider.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/router.dart';

class LogController extends ConsumerStatefulWidget {
  const LogController({Key? key}) : super(key: key);

  @override
  LogControllerState createState() => LogControllerState();
}

class LogControllerState extends ConsumerState<LogController>
    with WidgetsBindingObserver {
  UserModel? user;
  late HeroController _heroController;

  String currentRouteApp = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _heroController = HeroController();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != ref.read(visibleKeyboardAppNotifierProvider)) {
      if (ref.read(connectivityStatusAppNotifierProvider) ==
          ConnectivityResult.none) {
        if (newValue) {
          scaffoldMessengerKey.currentState!.clearSnackBars();
        } else {
          scaffoldMessengerKey.currentState!
              .showSnackBar(showSnackBarCustom(context, currentRouteApp));
        }
      }
      ref
          .read(visibleKeyboardAppNotifierProvider.notifier)
          .setVisibleKeyboard(newValue);
    }
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    user = ref.watch(userNotifierProvider);
    currentRouteApp = ref.watch(currentRouteAppNotifierProvider);

    return user!.token.trim() != ""
        ? WillPopScope(
            child: Navigator(
              key: navAuthKey,
              initialRoute: bottomNav,
              observers: [_heroController, routeObserver],
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
              observers: [routeObserver],
              onGenerateRoute: (settings) =>
                  generateRouteNonAuth(settings, context),
            ),
            onWillPop: () async {
              return !(await navNonAuthKey.currentState!.maybePop());
            },
          );
  }
}
