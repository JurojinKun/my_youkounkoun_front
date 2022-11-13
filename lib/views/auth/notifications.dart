import 'package:flutter/material.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
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

    return Scaffold(
        appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Text(
        AppLocalization.of(context)
            .translate("notifications_screen", "notifications"),
        style: textStyleCustomBold(Colors.white, 23),
        textScaleFactor: 1.0
      ),
    ));
  }
}
