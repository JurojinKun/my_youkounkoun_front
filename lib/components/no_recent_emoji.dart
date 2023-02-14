import 'package:flutter/material.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';

class NoRecentEmoji extends StatelessWidget {
  const NoRecentEmoji({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Pas d'emojis récents",
        textAlign: TextAlign.center,
        textScaleFactor: 1.0,
        style: textStyleCustomMedium(
            Helpers.uiApp(context),
            16),
      ),
    );
  }
}