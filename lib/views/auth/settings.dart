import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/providers/theme_app_provider.dart';
import 'package:my_boilerplate/providers/user_provider.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends ConsumerState<Settings> {
  bool _isDarkTheme = false;

  Future<void> _tryLogOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ref.read(userNotifierProvider.notifier).clearUser();
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
                    style: textStyleCustomMedium(Colors.red, 14),
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => navProfileKey!.currentState!.pop(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).brightness == Brightness.light
                ? cBlack
                : cWhite,
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
          IconButton(
              onPressed: () => _showDialogLogout(),
              icon: Icon(
                Icons.logout,
                color: Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite,
              ))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Column(
              children: [
                accountSettings(),
                const SizedBox(height: 15.0),
                themeSettings(),
              ],
            ),
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
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5))),
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
                  size: 23,
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

  Widget themeSettings() {
    return Container(
      height: 60.0,
      decoration: const BoxDecoration(
          border: Border(
        bottom: BorderSide(color: Colors.grey, width: 0.5),
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
}
