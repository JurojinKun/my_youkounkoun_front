import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationsActiveNotifierProvider = StateNotifierProvider<NotificationsActiveProvider, bool>((ref) => NotificationsActiveProvider());

class NotificationsActiveProvider extends StateNotifier<bool> {
  NotificationsActiveProvider() : super(true);

  void updateNotificationsActive(bool newState) {
    state = newState;
  }
}