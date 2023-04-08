import 'package:flutter/material.dart';

class CustomScrollBehavior extends ScrollBehavior {
  final Color overscrollColor;

  const CustomScrollBehavior({required this.overscrollColor});

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return GlowingOverscrollIndicator(
      color: overscrollColor,
      axisDirection: details.direction,
      showLeading: true,
      showTrailing: true,
      child: child,
    );
  }
}