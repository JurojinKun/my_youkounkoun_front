import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:myyoukounkoun/controllers/connectivity_controller.dart';
import 'package:myyoukounkoun/libraries/env_config_lib.dart';
import 'package:myyoukounkoun/libraries/http_overrides_lib.dart';
import 'package:myyoukounkoun/libraries/notifications_lib.dart';
import 'package:myyoukounkoun/libraries/sync_shared_prefs_lib.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
import 'package:myyoukounkoun/providers/new_maj_provider.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:myyoukounkoun/providers/splash_screen_provider.dart';
import 'package:myyoukounkoun/providers/version_app_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:myyoukounkoun/providers/theme_app_provider.dart';

Future<void> searchPotentialNewMaj(WidgetRef ref) async {
  Map<String, dynamic> newMajInfos = {
    "newMajAvailable": false,
    "newMajRequired": false,
    "linkAndroid": "https://play.google.com",
    "linkIOS": "https://apps.apple.com"
  };
  ref.read(newMajInfosNotifierProvider.notifier).setNewMajInfos(newMajInfos);
}

Future<void> loadDataUser(WidgetRef ref) async {
  //logic already log
  String? userEncoded = SyncSharedPrefsLib().prefs!.getString("user") ?? "";

  if (userEncoded.trim() != "") {
    Map<String, dynamic> decodedUserMap = json.decode(userEncoded);
    ref
        .read(userNotifierProvider.notifier)
        .setUser(UserModel.fromJSON(decodedUserMap));

    ref
        .read(recentSearchesNotifierProvider.notifier)
        .initRecentSearches(recentSearchesDatasMockes);
  }
}

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await EnvironmentConfigLib().initEnvironmentConfigLib();
  await Firebase.initializeApp();
  if (EnvironmentConfigLib().getEnvironmentAdmob) {
    await MobileAds.instance.initialize();
  }
  HttpOverrides.global = HttpOverridesLib();
  await DefaultCacheManager().emptyCache();
  await NotificationsLib.notificationsLogicMain();

  // Instantiate Global SyncSharedPrefs
  SyncSharedPrefsLib();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends ConsumerState<MyApp> {
  bool splashScreenDone = false;

  String themeApp = "";
  late Locale localeLanguage;

  //add all assets in our app here
  List<Image> imagesApp = [
    Image.asset("assets/images/ic_app_new.png")
  ];

  //connectivity
  final Connectivity _connectivity = Connectivity();

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
    ref
        .read(initConnectivityStatusAppNotifierProvider.notifier)
        .setInitConnectivityStatus(result);

    //logic theme system or theme choice user
    String theme = SyncSharedPrefsLib().prefs!.getString("theme") ?? "";
    await ref.read(themeAppNotifierProvider.notifier).setThemeApp(theme);

    //logic langue device or choice user
    await ref
        .read(localeLanguageNotifierProvider.notifier)
        .setLocaleLanguage();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    ref
        .read(versionAppNotifierProvider.notifier)
        .setVersionApp(packageInfo.version.toString());

    if (result != ConnectivityResult.none) {
      //logic new maj
      await searchPotentialNewMaj(ref);

      if (!ref.read(newMajInfosNotifierProvider)["newMajAvailable"]) {
        //logic load datas user
        await loadDataUser(ref);
      }
    }

    ref.read(splashScreenDoneNotifierProvider.notifier).splashScreenDone();
    FlutterNativeSplash.remove();
    if (Platform.isIOS) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
  }

  @override
  void initState() {
    super.initState();

    initApp(ref);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    splashScreenDone = ref.watch(splashScreenDoneNotifierProvider);
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
        AppLocalization.delegate,
      ],
      home:
          splashScreenDone ? const ConnectivityController() : const SizedBox(),
    );
  }
}
