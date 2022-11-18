import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/providers/locale_language_provider.dart';
import 'package:my_boilerplate/providers/theme_app_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:my_boilerplate/controllers/log_controller.dart';
import 'package:my_boilerplate/models/user_model.dart';
import 'package:my_boilerplate/providers/token_notifications_provider.dart';
import 'package:my_boilerplate/providers/user_provider.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';

// // Initialize the [FlutterLocalNotificationsPlugin] package.
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Define a top-level named handler which background/terminated messages will
/// call.
///
/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// Create an Android Notification Channel.
  // We use this channel in the `AndroidManifest.xml` file to override the default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description:
            'This channel is used for important notifications.', // description
        importance: Importance.high,
      ));

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {
  String themeApp = "";

  Future<void> initApp(WidgetRef ref) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    //logic theme system or theme choice user
    String theme = prefs.getString("theme") ?? "";
    ref.read(themeAppNotifierProvider.notifier).setThemeApp(theme);

    //logic already log
    String token = prefs.getString("token") ?? "";

    if (token.trim() != "") {
      ref.read(userNotifierProvider.notifier).initUser(User(
          id: 1,
          token: "tokenTest1234",
          email: "ccommunay@gmail.com",
          pseudo: "0ruj",
          gender: "Male",
          age: 25,
          nationality: "FR",
          profilePictureUrl:
              "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
          validCGU: true,
          validPrivacyPolicy: true,
          validEmail: false));
    }

    //get push token device
    String? tokenPush = await FirebaseMessaging.instance.getToken();
    if (tokenPush != null && tokenPush.trim() != "") {
      if (kDebugMode) {
        print("push token: $tokenPush");
      }
      ref
          .read(tokenNotificationsNotifierProvider.notifier)
          .updateTokenNotif(tokenPush);
    }

    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    super.initState();
    initApp(ref);
  }

  @override
  Widget build(BuildContext context) {
    themeApp = ref.watch(themeAppNotifierProvider);

    return MaterialApp(
      title: 'My boilerplate',
      debugShowCheckedModeBanner: false,
      themeMode: themeApp.trim() == ""
          ? ThemeMode.system
          : themeApp == "lightTheme"
              ? ThemeMode.light
              : ThemeMode.dark,
      theme: lightTheme,
      darkTheme: darkTheme,
      supportedLocales: const [Locale('en', ''), Locale('fr', '')],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale!.languageCode) {
            ref
                .read(localeLanguageNotifierProvider.notifier)
                .setLocaleLanguage(deviceLocale.languageCode);
            return deviceLocale;
          }
        }
        ref
            .read(localeLanguageNotifierProvider.notifier)
            .setLocaleLanguage(supportedLocales.first.languageCode);
        return supportedLocales.first;
      },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalization.delegate
      ],
      home: const LogController(),
    );
  }
}
