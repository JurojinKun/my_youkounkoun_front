import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/helpers/helpers.dart';
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

  bool _isEdit = false;
  bool _isKeyboard = false;
  bool _actualPasswordObscure = true;
  bool _newPasswordObscure = true;

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
              _isEdit && !_isKeyboard ? _saveEditSecurity() : const SizedBox()
            ],
          )),
    );
  }

  Widget _editSecurity() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        child: Padding(
          padding: EdgeInsets.only(bottom: _isEdit ? 110 : 10, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 20.0,
              ),
              Text(
                "Tu peux modifier la sécurité de ton compte directement ici !",
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

  Widget _saveEditSecurity() {
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
                        onPressed: () async {},
                        child: Text("Sauvegarder",
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
                        onPressed: () async {},
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
}
