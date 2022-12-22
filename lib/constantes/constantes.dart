import 'package:flutter/material.dart';

//route names for generated routes non auth
const String welcome = "Welcome";
const String login = "Login";
const String register = "Register";
const String forgotPassword = "Forgot password";

//route names for generated routes auth
const String bottomNav = "BottomNav";
const String home = "Home";
const String search = "Search";
const String activities = "Activities";
const String profile = "Profile";
const String settingsUser = "Settings user";
const String validateUser = "Validate user";
const String editAccount = "Edit account";
const String editSecurity = "Edit security";
const String newConversation = "New conversation";
const String recentSearches = "Recent searches";
const String userProfile = "User profile";
const String chatDetails = "Chat details";

//navigator keys
final GlobalKey<NavigatorState> navNonAuthKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navAuthKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState>? navHomeKey;
GlobalKey<NavigatorState>? navSearchKey;
GlobalKey<NavigatorState>? navActivitiesKey;
GlobalKey<NavigatorState>? navProfileKey;

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
const Color cBlue = Colors.blue;
const Color cRed = Colors.red;
const Color cWhite = Color(0xFFFEFFFF);
const Color cBlack = Color(0xFF030303);
const Color cGrey = Colors.grey;

//theme data app (light/dark theme)
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0XFFF3FAFA),
  primarySwatch: Colors.blue,
  canvasColor: const Color(0xFFFCFFFF)
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0XFF151515),
  primarySwatch: Colors.blue,
  canvasColor: const Color(0xFF060606)
);
