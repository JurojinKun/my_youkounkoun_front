import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenNotificationsNotifierProvider =
    StateNotifierProvider<TokenNotificationsProvider, String>(
        (ref) => TokenNotificationsProvider());

class TokenNotificationsProvider extends StateNotifier<String> {
  TokenNotificationsProvider() : super("");

  void updateTokenNotif(String newState) {
    state = newState;
  }
}
