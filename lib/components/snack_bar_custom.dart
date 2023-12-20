import 'package:flutter/material.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

SnackBar showSnackBarCustom(BuildContext context, String currentRouteApp) {
  return SnackBar(
        backgroundColor: cRed,
        elevation: 6,
        margin: EdgeInsets.fromLTRB(
            10.0, 0.0, 10.0, paddingSnackBarSwitchScreen(context, currentRouteApp)),
        content: Row(
          children: [
            RotationTransition(
              turns: Tween(begin: 0.0, end: 1.0)
                  .animate(animationSnackBarController),
              child: Image.asset("assets/images/ic_app_new.png",
                  height: 25, width: 25),
            ),
            const SizedBox(width: 10.0),
            Text(
                AppLocalization.of(context)
                    .translate("connectivity_screen", "no_connectivity"),
                style: textStyleCustomMedium(Helpers.uiApp(context), 14.0),
                textScaler: const TextScaler.linear(1.0)),
          ],
        ),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(days: 365),
        dismissDirection: DismissDirection.none,
      );
}

double paddingSnackBarSwitchScreen(BuildContext context, String currentRouteApp) {
    switch (currentRouteApp) {
      case bottomNav:
        return MediaQuery.of(context).padding.bottom + 80.0;
      default:
        return MediaQuery.of(context).padding.bottom + 10.0;
    }
  }