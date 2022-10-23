import 'package:flutter/material.dart';

//route names for generated routes non auth
const String welcome = "Welcome";

//route names for generated routes auth
const String bottomNav = "BottomNav";
const String home = "Home";
const String profile = "Profile";
const String modifyProfile = "Modify profile";
const String notifications = "Notifications";

//navigator keys
final GlobalKey<NavigatorState> navNonAuthKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> navAuthKey = GlobalKey<NavigatorState>();
GlobalKey<NavigatorState>? navHomeKey;
GlobalKey<NavigatorState>? navProfileKey;
GlobalKey<NavigatorState>? navNotificationsKey;
