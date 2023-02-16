import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/providers/current_route_app_provider.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';

class RouteObserverWidget extends ConsumerStatefulWidget {
  final String name;
  final Widget child;

  const RouteObserverWidget({Key? key, required this.name, required this.child})
      : super(key: key);

  @override
  RouteObserverWidgetState createState() => RouteObserverWidgetState();
}

// Implement RouteAware in a widget's state and subscribe it to the RouteObserver.
class RouteObserverWidgetState extends ConsumerState<RouteObserverWidget>
    with RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  // Called when the current route has been pushed.
  void didPush() {
    if (kDebugMode) {
      print('didPush ${widget.name}');
    }
    Future.delayed(Duration.zero, () {
      if (mounted) {
        ref
            .read(currentRouteAppNotifierProvider.notifier)
            .setCurrentRouteApp(widget.name, context, ref);
      }
    });
  }

  @override
  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    if (kDebugMode) {
      print('didPopNext ${widget.name}');
    }
    Future.delayed(Duration.zero, () {
      if (mounted) {
        ref
            .read(visibleKeyboardAppNotifierProvider.notifier)
            .clearVisibleKeyboard();
        ref
            .read(currentRouteAppNotifierProvider.notifier)
            .setCurrentRouteApp(widget.name, context, ref);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
