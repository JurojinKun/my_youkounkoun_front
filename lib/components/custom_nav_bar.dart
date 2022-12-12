import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';

class CustomNavBar extends ConsumerStatefulWidget {
  final TabController tabController;

  const CustomNavBar({Key? key, required this.tabController}) : super(key: key);

  @override
  CustomNavBarState createState() => CustomNavBarState();
}

class CustomNavBarState extends ConsumerState<CustomNavBar> {
  @override
  Widget build(BuildContext context) {
    return ColorfulSafeArea(
        top: false,
        left: false,
        right: false,
        bottom: true,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 70,
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15.0),
                    topRight: Radius.circular(15.0)),
                boxShadow: [
                  BoxShadow(
                    color: cBlue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0.0, -10.0),
                  )
                ]),
            child: Row(
              children: [
                Expanded(
                    child: InkWell(
                  onTap: () {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.tabController.index == 0
                            ? Icons.home
                            : Icons.home_outlined,
                        size: 30,
                        color: widget.tabController.index == 0
                            ? cBlue
                            : cGrey,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                          AppLocalization.of(context)
                              .translate("general", "home"),
                          style: textStyleCustomRegular(
                              widget.tabController.index == 0
                                  ? cBlue
                                  : cGrey,
                              12),
                          textScaleFactor: 1.0)
                    ],
                  ),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.tabController.index == 1
                            ? Icons.search
                            : Icons.search_outlined,
                        size: 30,
                        color: widget.tabController.index == 1
                            ? cBlue
                            : cGrey,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                          AppLocalization.of(context)
                              .translate("general", "search"),
                          style: textStyleCustomRegular(
                              widget.tabController.index == 1
                                  ? cBlue
                                  : cGrey,
                              12),
                          textScaleFactor: 1.0)
                    ],
                  ),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.tabController.index == 2
                            ? Icons.mail
                            : Icons.mail_outlined,
                        size: 30,
                        color: widget.tabController.index == 2
                            ? cBlue
                            : cGrey,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                          AppLocalization.of(context)
                              .translate("general", "activities"),
                          style: textStyleCustomRegular(
                              widget.tabController.index == 2
                                  ? cBlue
                                  : cGrey,
                              12),
                          textScaleFactor: 1.0)
                    ],
                  ),
                )),
                Expanded(
                    child: InkWell(
                  onTap: () {
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.tabController.index == 3
                            ? Icons.person
                            : Icons.person_outlined,
                        size: 30,
                        color: widget.tabController.index == 3
                            ? cBlue
                            : cGrey,
                      ),
                      const SizedBox(
                        height: 5.0,
                      ),
                      Text(
                          AppLocalization.of(context)
                              .translate("general", "profile"),
                          style: textStyleCustomRegular(
                              widget.tabController.index == 3
                                  ? cBlue
                                  : cGrey,
                              12),
                          textScaleFactor: 1.0)
                    ],
                  ),
                )),
              ],
            ),
          ),
        ));
  }
}
