import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/models/user_model.dart';

class TypingIndicator extends ConsumerStatefulWidget {
  final bool showIndicator;
  final Color bubbleColor;
  final Color flashingCircleDarkColor;
  final Color flashingCircleBrightColor;
  final Color colorThemeConv;
  final UserModel? user;

  const TypingIndicator(
      {super.key,
      this.showIndicator = false,
      required this.bubbleColor,
      required this.flashingCircleDarkColor,
      required this.flashingCircleBrightColor,
      required this.colorThemeConv,
      this.user});

  @override
  TypingIndicatorState createState() => TypingIndicatorState();
}

class TypingIndicatorState extends ConsumerState<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _appearanceController;

  late Animation<double> _indicatorSpaceAnimation;

  late Animation<double> _smallBubbleAnimation;
  late Animation<double> _mediumBubbleAnimation;
  late Animation<double> _largeBubbleAnimation;

  late AnimationController _repeatingController;
  final List<Interval> _dotIntervals = const [
    Interval(0.25, 0.8),
    Interval(0.35, 0.9),
    Interval(0.45, 1.0),
  ];

  @override
  void initState() {
    super.initState();

    _appearanceController = AnimationController(
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    _indicatorSpaceAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      reverseCurve: const Interval(0.0, 1.0, curve: Curves.easeOut),
    ).drive(Tween<double>(
      begin: 0.0,
      end: 70.0,
    ));

    _smallBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.0, 0.5, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.0, 0.3, curve: Curves.easeOut),
    );
    _mediumBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.2, 0.6, curve: Curves.easeOut),
    );
    _largeBubbleAnimation = CurvedAnimation(
      parent: _appearanceController,
      curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _repeatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.showIndicator) {
      _showIndicator();
    }
  }

  @override
  void didUpdateWidget(TypingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showIndicator != oldWidget.showIndicator) {
      if (widget.showIndicator) {
        _showIndicator();
      } else {
        _hideIndicator();
      }
    }
  }

  @override
  void dispose() {
    _appearanceController.dispose();
    _repeatingController.dispose();
    super.dispose();
  }

  void _showIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 750)
      ..forward();
    _repeatingController.repeat();
  }

  void _hideIndicator() {
    _appearanceController
      ..duration = const Duration(milliseconds: 150)
      ..reverse();
    _repeatingController.stop();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _indicatorSpaceAnimation,
      builder: (context, child) {
        return SizedBox(
          height: _indicatorSpaceAnimation.value,
          child: child,
        );
      },
      child: Row(
        children: [
          if (widget.user != null)
            Align(
              alignment: Alignment.bottomLeft,
              child: widget.user!.profilePictureUrl.trim() == ""
                  ? Container(
                      height: 25,
                      width: 25,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: widget.colorThemeConv),
                        color: cGrey.withOpacity(0.2),
                      ),
                      child: Icon(Icons.person,
                          color: widget.colorThemeConv, size: 15),
                    )
                  : CachedNetworkImageCustom(
                      profilePictureUrl: widget.user!.profilePictureUrl,
                      heightContainer: 25,
                      widthContainer: 25,
                      iconSize: 15,
                      colorTheme: widget.colorThemeConv),
            ),
          Expanded(
            child: Stack(
              children: [
                AnimatedBubble(
                  animation: _smallBubbleAnimation,
                  left: 4,
                  bottom: 15,
                  bubble: CircleBubble(
                    size: 8,
                    bubbleColor: widget.bubbleColor,
                  ),
                ),
                AnimatedBubble(
                  animation: _mediumBubbleAnimation,
                  left: 8,
                  bottom: 16,
                  bubble: CircleBubble(
                    size: 16,
                    bubbleColor: widget.bubbleColor,
                  ),
                ),
                AnimatedBubble(
                  animation: _largeBubbleAnimation,
                  left: 14,
                  bottom: 20,
                  bubble: StatusBubble(
                    repeatingController: _repeatingController,
                    dotIntervals: _dotIntervals,
                    flashingCircleDarkColor: widget.flashingCircleDarkColor,
                    flashingCircleBrightColor: widget.flashingCircleBrightColor,
                    bubbleColor: widget.bubbleColor,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CircleBubble extends StatelessWidget {
  const CircleBubble({
    super.key,
    required this.size,
    required this.bubbleColor,
  });

  final double size;
  final Color bubbleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: bubbleColor,
      ),
    );
  }
}

class AnimatedBubble extends StatelessWidget {
  const AnimatedBubble({
    super.key,
    required this.animation,
    required this.left,
    required this.bottom,
    required this.bubble,
  });

  final Animation<double> animation;
  final double left;
  final double bottom;
  final Widget bubble;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      bottom: bottom,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          return Transform.scale(
            scale: animation.value,
            alignment: Alignment.bottomLeft,
            child: child,
          );
        },
        child: bubble,
      ),
    );
  }
}

class StatusBubble extends StatelessWidget {
  const StatusBubble({
    super.key,
    required this.repeatingController,
    required this.dotIntervals,
    required this.flashingCircleBrightColor,
    required this.flashingCircleDarkColor,
    required this.bubbleColor,
  });

  final AnimationController repeatingController;
  final List<Interval> dotIntervals;
  final Color flashingCircleDarkColor;
  final Color flashingCircleBrightColor;
  final Color bubbleColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bubbleColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FlashingCircle(
            index: 0,
            repeatingController: repeatingController,
            dotIntervals: dotIntervals,
            flashingCircleDarkColor: flashingCircleDarkColor,
            flashingCircleBrightColor: flashingCircleBrightColor,
          ),
          FlashingCircle(
            index: 1,
            repeatingController: repeatingController,
            dotIntervals: dotIntervals,
            flashingCircleDarkColor: flashingCircleDarkColor,
            flashingCircleBrightColor: flashingCircleBrightColor,
          ),
          FlashingCircle(
            index: 2,
            repeatingController: repeatingController,
            dotIntervals: dotIntervals,
            flashingCircleDarkColor: flashingCircleDarkColor,
            flashingCircleBrightColor: flashingCircleBrightColor,
          ),
        ],
      ),
    );
  }
}

class FlashingCircle extends StatelessWidget {
  const FlashingCircle({
    super.key,
    required this.index,
    required this.repeatingController,
    required this.dotIntervals,
    required this.flashingCircleBrightColor,
    required this.flashingCircleDarkColor,
  });

  final int index;
  final AnimationController repeatingController;
  final List<Interval> dotIntervals;
  final Color flashingCircleDarkColor;
  final Color flashingCircleBrightColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repeatingController,
      builder: (context, child) {
        final circleFlashPercent = dotIntervals[index].transform(
          repeatingController.value,
        );
        final circleColorPercent = sin(pi * circleFlashPercent);

        return Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(
              flashingCircleDarkColor,
              flashingCircleBrightColor,
              circleColorPercent,
            ),
          ),
        );
      },
    );
  }
}
