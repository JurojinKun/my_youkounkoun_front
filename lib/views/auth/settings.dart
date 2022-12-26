import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/providers/check_valid_user_provider.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:myyoukounkoun/providers/notifications_active_provider.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:myyoukounkoun/providers/theme_app_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends ConsumerState<Settings> {
  bool _isDarkTheme = false;
  bool _notificationsActive = true;

  late Locale _localeLanguage;

  AppBar appBar = AppBar();

  void dropdownCallback(selectedValue) async {
    try {
      if (selectedValue is Locale) {
        await ref
            .read(localeLanguageNotifierProvider.notifier)
            .updateLocaleLanguage(selectedValue);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _tryLogOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ref.read(userNotifierProvider.notifier).clearUser();
      ref.read(checkValidUserNotifierProvider.notifier).clearValidUser();
      ref.read(recentSearchesNotifierProvider.notifier).clearRecentSearches();
      prefs.remove("token");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future _showDialogLogout() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              AppLocalization.of(context)
                  .translate("settings_screen", "logout_title"),
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  16),
            ),
            content: Text(
              AppLocalization.of(context)
                  .translate("settings_screen", "logout_content"),
              style: textStyleCustomRegular(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  14),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _tryLogOut();
                  },
                  child: Text(
                    AppLocalization.of(context)
                        .translate("general", "btn_confirm"),
                    style: textStyleCustomMedium(cBlue, 14),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalization.of(context)
                        .translate("general", "btn_cancel"),
                    style: textStyleCustomMedium(cRed, 14),
                  ))
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();

    if (ref.read(themeAppNotifierProvider).trim() == "") {
      var brightness = SchedulerBinding.instance.window.platformBrightness;
      if (brightness == Brightness.dark) {
        setState(() {
          _isDarkTheme = true;
        });
      } else {
        setState(() {
          _isDarkTheme = false;
        });
      }
    } else {
      if (ref.read(themeAppNotifierProvider) == "darkTheme") {
        setState(() {
          _isDarkTheme = true;
        });
      } else {
        setState(() {
          _isDarkTheme = false;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _localeLanguage = ref.watch(localeLanguageNotifierProvider);
    _notificationsActive = ref.watch(notificationsActiveNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size(
            MediaQuery.of(context).size.width, appBar.preferredSize.height),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              systemOverlayStyle:
                  Theme.of(context).brightness == Brightness.light
                      ? Platform.isIOS
                          ? SystemUiOverlayStyle.dark
                          : const SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent,
                              statusBarIconBrightness: Brightness.dark)
                      : Platform.isIOS
                          ? SystemUiOverlayStyle.light
                          : const SystemUiOverlayStyle(
                              statusBarColor: Colors.transparent,
                              statusBarIconBrightness: Brightness.light),
              leading: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: IconButton(
                  onPressed: () => navProfileKey!.currentState!.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                  ),
                ),
              ),
              title: Text(
                  AppLocalization.of(context)
                      .translate("settings_screen", "settings_user"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      20),
                  textScaleFactor: 1.0),
              actions: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: IconButton(
                      onPressed: () => _showDialogLogout(),
                      icon: Icon(
                        Icons.logout,
                        color: Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                      )),
                )
              ],
            ),
          ),
        ),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20.0, appBar.preferredSize.height + 30.0, 20.0, 80.0),
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              accountSettings(),
              const SizedBox(
                height: 15.0,
              ),
              securitySettings(),
              const SizedBox(height: 15.0),
              langueSettings(),
              const SizedBox(
                height: 15.0,
              ),
              themeSettings(),
              const SizedBox(height: 15.0),
              notificationsSettings()
            ],
          ),
        ),
      ),
    );
  }

  Widget accountSettings() {
    return InkWell(
      onTap: () => navAuthKey.currentState!.pushNamed(editAccount),
      child: Container(
        height: 60.0,
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: cGrey, width: 0.5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  size: 20,
                ),
                const SizedBox(width: 15.0),
                Text(
                    AppLocalization.of(context)
                        .translate("settings_screen", "my_account"),
                    style: textStyleCustomBold(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        16),
                    textScaleFactor: 1.0)
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).brightness == Brightness.light
                  ? cBlack
                  : cWhite,
              size: 18,
            )
          ],
        ),
      ),
    );
  }

  Widget securitySettings() {
    return InkWell(
      onTap: () => navAuthKey.currentState!.pushNamed(editSecurity),
      child: Container(
        height: 60.0,
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: cGrey, width: 0.5))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.lock,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  size: 20,
                ),
                const SizedBox(width: 15.0),
                Text(
                    AppLocalization.of(context)
                        .translate("settings_screen", "security_account"),
                    style: textStyleCustomBold(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        16),
                    textScaleFactor: 1.0)
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Theme.of(context).brightness == Brightness.light
                  ? cBlack
                  : cWhite,
              size: 18,
            )
          ],
        ),
      ),
    );
  }

  Widget langueSettings() {
    return Container(
      height: 60.0,
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(color: cGrey, width: 0.5),
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.language,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  size: 20),
              const SizedBox(
                width: 15.0,
              ),
              Text(AppLocalization.of(context).translate("settings_screen", "language"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      16),
                  textScaleFactor: 1.0),
            ],
          ),
          DropdownButton(
            style: textStyleCustomBold(Theme.of(context).brightness == Brightness.light ? cBlack : cWhite, 16),
            iconSize: 33,
            iconEnabledColor: Theme.of(context).brightness == Brightness.light ? cBlack : cWhite,
            underline: const SizedBox(),
            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            items: [
              DropdownMenuItem(
                alignment: Alignment.center,
                  value: const Locale('fr', ''), child: Text(AppLocalization.of(context).translate("settings_screen", "language_french"), style: textStyleCustomBold(Theme.of(context).brightness == Brightness.light ? cBlack : cWhite, 16), textScaleFactor: 1.0)),
              DropdownMenuItem(
                alignment: Alignment.center,
                value: const Locale('en', ''), child: Text(AppLocalization.of(context).translate("settings_screen", "language_english"), style: textStyleCustomBold(Theme.of(context).brightness == Brightness.light ? cBlack : cWhite, 16), textScaleFactor: 1.0))
            ],
            value: _localeLanguage,
            onChanged: dropdownCallback,
          )
        ],
      ),
    );
  }

  Widget themeSettings() {
    return Container(
      height: 60.0,
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(color: cGrey, width: 0.5),
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.brightness_6,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  size: 20),
              const SizedBox(
                width: 15.0,
              ),
              Text(
                  AppLocalization.of(context)
                      .translate("settings_screen", "theme"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      16),
                  textScaleFactor: 1.0),
            ],
          ),
          Row(
            children: [
              Icon(Icons.light_mode,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite),
              Switch(
                  activeColor: cBlue,
                  value: _isDarkTheme,
                  onChanged: (newTheme) async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    setState(() {
                      _isDarkTheme = newTheme;
                    });

                    if (newTheme) {
                      await prefs.setString("theme", "darkTheme");
                      ref
                          .read(themeAppNotifierProvider.notifier)
                          .setThemeApp("darkTheme");
                    } else {
                      await prefs.setString("theme", "lightTheme");
                      ref
                          .read(themeAppNotifierProvider.notifier)
                          .setThemeApp("lightTheme");
                    }
                  }),
              Icon(Icons.dark_mode,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite),
            ],
          )
        ],
      ),
    );
  }

  Widget notificationsSettings() {
    return Container(
      height: 60.0,
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(color: cGrey, width: 0.5),
      )),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.notifications,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  size: 20),
              const SizedBox(
                width: 15.0,
              ),
              Text(
                  AppLocalization.of(context)
                      .translate("settings_screen", "notifications"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      16),
                  textScaleFactor: 1.0),
            ],
          ),
          Row(
            children: [
              Icon(Icons.notifications_off,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite),
              Switch(
                  activeColor: cBlue,
                  value: _notificationsActive,
                  onChanged: (newSettingsNotifications) async {
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();

                    ref
                        .read(notificationsActiveNotifierProvider.notifier)
                        .updateNotificationsActive(newSettingsNotifications);

                    if (newSettingsNotifications) {
                      await prefs.setBool("notifications", true);
                    } else {
                      await prefs.setBool("notifications", false);
                    }
                  }),
              Icon(Icons.notifications_active,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite),
            ],
          )
        ],
      ),
    );
  }
}
