import 'dart:io';
import 'dart:ui';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/library/admob_lib.dart';
import 'package:myyoukounkoun/library/env_config_lib.dart';
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

    if (Platform.isIOS) {
      final statusTransparency =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (statusTransparency == TrackingStatus.notDetermined) {
        await Future.delayed(const Duration(seconds: 1));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    }

    setState(() {
      loadedHome = true;
    });
  }

  Future<void> initPushToken() async {
    if (Platform.isIOS) {
      NotificationSettings settings =
          await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
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

          os = "apple";
          IosDeviceInfo deviceInfoIOS = await deviceInfoPlugin.iosInfo;
          uuid = deviceInfoIOS.identifierForVendor;

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
    } else {
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

        os = "android";
        AndroidDeviceInfo deviceInfoAndroid =
            await deviceInfoPlugin.androidInfo;
        uuid = deviceInfoAndroid.id;

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
                systemOverlayStyle: Helpers.uiOverlayApp(context),
                title: Text(
                    AppLocalization.of(context)
                        .translate("home_screen", "home"),
                    style: textStyleCustomBold(Helpers.uiApp(context), 20),
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
                          style:
                              textStyleCustomMedium(Helpers.uiApp(context), 14),
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
                      if (EnvironmentConfigLib().getEnvironmentAdmob)
                        pubWidget()
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

  Widget pubWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
      child: Container(
          color: Colors.transparent,
          constraints: const BoxConstraints(maxHeight: 100.0, maxWidth: 320.0),
          alignment: Alignment.center,
          child: const AdMobWidget(
              adSize: AdSize.largeBanner, colorIndicator: Colors.blue)),
    );
  }
}
