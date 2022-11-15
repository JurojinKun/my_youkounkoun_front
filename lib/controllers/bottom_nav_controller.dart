import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/components/custom_nav_bar.dart';

import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/main.dart';
import 'package:my_boilerplate/router.dart';

/// Method called when user clic LOCALE notifications
void selectLocaleNotification(String? payload, BuildContext context) {
  Navigator.pushNamed(context, notifications);
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  //inutile à voir ce qu'on en fait
}

class BottomNavController extends ConsumerStatefulWidget {
  const BottomNavController({Key? key}) : super(key: key);

  @override
  BottomNavControllerState createState() => BottomNavControllerState();
}

class BottomNavControllerState extends ConsumerState<BottomNavController>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    /// Set OS configs
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notif');
    const IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);

    /// Set the user clic locale notification handler
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) =>
            selectLocaleNotification(payload, context));

    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        Navigator.pushNamed(
          context,
          notifications,
        );
      }
    });

    //new push notif
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("new notif here");
      }
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
                'high_importance_channel', // id
                'High Importance Notifications', // title
                channelDescription:
                    'This channel is used for important notifications.', // description
                importance: Importance.max,
                priority: Priority.high,
                showWhen: true),
          ),
        );
      }
    });

    //user click on notif app background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
      }
      Navigator.pushNamed(
        context,
        notifications,
      );
    });

    _tabController = TabController(length: 4, vsync: this);
    navHomeKey = GlobalKey<NavigatorState>();
    navChatKey = GlobalKey<NavigatorState>();
    navNotificationsKey = GlobalKey<NavigatorState>();
    navProfileKey = GlobalKey<NavigatorState>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(onWillPop: () async {
      if (_tabController.index == 0) {
        return !(await navHomeKey!.currentState!.maybePop());
      } else if (_tabController.index == 1) {
        return !(await navChatKey!.currentState!.maybePop());
      } else if (_tabController.index == 2) {
        return !(await navNotificationsKey!.currentState!.maybePop());
      } else if (_tabController.index == 3) {
        return !(await navProfileKey!.currentState!.maybePop());
      } else {
        return false;
      }
    }, child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: tabNavs()),
          CustomNavBar(tabController: _tabController)
        ],
      ),
    ));
  }

  List<Widget> tabNavs() {
    return [
      Navigator(
        key: navHomeKey,
        initialRoute: home,
        onGenerateRoute: (settings) =>
            generateRouteAuthHome(settings, context),
      ),
      Navigator(
        key: navChatKey,
        initialRoute: chat,
        onGenerateRoute: (settings) =>
            generateRouteAuthChat(settings, context),
      ),
      Navigator(
        key: navNotificationsKey,
        initialRoute: notifications,
        onGenerateRoute: (settings) =>
            generateRouteAuthNotifications(settings, context),
      ),
      Navigator(
        key: navProfileKey,
        initialRoute: profile,
        onGenerateRoute: (settings) =>
            generateRouteAuthProfile(settings, context),
      ),
    ];
  }
}
