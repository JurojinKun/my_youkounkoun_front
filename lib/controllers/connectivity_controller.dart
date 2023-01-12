import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/controllers/log_controller.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
import 'package:myyoukounkoun/providers/notifications_active_provider.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:myyoukounkoun/providers/token_notifications_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
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

  late AnimationController _animationController;

  Future<void> _loadDataUser(SharedPreferences prefs) async {
    //logic already log
    String token = prefs.getString("token") ?? "";
    print("////////token//////");
    print(token);

    if (token.trim() != "") {
      ref.read(userNotifierProvider.notifier).initUser(User(
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

    //get push token device
    String? tokenPush = await FirebaseMessaging.instance.getToken();
    if (tokenPush != null && tokenPush.trim() != "") {
      if (kDebugMode) {
        print("push token: $tokenPush");
      }
      ref
          .read(tokenNotificationsNotifierProvider.notifier)
          .updateTokenNotif(tokenPush);
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat();

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (initConnectivityStatusApp == ConnectivityResult.none &&
          result != ConnectivityResult.none) {
        await _loadDataUser(prefs);
        ref
            .read(initConnectivityStatusAppNotifierProvider.notifier)
            .setInitConnectivityStatus(result);
      } else if (initConnectivityStatusApp != ConnectivityResult.none) {
        if (result == ConnectivityResult.none) {
          if (!mounted) return;
          if (scaffoldMessengerKey.currentState != null) {
            scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
              backgroundColor: cRed,
              elevation: 6,
              margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
              content: Row(
                children: [
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0)
                        .animate(_animationController),
                    child: Image.asset("assets/images/ic_app.png",
                        height: 25, width: 25),
                  ),
                  const SizedBox(width: 10.0),
                  Text(
                      AppLocalization.of(context)
                          .translate("connectivity_screen", "no_connectivity"),
                      style: textStyleCustomMedium(cWhite, 14.0),
                      textScaleFactor: 1.0),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(days: 365),
              dismissDirection: DismissDirection.none,
            ));
          }

          ref
              .read(connectivityStatusAppNotifierProvider.notifier)
              .updateConnectivityStatus(result);
        } else if (result != ConnectivityResult.none &&
            ref.read(connectivityStatusAppNotifierProvider) ==
                ConnectivityResult.none) {
          await _loadDataUser(prefs);
          ref
              .read(connectivityStatusAppNotifierProvider.notifier)
              .updateConnectivityStatus(result);
          if (scaffoldMessengerKey.currentState != null) {
            scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    initConnectivityStatusApp =
        ref.watch(initConnectivityStatusAppNotifierProvider);

    return initConnectivityStatusApp == ConnectivityResult.none
        ? const ConnectivityDevice()
        : const LogController();
  }
}
