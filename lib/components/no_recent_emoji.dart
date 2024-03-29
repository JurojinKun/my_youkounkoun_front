import 'package:flutter/material.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';

class NoRecentEmoji extends StatelessWidget {
  const NoRecentEmoji({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        "Pas d'emojis récents",
        textAlign: TextAlign.center,
        textScaler: const TextScaler.linear(1.0),
        style: textStyleCustomMedium(
            Helpers.uiApp(context),
            16),
      ),
    );
  }
}