import "package:flutter/material.dart";
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/views/home.dart';
import 'package:my_boilerplate/views/notifications.dart';

Route<dynamic> generateRouteAuth(RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case home:
      return MaterialPageRoute(builder: (_) => const Home());
    case notifications:
      return MaterialPageRoute(builder: (_) => const Notifications());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}
