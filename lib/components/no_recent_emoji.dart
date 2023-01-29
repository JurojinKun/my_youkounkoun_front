import 'package:flutter/material.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';

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
            Theme.of(context).brightness == Brightness.light ? cBlack : cWhite,
            16),
      ),
    );
  }
}