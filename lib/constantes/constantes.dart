import 'package:flutter/material.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';

//route names for generated routes non auth
const String welcome = "welcome";
const String login = "login";
const String register = "register";
const String forgotPassword = "forgotPassword";

//route names for generated routes auth
const String bottomNav = "bottomNav";
const String home = "home";
const String search = "search";
const String activities = "activities";
const String profile = "profile";
const String settingsUser = "settingsUser";
const String validateUser = "validateUser";
const String editAccount = "editAccount";
const String editSecurity = "editSecurity";
const String newConversation = "newConversation";
const String recentSearches = "recentSearches";
const String userProfile = "userProfile";
const String chatDetails = "chatDetails";
const String infosApp = "infosApp";
const String dataTest = "dataTest";
const String carousselPictures = "carousselPictures";
const String informationsConv = "informationsConv";

//route observer
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

//scaffold messenger key & animation controller snack bar connectivity
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
late AnimationController animationSnackBarController;

//navigator keys
final GlobalKey<NavigatorState> navNonAuthKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navAuthKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState>? navHomeKey;
GlobalKey<NavigatorState>? navSearchKey;
GlobalKey<NavigatorState>? navActivitiesKey;
GlobalKey<NavigatorState>? navProfileKey;

//scaffold key drawer
//scaffold key
final GlobalKey<ScaffoldState> drawerScaffoldKey = GlobalKey<ScaffoldState>();

//tab controller app
TabController? tabControllerBottomNav;
TabController? tabControllerActivities;

//fonts app
textStyleCustomBold(Color color, double fontSize,
    [TextDecoration? decoration]) {
  return TextStyle(
      fontFamily: 'RobotoBold',
      fontSize: fontSize,
      color: color,
      decoration: decoration);
}

textStyleCustomMedium(Color color, double fontSize,
    [TextDecoration? decoration]) {
  return TextStyle(
      fontFamily: 'RobotoMedium',
      fontSize: fontSize,
      color: color,
      decoration: decoration);
}

textStyleCustomRegular(Color color, double fontSize,
    [TextDecoration? decoration]) {
  return TextStyle(
      fontFamily: 'RobotoRegular',
      fontSize: fontSize,
      color: color,
      decoration: decoration);
}

//colors app
const Color cBlue = Color(0xFF00A9BC);
const Color cRed = Colors.red;
const Color cWhite = Color(0xFFFEFFFF);
const Color cBlack = Color(0xFF030303);
const Color cGrey = Colors.grey;
MaterialColor materialColorBlue =
    MaterialColor(0xFF00A9BC, Helpers.getSwatch(const Color(0xFF00A9BC)));
LinearGradient defaultGradientMessagesChat =
    const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0XFF4284C4), Color(0xFF00A9BC)]);

//theme data app (light/dark theme)
ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0XFFF3FAFA),
    primarySwatch: materialColorBlue,
    canvasColor: const Color(0xFFD8DEDE));

ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0XFF151515),
    primarySwatch: materialColorBlue,
    canvasColor: const Color(0xFF313232));
