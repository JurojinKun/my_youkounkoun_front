import "package:flutter/material.dart";

import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/controllers/bottom_nav_controller.dart';
import 'package:my_boilerplate/views/auth/chat.dart';
import 'package:my_boilerplate/views/auth/home.dart';
import 'package:my_boilerplate/views/auth/modify_profile.dart';
import 'package:my_boilerplate/views/auth/notifications.dart';
import 'package:my_boilerplate/views/auth/profile.dart';
import 'package:my_boilerplate/views/nonAuth/login.dart';
import 'package:my_boilerplate/views/nonAuth/register.dart';
import 'package:my_boilerplate/views/nonAuth/welcome.dart';

Route<dynamic> generateRouteNonAuth(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case welcome:
      return MaterialPageRoute(builder: (_) => const Welcome());
    case login:
      return MaterialPageRoute(builder: (_) => const Login());
    case register:
      return MaterialPageRoute(builder: (_) => const Register());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

Route<dynamic> generateRouteAuth(RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case bottomNav:
      return MaterialPageRoute(builder: (_) => const BottomNavController());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

Route<dynamic> generateRouteAuthHome(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case home:
      return MaterialPageRoute(builder: (_) => const Home());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

Route<dynamic> generateRouteAuthChat(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case chat:
      return MaterialPageRoute(builder: (_) => const Chat());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}

Route<dynamic> generateRouteAuthNotifications(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
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

Route<dynamic> generateRouteAuthProfile(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case profile:
      return MaterialPageRoute(builder: (_) => const Profile());
    case modifyProfile:
      return MaterialPageRoute(builder: (_) => const ModifyProfile());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}')),
              ));
  }
}
