import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:email_validator/email_validator.dart';

import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/helpers/helpers.dart';
import 'package:my_boilerplate/models/user_model.dart';
import 'package:my_boilerplate/providers/user_provider.dart';

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

  Future<void> _tryLogin() async {
    await Future.delayed(const Duration(seconds: 2));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", "tokenTest1234");
    ref.read(userNotifierProvider.notifier).initUser(User(
        id: 1,
        token: "tokenTest1234",
        email: "ccommunay@gmail.com",
        pseudo: "0ruj",
        gender: "male",
        age: 25,
        nationality: "French",
        profilePictureUrl:
            "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg:large",
        validCGU: true,
        validPrivacyPolicy: true,
        validEmail: true));
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
    return GestureDetector(
      onTap: () => Helpers.hideKeyboard(context),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: IconButton(
              onPressed: () => navNonAuthKey.currentState!.pop(),
              icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite,
              )),
          title: Text(
              AppLocalization.of(context).translate("login_screen", "login"),
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  23),
              textScaleFactor: 1.0),
          centerTitle: false,
        ),
        body: Center(
          child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            children: [
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
                decoration: InputDecoration(
                    hintText: AppLocalization.of(context)
                        .translate("login_screen", "mail"),
                    hintStyle: textStyleCustomRegular(Colors.grey,
                        14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(cBlue,
                        14 / MediaQuery.of(context).textScaleFactor),
                    prefixIcon: Icon(Icons.mail,
                        color: _mailFocusNode.hasFocus
                            ? cBlue
                            : Colors.grey),
                    suffixIcon: _mailController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _mailController.clear();
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color: _mailFocusNode.hasFocus
                                  ? cBlue
                                  : Colors.grey,
                            ))
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
                onSubmitted: (val) {
                  Helpers.hideKeyboard(context);
                },
                decoration: InputDecoration(
                    hintText: AppLocalization.of(context)
                        .translate("login_screen", "password"),
                    hintStyle: textStyleCustomRegular(Colors.grey,
                        14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(cBlue,
                        14 / MediaQuery.of(context).textScaleFactor),
                    prefixIcon: Icon(Icons.lock,
                        color: _passwordFocusNode.hasFocus
                            ? cBlue
                            : Colors.grey),
                    suffixIcon: IconButton(
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
                              : Colors.grey,
                        ))),
              ),
              const SizedBox(
                height: 55.0,
              ),
              SizedBox(
                  height: 50.0,
                  child: ElevatedButton(
                      onPressed: () async {
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
                      child: _loadingLogin
                          ? const SizedBox(
                              height: 15,
                              width: 15,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: cWhite,
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
                                  23),
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
      ),
    );
  }
}
