import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';

class Notifications extends ConsumerStatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override 
  NotificationsState createState() => NotificationsState();
}

class NotificationsState extends ConsumerState<Notifications> with AutomaticKeepAliveClientMixin {

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
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Container(
        height: 150,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.notifications_active, color: Theme.of(context).brightness == Brightness.light ? cBlack: cWhite, size: 40,),
            const SizedBox(height: 15.0),
            Text("Work in progress", style: textStyleCustomMedium(Theme.of(context).brightness == Brightness.light ? cBlack: cWhite, 14), textAlign: TextAlign.center, textScaleFactor: 1.0,)
          ],
        ),
      ),
    );
  }
}