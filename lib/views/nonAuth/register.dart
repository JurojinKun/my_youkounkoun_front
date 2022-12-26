import 'dart:io';
import 'dart:ui';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:myyoukounkoun/providers/register_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class Register extends ConsumerStatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends ConsumerState<Register>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  late TextEditingController _mailController,
      _passwordController,
      _pseudoController;
  late FocusNode _mailFocusNode, _passwordFocusNode, _pseudoFocusNode;

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
  bool _loadingStepThree = false;
  bool _loadingStepFourth = false;
  bool _loadingStepFifth = false;
  bool _loadingStepSixth = false;

  late Locale localeLanguage;

  AppBar appBar = AppBar();

  showOptionsImage() {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 6,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        builder: (BuildContext context) {
          return Container(
            height: Platform.isIOS ? 180 : 160,
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
                  Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                            AppLocalization.of(context).translate(
                                "register_screen", "add_picture_profile"),
                            style: textStyleCustomBold(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                16),
                            textScaleFactor: 1.0),
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
                  ),
                  Expanded(
                      child: Ink(
                    child: InkWell(
                      splashColor: cBlue.withOpacity(0.3),
                      highlightColor: cBlue.withOpacity(0.3),
                      onTap: () => pickImage(ImageSource.camera),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 15.0,
                          ),
                          const Icon(Icons.photo_camera,
                              color: cBlue, size: 36),
                          const SizedBox(
                            width: 25.0,
                          ),
                          Text(
                              AppLocalization.of(context)
                                  .translate("register_screen", "camera"),
                              style: textStyleCustomBold(cBlue, 16),
                              textScaleFactor: 1.0)
                        ],
                      ),
                    ),
                  )),
                  Expanded(
                      child: Ink(
                    child: InkWell(
                      splashColor: cBlue.withOpacity(0.3),
                      highlightColor: cBlue.withOpacity(0.3),
                      onTap: () => pickImage(ImageSource.gallery),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 15.0,
                          ),
                          const Icon(Icons.photo, color: cBlue, size: 36),
                          const SizedBox(
                            width: 25.0,
                          ),
                          Text(
                              AppLocalization.of(context)
                                  .translate("register_screen", "galery"),
                              style: textStyleCustomBold(cBlue, 16),
                              textScaleFactor: 1.0)
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          );
        });
  }

  pickImage(ImageSource src) async {
    try {
      final image = await ImagePicker().pickImage(
          source: src, imageQuality: 75, maxHeight: 1800, maxWidth: 1800);
      if (image != null) {
        await cropImage(image.path);
        if (mounted) {
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  cropImage(String filePath) async {
    try {
      final croppedImage = await ImageCropper().cropImage(
          uiSettings: [
            AndroidUiSettings(
              dimmedLayerColor: cBlack,
              toolbarTitle: AppLocalization.of(context)
                  .translate("general", "title_cropper"),
              toolbarColor: Theme.of(context).scaffoldBackgroundColor,
              toolbarWidgetColor:
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
              cropFrameColor: cWhite,
              cropGridColor: cWhite,
              activeControlsWidgetColor: cBlue,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              hideBottomControls: true,
            ),
            IOSUiSettings(
              title: AppLocalization.of(context)
                  .translate("general", "title_cropper"),
            ),
          ],
          sourcePath: filePath,
          maxWidth: 1080,
          maxHeight: 1080,
          compressQuality: 75,
          compressFormat: ImageCompressFormat.jpg,
          cropStyle: CropStyle.circle);
      if (croppedImage != null) {
        File finalFile = File(croppedImage.path);
        ref
            .read(profilePictureRegisterNotifierProvider.notifier)
            .addNewProfilePicture(finalFile);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 6, vsync: this);

    _mailController = TextEditingController();
    _passwordController = TextEditingController();
    _pseudoController = TextEditingController();
    _mailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _pseudoFocusNode = FocusNode();
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

    _tabController.dispose();

    _mailController.dispose();
    _passwordController.dispose();
    _pseudoController.dispose();
    _mailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _pseudoFocusNode.dispose();
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
                      onPressed: () {
                        ref
                            .read(genderRegisterNotifierProvider.notifier)
                            .clearGender();
                        ref
                            .read(birthdayRegisterNotifierProvider.notifier)
                            .clearBirthday();
                        ref
                            .read(
                                profilePictureRegisterNotifierProvider.notifier)
                            .clearProfilePicture();
                        navNonAuthKey.currentState!.pop();
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                      )),
                ),
                title: Text(
                    AppLocalization.of(context)
                        .translate("register_screen", "register"),
                    style: textStyleCustomBold(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        20),
                    textScaleFactor: 1.0),
                centerTitle: false,
                actions: [stepRegister()],
              ),
            ),
          ),
        ),
        body: WillPopScope(
          onWillPop: () async {
            ref.read(genderRegisterNotifierProvider.notifier).clearGender();
            ref.read(birthdayRegisterNotifierProvider.notifier).clearBirthday();
            ref
                .read(profilePictureRegisterNotifierProvider.notifier)
                .clearProfilePicture();
            navNonAuthKey.currentState!.pop();
            return false;
          },
          child: GestureDetector(
            onHorizontalDragStart: (details) {
              if (Platform.isIOS && details.globalPosition.dx <= 70) {
                ref.read(genderRegisterNotifierProvider.notifier).clearGender();
                ref
                    .read(birthdayRegisterNotifierProvider.notifier)
                    .clearBirthday();
                ref
                    .read(profilePictureRegisterNotifierProvider.notifier)
                    .clearProfilePicture();
                navNonAuthKey.currentState!.pop();
              }
            },
            child: TabBarView(
                controller: _tabController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  firstStepRegister(),
                  secondStepRegister(),
                  thirdStepRegister(),
                  fourthStepRegister(),
                  fifthStepRegister(),
                  sixthStepRegister()
                ]),
          ),
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
                25.0, appBar.preferredSize.height + 50.0, 25.0, 0.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    AppLocalization.of(context)
                        .translate("register_screen", "step_one"),
                    style: textStyleCustomMedium(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        14),
                    textScaleFactor: 1.0),
                const SizedBox(height: 55.0),
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
                          .translate("register_screen", "mail"),
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
                                    color:
                                        _mailFocusNode.hasFocus ? cBlue : cGrey,
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
                  onSubmitted: (val) {
                    Helpers.hideKeyboard(context);
                  },
                  decoration: InputDecoration(
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
                              color:
                                  _passwordFocusNode.hasFocus ? cBlue : cGrey,
                            )),
                      )),
                ),
                const SizedBox(height: 55.0),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: CheckboxListTile(
                      value: _validCGU,
                      dense: false,
                      checkColor:
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                      activeColor: cBlue,
                      side: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite),
                      title: RichText(
                          textAlign: TextAlign.center,
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
                      onChanged: (value) {
                        setState(() {
                          _validCGU = value!;
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: CheckboxListTile(
                      value: _validPrivacypolicy,
                      dense: false,
                      checkColor:
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                      activeColor: cBlue,
                      side: BorderSide(
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite),
                      title: RichText(
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0,
                          text: TextSpan(
                              text: AppLocalization.of(context).translate(
                                  "register_screen", "accept_policy_privacy"),
                              style: textStyleCustomMedium(
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? cBlack
                                      : cWhite,
                                  14),
                              children: [
                                TextSpan(
                                    text: AppLocalization.of(context).translate(
                                        "register_screen", "policy_privacy"),
                                    style: textStyleCustomBold(cBlue, 14),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        //change url google to url cgu
                                        Helpers.launchMyUrl(
                                            "https://www.google.fr/");
                                      }),
                              ])),
                      onChanged: (value) {
                        setState(() {
                          _validPrivacypolicy = value!;
                        });
                      }),
                ),
              ],
            ),
          )),
          _isKeyboard
              ? const SizedBox()
              : Container(
                  height: 115,
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
                25.0, appBar.preferredSize.height + 50.0, 25.0, 0.0),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    AppLocalization.of(context)
                        .translate("register_screen", "step_two"),
                    style: textStyleCustomMedium(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        14),
                    textScaleFactor: 1.0),
                const SizedBox(
                  height: 55.0,
                ),
                TextField(
                  controller: _pseudoController,
                  focusNode: _pseudoFocusNode,
                  maxLines: 1,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  onChanged: (val) {
                    setState(() {
                      val = _pseudoController.text;
                    });
                  },
                  onSubmitted: (val) {
                    Helpers.hideKeyboard(context);
                  },
                  decoration: InputDecoration(
                      hintText: AppLocalization.of(context)
                          .translate("register_screen", "pseudo"),
                      hintStyle: textStyleCustomRegular(
                          cGrey, 14 / MediaQuery.of(context).textScaleFactor),
                      labelStyle: textStyleCustomRegular(
                          cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                      prefixIcon: Icon(Icons.person,
                          color: _pseudoFocusNode.hasFocus ? cBlue : cGrey),
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
                                    color: _pseudoFocusNode.hasFocus
                                        ? cBlue
                                        : cGrey,
                                  )),
                            )
                          : const SizedBox()),
                ),
              ],
            ),
          )),
          Container(
            height: 115,
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
                              AppLocalization.of(context)
                                  .translate("register_screen", "previous"),
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
                                if (_pseudoController.text.isNotEmpty) {
                                  setState(() {
                                    _loadingStepTwo = true;
                                  });
                                  _tabController.index += 1;
                                  setState(() {
                                    _loadingStepTwo = false;
                                  });
                                }
                              },
                              child: _loadingStepTwo
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
                    ],
                  ),
          )
        ],
      ),
    );
  }

  thirdStepRegister() {
    return SizedBox.expand(
      child: Column(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.fromLTRB(
                25.0, appBar.preferredSize.height + 50.0, 25.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    AppLocalization.of(context)
                        .translate("register_screen", "step_three"),
                    style: textStyleCustomMedium(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        14),
                    textScaleFactor: 1.0),
                const SizedBox(height: 20.0),
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
                    })
              ],
            ),
          )),
          Container(
            height: 115,
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
                              AppLocalization.of(context)
                                  .translate("register_screen", "previous"),
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
                                if (validGender.trim() != "") {
                                  setState(() {
                                    _loadingStepThree = true;
                                  });
                                  _tabController.index += 1;
                                  setState(() {
                                    _loadingStepThree = false;
                                  });
                                }
                              },
                              child: _loadingStepThree
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
                    ],
                  ),
          )
        ],
      ),
    );
  }

  fourthStepRegister() {
    return SizedBox.expand(
      child: Column(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.fromLTRB(
                25.0, appBar.preferredSize.height + 50.0, 25.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    AppLocalization.of(context)
                        .translate("register_screen", "step_four"),
                    style: textStyleCustomMedium(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        14),
                    textScaleFactor: 1.0),
                const SizedBox(
                  height: 55.0,
                ),
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
                      height: 34.0,
                      decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                                width: 1.0,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? cBlack
                                    : cWhite)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                            Helpers.formattingDate(
                                _dateBirthday ?? DateTime.now(),
                                localeLanguage.languageCode),
                            style: textStyleCustomBold(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                24),
                            textScaleFactor: 1.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
          Container(
            height: 115,
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
                              AppLocalization.of(context)
                                  .translate("register_screen", "previous"),
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
                                if (validBirthday) {
                                  setState(() {
                                    _loadingStepFourth = true;
                                  });
                                  _tabController.index += 1;
                                  setState(() {
                                    _loadingStepFourth = false;
                                  });
                                }
                              },
                              child: _loadingStepFourth
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
                    ],
                  ),
          )
        ],
      ),
    );
  }

  fifthStepRegister() {
    return SizedBox.expand(
      child: Column(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.fromLTRB(
                25.0, appBar.preferredSize.height + 50.0, 25.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    AppLocalization.of(context)
                        .translate("register_screen", "step_five"),
                    style: textStyleCustomMedium(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        14),
                    textScaleFactor: 1.0),
                const SizedBox(
                  height: 55.0,
                ),
                Container(
                    height: 45,
                    decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        border: Border.all(color: cGrey),
                        borderRadius: BorderRadius.circular(5.0)),
                    child: CountryCodePicker(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      backgroundColor: Colors.black54.withOpacity(0.7),
                      dialogBackgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      barrierColor: Colors.transparent,
                      closeIcon: Icon(Icons.clear,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                          size: 28),
                      onChanged: (countryCode) {
                        setState(() {
                          _selectedCountry = countryCode.code;
                        });
                      },
                      initialSelection: _selectedCountry,
                      showCountryOnly: true,
                      showOnlyCountryWhenClosed: true,
                      alignLeft: true,
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
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
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
          Container(
            height: 115,
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
                              AppLocalization.of(context)
                                  .translate("register_screen", "previous"),
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
                                if (_selectedCountry != null) {
                                  if (kDebugMode) {
                                    print(_selectedCountry);
                                  }
                                  setState(() {
                                    _loadingStepFifth = true;
                                  });
                                  _tabController.index += 1;
                                  setState(() {
                                    _loadingStepFifth = false;
                                  });
                                }
                              },
                              child: _loadingStepFifth
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
                    ],
                  ),
          )
        ],
      ),
    );
  }

  sixthStepRegister() {
    return SizedBox.expand(
      child: Column(
        children: [
          Expanded(
              child: Padding(
            padding: EdgeInsets.fromLTRB(
                25.0, appBar.preferredSize.height + 50.0, 25.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    AppLocalization.of(context)
                        .translate("register_screen", "step_six"),
                    style: textStyleCustomMedium(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        14),
                    textScaleFactor: 1.0),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: 175,
                      width: 175,
                      child: Stack(
                        children: [
                          validProfilePicture == null
                              ? Container(
                                  decoration: BoxDecoration(
                                      color: cGrey.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue)),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.person,
                                    color: cBlue,
                                    size: 75.0,
                                  ),
                                )
                              : Container(
                                  foregroundDecoration: BoxDecoration(
                                      color: cGrey.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue),
                                      image: DecorationImage(
                                          image:
                                              FileImage(validProfilePicture!),
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
                                    size: 75.0,
                                  ),
                                ),
                          Align(
                              alignment: Alignment.bottomRight,
                              child: GestureDetector(
                                  onTap: () {
                                    showOptionsImage();
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
                )
              ],
            ),
          )),
          Container(
            height: 115,
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
                              AppLocalization.of(context)
                                  .translate("register_screen", "previous"),
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
                                if (validProfilePicture != null) {
                                  setState(() {
                                    _loadingStepSixth = true;
                                  });
                                  ref
                                      .read(userNotifierProvider.notifier)
                                      .initUser(User(
                                          id: 1,
                                          token: "tokenTest1204",
                                          email: "ccommunay@gmail.com",
                                          pseudo: "0ruj",
                                          gender: "Male",
                                          birthday: "1997-06-06 00:00",
                                          nationality: "FR",
                                          profilePictureUrl:
                                              "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
                                          validCGU: true,
                                          validPrivacyPolicy: true,
                                          validEmail: false));
                                  setState(() {
                                    _loadingStepSixth = false;
                                  });
                                }
                              },
                              child: _loadingStepSixth
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
                                      AppLocalization.of(context).translate(
                                          "register_screen", "sign_up"),
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
