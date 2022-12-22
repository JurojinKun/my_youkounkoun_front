import "package:flutter/material.dart";

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/controllers/bottom_nav_controller.dart';
import 'package:myyoukounkoun/views/auth/chat_details.dart';
import 'package:myyoukounkoun/views/auth/new_conversation.dart';
import 'package:myyoukounkoun/views/auth/recent_searches.dart';
import 'package:myyoukounkoun/views/auth/search.dart';
import 'package:myyoukounkoun/views/auth/edit_account.dart';
import 'package:myyoukounkoun/views/auth/edit_security.dart';
import 'package:myyoukounkoun/views/auth/home.dart';
import 'package:myyoukounkoun/views/auth/settings.dart';
import 'package:myyoukounkoun/views/auth/activities.dart';
import 'package:myyoukounkoun/views/auth/profile.dart';
import 'package:myyoukounkoun/views/auth/user_profile.dart';
import 'package:myyoukounkoun/views/auth/validate_user.dart';
import 'package:myyoukounkoun/views/nonAuth/forgot_password.dart';
import 'package:myyoukounkoun/views/nonAuth/login.dart';
import 'package:myyoukounkoun/views/nonAuth/register.dart';
import 'package:myyoukounkoun/views/nonAuth/welcome.dart';

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
    case forgotPassword:
      return MaterialPageRoute(builder: (_) => const ForgotPassword());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text(
                  'No route defined for ${settings.name}',
                  textScaleFactor: 1.0,
                )),
              ));
  }
}

Route<dynamic> generateRouteAuth(RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case bottomNav:
      return MaterialPageRoute(builder: (_) => const BottomNavController());
    case validateUser:
      return MaterialPageRoute(builder: (_) => const ValidateUser());
    case editAccount:
      return MaterialPageRoute(builder: (_) => const EditAccount());
    case editSecurity:
      return MaterialPageRoute(builder: (_) => const EditSecurity());
    case newConversation:
      return MaterialPageRoute(builder: (_) => const NewConversation());
    case chatDetails: 
      return MaterialPageRoute(builder: (_) => ChatDetails(user: args![0], openWithModal: args[1],));
    case userProfile:
      return MaterialPageRoute(
          builder: (_) => UserProfile(user: args![0]));
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
                    child: Text('No route defined for ${settings.name}',
                        textScaleFactor: 1.0)),
              ));
  }
}

Route<dynamic> generateRouteAuthSearch(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case search:
      return MaterialPageRoute(builder: (_) => const Search());
    case recentSearches:
      return MaterialPageRoute(builder: (_) => const RecentSearches());
    case userProfile:
      return MaterialPageRoute(
          builder: (_) => UserProfile(user: args![0]));
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}',
                        textScaleFactor: 1.0)),
              ));
  }
}

Route<dynamic> generateRouteAuthActivities(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case activities:
      return MaterialPageRoute(builder: (_) => const Activities());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}',
                        textScaleFactor: 1.0)),
              ));
  }
}

Route<dynamic> generateRouteAuthProfile(
    RouteSettings settings, BuildContext context) {
  final List<dynamic>? args = settings.arguments as List<dynamic>?;

  switch (settings.name) {
    case profile:
      return MaterialPageRoute(builder: (_) => const Profile());
    case settingsUser:
      return MaterialPageRoute(builder: (_) => const Settings());
    default:
      return MaterialPageRoute(
          builder: (_) => Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: Center(
                    child: Text('No route defined for ${settings.name}',
                        textScaleFactor: 1.0)),
              ));
  }
}
