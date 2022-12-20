import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/providers/notifications_active_provider.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:myyoukounkoun/controllers/log_controller.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/token_notifications_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:myyoukounkoun/providers/theme_app_provider.dart';
import 'package:myyoukounkoun/views/connectivity/connectivity_device.dart';

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

  //add all assets in our app here
  List<Image> imagesApp = [Image.asset("assets/images/ic_app.png")];

  //connectivity
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectivityStatus = ConnectivityResult.none;

  Future<ConnectivityResult> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('Couldn\'t check connectivity status: $e');
      }
    }

    return result;
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectivityStatus = result;
    });
  }

  Future<void> initApp(WidgetRef ref) async {
    ConnectivityResult result = await initConnectivity();
    _updateConnectionStatus(result);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //logic theme system or theme choice user
    String theme = prefs.getString("theme") ?? "";
    ref.read(themeAppNotifierProvider.notifier).setThemeApp(theme);

    if (result != ConnectivityResult.none) {
      //logic load datas user
      await _loadDataUser(prefs);
    }

    FlutterNativeSplash.remove();
  }

  Future<void> _loadDataUser(SharedPreferences prefs) async {
    //logic already log
    String token = prefs.getString("token") ?? "";

    if (token.trim() != "") {
      ref.read(userNotifierProvider.notifier).initUser(User(
          id: 1,
          token: "tokenTest1234",
          email: "ccommunay@gmail.com",
          pseudo: "0ruj",
          gender: "Male",
          birthday: "1997-06-06 00:00",
          nationality: "FR",
          profilePictureUrl: "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
          validCGU: true,
          validPrivacyPolicy: true,
          validEmail: false));

      ref
          .read(recentSearchesNotifierProvider.notifier)
          .initRecentSearches(recentSearchesDatasMockes);

      bool notificationsActive = prefs.getBool("notifications") ?? true;
      ref
          .read(notificationsActiveNotifierProvider.notifier)
          .updateNotificationsActive(notificationsActive);
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
  }

  @override
  void initState() {
    super.initState();

    initApp(ref);

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      if (result == ConnectivityResult.none) {
        _updateConnectionStatus(result);
      } else if (result != ConnectivityResult.none &&
          _connectivityStatus == ConnectivityResult.none) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await _loadDataUser(prefs);
        _updateConnectionStatus(result);
      }
    });
  }

  @override
  void didChangeDependencies() {
    //logic precache all assets in our app => faster load on app
    for (var i = 0; i < imagesApp.length; i++) {
      precacheImage(imagesApp[i].image, context);
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    themeApp = ref.watch(themeAppNotifierProvider);

    return MaterialApp(
      title: 'My youkounkoun',
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
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalization.delegate
      ],
      home: _connectivityStatus == ConnectivityResult.none
          ? const ConnectivityDevice()
          : const LogController(),
    );
  }
}
