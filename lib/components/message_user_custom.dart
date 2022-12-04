import 'package:flutter/material.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void messageUser(BuildContext context, String message) {
  return showTopSnackBar(
      Overlay.of(context)!,
      Container(
        decoration: BoxDecoration(
          color: cBlue,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 35.0,
            horizontal: 55.0),
          child: Material(
            color: Colors.transparent,
            child: Text(message, style: TextStyle(
              fontFamily: "RobotoBold",
              fontSize: 16,
              color: Theme.of(context).brightness == Brightness.light ? cWhite : cBlack), textAlign: TextAlign.center, textScaleFactor: 1.0),),
        ),
      ),
      animationDuration: const Duration(milliseconds: 500),
      reverseAnimationDuration: const Duration(milliseconds: 500),
      displayDuration: const Duration(seconds: 4));
}