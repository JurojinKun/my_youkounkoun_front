import "package:flutter/material.dart";
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/controllers/bottom_nav_controller.dart';
import 'package:my_boilerplate/views/auth/home.dart';
import 'package:my_boilerplate/views/auth/modify_profile.dart';
import 'package:my_boilerplate/views/auth/notifications.dart';
import 'package:my_boilerplate/views/auth/profile.dart';

Route<dynamic> generateRouteAuth(RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case bottomNav:
      return MaterialPageRoute(builder: (_) => const BottomNavController());
    case home:
      return MaterialPageRoute(builder: (_) => const Home());
    case profile:
      return MaterialPageRoute(builder: (_) => const Profile());
    case modifyProfile:
      return MaterialPageRoute(builder: (_) => const ModifyProfile());
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
