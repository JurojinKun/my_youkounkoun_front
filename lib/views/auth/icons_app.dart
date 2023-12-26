import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_android_dynamic_icon/android_dynamic_icon.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dynamic_icon/flutter_dynamic_icon.dart';
import 'package:myyoukounkoun/components/message_user_custom.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/libraries/sync_shared_prefs_lib.dart';
import 'package:myyoukounkoun/models/icons_app_model.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class IconsApp extends ConsumerStatefulWidget {
  const IconsApp({super.key});

  @override
  IconsAppState createState() => IconsAppState();
}

class IconsAppState extends ConsumerState<IconsApp> {
  AppBar appBar = AppBar();

  final _androidDynamicIconPlugin = AndroidDynamicIcon();

  List<IconsAppModel> icons = [
    IconsAppModel(asset: "assets/icons_app/ic_default.png", name: "Default"),
    IconsAppModel(
        asset: "assets/icons_app/ic_just_black.png", name: "Just black"),
    IconsAppModel(
        asset: "assets/icons_app/ic_just_blue.png", name: "Just blue"),
    IconsAppModel(asset: "assets/icons_app/ic_space.png", name: "Space"),
  ];

  String choiceIcon =
      SyncSharedPrefsLib().prefs!.getString("iconApp") ?? "Default";

  bool validModif = false;

  Future<void> changeDynamicallyIconApp(String iconName) async {
    try {
      switch (iconName) {
        case "Default":
          if (Platform.isAndroid) {
            await _androidDynamicIconPlugin.changeIcon(
                bundleId: "com.example.myyoukounkoun",
                isNewIcon: false,
                iconName: "",
                iconNames: ["JustBlack", "JustBlue", "Space"]);
          } else if (Platform.isIOS &&
              await FlutterDynamicIcon.supportsAlternateIcons) {
            await FlutterDynamicIcon.setAlternateIconName(null);
          }
          break;
        case "Just black":
          if (Platform.isAndroid) {
            await _androidDynamicIconPlugin.changeIcon(
                bundleId: "com.example.myyoukounkoun",
                isNewIcon: true,
                iconName: "JustBlack",
                iconNames: ["JustBlack", "JustBlue", "Space"]);
          } else if (Platform.isIOS &&
              await FlutterDynamicIcon.supportsAlternateIcons) {
            await FlutterDynamicIcon.setAlternateIconName("justBlack");
          }
          break;
        case "Just blue":
          if (Platform.isAndroid) {
            await _androidDynamicIconPlugin.changeIcon(
                bundleId: "com.example.myyoukounkoun",
                isNewIcon: true,
                iconName: "JustBlue",
                iconNames: ["JustBlack", "JustBlue", "Space"]);
          } else if (Platform.isIOS &&
              await FlutterDynamicIcon.supportsAlternateIcons) {
            await FlutterDynamicIcon.setAlternateIconName("justBlue");
          }
          break;
        case "Space":
          if (Platform.isAndroid) {
            await _androidDynamicIconPlugin.changeIcon(
                bundleId: "com.example.myyoukounkoun",
                isNewIcon: true,
                iconName: "Space",
                iconNames: ["JustBlack", "JustBlue", "Space"]);
          } else if (Platform.isIOS &&
              await FlutterDynamicIcon.supportsAlternateIcons) {
            await FlutterDynamicIcon.setAlternateIconName("space");
          }
          break;
        default:
          if (Platform.isAndroid) {
            await _androidDynamicIconPlugin.changeIcon(
                bundleId: "com.example.myyoukounkoun",
                isNewIcon: false,
                iconName: "",
                iconNames: ["JustBlack", "JustBlue", "Space"]);
          } else if (Platform.isIOS &&
              await FlutterDynamicIcon.supportsAlternateIcons) {
            await FlutterDynamicIcon.setAlternateIconName(null);
          }
      }
      await SyncSharedPrefsLib().prefs!.setString('iconApp', choiceIcon);
      if (mounted) {
        messageUser(
            context,
            AppLocalization.of(context)
                .translate("icons_app_screen", "success_message"));
      }
    } catch (e) {
      if (mounted) {
        messageUser(context,
            AppLocalization.of(context).translate("general", "message_error"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                systemOverlayStyle: Helpers.uiOverlayApp(context),
                leading: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: IconButton(
                      onPressed: () => navAuthKey.currentState!.pop(),
                      icon: Icon(Icons.arrow_back_ios,
                          color: Helpers.uiApp(context))),
                ),
                centerTitle: false,
                title: Text(
                    AppLocalization.of(context)
                        .translate("icons_app_screen", "title_screen"),
                    style: textStyleCustomBold(Helpers.uiApp(context), 20),
                    textScaler: const TextScaler.linear(1.0)),
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            SizedBox.expand(
                child: ListView.builder(
              padding: EdgeInsets.fromLTRB(
                  20.0,
                  MediaQuery.of(context).padding.top +
                      appBar.preferredSize.height +
                      20.0,
                  20.0,
                  MediaQuery.of(context).padding.bottom + 20.0),
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              itemCount: icons.length,
              itemBuilder: (context, index) {
                IconsAppModel icon = icons[index];
                return _iconItem(icon);
              },
            )),
            if ((SyncSharedPrefsLib().prefs!.getString("iconApp") != null &&
                    choiceIcon !=
                        SyncSharedPrefsLib().prefs!.getString("iconApp")) ||
                (SyncSharedPrefsLib().prefs!.getString("iconApp") == null &&
                    choiceIcon != "Default"))
              _saveNewIconApp()
          ],
        ));
  }

  Widget _iconItem(IconsAppModel icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        onTap: () async {
          setState(() {
            choiceIcon = icon.name;
          });
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.asset(
            icon.asset,
            height: 65,
            width: 65,
          ),
        ),
        title: Text(
          icon.name,
          style: textStyleCustomMedium(Helpers.uiApp(context), 16),
          textScaler: const TextScaler.linear(1.0),
        ),
        trailing: Radio(
            activeColor: cBlue,
            toggleable: true,
            value: icon.name,
            groupValue: choiceIcon,
            onChanged: (String? value) {
              setState(() {
                choiceIcon = icon.name;
              });
            }),
      ),
    );
  }

  Widget _saveNewIconApp() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 100.0,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (!validModif) {
                            setState(() {
                              validModif = true;
                            });
                            await changeDynamicallyIconApp(choiceIcon);
                            setState(() {
                              validModif = false;
                            });
                          }
                        },
                        child: validModif
                            ? const SizedBox(
                                height: 15.0,
                                width: 15.0,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: cWhite,
                                    strokeWidth: 1.0,
                                  ),
                                ),
                              )
                            : Text(
                                AppLocalization.of(context).translate(
                                    "icons_app_screen", "save_new_icon_app"),
                                style: textStyleCustomMedium(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    20),
                                textAlign: TextAlign.center,
                                textScaler: const TextScaler.linear(1.0)))),
              ),
              const SizedBox(width: 15.0),
              Expanded(
                child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: cRed,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          setState(() {
                            choiceIcon = SyncSharedPrefsLib()
                                    .prefs!
                                    .getString("iconApp") ??
                                "Default";
                          });
                        },
                        child: Text(
                            AppLocalization.of(context)
                                .translate("general", "btn_cancel"),
                            style: textStyleCustomMedium(
                                Helpers.uiApp(context), 20),
                            textScaler: const TextScaler.linear(1.0)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
