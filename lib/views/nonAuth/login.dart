import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/libraries/sync_shared_prefs_lib.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/route_observer.dart';
import 'package:email_validator/email_validator.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/nonAuth/forgot_password.dart';

class Login extends ConsumerStatefulWidget {
  const Login({super.key});

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
          return const RouteObserverWidget(
              name: forgotPassword, child: ForgotPassword());
        });
  }

  Future<void> _tryLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    Map<String, dynamic> userMap = {
      "id": 1,
      "token": "tokenTest1234",
      "email": "ccommunay@gmail.com",
      "pseudo": "0ruj",
      "gender": "Male",
      "birthday": "1997-06-06 00:00",
      "nationality": "FR",
      "profilePictureUrl": "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
      "followers": [],
      "followings": [],
      "bio":
          "Je suis la bio donc à voir ce que ça donne au niveau de l'affichage du profil",
      "validCGU": true,
      "validPrivacyPolicy": true,
      "validEmail": false
    };
    String encodedUserMap = json.encode(userMap);
    SyncSharedPrefsLib().prefs!.setString("user", encodedUserMap);
    ref
        .read(userNotifierProvider.notifier)
        .setUser(UserModel.fromJSON(userMap));
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
                  systemOverlayStyle: Helpers.uiOverlayApp(context),
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
                          color: Helpers.uiApp(context),
                        )),
                  ),
                  title: Text(
                      AppLocalization.of(context)
                          .translate("login_screen", "login"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 20),
                      textScaler: const TextScaler.linear(1.0)),
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
                  Image.asset("assets/images/ic_app_new.png",
                      height: 125, width: 125),
                  const SizedBox(
                    height: 25.0,
                  ),
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
                          text: AppLocalization.of(context)
                              .translate("login_screen", "mail"),
                          style:
                              textStyleCustomBold(Helpers.uiApp(context), 18),
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
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: cBlue,
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
                        MediaQuery.of(context).textScaler.scale(14)),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      hintText: AppLocalization.of(context)
                          .translate("login_screen", "mail"),
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
                                    color: _mailFocusNode.hasFocus
                                        ? cBlue
                                        : cGrey,
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
                    height: 20.0,
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(children: [
                        WidgetSpan(
                            child: Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child: Icon(Icons.lock,
                              size: 20, color: Helpers.uiApp(context)),
                        )),
                        TextSpan(
                          text: AppLocalization.of(context)
                              .translate("login_screen", "password"),
                          style:
                              textStyleCustomBold(Helpers.uiApp(context), 18),
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
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    maxLines: 1,
                    textInputAction: TextInputAction.done,
                    keyboardType: TextInputType.text,
                    obscureText: _passwordObscure,
                    cursorColor: cBlue,
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
                        MediaQuery.of(context).textScaler.scale(14)),
                    decoration: InputDecoration(
                      contentPadding:
                          const EdgeInsets.fromLTRB(12, 12, 12, 12),
                      hintText: AppLocalization.of(context)
                          .translate("login_screen", "password"),
                      hintStyle: textStyleCustomRegular(
                          cGrey, MediaQuery.of(context).textScaler.scale(14)),
                      labelStyle: textStyleCustomRegular(
                          cBlue, MediaQuery.of(context).textScaler.scale(14)),
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
                              color:
                                  _passwordFocusNode.hasFocus ? cBlue : cGrey,
                            )),
                      ),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            color:
                                _passwordFocusNode.hasFocus ? cBlue : cGrey,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            color:
                                _passwordFocusNode.hasFocus ? cBlue : cGrey,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            color:
                                _passwordFocusNode.hasFocus ? cBlue : cGrey,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                      focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 2.0,
                            color:
                                _passwordFocusNode.hasFocus ? cBlue : cGrey,
                          ),
                          borderRadius: BorderRadius.circular(10.0)),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                        onPressed: () => _forgotPasswordBottomSheet(context),
                        child: Text(
                          AppLocalization.of(context)
                              .translate("login_screen", "forgot_password"),
                          style: textStyleCustomMedium(cBlue, 14),
                          textAlign: TextAlign.center,
                          textScaler: const TextScaler.linear(1.0),
                        )),
                  ),
                  const SizedBox(
                    height: 20.0,
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
                          style: ElevatedButton.styleFrom(
                              backgroundColor: cBlue),
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
                                  textScaler: const TextScaler.linear(1.0)))),
                  const SizedBox(
                    height: 15.0,
                  ),
                  RichText(
                      textAlign: TextAlign.center,
                      textScaler: const TextScaler.linear(1.0),
                      text: TextSpan(
                          text: AppLocalization.of(context)
                              .translate("login_screen", "no_account"),
                          style: textStyleCustomMedium(
                              Helpers.uiApp(context), 14),
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
    );
  }
}
