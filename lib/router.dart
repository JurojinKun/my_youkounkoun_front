import "package:flutter/material.dart";
import 'package:myyoukounkoun/components/picture_fullscreen.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/controllers/bottom_nav_controller.dart';
import 'package:myyoukounkoun/route_observer.dart';
import 'package:myyoukounkoun/views/auth/chat_details.dart';
import 'package:myyoukounkoun/views/auth/datas_test.dart';
import 'package:myyoukounkoun/views/auth/infos_app.dart';
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
      return MaterialPageRoute(
          builder: (_) =>
              const RouteAwareWidget(name: welcome, child: Welcome()));
    case login:
      return MaterialPageRoute(
          builder: (_) => const RouteAwareWidget(name: login, child: Login()));
    case register:
      return MaterialPageRoute(
          builder: (_) =>
              const RouteAwareWidget(name: register, child: Register()));
    case forgotPassword:
      return MaterialPageRoute(
          builder: (_) => const RouteAwareWidget(
              name: forgotPassword, child: ForgotPassword()));
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
      return MaterialPageRoute(
          builder: (_) => const RouteAwareWidget(
              name: bottomNav, child: BottomNavController()));
    case validateUser:
      return MaterialPageRoute(
          builder: (_) => const RouteAwareWidget(
              name: validateUser, child: ValidateUser()));
    case editAccount:
      return MaterialPageRoute(
          builder: (_) =>
              const RouteAwareWidget(name: editAccount, child: EditAccount()));
    case editSecurity:
      return MaterialPageRoute(
          builder: (_) => const RouteAwareWidget(
              name: editSecurity, child: EditSecurity()));
    case newConversation:
      return MaterialPageRoute(
          builder: (_) => const RouteAwareWidget(
              name: newConversation, child: NewConversation()));
    case chatDetails:
      return MaterialPageRoute(
          builder: (_) => RouteAwareWidget(
              name: chatDetails,
              child: ChatDetails(
                user: args![0],
                openWithModal: args[1],
              )));
    case infosApp:
      return MaterialPageRoute(
          builder: (_) =>
              const RouteAwareWidget(name: infosApp, child: InfosApp()));
    case userProfile:
      return MaterialPageRoute(
          builder: (_) => RouteAwareWidget(
              name: userProfile,
              child: UserProfile(
                user: args![0],
                bottomNav: args[1],
              )));
    case dataTest:
      return MaterialPageRoute(
          builder: (_) => RouteAwareWidget(
              name: dataTest, child: DatasTest(index: args![0])));
    case pictureFullscreen:
      return MaterialPageRoute(
          builder: (_) => RouteAwareWidget(
              name: pictureFullscreen,
              child: PictureFullscreen(imageUrl: args![0])));
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
          builder: (_) => UserProfile(
                user: args![0],
                bottomNav: args[1],
              ));
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
      return MaterialPageRoute(
        builder: (_) => const Activities(),
      );
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
