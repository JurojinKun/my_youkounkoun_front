import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class Notifications extends ConsumerStatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  NotificationsState createState() => NotificationsState();
}

class NotificationsState extends ConsumerState<Notifications>
    with AutomaticKeepAliveClientMixin {
  AppBar appBar = AppBar();

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          10.0, MediaQuery.of(context).padding.top + appBar.preferredSize.height + 20.0, 10.0, MediaQuery.of(context).padding.bottom + 90.0),
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_active,
            color: Theme.of(context).brightness == Brightness.light
                ? cBlack
                : cWhite,
            size: 40,
          ),
          const SizedBox(height: 15.0),
          Text(
            AppLocalization.of(context).translate("activities_screen", "no_notifications"),
            style: textStyleCustomMedium(
                Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite,
                14),
            textAlign: TextAlign.center,
            textScaleFactor: 1.0,
          )
        ],
      ),
    );
  }
}
