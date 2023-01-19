import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/models/notification_model.dart';

final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsProvider, List<NotificationModel>?>(
        (ref) => NotificationsProvider());
final notificationsActiveNotifierProvider = StateNotifierProvider<NotificationsActiveProvider, bool>((ref) => NotificationsActiveProvider());

final inChatDetailsNotifierProvider =
    StateNotifierProvider<InChatDetailsProvider, Map<String, dynamic>>(
        (ref) => InChatDetailsProvider());
final afterChatDetailsNotifierProvider =
    StateNotifierProvider<AfterChatDetailsProvider, bool>(
        (ref) => AfterChatDetailsProvider());

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

class NotificationsActiveProvider extends StateNotifier<bool> {
  NotificationsActiveProvider() : super(true);

  void updateNotificationsActive(bool newState) {
    state = newState;
  }
}

class InChatDetailsProvider extends StateNotifier<Map<String, dynamic>> {
  InChatDetailsProvider() : super({});

  void inChatDetails(String screen, String userID) {
    Map<String, dynamic> newState = {};
    newState = {"screen": screen, "userID": userID};

    state = newState;
    print("in chat");
    print(state);
  }

  void outChatDetails(String screen, String userID) {
    Map<String, dynamic> newState = {};

    if (screen.isNotEmpty &&
        screen.trim() != "" &&
        userID.isNotEmpty &&
        userID.trim() != "") {
      newState = {"screen": screen, "userID": userID};
    }

    state = newState;
    print("out chat");
    print(state);
  }
}

class AfterChatDetailsProvider extends StateNotifier<bool> {
  AfterChatDetailsProvider() : super(false);

  void updateAfterChat(bool newState) {
    state = newState;
  }

  void clearAfterChat() {
    state = false;
  }
}
