import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/providers/check_valid_user_provider.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
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
      ref.read(checkValidUserNotifierProvider.notifier).clearValidUser();
      ref.read(recentSearchesNotifierProvider.notifier).clearRecentSearches();
      ref
          .read(profilePictureAlreadyLoadedNotifierProvider.notifier)
          .clearProfilePicture();
      CachedNetworkImage.evictFromCache(
          ref.read(userNotifierProvider).profilePictureUrl);
      await DefaultCacheManager()
          .removeFile(ref.read(userNotifierProvider).profilePictureUrl);
      prefs.remove("token");
      ref.read(userNotifierProvider.notifier).clearUser();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _tryDeleteAccount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ref.read(checkValidUserNotifierProvider.notifier).clearValidUser();
      ref.read(recentSearchesNotifierProvider.notifier).clearRecentSearches();
      ref
          .read(profilePictureAlreadyLoadedNotifierProvider.notifier)
          .clearProfilePicture();
      CachedNetworkImage.evictFromCache(
          ref.read(userNotifierProvider).profilePictureUrl);
      await DefaultCacheManager()
          .removeFile(ref.read(userNotifierProvider).profilePictureUrl);
      prefs.remove("token");
      ref.read(userNotifierProvider.notifier).clearUser();
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
              style: textStyleCustomBold(Helpers.uiApp(context), 16),
            ),
            content: Text(
              AppLocalization.of(context)
                  .translate("settings_screen", "logout_content"),
              style: textStyleCustomRegular(Helpers.uiApp(context), 14),
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

  Future _showDialogDeleteAccount() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: Text(
              AppLocalization.of(context)
                  .translate("settings_screen", "delete_title"),
              style: textStyleCustomBold(Helpers.uiApp(context), 16),
            ),
            content: Text(
              AppLocalization.of(context)
                  .translate("settings_screen", "delete_content"),
              style: textStyleCustomRegular(Helpers.uiApp(context), 14),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _tryDeleteAccount();
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
              systemOverlayStyle: Helpers.uiOverlayApp(context),
              leading: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: IconButton(
                  onPressed: () => navProfileKey!.currentState!.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Helpers.uiApp(context),
                  ),
                ),
              ),
              title: Text(
                  AppLocalization.of(context)
                      .translate("settings_screen", "settings_user"),
                  style: textStyleCustomBold(Helpers.uiApp(context), 20),
                  textScaleFactor: 1.0),
              centerTitle: false,
              actions: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: IconButton(
                      onPressed: () => _showDialogLogout(),
                      icon: Icon(
                        Icons.logout,
                        color: Helpers.uiApp(context),
                      )),
                ),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: IconButton(
                      onPressed: () => _showDialogDeleteAccount(),
                      icon: Icon(
                        Icons.person_remove_outlined,
                        color: Helpers.uiApp(context),
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
              20.0,
              MediaQuery.of(context).padding.top +
                  appBar.preferredSize.height +
                  20.0,
              20.0,
              MediaQuery.of(context).padding.bottom + 90.0),
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              accountSettings(),
              const Divider(thickness: 1, color: cGrey),
              securitySettings(),
              const Divider(thickness: 1, color: cGrey),
              langueSettings(),
              const Divider(thickness: 1, color: cGrey),
              themeSettings(),
              const Divider(thickness: 1, color: cGrey),
              notificationsSettings(),
              const Divider(thickness: 1, color: cGrey),
              infosAppSettings()
            ],
          ),
        ),
      ),
    );
  }

  Widget accountSettings() {
    return InkWell(
      onTap: () => navAuthKey.currentState!.pushNamed(editAccount),
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.edit,
                    color: Helpers.uiApp(context),
                    size: 20,
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Text(
                        AppLocalization.of(context)
                            .translate("settings_screen", "my_account"),
                        style: textStyleCustomBold(Helpers.uiApp(context), 16),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0),
                  )
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Helpers.uiApp(context),
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
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.lock,
                    color: Helpers.uiApp(context),
                    size: 20,
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Text(
                        AppLocalization.of(context)
                            .translate("settings_screen", "security_account"),
                        style: textStyleCustomBold(Helpers.uiApp(context), 16),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0),
                  )
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Helpers.uiApp(context),
              size: 18,
            )
          ],
        ),
      ),
    );
  }

  Widget langueSettings() {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.language, color: Helpers.uiApp(context), size: 20),
                const SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: Text(
                      AppLocalization.of(context)
                          .translate("settings_screen", "language"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 16),
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 1.0),
                ),
              ],
            ),
          ),
          DropdownButton(
            style: textStyleCustomBold(Helpers.uiApp(context), 16),
            iconSize: 33,
            iconEnabledColor: Helpers.uiApp(context),
            underline: const SizedBox(),
            dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            items: [
              DropdownMenuItem(
                  alignment: Alignment.center,
                  value: const Locale('fr', ''),
                  child: Text(
                      AppLocalization.of(context)
                          .translate("settings_screen", "language_french"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 16),
                      textScaleFactor: 1.0)),
              DropdownMenuItem(
                  alignment: Alignment.center,
                  value: const Locale('en', ''),
                  child: Text(
                      AppLocalization.of(context)
                          .translate("settings_screen", "language_english"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 16),
                      textScaleFactor: 1.0))
            ],
            value: _localeLanguage,
            onChanged: dropdownCallback,
          )
        ],
      ),
    );
  }

  Widget themeSettings() {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.brightness_6,
                    color: Helpers.uiApp(context), size: 20),
                const SizedBox(
                  width: 15.0,
                ),
                Expanded(
                  child: Text(
                      AppLocalization.of(context)
                          .translate("settings_screen", "theme"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 16),
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 1.0),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.light_mode, color: Helpers.uiApp(context)),
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
              Icon(Icons.dark_mode, color: Helpers.uiApp(context)),
            ],
          )
        ],
      ),
    );
  }

  Widget notificationsSettings() {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(Icons.notifications,
                    color: Helpers.uiApp(context), size: 20),
                const SizedBox(
                  width: 15.0,
                ),
                Text(
                    AppLocalization.of(context)
                        .translate("settings_screen", "notifications"),
                    style: textStyleCustomBold(Helpers.uiApp(context), 16),
                    textScaleFactor: 1.0),
              ],
            ),
          ),
          Row(
            children: [
              Icon(Icons.notifications_off, color: Helpers.uiApp(context)),
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
              Icon(Icons.notifications_active, color: Helpers.uiApp(context)),
            ],
          )
        ],
      ),
    );
  }

  Widget infosAppSettings() {
    return InkWell(
      onTap: () => navAuthKey.currentState!.pushNamed(infosApp),
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.info,
                    color: Helpers.uiApp(context),
                    size: 20,
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Text(
                        AppLocalization.of(context)
                            .translate("settings_screen", "infos_app"),
                        style: textStyleCustomBold(Helpers.uiApp(context), 16),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0),
                  )
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Helpers.uiApp(context),
              size: 18,
            )
          ],
        ),
      ),
    );
  }
}
