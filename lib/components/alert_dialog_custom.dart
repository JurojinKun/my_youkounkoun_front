import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AlertDialogCustom extends ConsumerStatefulWidget {
  final Color backgroundColor;
  final ShapeBorder shape;
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  const AlertDialogCustom(
      {Key? key,
      required this.backgroundColor,
      required this.shape,
      required this.title,
      required this.content,
      required this.actions})
      : super(key: key);

  @override
  AlertDialogCustomState createState() => AlertDialogCustomState();
}

class AlertDialogCustomState extends ConsumerState<AlertDialogCustom> {
  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CupertinoAlertDialog(
            title: widget.title,
            content: widget.content,
            actions: widget.actions,
          )
        : AlertDialog(
            backgroundColor: widget.backgroundColor,
            shape: widget.shape,
            title: widget.title,
            content: widget.content,
            actions: widget.actions,
          );
  }
}
