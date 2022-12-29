import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/providers/check_valid_user_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ValidateUser extends ConsumerStatefulWidget {
  const ValidateUser({Key? key}) : super(key: key);

  @override
  ValidateUserState createState() => ValidateUserState();
}

class ValidateUserState extends ConsumerState<ValidateUser> {
  late TextEditingController _codeController;

  bool _isCheckLoading = false;

  AppBar appBar = AppBar();

  Future _showDialogSendCode(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
          return Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40.0,
                    width: 40.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite)),
                    child: Icon(Icons.check,
                        color: Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite),
                  ),
                  const SizedBox(height: 15.0),
                  Material(
                    type: MaterialType.transparency,
                    child: Text(
                        AppLocalization.of(context)
                            .translate("validate_user_screen", "send_mail"),
                        textScaleFactor: 1.0,
                        style: textStyleCustomMedium(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            16),
                        textAlign: TextAlign.center),
                  )
                ],
              ),
            ),
          );
        });
  }

  Future _showDialogErrorSendCode(BuildContext context) async {
    return showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          Future.delayed(const Duration(seconds: 2), () {
            Navigator.pop(context);
          });
          return Center(
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40.0,
                    width: 40.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite)),
                    child: Icon(Icons.clear,
                        color: Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite),
                  ),
                  const SizedBox(height: 15.0),
                  Material(
                    type: MaterialType.transparency,
                    child: Text(
                        AppLocalization.of(context).translate(
                            "validate_user_screen", "error_send_mail"),
                        textScaleFactor: 1.0,
                        style: textStyleCustomMedium(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            16),
                        textAlign: TextAlign.center),
                  )
                ],
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();

    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Helpers.hideKeyboard(context),
      onHorizontalDragStart: (details) async {
        if (Platform.isIOS && details.globalPosition.dx <= 70) {
          await ref
              .read(checkValidUserNotifierProvider.notifier)
              .checkValidUser();
          navAuthKey.currentState!.pop();
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          await ref
              .read(checkValidUserNotifierProvider.notifier)
              .checkValidUser();
          navAuthKey.currentState!.pop();
          return false;
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: Size(
                MediaQuery.of(context).size.width, appBar.preferredSize.height),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  systemOverlayStyle:
                      Theme.of(context).brightness == Brightness.light
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
                  title: Text(
                    AppLocalization.of(context)
                        .translate("validate_user_screen", "check_account"),
                    style: textStyleCustomBold(
                        Theme.of(context).brightness == Brightness.light
                            ? Colors.black
                            : Colors.white,
                        20),
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                  ),
                  centerTitle: false,
                  actions: [
                    Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: IconButton(
                          onPressed: () async {
                            await ref
                                .read(checkValidUserNotifierProvider.notifier)
                                .checkValidUser();
                            navAuthKey.currentState!.pop();
                          },
                          icon: Icon(
                            Icons.clear,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? Colors.black
                                    : Colors.white,
                          )),
                    )
                  ],
                ),
              ),
            ),
          ),
          body: SizedBox.expand(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  20.0,
                  MediaQuery.of(context).padding.top +
                      appBar.preferredSize.height +
                      20.0,
                  20.0,
                  MediaQuery.of(context).padding.bottom + 20.0),
              physics: const AlwaysScrollableScrollPhysics(
                  ),
              child: Column(
                children: [
                  Image.asset("assets/images/ic_app.png",
                      height: 125, width: 125),
                  const SizedBox(height: 20.0),
                  Text(
                    AppLocalization.of(context)
                        .translate("validate_user_screen", "content"),
                    style: textStyleCustomMedium(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        14),
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                  ),
                  TextButton(
                      onPressed: () {
                        //set logic send code mail user
                        try {
                          if (kDebugMode) {
                            print(ref.read(userNotifierProvider).email);
                          }
                          _showDialogSendCode(context);
                        } catch (e) {
                          if (kDebugMode) {
                            print(e);
                          }
                          _showDialogErrorSendCode(context);
                        }
                      },
                      child: Text(
                          AppLocalization.of(context)
                              .translate("validate_user_screen", "send_code"),
                          style: textStyleCustomBold(cBlue, 14.0),
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0)),
                  const SizedBox(
                    height: 60.0,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: PinCodeTextField(
                        appContext: context,
                        textStyle: textStyleCustomBold(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            18 / MediaQuery.of(context).textScaleFactor),
                        length: 6,
                        animationType: AnimationType.fade,
                        autoDisposeControllers: false,
                        pinTheme: PinTheme(
                            shape: PinCodeFieldShape.underline,
                            fieldHeight: 30,
                            fieldWidth: 30,
                            activeColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                            inactiveColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                            selectedColor:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite),
                        cursorColor:
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                        animationDuration: const Duration(milliseconds: 300),
                        controller: _codeController,
                        keyboardType: TextInputType.number,
                        onCompleted: (value) {
                          Helpers.hideKeyboard(context);
                        },
                        onChanged: (value) {
                          setState(() {
                            value = _codeController.text;
                          });
                        },
                        enablePinAutofill: false,
                      )),
                      const SizedBox(height: 30.0),
                  SizedBox(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        onPressed: () async {
                          if (_codeController.text.isNotEmpty &&
                              _codeController.text.length == 6) {
                            setState(() {
                              _isCheckLoading = true;
                            });
                            //set logic ws check code
                            await Future.delayed(const Duration(seconds: 2),
                                () {
                              ref
                                  .read(checkValidUserNotifierProvider.notifier)
                                  .checkValidUser();
                              navAuthKey.currentState!.pop();
                            });
                            setState(() {
                              _isCheckLoading = false;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: cBlue,
                            foregroundColor: cWhite,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            )),
                        child: _isCheckLoading
                            ? SizedBox(
                                height: 15.0,
                                width: 15.0,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 1.0,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                  ),
                                ),
                              )
                            : Text(
                                AppLocalization.of(context).translate(
                                    "validate_user_screen", "check_validity"),
                                textScaleFactor: 1.0,
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    20),
                              )),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
