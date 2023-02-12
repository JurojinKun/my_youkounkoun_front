import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/providers/token_notifications_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> with AutomaticKeepAliveClientMixin {
  String pushToken = "";

  AppBar appBar = AppBar();

  bool loadedHome = false;

  Future<void> initHome() async {
    await initPushToken();

    setState(() {
      loadedHome = true;
    });
  }

  Future<void> initPushToken() async {
    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    //get push token device
    String pushToken = await FirebaseMessaging.instance.getToken() ?? "";
    if (kDebugMode) {
      print("push token: $pushToken");
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (pushToken != prefs.getString("pushToken") && pushToken != "") {
      DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String os;
      String? uuid;

      if (Platform.isIOS) {
        os = "apple";
        IosDeviceInfo deviceInfoIOS = await deviceInfoPlugin.iosInfo;
        uuid = deviceInfoIOS.identifierForVendor;
      } else {
        os = "android";
        AndroidDeviceInfo deviceInfoAndroid =
            await deviceInfoPlugin.androidInfo;
        uuid = deviceInfoAndroid.id;
      }

      try {
        Map<String, dynamic> map = {
          "uuid": uuid,
          "os": os,
          "appVersion": packageInfo.version,
          "pushToken": pushToken,
        };
        String token = prefs.getString("token") ?? "";
        if (token.trim() != "") {
          //logic ws send push token
          ref
              .read(tokenNotificationsNotifierProvider.notifier)
              .updateTokenNotif(pushToken);
          prefs.setString("pushToken", pushToken);
        }
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    } else {
      ref
          .read(tokenNotificationsNotifierProvider.notifier)
          .updateTokenNotif(pushToken);
    }
  }

  @override
  void initState() {
    super.initState();

    initHome();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    pushToken = ref.watch(tokenNotificationsNotifierProvider);

    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: PreferredSize(
          preferredSize: Size(
              MediaQuery.of(context).size.width, appBar.preferredSize.height),
          child: ClipRect(
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
                title: Text(
                    AppLocalization.of(context)
                        .translate("home_screen", "home"),
                    style: textStyleCustomBold(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        20),
                    textScaleFactor: 1.0),
                centerTitle: false,
              ),
            ),
          ),
        ),
        body: SizedBox.expand(
          child: loadedHome
              ? SingleChildScrollView(
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
                      Text(
                          AppLocalization.of(context)
                              .translate("home_screen", "push_token"),
                          style: textStyleCustomMedium(
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                              14),
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0),
                      const SizedBox(
                        height: 15.0,
                      ),
                      pushToken.trim() != ""
                          ? SelectableText(
                              pushToken,
                              style: textStyleCustomMedium(
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? cBlack
                                      : cWhite,
                                  14),
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              AppLocalization.of(context)
                                  .translate("home_screen", "no_token"),
                              style: textStyleCustomMedium(
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? cBlack
                                      : cWhite,
                                  14),
                              textAlign: TextAlign.center,
                              textScaleFactor: 1.0),
                    ],
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(
                    color: cBlue,
                    strokeWidth: 1.5,
                  ),
                ),
        ));
  }
}
