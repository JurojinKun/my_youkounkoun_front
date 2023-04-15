import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/components/message_user_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/libraries/sync_shared_prefs_lib.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';
import 'package:myyoukounkoun/models/notification_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/chat_details_provider.dart';
import 'package:myyoukounkoun/providers/chat_provider.dart';
import 'package:myyoukounkoun/providers/current_route_app_provider.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
import 'package:myyoukounkoun/providers/push_token_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/route_observer.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/auth/chat_details.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsLib {
  // // Initialize the [FlutterLocalNotificationsPlugin] package.
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Define a top-level named handler which background/terminated messages will
  /// call.
  ///
  /// To verify things are working, check out the native platform logs.
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await Firebase.initializeApp();
  }

  static Future showMaterialRedirectNotifChat(
      BuildContext context, WidgetRef ref, String idSender) async {
    UserModel? otherUser;
    try {
      for (var item in potentialsResultsSearchDatasMockes) {
        if (item.id.toString() == idSender) {
          otherUser = item;
        }
      }
      if (otherUser != null) {
        //TODO replace this logic with logic firebase
        ConversationModel? currentConversation;
        bool convWithCurrentUser = false;
        bool convWithOtherUser = false;

        for (ConversationModel conversation
            in ref.read(conversationsNotifierProvider)!) {
          for (var user in conversation.users) {
            if (user["id"] == ref.read(userNotifierProvider).id) {
              convWithCurrentUser = true;
            }
            if (user["id"] == otherUser.id) {
              convWithOtherUser = true;
            }
          }

          if (convWithCurrentUser &&
              convWithOtherUser &&
              (conversation.lastMessageUserId ==
                      ref.read(userNotifierProvider).id ||
                  conversation.lastMessageUserId == otherUser.id)) {
            currentConversation = conversation;
          }
        }

        return showMaterialModalBottomSheet(
            context: context,
            expand: true,
            enableDrag: false,
            builder: (context) {
              return RouteObserverWidget(
                  name: chatDetails,
                  child: ChatDetails(
                      user: otherUser!,
                      openWithModal: true,
                      conversation: currentConversation ??
                          ConversationModel(
                              id: "temporary",
                              users: [],
                              lastMessageUserId: 0,
                              lastMessage: "",
                              isLastMessageRead: false,
                              timestampLastMessage: "",
                              typeLastMessage: "",
                              themeConv: [])));
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
  static void selectLocaleNotification(NotificationResponse? payload,
      WidgetRef ref, BuildContext context, TickerProvider tickerProvider) {
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

  static void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    //logic iOS < 10.0
  }

  static Future<void> notificationsLogicMain() async {
    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: false,
      badge: false,
      sound: false,
    );

    /// Create an Android Notification Channel.
    // We use this channel in the `AndroidManifest.xml` file to override the default FCM channel to enable heads up notifications.
    const channelId = 'default_notification_channel_id';
    const channelName = 'Default Channel';
    const channelDescription = 'Default channel for notifications';

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
            channelId, // id
            channelName, // title
            description: channelDescription, // description
            importance: Importance.high,
            enableVibration: true,
            sound: RawResourceAndroidNotificationSound('sound_diamond'),
            ledColor: cBlue));
  }

  static void notificationsLogicController(BuildContext context, WidgetRef ref,
      TickerProvider tickerProvider) async {
    /// Set OS configs
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_test_notif');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin);

    /// Set the user clic locale notification handler
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (payload) =>
            selectLocaleNotification(payload, ref, context, tickerProvider));

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
            tabControllerBottomNav = TabController(
                length: 4, initialIndex: 2, vsync: tickerProvider);
          } else {
            tabControllerBottomNav!.index = 2;
          }

          if (tabControllerActivities == null) {
            tabControllerActivities = TabController(
                length: 2, initialIndex: 1, vsync: tickerProvider);
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
    });

    //new push notif
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print("new notif here");
      }

      // Set Android channel
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
              'default_notification_channel_id', 'Default Channel',
              importance: Importance.high,
              priority: Priority.high,
              sound: RawResourceAndroidNotificationSound('sound_diamond'),
              color: cBlue,
              ledColor: cBlue,
              ledOnMs: 500,
              ledOffMs: 500);

      // Set iOS channel
      const DarwinNotificationDetails darwinPlatformChannelSpecifics =
          DarwinNotificationDetails(
              presentAlert:
                  true, // Present an alert when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
              presentBadge:
                  true, // Present the badge number when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
              presentSound:
                  true, // Play a sound when the notification is displayed and the application is in the foreground (only from iOS 10 onwards)
              sound: "sound_diamond.caf");

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
          if (ref.read(currentRouteAppNotifierProvider) != "chatDetails") {
            flutterLocalNotificationsPlugin.show(notification.hashCode,
                notification.title, notification.body, platformChannelSpecifics,
                payload: message.data["idSender"]);
          } else if (ref.read(currentRouteAppNotifierProvider) ==
                  "chatDetails" &&
              ref.read(currentChatUserIdNotifierProvider) !=
                  message.data["idSender"]) {
            flutterLocalNotificationsPlugin.show(notification.hashCode,
                notification.title, notification.body, platformChannelSpecifics,
                payload: message.data["idSender"]);
          }
        } else {
          //TODO delete this else version prod
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            platformChannelSpecifics,
          );
        }
      }
    });
  }

  static Future<void> setActiveNotifications(WidgetRef ref) async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String os;
    String? uuid;

    if (Platform.isIOS) {
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      NotificationSettings settings =
          await FirebaseMessaging.instance.getNotificationSettings();

      os = "apple";
      IosDeviceInfo deviceInfoIOS = await deviceInfoPlugin.iosInfo;
      uuid = deviceInfoIOS.identifierForVendor;
      String token = ref.read(userNotifierProvider).token;

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        String pushToken = await FirebaseMessaging.instance.getToken() ?? "";
        if (kDebugMode) {
          print("push token: $pushToken");
        }

        if (pushToken != SyncSharedPrefsLib().prefs!.getString("pushToken") &&
            pushToken != "") {
          try {
            //logic ws send push token
            Map<String, dynamic> map = {
              "uuid": uuid,
              "os": os,
              "appVersion": packageInfo.version,
              "pushToken": pushToken,
            };
            ref
                .read(pushTokenNotifierProvider.notifier)
                .updatePushToken(pushToken);
            SyncSharedPrefsLib().prefs!.setString("pushToken", pushToken);
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        } else if (pushToken != "") {
          ref
              .read(pushTokenNotifierProvider.notifier)
              .updatePushToken(pushToken);
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        if (SyncSharedPrefsLib().prefs!.getString("pushToken") != null) {
          try {
            //logic ws send push token null
            Map<String, dynamic> map = {
              "uuid": uuid,
              "os": os,
              "appVersion": packageInfo.version,
              "pushToken": null,
            };
            await FirebaseMessaging.instance.deleteToken();
            await SyncSharedPrefsLib().prefs!.remove("pushToken");
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        }
        if (ref.read(pushTokenNotifierProvider).trim() != "") {
          ref.read(pushTokenNotifierProvider.notifier).clearPushToken();
        }
      }
    } else {
      os = "android";
      AndroidDeviceInfo deviceInfoAndroid = await deviceInfoPlugin.androidInfo;
      uuid = deviceInfoAndroid.id;
      String token = ref.read(userNotifierProvider).token;

      PermissionStatus status = await Permission.notification.request();

      if (status == PermissionStatus.granted) {
        String pushToken = await FirebaseMessaging.instance.getToken() ?? "";
        if (kDebugMode) {
          print("push token: $pushToken");
        }

        if (pushToken != SyncSharedPrefsLib().prefs!.getString("pushToken") &&
            pushToken != "") {
          try {
            //logic ws send push token
            Map<String, dynamic> map = {
              "uuid": uuid,
              "os": os,
              "appVersion": packageInfo.version,
              "pushToken": pushToken,
            };
            ref
                .read(pushTokenNotifierProvider.notifier)
                .updatePushToken(pushToken);
            SyncSharedPrefsLib().prefs!.setString("pushToken", pushToken);
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        } else if (pushToken != "") {
          ref
              .read(pushTokenNotifierProvider.notifier)
              .updatePushToken(pushToken);
        }
      } else {
        if (SyncSharedPrefsLib().prefs!.getString("pushToken") != null) {
          try {
            //logic ws send push token null
            Map<String, dynamic> map = {
              "uuid": uuid,
              "os": os,
              "appVersion": packageInfo.version,
              "pushToken": null,
            };
            await FirebaseMessaging.instance.deleteToken();
            await SyncSharedPrefsLib().prefs!.remove("pushToken");
          } catch (e) {
            if (kDebugMode) {
              print(e);
            }
          }
        }
        if (ref.read(pushTokenNotifierProvider).trim() != "") {
          ref.read(pushTokenNotifierProvider.notifier).clearPushToken();
        }
      }
    }
  }
}
