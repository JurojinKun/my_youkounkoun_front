import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_code_picker/country_code_picker.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/libraries/edit_picture_lib.dart';
import 'package:myyoukounkoun/libraries/sync_shared_prefs_lib.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:myyoukounkoun/providers/register_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class Register extends ConsumerStatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends ConsumerState<Register>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  late TextEditingController _mailController,
      _passwordController,
      _confirmPasswordController,
      _pseudoController,
      _bioController;
  late FocusNode _mailFocusNode,
      _passwordFocusNode,
      _confirmPasswordFocusNode,
      _pseudoFocusNode,
      _bioFocusNode;

  bool _validCGU = false;
  bool _validPrivacypolicy = false;

  List genders = [];
  String validGender = "";

  DateTime? _dateBirthday;
  bool validBirthday = false;

  String? _selectedCountry = "FR";

  File? validProfilePicture;

  bool _isKeyboard = false;
  bool _passwordObscure = true;
  bool _loadingStepOne = false;
  bool _loadingStepTwo = false;
  bool _swipeBack = false;

  late Locale localeLanguage;

  AppBar appBar = AppBar();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _mailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _pseudoController = TextEditingController();
    _bioController = TextEditingController();

    _mailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _confirmPasswordFocusNode = FocusNode();
    _pseudoFocusNode = FocusNode();
    _bioFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _tabController.dispose();

    _mailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pseudoController.dispose();
    _bioController.dispose();

    _mailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _pseudoFocusNode.dispose();
    _bioFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    genders = [
      {
        "id": "Male",
        "type": AppLocalization.of(context).translate("register_screen", "man"),
        "icon": Icons.male
      },
      {
        "id": "Female",
        "type":
            AppLocalization.of(context).translate("register_screen", "woman"),
        "icon": Icons.female
      }
    ];

    localeLanguage = ref.watch(localeLanguageNotifierProvider);
    validGender = ref.watch(genderRegisterNotifierProvider);
    validBirthday = ref.watch(birthdayRegisterNotifierProvider);
    validProfilePicture = ref.watch(profilePictureRegisterNotifierProvider);
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
          extendBodyBehindAppBar: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: PreferredSize(
            preferredSize: Size(
                MediaQuery.of(context).size.width, appBar.preferredSize.height),
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
                          .translate("register_screen", "register"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 20),
                      textScaleFactor: 1.0),
                  centerTitle: false,
                  actions: [stepRegister()],
                ),
              ),
            ),
          ),
          body: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                firstStepRegister(),
                secondStepRegister(),
              ]),
        ),
      ),
    );
  }

  Widget stepRegister() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TabPageSelector(
        controller: _tabController,
        selectedColor: cBlue,
        color: Colors.transparent,
        indicatorSize: 14,
      ),
    );
  }

  firstStepRegister() {
    return SizedBox.expand(
      child: Column(
        children: [
          Expanded(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    AppLocalization.of(context)
                        .translate("register_screen", "step_one"),
                    style: textStyleCustomMedium(Helpers.uiApp(context), 14),
                    textScaleFactor: 1.0),
                const SizedBox(height: 20.0),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(Icons.mail,
                          size: 20, color: Helpers.uiApp(context)),
                    )),
                    TextSpan(
                      text: AppLocalization.of(context)
                          .translate("register_screen", "mail"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 18),
                    )
                  ]),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0,
                ),
                const SizedBox(height: 10.0),
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
                      14 / MediaQuery.of(context).textScaleFactor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    hintText: AppLocalization.of(context)
                        .translate("register_screen", "mail"),
                    hintStyle: textStyleCustomRegular(
                        cGrey, 14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(
                        cBlue, 14 / MediaQuery.of(context).textScaleFactor),
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
                  height: 20.0,
                ),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(Icons.lock,
                          size: 20, color: Helpers.uiApp(context)),
                    )),
                    TextSpan(
                      text: AppLocalization.of(context)
                          .translate("register_screen", "password"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 18),
                    )
                  ]),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0,
                ),
                const SizedBox(height: 10.0),
                TextField(
                  scrollPhysics: const BouncingScrollPhysics(),
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  maxLines: 1,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  obscureText: _passwordObscure,
                  cursorColor: cBlue,
                  onChanged: (val) {
                    setState(() {
                      val = _passwordController.text;
                    });
                  },
                  onSubmitted: (val) {
                    FocusScope.of(context)
                        .requestFocus(_confirmPasswordFocusNode);
                  },
                  style: textStyleCustomRegular(
                      _passwordFocusNode.hasFocus ? cBlue : cGrey,
                      14 / MediaQuery.of(context).textScaleFactor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    hintText: AppLocalization.of(context)
                        .translate("register_screen", "password"),
                    hintStyle: textStyleCustomRegular(
                        cGrey, 14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(
                        cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                    prefixIcon: Icon(Icons.lock,
                        color: _passwordFocusNode.hasFocus ? cBlue : cGrey),
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
                            color: _passwordFocusNode.hasFocus ? cBlue : cGrey,
                          )),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _passwordFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _passwordFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _passwordFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _passwordFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                TextField(
                  scrollPhysics: const BouncingScrollPhysics(),
                  controller: _confirmPasswordController,
                  focusNode: _confirmPasswordFocusNode,
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  obscureText: _passwordObscure,
                  cursorColor: cBlue,
                  onChanged: (val) {
                    setState(() {
                      val = _confirmPasswordController.text;
                    });
                  },
                  onSubmitted: (val) {
                    Helpers.hideKeyboard(context);
                  },
                  style: textStyleCustomRegular(
                      _confirmPasswordFocusNode.hasFocus ? cBlue : cGrey,
                      14 / MediaQuery.of(context).textScaleFactor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    hintText: AppLocalization.of(context)
                        .translate("register_screen", "confirm_password"),
                    hintStyle: textStyleCustomRegular(
                        cGrey, 14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(
                        cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                    prefixIcon: Icon(Icons.lock,
                        color:
                            _confirmPasswordFocusNode.hasFocus ? cBlue : cGrey),
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
                            color: _confirmPasswordFocusNode.hasFocus
                                ? cBlue
                                : cGrey,
                          )),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _confirmPasswordFocusNode.hasFocus
                              ? cBlue
                              : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _confirmPasswordFocusNode.hasFocus
                              ? cBlue
                              : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _confirmPasswordFocusNode.hasFocus
                              ? cBlue
                              : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _confirmPasswordFocusNode.hasFocus
                              ? cBlue
                              : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                const SizedBox(height: 40.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        width: 150,
                        margin: const EdgeInsets.symmetric(vertical: 10.0),
                        child: RichText(
                            textScaleFactor: 1.0,
                            text: TextSpan(
                                text: AppLocalization.of(context)
                                    .translate("register_screen", "accept_cgu"),
                                style: textStyleCustomMedium(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    14),
                                children: [
                                  TextSpan(
                                      text: AppLocalization.of(context)
                                          .translate("register_screen", "cgu"),
                                      style: textStyleCustomBold(cBlue, 14),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          //change url google to url cgu
                                          Helpers.launchMyUrl(
                                              "https://www.google.fr/");
                                        }),
                                ])),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _validCGU = !_validCGU;
                          });
                        },
                        child: Container(
                          height: 25.0,
                          width: 25.0,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.0),
                              color: Theme.of(context).scaffoldBackgroundColor,
                              border: Border.all(
                                  color: _validCGU
                                      ? cBlue
                                      : Helpers.uiApp(context),
                                  width: 2.0)),
                          child: Padding(
                            padding: const EdgeInsets.all(1.5),
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: _validCGU
                                      ? cBlue
                                      : Theme.of(context)
                                          .scaffoldBackgroundColor),
                              child: _validCGU
                                  ? Icon(
                                      Icons.check,
                                      size: 11,
                                      color: Helpers.uiApp(context),
                                    )
                                  : const SizedBox(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                          width: 150,
                          margin: const EdgeInsets.symmetric(vertical: 20.0),
                          child: RichText(
                              textScaleFactor: 1.0,
                              text: TextSpan(
                                  text: AppLocalization.of(context).translate(
                                      "register_screen",
                                      "accept_policy_privacy"),
                                  style: textStyleCustomMedium(
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? cBlack
                                          : cWhite,
                                      14),
                                  children: [
                                    TextSpan(
                                        text: AppLocalization.of(context)
                                            .translate("register_screen",
                                                "policy_privacy"),
                                        style: textStyleCustomBold(cBlue, 14),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            //change url google to url cgu
                                            Helpers.launchMyUrl(
                                                "https://www.google.fr/");
                                          }),
                                  ])),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _validPrivacypolicy = !_validPrivacypolicy;
                            });
                          },
                          child: Container(
                            height: 25.0,
                            width: 25.0,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                border: Border.all(
                                    color: _validPrivacypolicy
                                        ? cBlue
                                        : Helpers.uiApp(context),
                                    width: 2.0)),
                            child: Padding(
                              padding: const EdgeInsets.all(1.5),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.0),
                                    color: _validPrivacypolicy
                                        ? cBlue
                                        : Theme.of(context)
                                            .scaffoldBackgroundColor),
                                child: _validPrivacypolicy
                                    ? Icon(
                                        Icons.check,
                                        size: 11,
                                        color: Helpers.uiApp(context),
                                      )
                                    : const SizedBox(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )),
              ],
            ),
          )),
          _isKeyboard
              ? const SizedBox()
              : Container(
                  height: 115 + MediaQuery.of(context).padding.bottom,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: SizedBox(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width / 2,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_mailController.text.isNotEmpty &&
                                EmailValidator.validate(_mailController.text) &&
                                _passwordController.text.isNotEmpty &&
                                _passwordController.text.length >= 3 &&
                                _confirmPasswordController.text.isNotEmpty &&
                                _confirmPasswordController.text.length >= 3 &&
                                _passwordController.text ==
                                    _confirmPasswordController.text &&
                                _validCGU &&
                                _validPrivacypolicy) {
                              setState(() {
                                _loadingStepOne = true;
                              });
                              _tabController.index += 1;
                              setState(() {
                                _loadingStepOne = false;
                              });
                            }
                          },
                          style:
                              ElevatedButton.styleFrom(backgroundColor: _mailController.text.isNotEmpty &&
                                EmailValidator.validate(_mailController.text) &&
                                _passwordController.text.isNotEmpty &&
                                _passwordController.text.length >= 3 &&
                                _confirmPasswordController.text.isNotEmpty &&
                                _confirmPasswordController.text.length >= 3 &&
                                _passwordController.text ==
                                    _confirmPasswordController.text &&
                                _validCGU &&
                                _validPrivacypolicy ? cBlue : cGrey),
                          child: _loadingStepOne
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
                                      .translate("register_screen", "next"),
                                  style: textStyleCustomMedium(
                                      Theme.of(context).brightness ==
                                              Brightness.light
                                          ? cBlack
                                          : cWhite,
                                      20),
                                  textScaleFactor: 1.0))),
                )
        ],
      ),
    );
  }

  secondStepRegister() {
    return SizedBox.expand(
      child: Column(
        children: [
          Expanded(
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    AppLocalization.of(context)
                        .translate("register_screen", "step_two"),
                    style: textStyleCustomMedium(Helpers.uiApp(context), 14),
                    textScaleFactor: 1.0),
                const SizedBox(
                  height: 20.0,
                ),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(Icons.image,
                          size: 20, color: Helpers.uiApp(context)),
                    )),
                    TextSpan(
                      text: "Image de profil",
                      style: textStyleCustomBold(Helpers.uiApp(context), 18),
                    )
                  ]),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0,
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: SizedBox(
                    height: 145,
                    width: 145,
                    child: Stack(
                      children: [
                        validProfilePicture == null
                            ? Container(
                                height: 145,
                                width: 145,
                                decoration: BoxDecoration(
                                    color: cGrey.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cBlue)),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.person,
                                  color: cBlue,
                                  size: 55.0,
                                ),
                              )
                            : Container(
                                height: 145,
                                width: 145,
                                foregroundDecoration: BoxDecoration(
                                    color: cGrey.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cBlue),
                                    image: DecorationImage(
                                        image: FileImage(validProfilePicture!),
                                        fit: BoxFit.cover,
                                        filterQuality: FilterQuality.high)),
                                decoration: BoxDecoration(
                                  color: cGrey.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cBlue),
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: cBlue,
                                  size: 55.0,
                                ),
                              ),
                        Align(
                            alignment: Alignment.bottomRight,
                            child: GestureDetector(
                                onTap: () async {
                                  await EditPictureLib
                                      .showOptionsImageWithCropped(context);
                                },
                                child: Container(
                                  height: 50.0,
                                  width: 50.0,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .scaffoldBackgroundColor,
                                      shape: BoxShape.circle,
                                      boxShadow: const [
                                        BoxShadow(
                                          color: cBlue,
                                          blurRadius: 5,
                                        )
                                      ]),
                                  child: const Icon(
                                    Icons.photo_camera,
                                    color: cBlue,
                                    size: 30.0,
                                  ),
                                )))
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(Icons.person,
                          size: 20, color: Helpers.uiApp(context)),
                    )),
                    TextSpan(
                      text: AppLocalization.of(context)
                          .translate("register_screen", "pseudo"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 18),
                    )
                  ]),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0,
                ),
                const SizedBox(height: 10.0),
                TextField(
                  scrollPhysics: const BouncingScrollPhysics(),
                  controller: _pseudoController,
                  focusNode: _pseudoFocusNode,
                  maxLines: 1,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  cursorColor: cBlue,
                  onChanged: (val) {
                    setState(() {
                      val = _pseudoController.text;
                    });
                  },
                  onSubmitted: (val) {
                    FocusScope.of(context).requestFocus(_bioFocusNode);
                  },
                  style: textStyleCustomRegular(
                      _pseudoFocusNode.hasFocus ? cBlue : cGrey,
                      14 / MediaQuery.of(context).textScaleFactor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    hintText: AppLocalization.of(context)
                        .translate("register_screen", "pseudo"),
                    hintStyle: textStyleCustomRegular(
                        cGrey, 14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(
                        cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                    suffixIcon: _pseudoController.text.isNotEmpty
                        ? Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _pseudoController.clear();
                                  });
                                },
                                icon: Icon(
                                  Icons.clear,
                                  color:
                                      _pseudoFocusNode.hasFocus ? cBlue : cGrey,
                                )),
                          )
                        : const SizedBox(),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _pseudoFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _pseudoFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _pseudoFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _pseudoFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                const SizedBox(height: 20.0),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(Icons.rate_review,
                          size: 20, color: Helpers.uiApp(context)),
                    )),
                    TextSpan(
                      text: "Biographie",
                      style: textStyleCustomBold(Helpers.uiApp(context), 18),
                    )
                  ]),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0,
                ),
                const SizedBox(height: 10.0),
                TextField(
                  scrollPhysics: const BouncingScrollPhysics(),
                  controller: _bioController,
                  focusNode: _bioFocusNode,
                  minLines: 1,
                  maxLines: null,
                  maxLength: 100,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  onChanged: (val) {
                    setState(() {
                      val = _bioController.text;
                    });
                  },
                  onSubmitted: (val) {
                    Helpers.hideKeyboard(context);
                  },
                  style: textStyleCustomRegular(
                      _bioFocusNode.hasFocus ? cBlue : cGrey,
                      14 / MediaQuery.of(context).textScaleFactor),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                    hintText: "Biographie",
                    hintStyle: textStyleCustomRegular(
                        cGrey, 14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(
                        cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                    enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _bioFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _bioFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _bioFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2.0,
                          color: _bioFocusNode.hasFocus ? cBlue : cGrey,
                        ),
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                const SizedBox(height: 20.0),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(Icons.diversity_1,
                          size: 20, color: Helpers.uiApp(context)),
                    )),
                    TextSpan(
                      text: "Genre",
                      style: textStyleCustomBold(Helpers.uiApp(context), 18),
                    )
                  ]),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0,
                ),
                const SizedBox(height: 10.0),
                GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: genders.length,
                    itemBuilder: (_, int index) {
                      var element = genders[index];

                      return validGender == element["id"]
                          ? Column(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(genderRegisterNotifierProvider
                                              .notifier)
                                          .clearGender();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: cBlue,
                                          border: Border.all(color: cBlue),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Center(
                                        child: Icon(
                                          element["icon"],
                                          color: Theme.of(context).brightness ==
                                                  Brightness.light
                                              ? cBlack
                                              : cWhite,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Text(element["type"],
                                    style: textStyleCustomBold(cBlue, 16),
                                    textScaleFactor: 1.0)
                              ],
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      ref
                                          .read(genderRegisterNotifierProvider
                                              .notifier)
                                          .choiceGender(element["id"]);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          border: Border.all(color: cGrey),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      child: Center(
                                        child: Icon(
                                          element["icon"],
                                          color: cGrey,
                                          size: 50,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 5.0),
                                Text(element["type"],
                                    style: textStyleCustomBold(cGrey, 16),
                                    textScaleFactor: 1.0)
                              ],
                            );
                    }),
                const SizedBox(height: 20.0),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(Icons.celebration,
                          size: 20, color: Helpers.uiApp(context)),
                    )),
                    TextSpan(
                      text: "Date de naissance",
                      style: textStyleCustomBold(Helpers.uiApp(context), 18),
                    )
                  ]),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0,
                ),
                const SizedBox(height: 10.0),
                Center(
                  child: GestureDetector(
                    onTap: () {
                      DatePicker.showDatePicker(context,
                          showTitleActions: true,
                          locale: localeLanguage.languageCode == "fr"
                              ? LocaleType.fr
                              : LocaleType.en,
                          theme: DatePickerTheme(
                            backgroundColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            cancelStyle: textStyleCustomBold(cBlue, 16),
                            doneStyle: textStyleCustomBold(cBlue, 16),
                            itemStyle: textStyleCustomBold(
                                Theme.of(context).iconTheme.color!, 18),
                          ),
                          minTime: DateTime(1900, 1, 1),
                          maxTime: DateTime.now(), onConfirm: (date) {
                        setState(() {
                          _dateBirthday = date;
                        });
                        //verif 18 years old or not
                        final verif =
                            DateTime.now().subtract(const Duration(days: 6570));
                        if (_dateBirthday!.isBefore(verif)) {
                          ref
                              .read(birthdayRegisterNotifierProvider.notifier)
                              .updateBirthday(true);
                        } else {
                          ref
                              .read(birthdayRegisterNotifierProvider.notifier)
                              .updateBirthday(false);
                        }
                      }, currentTime: _dateBirthday ?? DateTime.now());
                    },
                    child: Container(
                      height: 45.0,
                      width: MediaQuery.of(context).size.width,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          border: Border.all(color: cGrey),
                          borderRadius: BorderRadius.circular(5.0)),
                      child: Text(
                          Helpers.formattingDate(
                              _dateBirthday ?? DateTime.now(),
                              localeLanguage.languageCode),
                          style:
                              textStyleCustomBold(Helpers.uiApp(context), 20),
                          textScaleFactor: 1.0),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                RichText(
                  text: TextSpan(children: [
                    WidgetSpan(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Icon(Icons.travel_explore,
                          size: 20, color: Helpers.uiApp(context)),
                    )),
                    TextSpan(
                      text: "Nationnalité",
                      style: textStyleCustomBold(Helpers.uiApp(context), 18),
                    )
                  ]),
                  textAlign: TextAlign.center,
                  textScaleFactor: 1.0,
                ),
                const SizedBox(height: 10.0),
                Container(
                    height: 45,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        border: Border.all(color: cGrey),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: CountryCodePicker(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      backgroundColor: Colors.black54.withOpacity(0.7),
                      dialogBackgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      barrierColor: Colors.transparent,
                      closeIcon: Icon(Icons.clear,
                          color: Helpers.uiApp(context), size: 28),
                      onChanged: (countryCode) {
                        setState(() {
                          _selectedCountry = countryCode.code;
                        });
                      },
                      initialSelection: _selectedCountry,
                      showCountryOnly: true,
                      showOnlyCountryWhenClosed: true,
                      alignLeft: false,
                      enabled: true,
                      dialogSize: Size(MediaQuery.of(context).size.width - 25.0,
                          MediaQuery.of(context).size.height / 1.25),
                      textStyle: Theme.of(context).textTheme.titleSmall,
                      dialogTextStyle: Theme.of(context).textTheme.titleSmall,
                      flagWidth: 30,
                      searchDecoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        fillColor: Theme.of(context).canvasColor,
                        filled: true,
                        labelText: AppLocalization.of(context)
                            .translate("register_screen", "search_country"),
                        border: const OutlineInputBorder(),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                          color: cBlue,
                        )),
                      ),
                      emptySearchBuilder: (_) => Text(
                          AppLocalization.of(context).translate(
                              "register_screen", "empty_search_country"),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleSmall,
                          textScaleFactor: 1.0),
                    )),
              ],
            ),
          )),
          _isKeyboard
              ? const SizedBox()
              : Container(
                  height: 115 + MediaQuery.of(context).padding.bottom,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: _isKeyboard
                      ? const SizedBox()
                      : Column(
                          children: [
                            TextButton(
                                onPressed: () {
                                  setState(() {
                                    _tabController.index -= 1;
                                  });
                                },
                                child: Text(
                                    AppLocalization.of(context).translate(
                                        "register_screen", "previous"),
                                    style: textStyleCustomBold(
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? cBlack
                                            : cWhite,
                                        14,
                                        TextDecoration.underline),
                                    textScaleFactor: 1.0)),
                            SizedBox(
                                height: 50.0,
                                width: MediaQuery.of(context).size.width / 2,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      if (_pseudoController.text.isNotEmpty &&
                                          validGender.trim() != "" &&
                                          validBirthday &&
                                          _selectedCountry != null &&
                                          validProfilePicture != null) {
                                        setState(() {
                                          _loadingStepTwo = true;
                                        });
                                        Map<String, dynamic> userMap = {
                                          "id": 1,
                                          "token": "tokenTest1234",
                                          "email": "ccommunay@gmail.com",
                                          "pseudo": "0ruj",
                                          "gender": "Male",
                                          "birthday": "1997-06-06 00:00",
                                          "nationality": "FR",
                                          "profilePictureUrl":
                                              "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
                                          "followers": 1001,
                                          "followings": 157,
                                          "bio":
                                              "Je suis la bio donc à voir ce que ça donne au niveau de l'affichage du profil",
                                          "validCGU": true,
                                          "validPrivacyPolicy": true,
                                          "validEmail": false
                                        };
                                        String encodedUserMap =
                                            json.encode(userMap);
                                        SyncSharedPrefsLib()
                                            .prefs!
                                            .setString("user", encodedUserMap);
                                        ref
                                            .read(userNotifierProvider.notifier)
                                            .setUser(
                                                UserModel.fromJSON(userMap));
                                        setState(() {
                                          _loadingStepTwo = false;
                                        });
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: _pseudoController.text.isNotEmpty &&
                                          validGender.trim() != "" &&
                                          validBirthday &&
                                          _selectedCountry != null &&
                                          validProfilePicture != null ? cBlue : cGrey),
                                    child: _loadingStepTwo
                                        ? SizedBox(
                                            height: 15,
                                            width: 15,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? cBlack
                                                    : cWhite,
                                                strokeWidth: 1.0,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            AppLocalization.of(context)
                                                .translate("register_screen",
                                                    "sign_up"),
                                            style: textStyleCustomMedium(
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? cBlack
                                                    : cWhite,
                                                20),
                                            textScaleFactor: 1.0))),
                          ],
                        ),
                )
        ],
      ),
    );
  }
}
