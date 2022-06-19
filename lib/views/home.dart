import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/main.dart';

/// Method called when user clic LOCALE notifications
void selectLocaleNotification(String? payload, BuildContext context) {
  Navigator.pushNamed(context, notifications);
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  //inutile à voir ce qu'on en fait
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? token;

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

    //get push token device
    FirebaseMessaging.instance.getToken().then((value) {
      if (kDebugMode) {
        print(value);
      }
      setState(() {
        token = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [
          IconButton(
              onPressed: () => Navigator.pushNamed(context, notifications),
              icon: const Icon(Icons.notifications_active))
        ],
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child:
            token != null ? SelectableText(token!) : const Text("Pas de token"),
      )),
    );
  }
}
