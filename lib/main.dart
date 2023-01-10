import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
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

//Solved problems bad certifications
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

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
  await Firebase.initializeApp();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  HttpOverrides.global = MyHttpOverrides();
  await DefaultCacheManager().emptyCache();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: false,
    sound: false,
  );

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

class MyAppState extends ConsumerState<MyApp>
    with SingleTickerProviderStateMixin {
  String themeApp = "";
  late Locale localeLanguage;

  //add all assets in our app here
  List<Image> imagesApp = [Image.asset("assets/images/ic_app.png")];

  //connectivity
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult initConnectivitystatus = ConnectivityResult.none;
  ConnectivityResult? connectivityStatusApp;

  late AnimationController _animationController;

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

  Future<void> initApp(WidgetRef ref) async {
    ConnectivityResult result = await initConnectivity();
    initConnectivitystatus = result;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    //logic theme system or theme choice user
    String theme = prefs.getString("theme") ?? "";
    await ref.read(themeAppNotifierProvider.notifier).setThemeApp(theme);

    //logic langue device or choice user
    await ref
        .read(localeLanguageNotifierProvider.notifier)
        .setLocaleLanguage(prefs);

    if (initConnectivitystatus != ConnectivityResult.none) {
      //logic load datas user
      await _loadDataUser(prefs);
    }

    FlutterNativeSplash.remove();
    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
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

    _animationController =
        AnimationController(duration: const Duration(seconds: 3), vsync: this)
          ..repeat();

    initApp(ref);

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((ConnectivityResult result) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      if (initConnectivitystatus == ConnectivityResult.none) {
        await _loadDataUser(prefs);
        setState(() {
          initConnectivitystatus = result;
        });
      } else {
        if (result == ConnectivityResult.none) {
          if (!mounted) return;
          if (scaffoldMessengerKey.currentState != null) {
            scaffoldMessengerKey.currentState!.showSnackBar(SnackBar(
              backgroundColor: cRed,
              elevation: 6,
              margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 20.0),
              content: Row(
                children: [
                  RotationTransition(
                    turns: Tween(begin: 0.0, end: 1.0)
                        .animate(_animationController),
                    child: Image.asset("assets/images/ic_app.png",
                        height: 25, width: 25),
                  ),
                  const SizedBox(width: 10.0),
                  Text("Pas de connexion actuellement",
                      style: textStyleCustomMedium(cWhite, 14.0),
                      textScaleFactor: 1.0),
                ],
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(days: 365),
              dismissDirection: DismissDirection.none,
            ));
          }

          ref
              .read(connectivityStatusAppNotifierProvider.notifier)
              .updateConnectivityStatus(result);
        } else if (result != ConnectivityResult.none &&
            connectivityStatusApp == ConnectivityResult.none) {
          await _loadDataUser(prefs);
          ref
              .read(connectivityStatusAppNotifierProvider.notifier)
              .updateConnectivityStatus(result);
          if (scaffoldMessengerKey.currentState != null) {
            scaffoldMessengerKey.currentState!.removeCurrentSnackBar();
          }
        }
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    connectivityStatusApp = ref.watch(connectivityStatusAppNotifierProvider);
    themeApp = ref.watch(themeAppNotifierProvider);
    localeLanguage = ref.watch(localeLanguageNotifierProvider);

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
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
      locale: localeLanguage,
      localizationsDelegates: const [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        AppLocalization.delegate
      ],
      home: initConnectivitystatus == ConnectivityResult.none
          ? const ConnectivityDevice()
          : const LogController(),
    );
  }
}
