import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/snack_bar_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
import 'package:myyoukounkoun/providers/current_route_app_provider.dart';
import 'package:myyoukounkoun/providers/search_enabled_provider.dart';
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

    navHomeKey = GlobalKey<NavigatorState>();
    navSearchKey = GlobalKey<NavigatorState>();
    navActivitiesKey = GlobalKey<NavigatorState>();
    navProfileKey = GlobalKey<NavigatorState>();
  }

  @override
  void didChangeMetrics() async {
    final bottomInset = View.of(context).viewInsets.bottom;
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
        ? NavigatorPopHandler(
            onPop: () {
              if (navAuthKey.currentState!.canPop()) {
                if (!ref.read(searchEnabledNotifierProvider)) {
                  navAuthKey.currentState!.pop();
                } else {
                  ref.read(searchEnabledNotifierProvider.notifier).updateState(false);
                  searchMessagesController!.clear();
                }
              } else {
                switch (tabControllerBottomNav!.index) {
                  case 0:
                    if (navHomeKey!.currentState != null &&
                        navHomeKey!.currentState!.canPop()) {
                      navHomeKey!.currentState!.pop();
                    } else {
                      SystemNavigator.pop();
                    }
                    break;
                  case 1:
                    if (navSearchKey!.currentState != null &&
                        navSearchKey!.currentState!.canPop()) {
                      navSearchKey!.currentState!.pop();
                    } else {
                      SystemNavigator.pop();
                    }
                    break;
                  case 2:
                    if (navActivitiesKey!.currentState != null &&
                        navActivitiesKey!.currentState!.canPop()) {
                      navActivitiesKey!.currentState!.pop();
                    } else {
                      SystemNavigator.pop();
                    }
                    break;
                  case 3:
                    if (navProfileKey!.currentState != null &&
                        navProfileKey!.currentState!.canPop()) {
                      navProfileKey!.currentState!.pop();
                    } else {
                      SystemNavigator.pop();
                    }
                    break;
                }
              }
            },
            child: Navigator(
              key: navAuthKey,
              initialRoute: bottomNav,
              observers: [_heroController, routeObserver],
              onGenerateRoute: (settings) =>
                  generateRouteAuth(settings, context),
            ),
          )
        : NavigatorPopHandler(
            onPop: () {
              navNonAuthKey.currentState!.pop();
            },
            child: Navigator(
              key: navNonAuthKey,
              initialRoute: welcome,
              observers: [routeObserver],
              onGenerateRoute: (settings) =>
                  generateRouteNonAuth(settings, context),
            ));
  }
}
