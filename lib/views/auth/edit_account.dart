import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/models/user_model.dart';
import 'package:my_boilerplate/providers/user_provider.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';

class EditAccount extends ConsumerStatefulWidget {
  const EditAccount({Key? key}) : super(key: key);

  @override
  EditAccountState createState() => EditAccountState();
}

class EditAccountState extends ConsumerState<EditAccount> {
  late User user;

  @override
  Widget build(BuildContext context) {
    user = ref.watch(userNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        systemOverlayStyle: Theme.of(context).brightness == Brightness.light
            ? Platform.isIOS
                ? SystemUiOverlayStyle.dark
                : const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark)
            : Platform.isIOS
                ? SystemUiOverlayStyle.light
                : const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light),
        leading: IconButton(
            onPressed: () => navAuthKey.currentState!.pop(),
            icon: Icon(Icons.arrow_back_ios,
                color: Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite)),
        title: Text(
          AppLocalization.of(context)
              .translate("edit_account_screen", "my_account"),
          style: textStyleCustomBold(
              Theme.of(context).brightness == Brightness.light
                  ? cBlack
                  : cWhite,
              20),
          textScaleFactor: 1.0,
        ),
      ),
    );
  }
}
