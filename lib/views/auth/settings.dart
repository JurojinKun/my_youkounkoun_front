import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/providers/theme_app_provider.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends ConsumerState<Settings> {
  bool _isDarkTheme = false;

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
                ? Colors.black
                : Colors.white,
          ),
        ),
        title: Text(
            AppLocalization.of(context)
                .translate("settings_screen", "settings_user"),
            style: textStyleCustomBold(
                Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                23),
            textScaleFactor: 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              themeSettings(),
            ],
          ),
        ),
      ),
    );
  }

  Widget themeSettings() {
    return SizedBox(
      height: 50.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Theme",
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                  20),
              textScaleFactor: 1.0),
          Switch(
              activeColor: Colors.blue,
              value: _isDarkTheme,
              onChanged: (newTheme) async {
                SharedPreferences prefs = await SharedPreferences.getInstance();

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
              })
        ],
      ),
    );
  }
}
