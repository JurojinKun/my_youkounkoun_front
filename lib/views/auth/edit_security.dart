import 'dart:io';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/helpers/helpers.dart';
import 'package:my_boilerplate/providers/edit_security_account.dart';
import 'package:my_boilerplate/providers/user_provider.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';

class EditSecurity extends ConsumerStatefulWidget {
  const EditSecurity({Key? key}) : super(key: key);

  @override
  EditSecurityState createState() => EditSecurityState();
}

class EditSecurityState extends ConsumerState<EditSecurity>
    with WidgetsBindingObserver {
  late TextEditingController _mailController,
      _actualPasswordController,
      _newPasswordController;
  late FocusNode _mailFocusNode,
      _actualPasswordFocusNode,
      _newPasswordFocusNode;

  bool _isKeyboard = false;
  bool _actualPasswordObscure = true;
  bool _newPasswordObscure = true;

  bool validEditMail = false;
  bool validEditPassword = false;

  void _updateMail() {
    if (_mailController.text.trim().isNotEmpty &&
        _mailController.text != ref.read(userNotifierProvider).email &&
        EmailValidator.validate(_mailController.text)) {
      ref.read(editMailUserNotifierProvider.notifier).updateEditMail(true);
    } else {
      ref.read(editMailUserNotifierProvider.notifier).updateEditMail(false);
    }
  }

  void _updatePassword() {
    if (_actualPasswordController.text.trim().isNotEmpty &&
        _newPasswordController.text.trim().isNotEmpty &&
        _actualPasswordController.text != _newPasswordController.text &&
        _newPasswordController.text.length >= 3) {
      ref
          .read(editPasswordUserNotifierProvider.notifier)
          .updateEditPassword(true);
    } else {
      ref
          .read(editPasswordUserNotifierProvider.notifier)
          .updateEditPassword(false);
    }
  }

  Future<void> _saveUpdateMail() async {
    try {
      print("save update mail");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _saveUpdatePassword() async {
    try {
      print("save update password");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void _cancelUpdateSecurity() {
    _mailController.text = ref.read(userNotifierProvider).email;
    _actualPasswordController.clear();
    _newPasswordController.clear();
    ref.read(editMailUserNotifierProvider.notifier).clearEditMail();
    ref.read(editPasswordUserNotifierProvider.notifier).clearEditPassword();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _mailController =
        TextEditingController(text: ref.read(userNotifierProvider).email);
    _actualPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();

    _mailFocusNode = FocusNode();
    _actualPasswordFocusNode = FocusNode();
    _newPasswordFocusNode = FocusNode();

    _mailController.addListener(() {
      _updateMail();
    });
    _actualPasswordController.addListener(() {
      _updatePassword();
    });
    _newPasswordController.addListener(() {
      _updatePassword();
    });
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboard) {
      setState(() {
        _isKeyboard = newValue;
      });
    }
    super.didChangeMetrics();
  }

  @override
  void deactivate() {
    _mailController.removeListener(() {
      _updateMail();
    });
    _actualPasswordController.removeListener(() {
      _updatePassword();
    });
    _newPasswordController.removeListener(() {
      _updatePassword();
    });
    super.deactivate();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _mailFocusNode.dispose();
    _actualPasswordFocusNode.dispose();
    _newPasswordFocusNode.dispose();

    _mailController.dispose();
    _actualPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    validEditMail = ref.watch(editMailUserNotifierProvider);
    validEditPassword = ref.watch(editPasswordUserNotifierProvider);

    return GestureDetector(
      onTap: () => Helpers.hideKeyboard(context),
      child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
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
            centerTitle: false,
            title: Text(
                AppLocalization.of(context)
                    .translate("edit_security_screen", "security_account"),
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    20),
                textScaleFactor: 1.0),
          ),
          body: Stack(
            children: [
              _editSecurity(),
              !_isKeyboard
                  ? (validEditMail && validEditPassword)
                      ? _errorSaveSecurity()
                      : validEditMail
                          ? _saveEditMail()
                          : validEditPassword
                              ? _saveEditPassword()
                              : const SizedBox()
                  : const SizedBox()
            ],
          )),
    );
  }

  Widget _editSecurity() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: Padding(
          padding: EdgeInsets.only(
              bottom: validEditMail || validEditPassword ? 110 : 10,
              left: 20,
              right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Tu peux modifier la sécurité de ton compte directement ici.\nAttention, tu ne pourras pas modifier ton mail et ton mot de passe en même temps !",
                style: textStyleCustomRegular(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    16),
                textScaleFactor: 1.0,
              ),
              const SizedBox(
                height: 25.0,
              ),
              Text(
                "Email",
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    18),
                textAlign: TextAlign.center,
                textScaleFactor: 1.0,
              ),
              const SizedBox(
                height: 10.0,
              ),
              TextField(
                controller: _mailController,
                focusNode: _mailFocusNode,
                maxLines: 1,
                textInputAction: TextInputAction.done,
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
                    hintStyle: textStyleCustomRegular(Colors.grey,
                        14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(
                        cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                    prefixIcon: Icon(Icons.mail,
                        color: _mailFocusNode.hasFocus ? cBlue : Colors.grey),
                    suffixIcon: _mailController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _mailController.clear();
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color:
                                  _mailFocusNode.hasFocus ? cBlue : Colors.grey,
                            ))
                        : const SizedBox()),
              ),
              const SizedBox(
                height: 45.0,
              ),
              Text(
                "Mot de passe",
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    18),
                textAlign: TextAlign.center,
                textScaleFactor: 1.0,
              ),
              const SizedBox(
                height: 15.0,
              ),
              TextField(
                controller: _actualPasswordController,
                focusNode: _actualPasswordFocusNode,
                maxLines: 1,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                obscureText: _actualPasswordObscure,
                onChanged: (val) {
                  setState(() {
                    val = _actualPasswordController.text;
                  });
                },
                onSubmitted: (val) {
                  setState(() {
                    FocusScope.of(context).requestFocus(_newPasswordFocusNode);
                  });
                },
                decoration: InputDecoration(
                    hintText: "Actuel mot de passe",
                    hintStyle: textStyleCustomRegular(Colors.grey,
                        14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(
                        cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                    prefixIcon: Icon(Icons.lock,
                        color: _actualPasswordFocusNode.hasFocus
                            ? cBlue
                            : Colors.grey),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _actualPasswordObscure = !_actualPasswordObscure;
                          });
                        },
                        icon: Icon(
                          _actualPasswordObscure
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: _actualPasswordFocusNode.hasFocus
                              ? cBlue
                              : Colors.grey,
                        ))),
              ),
              const SizedBox(
                height: 25.0,
              ),
              TextField(
                controller: _newPasswordController,
                focusNode: _newPasswordFocusNode,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                obscureText: _newPasswordObscure,
                onChanged: (val) {
                  setState(() {
                    val = _newPasswordController.text;
                  });
                },
                onSubmitted: (val) {
                  Helpers.hideKeyboard(context);
                },
                decoration: InputDecoration(
                    hintText: "Nouveau mot de passe",
                    hintStyle: textStyleCustomRegular(Colors.grey,
                        14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(
                        cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                    prefixIcon: Icon(Icons.lock,
                        color: _newPasswordFocusNode.hasFocus
                            ? cBlue
                            : Colors.grey),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _newPasswordObscure = !_newPasswordObscure;
                          });
                        },
                        icon: Icon(
                          _newPasswordObscure
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: _newPasswordFocusNode.hasFocus
                              ? cBlue
                              : Colors.grey,
                        ))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveEditMail() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 100.0,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                        onPressed: () async {
                          await _saveUpdateMail();
                        },
                        child: Text("Modifier mail",
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                20),
                            textScaleFactor: 1.0))),
              ),
              const SizedBox(width: 15.0),
              Expanded(
                child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: cRed,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          _cancelUpdateSecurity();
                        },
                        child: Text("Annuler",
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                20),
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.0))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _saveEditPassword() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 100.0,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                        onPressed: () async {
                          await _saveUpdatePassword();
                        },
                        child: Text("Modifier mot de passe",
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                20),
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.0))),
              ),
              const SizedBox(width: 15.0),
              Expanded(
                child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: cRed,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          _cancelUpdateSecurity();
                        },
                        child: Text("Annuler",
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                20),
                            textScaleFactor: 1.0))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorSaveSecurity() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 100.0,
        alignment: Alignment.center,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
                "Impossible de modifier ton mail et ton mot de passe en même temps ! Chaque chose en son temps..",
                style: textStyleCustomBold(cRed, 16),
                textAlign: TextAlign.center,
                textScaleFactor: 1.0)),
      ),
    );
  }
}
