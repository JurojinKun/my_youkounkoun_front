import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/route_observer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/nonAuth/forgot_password.dart';

class Login extends ConsumerStatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  LoginState createState() => LoginState();
}

class LoginState extends ConsumerState<Login> {
  late TextEditingController _mailController, _passwordController;
  late FocusNode _mailFocusNode, _passwordFocusNode;

  bool _passwordObscure = true;
  bool _loadingLogin = false;
  bool _isKeyboard = false;
  bool _swipeBack = false;

  AppBar appBar = AppBar();

  Future _forgotPasswordBottomSheet(BuildContext context) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: false,
        builder: (context) {
          return const RouteAwareWidget(
              name: forgotPassword, child: ForgotPassword());
        });
  }

  Future<void> _tryLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", "tokenTest1234");
    ref.read(userNotifierProvider.notifier).initUser(User(
        id: 1,
        token: "tokenTest1234",
        email: "ccommunay@gmail.com",
        pseudo: "0ruj",
        gender: "Male",
        birthday: "1997-06-06 00:00",
        nationality: "FR",
        profilePictureUrl: "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
        validCGU: true,
        validPrivacyPolicy: true,
        validEmail: false));
    ref
        .read(recentSearchesNotifierProvider.notifier)
        .initRecentSearches(recentSearchesDatasMockes);
  }

  @override
  void initState() {
    super.initState();

    _mailController = TextEditingController();
    _passwordController = TextEditingController();

    _mailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {

    _mailController.dispose();
    _passwordController.dispose();

    _mailFocusNode.dispose();
    _passwordFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isKeyboard = ref.watch(visibleKeyboardAppNotifierProvider);
    
    return GestureDetector(
      onTap: () => Helpers.hideKeyboard(context),
      onHorizontalDragUpdate: (details) async {
        int sensitivity = 8;
        if (Platform.isIOS &&
            details.delta.dx > sensitivity &&
            details.globalPosition.dx <= 70 &&
            !_swipeBack) {
          _swipeBack = true;
          if (_isKeyboard) {
            Helpers.hideKeyboard(context);
            await Future.delayed(const Duration(milliseconds: 200));
          }
          navNonAuthKey.currentState!.pop();
          if (mounted) {
            _swipeBack = false;
          }
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          navNonAuthKey.currentState!.pop();
          return false;
        },
        child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            extendBodyBehindAppBar: true,
            appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width,
                  appBar.preferredSize.height),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
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
                    leading: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: IconButton(
                          onPressed: () async {
                            if (_isKeyboard) {
                              Helpers.hideKeyboard(context);
                              await Future.delayed(
                                  const Duration(milliseconds: 200));
                            }
                            navNonAuthKey.currentState!.pop();
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                          )),
                    ),
                    title: Text(
                        AppLocalization.of(context)
                            .translate("login_screen", "login"),
                        style: textStyleCustomBold(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            20),
                        textScaleFactor: 1.0),
                    centerTitle: false,
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
                    Image.asset("assets/images/ic_app.png",
                        height: 125, width: 125),
                    const SizedBox(
                      height: 55.0,
                    ),
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
                        FocusScope.of(context).requestFocus(_passwordFocusNode);
                      },
                      style: textStyleCustomRegular(
                          _mailFocusNode.hasFocus ? cBlue : cGrey,
                          14 / MediaQuery.of(context).textScaleFactor),
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(top: 15.0, left: 15.0),
                          hintText: AppLocalization.of(context)
                              .translate("login_screen", "mail"),
                          hintStyle: textStyleCustomRegular(cGrey,
                              14 / MediaQuery.of(context).textScaleFactor),
                          labelStyle: textStyleCustomRegular(cBlue,
                              14 / MediaQuery.of(context).textScaleFactor),
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
                                        color: _mailFocusNode.hasFocus
                                            ? cBlue
                                            : cGrey,
                                      )),
                                )
                              : const SizedBox()),
                    ),
                    const SizedBox(
                      height: 55.0,
                    ),
                    TextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      maxLines: 1,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.text,
                      obscureText: _passwordObscure,
                      onChanged: (val) {
                        setState(() {
                          val = _passwordController.text;
                        });
                      },
                      onSubmitted: (val) async {
                        Helpers.hideKeyboard(context);
                        if (_mailController.text.isNotEmpty &&
                            EmailValidator.validate(_mailController.text) &&
                            _passwordController.text.isNotEmpty) {
                          setState(() {
                            _loadingLogin = true;
                          });
                          await _tryLogin();
                          setState(() {
                            _loadingLogin = false;
                          });
                        }
                      },
                      style: textStyleCustomRegular(
                          _passwordFocusNode.hasFocus ? cBlue : cGrey,
                          14 / MediaQuery.of(context).textScaleFactor),
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(top: 15.0, left: 15.0),
                          hintText: AppLocalization.of(context)
                              .translate("login_screen", "password"),
                          hintStyle: textStyleCustomRegular(cGrey,
                              14 / MediaQuery.of(context).textScaleFactor),
                          labelStyle: textStyleCustomRegular(cBlue,
                              14 / MediaQuery.of(context).textScaleFactor),
                          prefixIcon: Icon(Icons.lock,
                              color:
                                  _passwordFocusNode.hasFocus ? cBlue : cGrey),
                          suffixIcon: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _passwordObscure = !_passwordObscure;
                                  });
                                },
                                icon: Icon(
                                  _passwordObscure
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: _passwordFocusNode.hasFocus
                                      ? cBlue
                                      : cGrey,
                                )),
                          )),
                    ),
                    const SizedBox(height: 10.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                          onPressed: () => _forgotPasswordBottomSheet(context),
                          child: Text(
                            AppLocalization.of(context)
                                .translate("login_screen", "forgot_password"),
                            style: textStyleCustomMedium(cBlue, 14),
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.0,
                          )),
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
                                  EmailValidator.validate(
                                      _mailController.text) &&
                                  _passwordController.text.isNotEmpty) {
                                setState(() {
                                  _loadingLogin = true;
                                });
                                await _tryLogin();
                                setState(() {
                                  _loadingLogin = false;
                                });
                              }
                            },
                            child: _loadingLogin
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
                                        .translate("login_screen", "login"),
                                    style: textStyleCustomMedium(
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? cBlack
                                            : cWhite,
                                        20),
                                    textScaleFactor: 1.0))),
                    const SizedBox(
                      height: 15.0,
                    ),
                    RichText(
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.0,
                        text: TextSpan(
                            text: AppLocalization.of(context)
                                .translate("login_screen", "no_account"),
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                14),
                            children: [
                              TextSpan(
                                  text: AppLocalization.of(context)
                                      .translate("login_screen", "sign_up"),
                                  style: textStyleCustomMedium(cBlue, 14),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => navNonAuthKey.currentState!
                                        .pushNamed(register)),
                            ]))
                  ],
                ),
              ),
            )),
      ),
    );
  }
}
