import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:myyoukounkoun/components/custom_drawer.dart';
import 'package:myyoukounkoun/components/custom_nav_bar.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/libraries/env_config_lib.dart';
import 'package:myyoukounkoun/libraries/notifications_lib.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';
import 'package:myyoukounkoun/models/notification_model.dart';
import 'package:myyoukounkoun/providers/chat_provider.dart';
import 'package:myyoukounkoun/providers/check_valid_user_provider.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/route_observer.dart';
import 'package:myyoukounkoun/router.dart';
import 'package:myyoukounkoun/views/auth/validate_user.dart';

class BottomNavController extends ConsumerStatefulWidget {
  const BottomNavController({super.key});

  @override
  BottomNavControllerState createState() => BottomNavControllerState();
}

class BottomNavControllerState extends ConsumerState<BottomNavController>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isKeyboard = false;

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  Future _validateUserBottomSheet(BuildContext context) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: false,
        builder: (context) {
          return const RouteObserverWidget(
              name: validateUser, child: ValidateUser());
        });
  }

  Future<void> setActivities() async {
    //logique back à mettre en place mais plus avec un stream builder et via firebase firestore pour la partie set chat
    List<ConversationModel> conversationsUser = [];
    for (var conv in conversationsDatasMockes) {
      for (var user in conv.users) {
        if (user["id"] == ref.read(userNotifierProvider).id) {
          conversationsUser.add(conv);
        }
      }
    }

    if (conversationsUser.isNotEmpty) {
      conversationsUser.sort((a, b) => int.parse(b.timestampLastMessage)
          .compareTo(int.parse(a.timestampLastMessage)));
      ref
          .read(conversationsNotifierProvider.notifier)
          .setConversations(conversationsUser);
    } else {
      ref.read(conversationsNotifierProvider.notifier).setConversations([]);
    }

    //logic back à mettre en place ici (à voir si j'utilise stream builder ou pas pour les notifs au final) pour la partie set notif
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
    WidgetsBinding.instance.addObserver(this);

    NotificationsLib.notificationsLogicController(context, ref, this);

    tabControllerBottomNav ??=
        TabController(length: 4, initialIndex: 0, vsync: this);
    tabControllerBottomNav!.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(userNotifierProvider).validEmail &&
          !ref.read(checkValidUserNotifierProvider)) {
        _validateUserBottomSheet(navAuthKey.currentContext!);
      }

      //set chat and notifications current user
      setActivities();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed &&
        _appLifecycleState != AppLifecycleState.resumed) {
      await NotificationsLib.setActiveNotifications(ref);
    }
    _appLifecycleState = state;
  }

  @override
  void deactivate() {
    tabControllerBottomNav!.removeListener(() {
      setState(() {});
    });
    super.deactivate();
  }

  @override
  void dispose() {
    tabControllerBottomNav!.dispose();
    tabControllerBottomNav = null;

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isKeyboard = ref.watch(visibleKeyboardAppNotifierProvider);

    return Scaffold(
      key: EnvironmentConfigLib().getEnvironmentBottomNavBar
          ? null
          : drawerScaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      endDrawer: EnvironmentConfigLib().getEnvironmentBottomNavBar
          ? null
          : CustomDrawer(tabController: tabControllerBottomNav!),
      body: EnvironmentConfigLib().getEnvironmentBottomNavBar
          ? Stack(
              children: [
                TabBarView(
                    controller: tabControllerBottomNav,
                    physics: const NeverScrollableScrollPhysics(),
                    children: tabNavs()),
                !_isKeyboard
                    ? CustomNavBar(tabController: tabControllerBottomNav!)
                    : const SizedBox()
              ],
            )
          : TabBarView(
              controller: tabControllerBottomNav,
              physics: const NeverScrollableScrollPhysics(),
              children: tabNavs()),
    );
  }

  List<Widget> tabNavs() {
    return [
      NavigatorPopHandler(
        child: Navigator(
          key: navHomeKey,
          initialRoute: home,
          onGenerateRoute: (settings) =>
              generateRouteAuthHome(settings, context),
        ),
      ),
      NavigatorPopHandler(
        child: Navigator(
          key: navSearchKey,
          initialRoute: search,
          onGenerateRoute: (settings) =>
              generateRouteAuthSearch(settings, context),
        ),
      ),
      NavigatorPopHandler(
        child: Navigator(
            key: navActivitiesKey,
            initialRoute: activities,
            onGenerateRoute: (settings) =>
                generateRouteAuthActivities(settings, context)),
      ),
      NavigatorPopHandler(
        child: Navigator(
          key: navProfileKey,
          initialRoute: profile,
          onGenerateRoute: (settings) =>
              generateRouteAuthProfile(settings, context),
        ),
      ),
    ];
  }
}
