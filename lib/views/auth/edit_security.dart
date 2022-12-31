import 'dart:io';
import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/edit_security_account_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class EditSecurity extends ConsumerStatefulWidget {
  const EditSecurity({Key? key}) : super(key: key);

  @override
  EditSecurityState createState() => EditSecurityState();
}

class EditSecurityState extends ConsumerState<EditSecurity>
    with WidgetsBindingObserver {
  late TextEditingController _mailController,
      _actualPasswordController,
      _newPasswordController,
      _validModifPasswordController;
  late FocusNode _mailFocusNode,
      _actualPasswordFocusNode,
      _newPasswordFocusNode,
      _validModifPasswordFocusNode;

  bool _isKeyboard = false;
  bool _actualPasswordObscure = true;
  bool _newPasswordObscure = true;
  bool _validModifPasswordObscure = true;
  bool _isModifMail = false;

  bool validEditMail = false;
  bool validEditPassword = false;
  bool validModif = false;

  AppBar appBar = AppBar();

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

  _showVerifModif() {
    double sizeModalVerif = Platform.isIOS
        ? MediaQuery.of(context).size.height / 2 + 20.0
        : MediaQuery.of(context).size.height / 2;

    return showMaterialModalBottomSheet(
        context: context,
        expand: false,
        enableDrag: true,
        elevation: 6,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SafeArea(
              left: false,
              right: false,
              bottom: false,
              top: true,
              child: GestureDetector(
                onTap: () {
                  Helpers.hideKeyboard(context);
                  sizeModalVerif = Platform.isIOS
                      ? MediaQuery.of(context).size.height / 2 + 20.0
                      : MediaQuery.of(context).size.height / 2;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 750),
                  height: sizeModalVerif,
                  decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15.0),
                          topRight: Radius.circular(15.0)),
                      boxShadow: [
                        BoxShadow(
                          color: cBlue.withOpacity(0.5),
                          blurRadius: 10,
                          offset: const Offset(0.0, -5.0),
                        )
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Text(
                                    AppLocalization.of(context).translate(
                                        "edit_security_screen",
                                        "verify_validity"),
                                    style: textStyleCustomBold(
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? cBlack
                                            : cWhite,
                                        16),
                                    textAlign: TextAlign.left,
                                    textScaleFactor: 1.0),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.clear,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? cBlack
                                          : cWhite)),
                            )
                          ],
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 35,
                              ),
                              Text(
                                  AppLocalization.of(context).translate(
                                      "edit_security_screen", "content_verify"),
                                  style: textStyleCustomMedium(
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? cBlack
                                          : cWhite,
                                      14),
                                  textScaleFactor: 1.0),
                              const SizedBox(
                                height: 25.0,
                              ),
                              TextField(
                                controller: _validModifPasswordController,
                                focusNode: _validModifPasswordFocusNode,
                                maxLines: 1,
                                textInputAction: TextInputAction.done,
                                keyboardType: TextInputType.text,
                                obscureText: _validModifPasswordObscure,
                                onTap: () {
                                  if (Platform.isIOS) {
                                    sizeModalVerif = sizeModalVerif ==
                                            MediaQuery.of(context).size.height /
                                                    2 +
                                                20.0
                                        ? MediaQuery.of(context).size.height
                                        : MediaQuery.of(context).size.height /
                                                2 +
                                            20.0;
                                  } else {
                                    sizeModalVerif = sizeModalVerif ==
                                            MediaQuery.of(context).size.height /
                                                2
                                        ? MediaQuery.of(context).size.height
                                        : MediaQuery.of(context).size.height /
                                            2;
                                  }
                                },
                                onChanged: (val) {
                                  setState(() {
                                    val = _validModifPasswordController.text;
                                  });
                                },
                                onSubmitted: (val) {
                                  Helpers.hideKeyboard(context);
                                  sizeModalVerif = Platform.isIOS
                                      ? MediaQuery.of(context).size.height / 2 +
                                          20.0
                                      : MediaQuery.of(context).size.height / 2;
                                },
                                style: textStyleCustomRegular(
                                    cBlue,
                                    14 /
                                        MediaQuery.of(context).textScaleFactor),
                                decoration: InputDecoration(
                                    hintText: AppLocalization.of(context)
                                        .translate(
                                            "edit_security_screen", "password"),
                                    hintStyle: textStyleCustomRegular(
                                        cGrey,
                                        14 /
                                            MediaQuery.of(context)
                                                .textScaleFactor),
                                    labelStyle: textStyleCustomRegular(
                                        cBlue,
                                        14 /
                                            MediaQuery.of(context)
                                                .textScaleFactor),
                                    prefixIcon: Icon(Icons.lock,
                                        color: _validModifPasswordFocusNode
                                                .hasFocus
                                            ? cBlue
                                            : cGrey),
                                    suffixIcon: Material(
                                      color: Colors.transparent,
                                      shape: const CircleBorder(),
                                      clipBehavior: Clip.hardEdge,
                                      child: IconButton(
                                          onPressed: () {
                                            setState(() {
                                              _validModifPasswordObscure =
                                                  !_validModifPasswordObscure;
                                            });
                                          },
                                          icon: Icon(
                                            _validModifPasswordObscure
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: _validModifPasswordFocusNode
                                                    .hasFocus
                                                ? cBlue
                                                : cGrey,
                                          )),
                                    )),
                              ),
                              const SizedBox(
                                height: 45.0,
                              ),
                              SizedBox(
                                  height: 50.0,
                                  width: 125.0,
                                  child: ElevatedButton(
                                      onPressed: () async {
                                        if (_validModifPasswordController
                                                .text.isNotEmpty &&
                                            !validModif) {
                                          setState(() {
                                            validModif = true;
                                          });
                                          await _saveUpdateSecurity();
                                          setState(() {
                                            validModif = false;
                                          });
                                        }
                                      },
                                      child: validModif
                                          ? const SizedBox(
                                              height: 15.0,
                                              width: 15.0,
                                              child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  color: cWhite,
                                                  strokeWidth: 1.0,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              AppLocalization.of(context)
                                                  .translate("general",
                                                      "btn_validate"),
                                              style: textStyleCustomMedium(
                                                  Theme.of(context)
                                                              .brightness ==
                                                          Brightness.light
                                                      ? cBlack
                                                      : cWhite,
                                                  20),
                                              textAlign: TextAlign.center,
                                              textScaleFactor: 1.0)))
                            ],
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  Future<void> _saveUpdateSecurity() async {
    try {
      if (_isModifMail) {
        //logic ws vérification bon mot de passe pour modifier le mail
        await Future.delayed(const Duration(seconds: 3));

        Map<String, dynamic> mapUser = {
          "id": 1,
          "token": "tokenTest1234",
          "email": _mailController.text,
          "pseudo": ref.read(userNotifierProvider).pseudo,
          "gender": ref.read(userNotifierProvider).gender,
          "birthday": ref.read(userNotifierProvider).birthday,
          "nationality": ref.read(userNotifierProvider).nationality,
          "profilePictureUrl":
              "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
          "validCGU": true,
          "validPrivacyPolicy": true,
          "validEmail": false
        };
        User user = User.fromJSON(mapUser);
        ref.read(userNotifierProvider.notifier).updateUser(user);
      } else {
        //logic ws vérification bon mot de passe pour modifier le mot de passe
        await Future.delayed(const Duration(seconds: 3));
      }

      _mailController.text = ref.read(userNotifierProvider).email;
      _actualPasswordController.clear();
      _newPasswordController.clear();
      ref.read(editMailUserNotifierProvider.notifier).clearEditMail();
      ref.read(editPasswordUserNotifierProvider.notifier).clearEditPassword();

      if (mounted) {
        Navigator.pop(context);
      }
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
    _validModifPasswordController = TextEditingController();

    _mailFocusNode = FocusNode();
    _actualPasswordFocusNode = FocusNode();
    _newPasswordFocusNode = FocusNode();
    _validModifPasswordFocusNode = FocusNode();

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
    _validModifPasswordController.dispose();

    _mailController.dispose();
    _actualPasswordController.dispose();
    _newPasswordController.dispose();
    _validModifPasswordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    validEditMail = ref.watch(editMailUserNotifierProvider);
    validEditPassword = ref.watch(editPasswordUserNotifierProvider);

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
                        onPressed: () => navAuthKey.currentState!.pop(),
                        icon: Icon(Icons.arrow_back_ios,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite)),
                  ),
                  centerTitle: false,
                  title: Text(
                      AppLocalization.of(context).translate(
                          "edit_security_screen", "security_account"),
                      style: textStyleCustomBold(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          20),
                      textScaleFactor: 1.0),
                ),
              ),
            ),
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
    return SizedBox.expand(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20.0,
            MediaQuery.of(context).padding.top +
                appBar.preferredSize.height +
                20.0,
            20.0,
            validEditMail || validEditPassword
                ? MediaQuery.of(context).padding.bottom + 120.0
                : MediaQuery.of(context).padding.bottom + 20.0),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalization.of(context)
                  .translate("edit_security_screen", "content"),
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
              AppLocalization.of(context)
                  .translate("edit_security_screen", "mail"),
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
              style: textStyleCustomRegular(
                  cBlue, 14 / MediaQuery.of(context).textScaleFactor),
              decoration: InputDecoration(
                  hintText: AppLocalization.of(context)
                      .translate("edit_security_screen", "mail"),
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
              height: 45.0,
            ),
            Text(
              AppLocalization.of(context)
                  .translate("edit_security_screen", "password"),
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
              style: textStyleCustomRegular(
                  cBlue, 14 / MediaQuery.of(context).textScaleFactor),
              decoration: InputDecoration(
                  hintText: AppLocalization.of(context)
                      .translate("edit_security_screen", "actual_password"),
                  hintStyle: textStyleCustomRegular(
                      cGrey, 14 / MediaQuery.of(context).textScaleFactor),
                  labelStyle: textStyleCustomRegular(
                      cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                  prefixIcon: Icon(Icons.lock,
                      color: _actualPasswordFocusNode.hasFocus ? cBlue : cGrey),
                  suffixIcon: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            _actualPasswordObscure = !_actualPasswordObscure;
                          });
                        },
                        icon: Icon(
                          _actualPasswordObscure
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color:
                              _actualPasswordFocusNode.hasFocus ? cBlue : cGrey,
                        )),
                  )),
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
              style: textStyleCustomRegular(
                  cBlue, 14 / MediaQuery.of(context).textScaleFactor),
              decoration: InputDecoration(
                  hintText: AppLocalization.of(context)
                      .translate("edit_security_screen", "new_password"),
                  hintStyle: textStyleCustomRegular(
                      cGrey, 14 / MediaQuery.of(context).textScaleFactor),
                  labelStyle: textStyleCustomRegular(
                      cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                  prefixIcon: Icon(Icons.lock,
                      color: _newPasswordFocusNode.hasFocus ? cBlue : cGrey),
                  suffixIcon: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                        onPressed: () {
                          setState(() {
                            _newPasswordObscure = !_newPasswordObscure;
                          });
                        },
                        icon: Icon(
                          _newPasswordObscure
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: _newPasswordFocusNode.hasFocus ? cBlue : cGrey,
                        )),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveEditMail() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 100.0 + MediaQuery.of(context).padding.bottom,
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
                          if (_validModifPasswordController.text.isNotEmpty) {
                            _validModifPasswordController.clear();
                          }
                          _isModifMail = true;
                          await _showVerifModif();
                        },
                        child: Text(
                            AppLocalization.of(context).translate(
                                "edit_security_screen", "update_mail"),
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
                        child: Text(
                            AppLocalization.of(context)
                                .translate("general", "btn_cancel"),
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
                          if (_validModifPasswordController.text.isNotEmpty) {
                            _validModifPasswordController.clear();
                          }
                          _isModifMail = false;
                          await _showVerifModif();
                        },
                        child: Text(
                            AppLocalization.of(context).translate(
                                "edit_security_screen", "update_password"),
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
                        child: Text(
                            AppLocalization.of(context)
                                .translate("general", "btn_cancel"),
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
                AppLocalization.of(context)
                    .translate("edit_security_screen", "error_update"),
                style: textStyleCustomBold(cRed, 16),
                textAlign: TextAlign.center,
                textScaleFactor: 1.0)),
      ),
    );
  }
}
