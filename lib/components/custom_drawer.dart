import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class CustomDrawer extends ConsumerStatefulWidget {
  final TabController tabController;

  const CustomDrawer({Key? key, required this.tabController}) : super(key: key);

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends ConsumerState<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 6,
      child: Padding(
        padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        Image.asset(
                          "assets/images/ic_app.png",
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 10.0),
                        Text(
                          "Menu",
                          style:
                              textStyleCustomBold(Helpers.uiApp(context), 20),
                        )
                      ],
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.clear,
                          color: Helpers.uiApp(context),
                          size: 30,
                        )),
                  )
                ],
              ),
            ),
            Expanded(
                child: ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    if (!widget.tabController.indexIsChanging) {
                      if (widget.tabController.index == 0) {
                        navHomeKey!.currentState!
                            .popUntil((route) => route.isFirst);
                      } else {
                        setState(() {
                          widget.tabController.animateTo(0);
                        });
                      }
                    }
                  },
                  leading: Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 50,
                    child: Icon(
                      widget.tabController.index == 0
                          ? Icons.home
                          : Icons.home_outlined,
                      color: widget.tabController.index == 0 ? cBlue : cGrey,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    AppLocalization.of(context).translate("general", "home"),
                    style: textStyleCustomBold(
                        widget.tabController.index == 0 ? cBlue : cGrey, 18),
                  ),
                ),
                const SizedBox(height: 15.0),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    if (!widget.tabController.indexIsChanging) {
                      if (widget.tabController.index == 1) {
                        navSearchKey!.currentState!
                            .popUntil((route) => route.isFirst);
                      } else {
                        setState(() {
                          widget.tabController.animateTo(1);
                        });
                      }
                    }
                  },
                  leading: Container(
                    height: 30,
                    width: 50,
                    alignment: Alignment.center,
                    child: Icon(
                      widget.tabController.index == 1
                          ? Icons.search
                          : Icons.search_outlined,
                      color: widget.tabController.index == 1 ? cBlue : cGrey,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    AppLocalization.of(context).translate("general", "search"),
                    style: textStyleCustomBold(
                        widget.tabController.index == 1 ? cBlue : cGrey, 18),
                  ),
                ),
                const SizedBox(height: 15.0),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    if (!widget.tabController.indexIsChanging) {
                      if (widget.tabController.index == 2) {
                        navActivitiesKey!.currentState!
                            .popUntil((route) => route.isFirst);
                      } else {
                        setState(() {
                          widget.tabController.animateTo(2);
                        });
                      }
                    }
                  },
                  leading: Container(
                    height: 30,
                    width: 50,
                    alignment: Alignment.center,
                    child: Stack(children: [
                      Align(
                        alignment: Alignment.center,
                        child: Icon(
                          widget.tabController.index == 2
                              ? Icons.mail
                              : Icons.mail_outlined,
                          color:
                              widget.tabController.index == 2 ? cBlue : cGrey,
                          size: 30,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 10.0,
                          width: 10.0,
                          decoration: const BoxDecoration(
                              color: Colors.blue, shape: BoxShape.circle),
                        ),
                      )
                    ]),
                  ),
                  title: Text(
                    AppLocalization.of(context)
                        .translate("general", "activities"),
                    style: textStyleCustomBold(
                        widget.tabController.index == 2 ? cBlue : cGrey, 18),
                  ),
                ),
                const SizedBox(height: 15.0),
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    if (!widget.tabController.indexIsChanging) {
                      if (widget.tabController.index == 3) {
                        navProfileKey!.currentState!
                            .popUntil((route) => route.isFirst);
                      } else {
                        setState(() {
                          widget.tabController.animateTo(3);
                        });
                      }
                    }
                  },
                  leading: Container(
                    height: 30,
                    width: 50,
                    alignment: Alignment.center,
                    child: Icon(
                      widget.tabController.index == 3
                          ? Icons.person
                          : Icons.person_outlined,
                      color: widget.tabController.index == 3 ? cBlue : cGrey,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    AppLocalization.of(context).translate("general", "profile"),
                    style: textStyleCustomBold(
                        widget.tabController.index == 3 ? cBlue : cGrey, 18),
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}
