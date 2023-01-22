import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/notification_model.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class Notifications extends ConsumerStatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  NotificationsState createState() => NotificationsState();
}

class NotificationsState extends ConsumerState<Notifications>
    with AutomaticKeepAliveClientMixin {
  List<NotificationModel>? notifications = [];

  //logic back à mettre en place ici (à voir si j'utilise stream builder ou pas pour les notifs au final)
  Future<void> setNotifications() async {
    await Future.delayed(const Duration(seconds: 3));
    //Attention mettre une liste vide si pas encore de notifs pour enlever le statut null du provider et mettre la logique du length == 0
    if (notificationsInformativesDatasMockes.isNotEmpty) {
      notificationsInformativesDatasMockes.sort(
          (a, b) => int.parse(b.timestamp).compareTo(int.parse(a.timestamp)));
      ref
          .read(notificationsNotifierProvider.notifier)
          .setNotifications(notificationsInformativesDatasMockes);
    } else {
      ref.read(notificationsNotifierProvider.notifier).setNotifications([]);
    }
  }

  @override
  void initState() {
    super.initState();

    setNotifications();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    notifications = ref.watch(notificationsNotifierProvider);

    return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            10.0,
            MediaQuery.of(context).padding.top + 20.0,
            10.0,
            MediaQuery.of(context).padding.bottom + 90.0),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: notifications == null
            ? SizedBox(
                height: MediaQuery.of(context).size.height -
                    (MediaQuery.of(context).padding.top +
                        20.0 +
                        MediaQuery.of(context).padding.bottom +
                        90.0),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: cBlue,
                    strokeWidth: 1.0,
                  ),
                ))
            : notifications!.isEmpty
                ? emptyNotifications()
                : listNotifications());
  }

  Widget emptyNotifications() {
    return SizedBox(
        height: MediaQuery.of(context).size.height -
            (MediaQuery.of(context).padding.top +
                20.0 +
                MediaQuery.of(context).padding.bottom +
                90.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active,
              color: Theme.of(context).brightness == Brightness.light
                  ? cBlack
                  : cWhite,
              size: 40,
            ),
            const SizedBox(height: 15.0),
            Text(
              AppLocalization.of(context)
                  .translate("activities_screen", "no_notifications"),
              style: textStyleCustomMedium(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  14),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            )
          ],
        ));
  }

  Widget listNotifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppLocalization.of(context)
                  .translate("activities_screen", "notifications"),
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  20),
              textScaleFactor: 1.0,
            ),
            Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.hardEdge,
              child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    ref
                        .read(notificationsNotifierProvider.notifier)
                        .readAllNotifications();
                  },
                  icon: Icon(
                    Icons.checklist,
                    color: Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    size: 30,
                  )),
            )
          ],
        ),
        ...notifications!.map((notification) {
          int index = notifications!.indexOf(notification);
          return notificationItem(notification, index);
        }),
      ],
    );
  }

  Widget notificationItem(NotificationModel notification, int index) {

    return Column(
      children: [
        Slidable(
          key: UniqueKey(),
          endActionPane: ActionPane(
              motion: const DrawerMotion(),
              dismissible: DismissiblePane(onDismissed: () {
                ref
                    .read(notificationsNotifierProvider.notifier)
                    .removeNotification(notification);
              }),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    ref
                        .read(notificationsNotifierProvider.notifier)
                        .removeNotification(notification);
                  },
                  autoClose: true,
                  flex: 1,
                  backgroundColor: cRed,
                  foregroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                  icon: Icons.delete_forever_outlined,
                  label: AppLocalization.of(context)
                      .translate("activities_screen", "delete"),
                )
              ]),
          child: InkWell(
            onTap: () {
              ref
                  .read(notificationsNotifierProvider.notifier)
                  .readOneNotification(notification);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 45.0,
                    width: 45.0,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 35,
                            width: 35,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                      color: cBlue,
                                      blurRadius: 6,
                                      spreadRadius: 2)
                                ]),
                            child: Icon(
                              Icons.notifications_active,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? cBlack
                                  : cWhite,
                              size: 20,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              height: 7.5,
                              width: 7.5,
                              decoration: const BoxDecoration(
                                color: cBlue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.title,
                            style: textStyleCustomBold(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                16),
                            textScaleFactor: 1.0),
                        Text(notification.body,
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                14),
                            textScaleFactor: 1.0)
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Text(Helpers.readTimeStamp(context, int.parse(notification.timestamp)),
                        style: textStyleCustomMedium(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            12),
                        textScaleFactor: 1.0),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (index != notifications!.length - 1)
          const Divider(thickness: 1, color: cGrey)
      ],
    );
  }
}
