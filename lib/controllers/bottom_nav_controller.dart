import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/components/custom_drawer.dart';
import 'package:myyoukounkoun/components/custom_nav_bar.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/libraries/env_config_lib.dart';
import 'package:myyoukounkoun/libraries/notifications_lib.dart';
import 'package:myyoukounkoun/providers/check_valid_user_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/route_observer.dart';
import 'package:myyoukounkoun/router.dart';
import 'package:myyoukounkoun/views/auth/validate_user.dart';

class BottomNavController extends ConsumerStatefulWidget {
  const BottomNavController({Key? key}) : super(key: key);

  @override
  BottomNavControllerState createState() => BottomNavControllerState();
}

class BottomNavControllerState extends ConsumerState<BottomNavController>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isKeyboard = false;

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

    navHomeKey = GlobalKey<NavigatorState>();
    navSearchKey = GlobalKey<NavigatorState>();
    navActivitiesKey = GlobalKey<NavigatorState>();
    navProfileKey = GlobalKey<NavigatorState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(userNotifierProvider).validEmail &&
          !ref.read(checkValidUserNotifierProvider)) {
        _validateUserBottomSheet(navAuthKey.currentContext!);
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await NotificationsLib.setActiveNotifications(ref);
    }
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

    return WillPopScope(
        onWillPop: () async {
          if (tabControllerBottomNav!.index == 0) {
            return !(await navHomeKey!.currentState!.maybePop());
          } else if (tabControllerBottomNav!.index == 1) {
            return !(await navSearchKey!.currentState!.maybePop());
          } else if (tabControllerBottomNav!.index == 2) {
            return !(await navActivitiesKey!.currentState!.maybePop());
          } else if (tabControllerBottomNav!.index == 3) {
            return !(await navProfileKey!.currentState!.maybePop());
          } else {
            return false;
          }
        },
        child: Scaffold(
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
        ));
  }

  List<Widget> tabNavs() {
    return [
      Navigator(
        key: navHomeKey,
        initialRoute: home,
        onGenerateRoute: (settings) => generateRouteAuthHome(settings, context),
      ),
      Navigator(
        key: navSearchKey,
        initialRoute: search,
        onGenerateRoute: (settings) =>
            generateRouteAuthSearch(settings, context),
      ),
      Navigator(
          key: navActivitiesKey,
          initialRoute: activities,
          onGenerateRoute: (settings) =>
              generateRouteAuthActivities(settings, context)),
      Navigator(
        key: navProfileKey,
        initialRoute: profile,
        onGenerateRoute: (settings) =>
            generateRouteAuthProfile(settings, context),
      ),
    ];
  }
}
