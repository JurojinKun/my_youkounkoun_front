import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/models/notification_model.dart';

final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsProvider, List<NotificationModel>?>(
        (ref) => NotificationsProvider());

class NotificationsProvider extends StateNotifier<List<NotificationModel>?> {
  NotificationsProvider() : super(null);

  void setNotifications(List<NotificationModel> notifications) {
    state = [...notifications];
  }

  void addNewNotification(NotificationModel notification) {
    List<NotificationModel> newState = [notification, ...state!];
    state = newState;
  }

  void removeNotification(NotificationModel notification) {
    List<NotificationModel> newState = [...state!];
    newState.removeWhere((element) => element.id == notification.id);
    state = [...newState];
  }

  void readOneNotification(NotificationModel notification) {
    List<NotificationModel> newState = [...state!];

    for (var notif in newState) {
      if (notif.id == notification.id && !notif.isRead) {
        notif.isRead = true;
      }
    }

    state = [...newState];
  }

  void readAllNotifications() {
    List<NotificationModel> newState = [...state!];

    for (var notif in newState) {
      if (!notif.isRead) {
        notif.isRead = true;
      }
    }

    state = [...newState];
  }
}