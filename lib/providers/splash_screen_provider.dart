import 'package:flutter_riverpod/flutter_riverpod.dart';

final splashScreenDoneNotifierProvider =
    StateNotifierProvider<SplashScreenDoneProvider, bool>(
        (ref) => SplashScreenDoneProvider());

class SplashScreenDoneProvider extends StateNotifier<bool> {
  SplashScreenDoneProvider() : super(false);

  void splashScreenDone() {
    state = true;
  }
}
