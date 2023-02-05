import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class InfosApp extends ConsumerStatefulWidget {
  const InfosApp({Key? key}) : super(key: key);

  @override
  InfosAppState createState() => InfosAppState();
}

class InfosAppState extends ConsumerState<InfosApp> {
  AppBar appBar = AppBar();

  String version = "";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        version = packageInfo.version;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
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
                        onPressed: () => navAuthKey.currentState!.pop(),
                        icon: Icon(Icons.arrow_back_ios,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite)),
                  ),
                  title: Text(
                      AppLocalization.of(context)
                          .translate("infos_app_screen", "title"),
                      style: textStyleCustomBold(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          20),
                      textScaleFactor: 1.0),
                  centerTitle: false,
                )),
          )),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20.0,
              MediaQuery.of(context).padding.top +
                  appBar.preferredSize.height +
                  20.0,
              20.0,
              MediaQuery.of(context).padding.bottom + 20.0),
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              cguApp(),
              const Divider(thickness: 1, color: cGrey),
              policyPrivacyApp(),
              const Divider(thickness: 1, color: cGrey),
              versionApp()
            ],
          ),
        ),
      ),
    );
  }

  Widget cguApp() {
    return InkWell(
      onTap: () {
        //change url google to url cgu
        Helpers.launchMyUrl("https://www.google.fr/");
      },
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    size: 20,
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Text(
                        AppLocalization.of(context)
                            .translate("infos_app_screen", "cgu"),
                        style: textStyleCustomBold(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            16),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0),
                  )
                ],
              ),
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

  Widget policyPrivacyApp() {
    return InkWell(
      onTap: () {
        //change url google to url cgu
        Helpers.launchMyUrl("https://www.google.fr/");
      },
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.gavel,
                    color: Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    size: 20,
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Text(
                        AppLocalization.of(context)
                            .translate("infos_app_screen", "policy_privacy"),
                        style: textStyleCustomBold(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            16),
                        overflow: TextOverflow.ellipsis,
                        textScaleFactor: 1.0),
                  )
                ],
              ),
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

  Widget versionApp() {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.smartphone,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  size: 20,
                ),
                const SizedBox(width: 15.0),
                Expanded(
                  child: Text(
                      AppLocalization.of(context)
                          .translate("infos_app_screen", "version"),
                      style: textStyleCustomBold(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          16),
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 1.0),
                )
              ],
            ),
          ),
          Text(version,
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  16),
              textScaleFactor: 1.0)
        ],
      ),
    );
  }
}
