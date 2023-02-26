import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/snack_bar_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/controllers/log_controller.dart';
import 'package:myyoukounkoun/main.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
import 'package:myyoukounkoun/providers/current_route_app_provider.dart';
import 'package:myyoukounkoun/providers/new_maj_provider.dart';
import 'package:myyoukounkoun/views/connectivity/connectivity_device.dart';
import 'package:myyoukounkoun/views/newMaj/new_version_app.dart';
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

  Map<String, dynamic> newMajInfos = {};
  bool newMajInfosAlreadySeen = false;

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
        //logic new maj
        await searchPotentialNewMaj(ref);

        if (!ref.read(newMajInfosNotifierProvider)["newMajAvailable"]) {
          //logic load datas user
          await loadDataUser(prefs, ref);
        }

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
    newMajInfos = ref.watch(newMajInfosNotifierProvider);
    newMajInfosAlreadySeen = ref.watch(newMajInfosAlreadySeenNotifierProvider);

    return initConnectivityStatusApp == ConnectivityResult.none
        ? const ConnectivityDevice()
        : newMajInfos["newMajAvailable"] && !newMajInfosAlreadySeen
            ? const NewVersionApp()
            : const LogController();
  }
}
