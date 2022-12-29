import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/providers/token_notifications_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> with AutomaticKeepAliveClientMixin {
  String tokenNotif = "";

  AppBar appBar = AppBar();

  late RefreshController refreshController;

  //logic pull to refresh
  Future<void> _refreshHome() async {
    await Future.delayed(const Duration(seconds: 2));
    refreshController.refreshCompleted();
    if (kDebugMode) {
      print("refresh home done");
    }
  }

  @override
  void initState() {
    super.initState();

    refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    tokenNotif = ref.watch(tokenNotificationsNotifierProvider);

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
          child: SmartRefresher(
            controller: refreshController,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            enablePullDown: true,
            header: WaterDropMaterialHeader(
              offset: MediaQuery.of(context).padding.top + appBar.preferredSize.height,
              distance: 40.0,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              color: cBlue,
            ),
            onRefresh: _refreshHome,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20.0, MediaQuery.of(context).padding.top + appBar.preferredSize.height + 20.0, 20.0, MediaQuery.of(context).padding.bottom + 90.0),
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
                  tokenNotif.trim() != ""
                      ? SelectableText(
                          tokenNotif,
                          style: textStyleCustomMedium(
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                              14),
                          textAlign: TextAlign.center,
                        )
                      : Text(
                          AppLocalization.of(context)
                              .translate("home_screen", "no_token"),
                          style: textStyleCustomMedium(
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                              14),
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0),
                ],
              ),
            ),
          ),
        ));
  }
}
