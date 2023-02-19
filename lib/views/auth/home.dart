import 'dart:io';
import 'dart:ui';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/library/admob_lib.dart';
import 'package:myyoukounkoun/library/env_config_lib.dart';
import 'package:myyoukounkoun/library/notifications_lib.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
import 'package:myyoukounkoun/providers/home_provider.dart';
import 'package:myyoukounkoun/providers/token_notifications_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> with AutomaticKeepAliveClientMixin {
  AppBar appBar = AppBar();
  ConnectivityResult? connectivityStatus;

  String pushToken = "";

  bool loadedHome = false;
  bool pubHomeAlreadyLoaded = false;

  Future<void> initHome() async {
    await NotificationsLib.initPushToken(ref);

    if (Platform.isIOS) {
      await AdMobConfig.setAppTrackingTransparency();
    }

    setState(() {
      loadedHome = true;
    });
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
    connectivityStatus = ref.watch(connectivityStatusAppNotifierProvider);
    pushToken = ref.watch(tokenNotificationsNotifierProvider);
    pubHomeAlreadyLoaded = ref.watch(pubHomeAlreadyLoadedNotifierProvider);

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
                actions: [
                  if (!EnvironmentConfigLib().getEnvironmentBottomNavBar)
                    Material(
                        color: Colors.transparent,
                        shape: const CircleBorder(),
                        clipBehavior: Clip.hardEdge,
                        child: IconButton(
                            onPressed: () {
                              drawerScaffoldKey.currentState!.openEndDrawer();
                            },
                            icon: SizedBox(
                                height: 25.0,
                                width: 25.0,
                                child: Stack(
                                  alignment: AlignmentDirectional.center,
                                  children: [
                                    Icon(
                                      Icons.menu,
                                      color: Helpers.uiApp(context),
                                      size: 25,
                                    ),
                                    Positioned(
                                      top: 2,
                                      right: 0,
                                      child: Container(
                                        height: 10.0,
                                        width: 10.0,
                                        decoration: const BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle),
                                      ),
                                    )
                                  ],
                                ))))
                ],
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
                        connectivityStatus == ConnectivityResult.none &&
                                !pubHomeAlreadyLoaded
                            ? const SizedBox()
                            : pubWidget()
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
          constraints: const BoxConstraints(maxHeight: 110.0, maxWidth: 330.0),
          alignment: Alignment.center,
          child: const AdMobWidget(
            adSize: AdSize.largeBanner,
            colorIndicator: Colors.blue,
            screenPub: "home",
          )),
    );
  }
}
