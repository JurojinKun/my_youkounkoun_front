import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/libraries/env_config_lib.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/auth/chat.dart';
import 'package:myyoukounkoun/views/auth/notifications.dart';

class Activities extends ConsumerStatefulWidget {
  const Activities({Key? key}) : super(key: key);

  @override
  ActivitiesState createState() => ActivitiesState();
}

class ActivitiesState extends ConsumerState<Activities>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  AppBar appBar = AppBar();

  @override
  void initState() {
    super.initState();

    tabControllerActivities ??=
        TabController(length: 2, initialIndex: 0, vsync: this);
    tabControllerActivities!.addListener(() {
      setState(() {});
    });
  }

  @override
  void deactivate() {
    tabControllerActivities!.removeListener(() {
      setState(() {});
    });
    super.deactivate();
  }

  @override
  void dispose() {
    tabControllerActivities!.dispose();
    tabControllerActivities = null;
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _customAppBarActivities(),
        body: SizedBox.expand(
          child: TabBarView(
              controller: tabControllerActivities,
              physics: const NeverScrollableScrollPhysics(),
              children: const [Chat(), Notifications()]),
        ));
  }

  PreferredSizeWidget _customAppBarActivities() {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width,
          appBar.preferredSize.height + 50.0),
      child: ClipRRect(
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
                        .translate("activities_screen", "activities"),
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
                                            color: cBlue,
                                            shape: BoxShape.circle),
                                      ),
                                    )
                                  ],
                                ))))
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50.0),
                  child: Container(
                    height: 50.0,
                    decoration: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: cGrey, width: 0.2)),
                    ),
                    child: TabBar(
                        controller: tabControllerActivities,
                        indicatorColor: Colors.transparent,
                        labelColor: Helpers.uiApp(context),
                        unselectedLabelColor: cGrey,
                        labelStyle:
                            textStyleCustomBold(Helpers.uiApp(context), 16),
                        unselectedLabelStyle: textStyleCustomBold(cGrey, 16),
                        indicator: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(color: cBlue, width: 2.0))),
                        tabs: [
                          SizedBox.expand(
                              child: Stack(
                            children: [
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(tabControllerActivities!.index == 0
                                        ? Icons.send
                                        : Icons.send_outlined),
                                    const SizedBox(
                                      width: 5.0,
                                    ),
                                    Text(
                                      AppLocalization.of(context).translate(
                                          "activities_screen", "chat"),
                                    )
                                  ],
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 0,
                                child: Container(
                                  height: 10.0,
                                  width: 10.0,
                                  decoration: const BoxDecoration(
                                    color: cBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            ],
                          )),
                          SizedBox.expand(
                              child: Stack(
                            children: [
                              Center(
                                  child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(tabControllerActivities!.index == 1
                                      ? Icons.notifications_active
                                      : Icons.notifications_active_outlined),
                                  const SizedBox(
                                    width: 5.0,
                                  ),
                                  Text(AppLocalization.of(context).translate(
                                      "activities_screen", "notifications"))
                                ],
                              )),
                              Positioned(
                                top: 10.0,
                                right: 0,
                                child: Container(
                                  height: 10.0,
                                  width: 10.0,
                                  decoration: const BoxDecoration(
                                    color: cBlue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            ],
                          ))
                        ]),
                  ),
                ),
              ))),
    );
  }
}
