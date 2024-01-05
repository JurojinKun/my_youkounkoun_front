import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvironmentConfig {
  late String keyApiGiphy;
  late bool admob;
  late String bannerAdmobIdAndroid;
  late String bannerAdmobIdIos;
  late String nativeAdmobIdAndroid;
  late String nativeAdmobIdIos;
  late bool bottomNavBar;
  late String keyEncryptedUserBox;
  late String keyEncryptedTokensBox;

  EnvironmentConfig(
      {required this.keyApiGiphy,
      required this.admob,
      required this.bannerAdmobIdAndroid,
      required this.bannerAdmobIdIos,
      required this.nativeAdmobIdAndroid,
      required this.nativeAdmobIdIos,
      required this.bottomNavBar,
      required this.keyEncryptedUserBox,
      required this.keyEncryptedTokensBox});
}

class EnvironmentConfigLib {
  static final EnvironmentConfigLib _singleton =
      EnvironmentConfigLib._internal();

  factory EnvironmentConfigLib() {
    return _singleton;
  }

  EnvironmentConfigLib._internal();

  late final EnvironmentConfig _environmentConfig = EnvironmentConfig(
      keyApiGiphy: "",
      admob: false,
      bannerAdmobIdAndroid: "",
      bannerAdmobIdIos: "",
      nativeAdmobIdAndroid: "",
      nativeAdmobIdIos: "",
      bottomNavBar: false,
      keyEncryptedUserBox: "",
      keyEncryptedTokensBox: "");

  Future<void> initEnvironmentConfigLib() async {
    await dotenv.load(fileName: ".env");

    if (dotenv.env["KEY_API_GIPHY"] != null &&
        dotenv.env["KEY_API_GIPHY"]?.trim() != "" &&
        dotenv.env["KEY_API_GIPHY"] is String) {
      _environmentConfig.keyApiGiphy = dotenv.env["KEY_API_GIPHY"] ?? "";
    }

    if (dotenv.env["ADMOB"] != null &&
        dotenv.env["ADMOB"]?.trim() != "" &&
        dotenv.env["ADMOB"] is String) {
      if (dotenv.env["ADMOB"] == "true") {
        _environmentConfig.admob = true;
        _environmentConfig.bannerAdmobIdAndroid =
            dotenv.env["BANNER_ADMOB_ID_ANDROID"] ?? "";
        _environmentConfig.bannerAdmobIdIos =
            dotenv.env["BANNER_ADMOB_ID_IOS"] ?? "";
        _environmentConfig.nativeAdmobIdAndroid =
            dotenv.env["NATIVE_ADMOB_ID_ANDROID"] ?? "";
        _environmentConfig.nativeAdmobIdIos =
            dotenv.env["NATIVE_ADMOB_ID_IOS"] ?? "";
      } else {
        _environmentConfig.admob = false;
      }
    }

    if (dotenv.env["BOTTOM_NAV_BAR"] != null &&
        dotenv.env["BOTTOM_NAV_BAR"]?.trim() != "" &&
        dotenv.env["BOTTOM_NAV_BAR"] is String) {
      if (dotenv.env["BOTTOM_NAV_BAR"] == "true") {
        _environmentConfig.bottomNavBar = true;
      } else {
        _environmentConfig.bottomNavBar = false;
      }
    }

    if (dotenv.env["KEY_ENCRYPTED_USER_BOX"] != null &&
        dotenv.env["KEY_ENCRYPTED_USER_BOX"]?.trim() != "" &&
        dotenv.env["KEY_ENCRYPTED_USER_BOX"] is String) {
      _environmentConfig.keyEncryptedUserBox =
          dotenv.env["KEY_ENCRYPTED_USER_BOX"] ?? "";
    }

    if (dotenv.env["KEY_ENCRYPT_TOKENS_BOX"] != null &&
        dotenv.env["KEY_ENCRYPT_TOKENS_BOX"]?.trim() != "" &&
        dotenv.env["KEY_ENCRYPT_TOKENS_BOX"] is String) {
      _environmentConfig.keyEncryptedTokensBox =
          dotenv.env["KEY_ENCRYPT_TOKENS_BOX"] ?? "";
    }
  }

  String get getEnvironmentConfigKeyApiGiphy => _environmentConfig.keyApiGiphy;

  bool get getEnvironmentAdmob => _environmentConfig.admob;

  String get getEnvironmentBannerAdmobIdAndroid =>
      _environmentConfig.bannerAdmobIdAndroid;

  String get getEnvironmentBannerAdmobIdIos =>
      _environmentConfig.bannerAdmobIdIos;

  String get getEnvironmentNativeAdmobIdAndroid =>
      _environmentConfig.nativeAdmobIdAndroid;

  String get getEnvironmentNativeAdmobIdIos =>
      _environmentConfig.nativeAdmobIdIos;

  bool get getEnvironmentBottomNavBar => _environmentConfig.bottomNavBar;

  String get getEnvironmentKeyEncryptedUserBox =>
      _environmentConfig.keyEncryptedUserBox;

  String get getEnvironmentKeyEncryptedTokensBox =>
      _environmentConfig.keyEncryptedTokensBox;
}
