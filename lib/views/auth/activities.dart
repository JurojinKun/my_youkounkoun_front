import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/auth/chat.dart';
import 'package:myyoukounkoun/views/auth/new_conversation.dart';
import 'package:myyoukounkoun/views/auth/notifications.dart';

class Activities extends ConsumerStatefulWidget {
  const Activities({Key? key}) : super(key: key);

  @override
  ActivitiesState createState() => ActivitiesState();
}

class ActivitiesState extends ConsumerState<Activities>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  late TabController _tabController;

  AppBar appBar = AppBar();

  Future _newConversationBottomSheet(BuildContext context) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: false,
        builder: (context) {
          return const NewConversation();
        });
  }

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void deactivate() {
    _tabController.removeListener(() {
      setState(() {});
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              controller: _tabController,
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
                        .translate("activities_screen", "activities"),
                    style: textStyleCustomBold(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        20),
                    textScaleFactor: 1.0),
                centerTitle: false,
                actions: [
                  _tabController.index == 0
                      ? Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: IconButton(
                              onPressed: () => _newConversationBottomSheet(
                                  navAuthKey.currentContext!),
                              icon: Icon(Icons.edit_note,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? cBlack
                                      : cWhite,
                                  size: 33)),
                        )
                      : const SizedBox()
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50.0),
                  child: SizedBox(
                    height: 50.0,
                    child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.transparent,
                        labelColor:
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                        unselectedLabelColor: cGrey,
                        labelStyle: textStyleCustomBold(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            16),
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
                                    Icon(_tabController.index == 0
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
                                children: [
                                  Center(
                                    child: Icon(_tabController.index == 1
                                        ? Icons.notifications_active
                                        : Icons.notifications_active_outlined),
                                  ),
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
