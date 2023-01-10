import 'package:flutter/material.dart';

class SnackBarCustom extends SnackBar {
  const SnackBarCustom({Key? key, required super.content}) : super(key: key);

  Widget build(BuildContext context) {
    return SnackBar(
      backgroundColor: Theme.of(context).canvasColor,
      elevation: 6,
      content: content,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(days: 365),
    );
  }
}
