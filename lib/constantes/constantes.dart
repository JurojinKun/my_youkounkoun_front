import 'package:flutter/material.dart';

//route names for generated routes non auth
const String welcome = "Welcome";
const String login = "Login";
const String register = "Register";

//route names for generated routes auth
const String bottomNav = "BottomNav";
const String home = "Home";
const String chat = "Chat";
const String notifications = "Notifications";
const String profile = "Profile";
const String settingsUser = "Settings user";

//navigator keys
final GlobalKey<NavigatorState> navNonAuthKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navAuthKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState>? navHomeKey;
GlobalKey<NavigatorState>? navChatKey;
GlobalKey<NavigatorState>? navNotificationsKey;
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
