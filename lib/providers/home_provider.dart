import "package:flutter_riverpod/flutter_riverpod.dart";

final pubHomeAlreadyLoadedNotifierProvider = StateNotifierProvider<PubHomeAlreadyLoaded, bool>(
    (ref) => PubHomeAlreadyLoaded());

class PubHomeAlreadyLoaded extends StateNotifier<bool> {
  PubHomeAlreadyLoaded() : super(false);

  void pubHomeAlreadyLoaded() {
    state = true;
  }
}