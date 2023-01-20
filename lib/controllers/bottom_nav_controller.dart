import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/components/custom_nav_bar.dart';
import 'package:myyoukounkoun/components/message_user_custom.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/main.dart';
import 'package:myyoukounkoun/models/notification_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/check_valid_user_provider.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/route_observer.dart';
import 'package:myyoukounkoun/router.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/auth/chat_details.dart';
import 'package:myyoukounkoun/views/auth/validate_user.dart';

Future showMaterialRedirectNotifChat(
    BuildContext context, WidgetRef ref, String idSender) async {
  User? user;
  try {
    for (var item in potentialsResultsSearchDatasMockes) {
      if (item.id.toString() == idSender) {
        user = item;
      }
    }
    if (user != null) {
      return showMaterialModalBottomSheet(
          context: context,
          expand: true,
          enableDrag: false,
          builder: (context) {
            return RouteAwareWidget(
                name: chatDetails,
                child: ChatDetails(user: user!, openWithModal: true));
          });
    } else {
      messageUser(
          navAuthKey.currentContext!,
          AppLocalization.of(navAuthKey.currentContext!)
              .translate("general", "no_user"));
    }
  } catch (e) {
    messageUser(
        navAuthKey.currentContext!,
        AppLocalization.of(navAuthKey.currentContext!)
            .translate("general", "problem"));
  }
}

/// Method called when user clic LOCALE notifications
void selectLocaleNotification(NotificationResponse? payload, WidgetRef ref,
    BuildContext context, TickerProvider tickerProvider) {
  if (payload != null) {
    if (kDebugMode) {
      print(payload.actionId);
      print(payload.input);
      print(payload.notificationResponseType);
      print(payload.payload);
    }
    if (payload.payload != null && payload.payload!.trim() != "") {
      showMaterialRedirectNotifChat(context, ref, payload.payload!);
    } else {
      if (tabControllerBottomNav == null) {
        tabControllerBottomNav =
            TabController(length: 4, initialIndex: 2, vsync: tickerProvider);
      } else if (tabControllerBottomNav!.index != 2) {
        tabControllerBottomNav!.index = 2;
      }

      if (tabControllerActivities == null) {
        tabControllerActivities =
            TabController(length: 2, initialIndex: 1, vsync: tickerProvider);
      } else if (tabControllerActivities!.index != 1) {
        tabControllerActivities!.index = 1;
      }
    }
  }
}

void onDidReceiveLocalNotification(
    int id, String? title, String? body, String? payload) async {
  //logic iOS < 10.0
}

class BottomNavController extends ConsumerStatefulWidget {
  const BottomNavController({Key? key}) : super(key: key);

  @override
  BottomNavControllerState createState() => BottomNavControllerState();
}

class BottomNavControllerState extends ConsumerState<BottomNavController>
    with TickerProviderStateMixin {
  bool _isKeyboard = false;

  Future _validateUserBottomSheet(BuildContext context) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: false,
        builder: (context) {
          return const RouteAwareWidget(
              name: validateUser, child: ValidateUser());
        });
  }

  @override
  void initState() {
    super.initState();

    /// Set OS configs
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notif');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);

    /// Set the user clic locale notification handler
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) =>
            selectLocaleNotification(payload, ref, context, this));

    //user click on notif app killed
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        //notif chat => redirect vers chat details
        if (message.data["type"] == "M") {
          showMaterialRedirectNotifChat(context, ref, message.data["idSender"]);
        }
        //notif informative => redirect vers activities index 1
        else if (message.data["type"] == "I") {
          if (tabControllerBottomNav == null) {
            tabControllerBottomNav =
                TabController(length: 4, initialIndex: 2, vsync: this);
          } else {
            tabControllerBottomNav!.index = 2;
          }

          if (tabControllerActivities == null) {
            tabControllerActivities =
                TabController(length: 2, initialIndex: 1, vsync: this);
          } else {
            tabControllerActivities!.index = 1;
          }
        }
      }
    });

    //user click on notif app background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
      }
      //notif chat => redirect vers chat details
      if (message.data["type"] == "M") {
        showMaterialRedirectNotifChat(context, ref, message.data["idSender"]);
      }
      //notif informative => redirect vers activities index 1
      else if (message.data["type"] == "I") {
        if (tabControllerBottomNav == null) {
          tabControllerBottomNav =
              TabController(length: 4, initialIndex: 2, vsync: this);
        } else if (tabControllerBottomNav!.index != 2) {
          tabControllerBottomNav!.index = 2;
        }

        if (tabControllerActivities == null) {
          tabControllerActivities =
              TabController(length: 2, initialIndex: 1, vsync: this);
        } else if (tabControllerActivities!.index != 1) {
          tabControllerActivities!.index = 1;
        }
      }
    });

    //new push notif
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("new notif here");
        print(message.data);
      }

      // Set Android channel
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'high_importance_channel', // id
              'High Importance Notifications', // title
              channelDescription:
                  'This channel is used for important notifications.', // description
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true);

      // Set iOS channel
      const DarwinNotificationDetails darwinPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert:
            true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentBadge:
            true, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
        presentSound:
            true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
      );

      // Set platform specific channel
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
          iOS: darwinPlatformChannelSpecifics);

      RemoteNotification? notification = message.notification;

      //logic de mise en silence d'une nouvelle notif push si le user est déjà sur le screen activities index 1 ou sur le chat details
      if (notification != null && !kIsWeb) {
        if (message.data["type"] == "I") {
          if (tabControllerActivities == null ||
              (tabControllerBottomNav!.index != 2 ||
                  tabControllerActivities!.index != 1)) {
            flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              platformChannelSpecifics,
            );
          }
          //à voir si ça suffit pour add la notif dans la liste des notifs
          if (ref.read(notificationsNotifierProvider) != null) {
            NotificationModel newNotif =
                NotificationModel.fromJSON(message.data["data"]);
            ref
                .read(notificationsNotifierProvider.notifier)
                .addNewNotification(newNotif);
          }
        } else if (message.data["type"] == "M") {
          if (ref.read(inChatDetailsNotifierProvider).isEmpty ||
              (ref.read(inChatDetailsNotifierProvider).isNotEmpty &&
                  ref.read(inChatDetailsNotifierProvider)["screen"] ==
                      "ChatDetails" &&
                  ref.read(inChatDetailsNotifierProvider)["userID"] !=
                      message.data["idSender"]) ||
              (ref.read(inChatDetailsNotifierProvider).isNotEmpty &&
                  ref.read(inChatDetailsNotifierProvider)["screen"] ==
                      "UserProfile")) {
            flutterLocalNotificationsPlugin.show(notification.hashCode,
                notification.title, notification.body, platformChannelSpecifics,
                payload: message.data["idSender"]);
          }
        }

        //logic de test de mise en silence de notifs push
        // if (tabControllerActivities == null ||
        //     (tabControllerBottomNav!.index != 2 ||
        //         tabControllerActivities!.index != 1)) {
        //   print("premier if");
        //   flutterLocalNotificationsPlugin.show(notification.hashCode,
        //       notification.title, notification.body, platformChannelSpecifics,
        //       //à la place de "45" mettre l'id sender
        //       payload: "45");
        // } else if (ref.read(inChatDetailsNotifierProvider).isEmpty ||
        //     (ref.read(inChatDetailsNotifierProvider).isNotEmpty &&
        //         ref.read(inChatDetailsNotifierProvider)["screen"] ==
        //             "ChatDetails" &&
        //         ref.read(inChatDetailsNotifierProvider)["userID"] != "45") ||
        //     (ref.read(inChatDetailsNotifierProvider).isNotEmpty &&
        //         ref.read(inChatDetailsNotifierProvider)["screen"] ==
        //             "UserProfile")) {
        //   print("second if");
        //   flutterLocalNotificationsPlugin.show(notification.hashCode,
        //       notification.title, notification.body, platformChannelSpecifics,
        //       //à la place de "45" mettre l'id sender
        //       payload: "45");
        // }
      }
    });

    tabControllerBottomNav ??=
        TabController(length: 4, initialIndex: 0, vsync: this);
    tabControllerBottomNav!.addListener(() {
      setState(() {});
    });

    navHomeKey = GlobalKey<NavigatorState>();
    navSearchKey = GlobalKey<NavigatorState>();
    navActivitiesKey = GlobalKey<NavigatorState>();
    navProfileKey = GlobalKey<NavigatorState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(userNotifierProvider).validEmail &&
          !ref.read(checkValidUserNotifierProvider)) {
        _validateUserBottomSheet(navAuthKey.currentContext!);
      }
    });
  }

  @override
  void deactivate() {
    tabControllerBottomNav!.removeListener(() {
      setState(() {});
    });
    super.deactivate();
  }

  @override
  void dispose() {
    tabControllerBottomNav!.dispose();
    tabControllerBottomNav = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isKeyboard = ref.watch(visibleKeyboardAppNotifierProvider);

    return WillPopScope(
        onWillPop: () async {
          if (tabControllerBottomNav!.index == 0) {
            return !(await navHomeKey!.currentState!.maybePop());
          } else if (tabControllerBottomNav!.index == 1) {
            return !(await navSearchKey!.currentState!.maybePop());
          } else if (tabControllerBottomNav!.index == 2) {
            return !(await navActivitiesKey!.currentState!.maybePop());
          } else if (tabControllerBottomNav!.index == 3) {
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
                  controller: tabControllerBottomNav,
                  physics: const NeverScrollableScrollPhysics(),
                  children: tabNavs()),
              !_isKeyboard
                  ? CustomNavBar(tabController: tabControllerBottomNav!)
                  : const SizedBox()
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
        onGenerateRoute: (settings) =>
            generateRouteAuthSearch(settings, context),
      ),
      Navigator(
          key: navActivitiesKey,
          initialRoute: activities,
          onGenerateRoute: (settings) =>
              generateRouteAuthActivities(settings, context)),
      Navigator(
        key: navProfileKey,
        initialRoute: profile,
        onGenerateRoute: (settings) =>
            generateRouteAuthProfile(settings, context),
      ),
    ];
  }
}
