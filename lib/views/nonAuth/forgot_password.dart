import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
                        border: Border.all(color: Helpers.uiApp(context))),
                    child: Icon(Icons.check, color: Helpers.uiApp(context)),
                  ),
                  const SizedBox(height: 15.0),
                  Material(
                    type: MaterialType.transparency,
                    child: Text(
                        AppLocalization.of(context)
                            .translate("forgot_password_screen", "send_mail"),
                        textScaler: const TextScaler.linear(1.0),
                        style:
                            textStyleCustomMedium(Helpers.uiApp(context), 16),
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
                        border: Border.all(color: Helpers.uiApp(context))),
                    child: Icon(Icons.clear, color: Helpers.uiApp(context)),
                  ),
                  const SizedBox(height: 15.0),
                  Material(
                    type: MaterialType.transparency,
                    child: Text(
                        AppLocalization.of(context).translate(
                            "forgot_password_screen", "error_send_mail"),
                        textScaler: const TextScaler.linear(1.0),
                        style:
                            textStyleCustomMedium(Helpers.uiApp(context), 16),
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
      if (!mounted) return;
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
                systemOverlayStyle: Helpers.uiOverlayApp(context),
                title: Text(
                  AppLocalization.of(context)
                      .translate("forgot_password_screen", "forgot_password"),
                  style: textStyleCustomBold(Helpers.uiApp(context), 20),
                  textScaler: const TextScaler.linear(1.0),
                ),
                centerTitle: false,
                actions: [
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                        onPressed: () => navNonAuthKey.currentState!.pop(),
                        icon: Icon(Icons.clear, color: Helpers.uiApp(context))),
                  )
                ],
              ),
            ),
          ),
        ),
        body: SizedBox.expand(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                25.0,
                MediaQuery.of(context).padding.top +
                    appBar.preferredSize.height +
                    20.0,
                25.0,
                MediaQuery.of(context).padding.bottom + 20.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Image.asset("assets/images/ic_app_new.png",
                    height: 125, width: 125),
                const SizedBox(height: 25.0),
                Text(
                  AppLocalization.of(context)
                      .translate("forgot_password_screen", "content"),
                  style: textStyleCustomMedium(Helpers.uiApp(context), 14),
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1.0),
                ),
                const SizedBox(height: 45.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: RichText(
                    text: TextSpan(children: [
                      WidgetSpan(
                          child: Padding(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: Icon(Icons.mail,
                            size: 20, color: Helpers.uiApp(context)),
                      )),
                      TextSpan(
                        text: "Email",
                        style: textStyleCustomBold(Helpers.uiApp(context), 18),
                      )
                    ]),
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextField(
                  scrollPhysics: const BouncingScrollPhysics(),
                  controller: _mailController,
                  focusNode: _mailFocusNode,
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  cursorColor: cBlue,
                  onChanged: (val) {
                    setState(() {
                      val = _mailController.text;
                    });
                  },
                  onSubmitted: (val) {
                    Helpers.hideKeyboard(context);
                  },
                  style: textStyleCustomRegular(
                      _mailFocusNode.hasFocus ? cBlue : cGrey,
                      MediaQuery.of(context).textScaler.scale(14)),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(top: 15.0, left: 15.0),
                    hintText: "Email",
                    hintStyle: textStyleCustomRegular(
                        cGrey, MediaQuery.of(context).textScaler.scale(14)),
                    labelStyle: textStyleCustomRegular(
                        cBlue, MediaQuery.of(context).textScaler.scale(14)),
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
                                  color:
                                      _mailFocusNode.hasFocus ? cBlue : cGrey,
                                )),
                          )
                        : const SizedBox(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _mailFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _mailFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _mailFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _mailFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
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
                        style: ElevatedButton.styleFrom(backgroundColor: cBlue),
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
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    20),
                                textScaler: const TextScaler.linear(1.0)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
