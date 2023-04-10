import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:myyoukounkoun/libraries/env_config_lib.dart';
import 'package:myyoukounkoun/providers/home_provider.dart';

class AdMobConfig {
  static String get bannerAdMobUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/6300978111";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2934735716";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      //TODO uncomment id admob prod my youkounkoun version prod

      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/6300978111";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/2934735716";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
      // if (Platform.isAndroid) {
      //   return EnvironmentConfigLib().getEnvironmentBannerAdmobIdAndroid;
      // } else if (Platform.isIOS) {
      //   return EnvironmentConfigLib().getEnvironmentBannerAdmobIdIos;
      // } else {
      //   throw UnsupportedError("Unsupported platform");
      // }
    }
  }

  static String get nativeAdMobUnitId {
    if (kDebugMode) {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544/2247696110";
      } else if (Platform.isIOS) {
        return "ca-app-pub-3940256099942544/3986624511";
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    } else {
      if (Platform.isAndroid) {
        return EnvironmentConfigLib().getEnvironmentNativeAdmobIdAndroid;
      } else if (Platform.isIOS) {
        return EnvironmentConfigLib().getEnvironmentNativeAdmobIdIos;
      } else {
        throw UnsupportedError("Unsupported platform");
      }
    }
  }

  static Future<void> setAppTrackingTransparency() async {
    final statusTransparency =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    if (statusTransparency == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(seconds: 1));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }
}

class AdMobWidget extends ConsumerStatefulWidget {
  final AdSize adSize;
  final Color colorIndicator;
  final String screenPub;

  const AdMobWidget(
      {Key? key,
      required this.adSize,
      required this.colorIndicator,
      required this.screenPub})
      : super(key: key);

  @override
  AdMobWidgetState createState() => AdMobWidgetState();
}

class AdMobWidgetState extends ConsumerState<AdMobWidget>
    with AutomaticKeepAliveClientMixin {
  BannerAd? _bannerAd;

  Future<void> initBannerAd() async {
    if (Platform.isIOS) {
      final statusTransparency =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      if (statusTransparency == TrackingStatus.notDetermined) {
        await AppTrackingTransparency.requestTrackingAuthorization();
        TrackingStatus newStatusTransparency =
            await AppTrackingTransparency.trackingAuthorizationStatus;
        BannerAd(
          adUnitId: AdMobConfig.bannerAdMobUnitId,
          size: widget.adSize,
          request: AdRequest(
              nonPersonalizedAds:
                  newStatusTransparency == TrackingStatus.authorized
                      ? false
                      : true),
          listener: BannerAdListener(
            onAdLoaded: (ad) {
              setState(() {
                _bannerAd = ad as BannerAd;
              });
              if (widget.screenPub == "home") {
                ref
                    .read(pubHomeAlreadyLoadedNotifierProvider.notifier)
                    .pubHomeAlreadyLoaded();
              }
            },
            onAdFailedToLoad: (ad, error) {
              if (kDebugMode) {
                print(error);
              }
              if (widget.screenPub == "home") {
                ref
                    .read(pubHomeAlreadyLoadedNotifierProvider.notifier)
                    .pubHomeAlreadyLoaded();
              }
              ad.dispose();
            },
            onAdClosed: (Ad ad) {
              ad.dispose();
            },
          ),
        ).load();
      } else {
        BannerAd(
          adUnitId: AdMobConfig.bannerAdMobUnitId,
          size: widget.adSize,
          request: AdRequest(
              nonPersonalizedAds:
                  statusTransparency == TrackingStatus.authorized
                      ? false
                      : true),
          listener: BannerAdListener(
            onAdLoaded: (ad) {
              setState(() {
                _bannerAd = ad as BannerAd;
              });
              if (widget.screenPub == "home") {
                ref
                    .read(pubHomeAlreadyLoadedNotifierProvider.notifier)
                    .pubHomeAlreadyLoaded();
              }
            },
            onAdFailedToLoad: (ad, error) {
              if (widget.screenPub == "home") {
                ref
                    .read(pubHomeAlreadyLoadedNotifierProvider.notifier)
                    .pubHomeAlreadyLoaded();
              }
              ad.dispose();
            },
            onAdClosed: (Ad ad) {
              ad.dispose();
            },
          ),
        ).load();
      }
    } else {
      BannerAd(
        adUnitId: AdMobConfig.bannerAdMobUnitId,
        size: widget.adSize,
        request: const AdRequest(nonPersonalizedAds: false),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _bannerAd = ad as BannerAd;
            });
            if (widget.screenPub == "home") {
              ref
                  .read(pubHomeAlreadyLoadedNotifierProvider.notifier)
                  .pubHomeAlreadyLoaded();
            }
          },
          onAdFailedToLoad: (ad, error) {
            if (widget.screenPub == "home") {
              ref
                  .read(pubHomeAlreadyLoadedNotifierProvider.notifier)
                  .pubHomeAlreadyLoaded();
            }
            ad.dispose();
          },
          onAdClosed: (Ad ad) {
            ad.dispose();
          },
        ),
      ).load();
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    initBannerAd();
  }

  @override
  void dispose() {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return _bannerAd == null
        ? Center(
            child: SizedBox(
              height: 25.0,
              width: 25.0,
              child: CircularProgressIndicator(
                color: widget.colorIndicator,
                strokeWidth: 1.0,
              ),
            ),
          )
        : AdWidget(ad: _bannerAd!);
  }
}
