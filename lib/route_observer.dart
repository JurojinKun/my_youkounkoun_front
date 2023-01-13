import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/providers/current_route_app_provider.dart';

class RouteAwareWidget extends ConsumerStatefulWidget {
  final String name;
  final Widget child;

  const RouteAwareWidget({Key? key, required this.name, required this.child})
      : super(key: key);

  @override
  RouteAwareWidgetState createState() => RouteAwareWidgetState();
}

// Implement RouteAware in a widget's state and subscribe it to the RouteObserver.
class RouteAwareWidgetState extends ConsumerState<RouteAwareWidget>
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
    print('didPush ${widget.name}');
    Future.delayed(Duration.zero, () {
      ref
          .read(currentRouteAppNotifierProvider.notifier)
          .setCurrentRouteApp(widget.name, context, ref);
    });
  }

  @override
  // Called when the top route has been popped off, and the current route shows up.
  void didPopNext() {
    print('didPopNext ${widget.name}');
    Future.delayed(
        Duration.zero,
        () => ref
            .read(currentRouteAppNotifierProvider.notifier)
            .setCurrentRouteApp(widget.name, context, ref));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
