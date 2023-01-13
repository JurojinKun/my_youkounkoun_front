import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

final currentRouteAppNotifierProvider =
    StateNotifierProvider<CurrentRouteAppProvider, String>(
        (ref) => CurrentRouteAppProvider());

class CurrentRouteAppProvider extends StateNotifier<String> {
  CurrentRouteAppProvider() : super("");

  void setCurrentRouteApp(
      String newState, BuildContext context, WidgetRef ref) {
    state = newState;

    if (ref.read(connectivityStatusAppNotifierProvider) ==
        ConnectivityResult.none) {
      scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
      scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
        backgroundColor: cRed,
        elevation: 6,
        margin: EdgeInsets.fromLTRB(
            10.0, 0.0, 10.0, Helpers.paddingSnackBarSwitchScreen(state)),
        content: Row(
          children: [
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0)
                  .animate(animationSnackBarController),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 365),
        dismissDirection: DismissDirection.none,
      ));
    }
  }
}
