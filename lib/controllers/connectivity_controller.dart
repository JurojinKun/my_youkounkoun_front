import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/snack_bar_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/controllers/log_controller.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
import 'package:myyoukounkoun/providers/current_route_app_provider.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/views/connectivity/connectivity_device.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectivityController extends ConsumerStatefulWidget {
  const ConnectivityController({Key? key}) : super(key: key);

  @override
  ConnectivityControllerState createState() => ConnectivityControllerState();
}

class ConnectivityControllerState extends ConsumerState<ConnectivityController>
    with SingleTickerProviderStateMixin {
  //connectivity
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult? initConnectivityStatusApp;

  String currentRouteApp = "";

  Future<void> _reloadDataUser(SharedPreferences prefs) async {
    //logic already log
    String token = prefs.getString("token") ?? "";

    if (token.trim() != "") {
      ref.read(userNotifierProvider.notifier).initUser(UserModel(
          id: 1,
          token: "tokenTest1234",
          email: "ccommunay@gmail.com",
          pseudo: "0ruj",
          gender: "Male",
          birthday: "1997-06-06 00:00",
          nationality: "FR",
          profilePictureUrl: "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
          validCGU: true,
          validPrivacyPolicy: true,
          validEmail: false));

      ref
          .read(recentSearchesNotifierProvider.notifier)
          .initRecentSearches(recentSearchesDatasMockes);

      bool notificationsActive = prefs.getBool("notifications") ?? true;
      ref
          .read(notificationsActiveNotifierProvider.notifier)
          .updateNotificationsActive(notificationsActive);
    }
  }

  @override
  void initState() {
    super.initState();

    animationSnackBarController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat();

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (initConnectivityStatusApp == ConnectivityResult.none &&
          result != ConnectivityResult.none) {
        await _reloadDataUser(prefs);
        ref
            .read(initConnectivityStatusAppNotifierProvider.notifier)
            .setInitConnectivityStatus(result);
      } else if (initConnectivityStatusApp != ConnectivityResult.none) {
        if (result == ConnectivityResult.none) {
          if (!mounted) return;
          if (scaffoldMessengerKey.currentState != null) {
            scaffoldMessengerKey.currentState!
                .showSnackBar(showSnackBarCustom(context, currentRouteApp));
          }

          ref
              .read(connectivityStatusAppNotifierProvider.notifier)
              .updateConnectivityStatus(result);
        } else if (result != ConnectivityResult.none &&
            ref.read(connectivityStatusAppNotifierProvider) ==
                ConnectivityResult.none) {
          await _reloadDataUser(prefs);
          ref
              .read(connectivityStatusAppNotifierProvider.notifier)
              .updateConnectivityStatus(result);
          if (scaffoldMessengerKey.currentState != null) {
            scaffoldMessengerKey.currentState!.clearSnackBars();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    animationSnackBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initConnectivityStatusApp =
        ref.watch(initConnectivityStatusAppNotifierProvider);
    currentRouteApp = ref.watch(currentRouteAppNotifierProvider);

    return initConnectivityStatusApp == ConnectivityResult.none
        ? const ConnectivityDevice()
        : const LogController();
  }
}
