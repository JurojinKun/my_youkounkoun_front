import 'dart:io';
import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class ForgotPassword extends ConsumerStatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  ForgotPasswordState createState() => ForgotPasswordState();
}

class ForgotPasswordState extends ConsumerState<ForgotPassword> {
  late TextEditingController _mailController;
  late FocusNode _mailFocusNode;

  bool _loadingForgotPassword = false;

  AppBar appBar = AppBar();

  Future _showDialogSendForgotPassword(BuildContext context) async {
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
                            .translate("forgot_password_screen", "send_mail"),
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

  Future _showDialogErrorSendForgotPassword(BuildContext context) async {
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
                            "forgot_password_screen", "error_send_mail"),
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

  Future _tryForgotPassword() async {
    try {
      //logic send mail forgot password
      await Future.delayed(const Duration(seconds: 2),
          () => _showDialogSendForgotPassword(context));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      _showDialogErrorSendForgotPassword(context);
    }
  }

  @override
  void initState() {
    super.initState();

    _mailController = TextEditingController();
    _mailFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _mailController.dispose();
    _mailFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Helpers.hideKeyboard(context),
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
                      .translate("forgot_password_screen", "forgot_password"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      20),
                  textScaleFactor: 1.0,
                ),
                centerTitle: false,
                actions: [
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                        onPressed: () => navNonAuthKey.currentState!.pop(),
                        icon: Icon(Icons.clear,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite)),
                  )
                ],
              ),
            ),
          ),
        ),
        body: SizedBox.expand(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(25.0, MediaQuery.of(context).padding.top + appBar.preferredSize.height + 20.0, 25.0, 0.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Image.asset("assets/images/ic_app.png", height: 125, width: 125),
            const SizedBox(
              height: 25.0,
            ),
            Text("My youkounkoun",
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    33),
                textAlign: TextAlign.center,
                textScaleFactor: 1.0),
            const SizedBox(height: 45.0),
            Text(
              AppLocalization.of(context)
                  .translate("forgot_password_screen", "content"),
              style: textStyleCustomMedium(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  14),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            ),
            const SizedBox(height: 45.0),
            TextField(
              controller: _mailController,
              focusNode: _mailFocusNode,
              maxLines: 1,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              onChanged: (val) {
                setState(() {
                  val = _mailController.text;
                });
              },
              onSubmitted: (val) {
                Helpers.hideKeyboard(context);
              },
              decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: textStyleCustomRegular(
                      cGrey, 14 / MediaQuery.of(context).textScaleFactor),
                  labelStyle: textStyleCustomRegular(
                      cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                  prefixIcon: Icon(Icons.mail,
                      color: _mailFocusNode.hasFocus ? cBlue : cGrey),
                  suffixIcon: _mailController.text.isNotEmpty
                      ? Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _mailController.clear();
                                });
                              },
                              icon: Icon(
                                Icons.clear,
                                color: _mailFocusNode.hasFocus ? cBlue : cGrey,
                              )),
                        )
                      : const SizedBox()),
            ),
            const SizedBox(
              height: 55.0,
            ),
            SizedBox(
                height: 50.0,
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                    onPressed: () async {
                      if (_mailController.text.isNotEmpty &&
                          EmailValidator.validate(_mailController.text)) {
                        setState(() {
                          _loadingForgotPassword = true;
                        });
                        await _tryForgotPassword();
                        setState(() {
                          _loadingForgotPassword = false;
                        });
                      }
                    },
                    child: _loadingForgotPassword
                        ? SizedBox(
                            height: 15,
                            width: 15,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? cBlack
                                    : cWhite,
                                strokeWidth: 1.0,
                              ),
                            ),
                          )
                        : Text(
                            AppLocalization.of(context)
                                .translate("general", "btn_send"),
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                20),
                            textScaleFactor: 1.0))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
