import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/components/custom_nav_bar.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/main.dart';
import 'package:myyoukounkoun/providers/check_valid_user_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/router.dart';
import 'package:myyoukounkoun/views/auth/validate_user.dart';

/// Method called when user clic LOCALE notifications
void selectLocaleNotification(String? payload, BuildContext context) {
  Navigator.pushNamed(context, activities);
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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  bool _isKeyboard = false;

  Future _validateUserBottomSheet(BuildContext context) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: false,
        builder: (context) {
          return const ValidateUser();
        });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

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
          activities,
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
        activities,
      );
    });

    _tabController = TabController(length: 4, vsync: this);
    navHomeKey = GlobalKey<NavigatorState>();
    navSearchKey = GlobalKey<NavigatorState>();
    navActivitiesKey = GlobalKey<NavigatorState>();
    navProfileKey = GlobalKey<NavigatorState>();

    Future.delayed(const Duration(seconds: 0), () {
      if (!ref.read(userNotifierProvider).validEmail &&
          !ref.read(checkValidUserNotifierProvider)) {
        _validateUserBottomSheet(navAuthKey.currentContext!);
      }
    });
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboard) {
      setState(() {
        _isKeyboard = newValue;
      });
    }
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          if (_tabController.index == 0) {
            return !(await navHomeKey!.currentState!.maybePop());
          } else if (_tabController.index == 1) {
            return !(await navSearchKey!.currentState!.maybePop());
          } else if (_tabController.index == 2) {
            return !(await navActivitiesKey!.currentState!.maybePop());
          } else if (_tabController.index == 3) {
            return !(await navProfileKey!.currentState!.maybePop());
          } else {
            return false;
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: tabNavs()),
              !_isKeyboard ? CustomNavBar(tabController: _tabController) : const SizedBox()
            ],
          ),
        ));
  }

  List<Widget> tabNavs() {
    return [
      Navigator(
        key: navHomeKey,
        initialRoute: home,
        onGenerateRoute: (settings) => generateRouteAuthHome(settings, context),
      ),
      Navigator(
        key: navSearchKey,
        initialRoute: search,
        onGenerateRoute: (settings) => generateRouteAuthSearch(settings, context),
      ),
      Navigator(
        key: navActivitiesKey,
        initialRoute: activities,
        onGenerateRoute: (settings) =>
            generateRouteAuthActivities(settings, context),
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
