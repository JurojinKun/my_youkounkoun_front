import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as picker;

import 'package:myyoukounkoun/components/message_user_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/libraries/edit_picture_lib.dart';
import 'package:myyoukounkoun/libraries/env_config_lib.dart';
import 'package:myyoukounkoun/libraries/hive_lib.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
import 'package:myyoukounkoun/providers/edit_account_provider.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class EditAccount extends ConsumerStatefulWidget {
  const EditAccount({super.key});

  @override
  EditAccountState createState() => EditAccountState();
}

class EditAccountState extends ConsumerState<EditAccount> {
  late Locale localeLanguage;

  late UserModel user;

  File? editPictureProfile;
  late TextEditingController _pseudoController, _bioController;
  late FocusNode _pseudoFocusNode, _bioFocusNode;
  List genders = [];
  String _selectedGender = "";
  DateTime? _dateBirthday;
  String? _selectedCountry;

  bool isEdit = false;
  bool _isKeyboard = false;

  AppBar appBar = AppBar();

  bool profilePictureAlreadyLoaded = false;
  ConnectivityResult? connectivityStatusApp;

  void updatePseudo() {
    if (_pseudoController.text.trim().isNotEmpty &&
        _pseudoController.text != ref.read(userNotifierProvider).pseudo &&
        _pseudoController.text.length >= 3) {
      ref.read(editPseudoUserNotifierProvider.notifier).editPseudo(true);
    } else {
      ref.read(editPseudoUserNotifierProvider.notifier).editPseudo(false);
    }
  }

  void updateBio() {
    if (_bioController.text != ref.read(userNotifierProvider).bio &&
        _bioController.text.length <= 100) {
      ref.read(editBioUserNotifierProvider.notifier).editBio(true);
    } else {
      ref.read(editBioUserNotifierProvider.notifier).editBio(false);
    }
  }

  Future<void> _saveModifUser() async {
    //logic à modifier lorsque câbler avec le back
    try {
      Map<String, dynamic> mapUser = {
        "id": 1,
        "email": "ccommunay@gmail.com",
        "pseudo": _pseudoController.text,
        "gender": _selectedGender,
        "birthday": _dateBirthday.toString(),
        "nationality": _selectedCountry,
        "profilePictureUrl": "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg",
        "followers": ref.read(userNotifierProvider).followers,
        "followings": ref.read(userNotifierProvider).followings,
        "bio": _bioController.text,
        "validCGU": true,
        "validPrivacyPolicy": true,
        "validEmail": false
      };
      await HiveLib.setDatasHive(
          true, EnvironmentConfigLib().getEnvironmentKeyEncryptedUserBox, "userBox", "user", mapUser);
      UserModel user = UserModel.fromJSON(mapUser);
      ref.read(userNotifierProvider.notifier).setUser(user);
      _pseudoController.text = user.pseudo;
      ref
          .read(editProfilePictureUserNotifierProvider.notifier)
          .clearEditProfilePicture();
      ref.read(editPseudoUserNotifierProvider.notifier).clearPseudo();
      ref
          .read(editGenderUserNotifierProvider.notifier)
          .clearGender(user.gender);
      ref
          .read(editBirthdayUserNotifierProvider.notifier)
          .clearBirthday(Helpers.convertStringToDateTime(user.birthday));
      ref
          .read(editNationalityUserNotifierProvider.notifier)
          .clearNationality(user.nationality);
      _bioController.text = user.bio;

      if (mounted) {
        messageUser(
            context,
            AppLocalization.of(context).translate(
                "edit_account_screen", "message_success_update_account"));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      if (mounted) {
        messageUser(context,
            AppLocalization.of(context).translate("general", "message_error"));
      }
    }
  }

  Future<void> _canceledModifUser() async {
    _pseudoController.text = user.pseudo;
    ref
        .read(editProfilePictureUserNotifierProvider.notifier)
        .clearEditProfilePicture();
    ref.read(editPseudoUserNotifierProvider.notifier).clearPseudo();
    ref.read(editGenderUserNotifierProvider.notifier).clearGender(user.gender);
    ref
        .read(editBirthdayUserNotifierProvider.notifier)
        .clearBirthday(Helpers.convertStringToDateTime(user.birthday));
    ref
        .read(editNationalityUserNotifierProvider.notifier)
        .clearNationality(user.nationality);
    _bioController.text = user.bio;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref
          .read(editGenderUserNotifierProvider.notifier)
          .initGender(ref.read(userNotifierProvider).gender);
      ref.read(editBirthdayUserNotifierProvider.notifier).initBirthday(
          Helpers.convertStringToDateTime(
              ref.read(userNotifierProvider).birthday));
      ref
          .read(editNationalityUserNotifierProvider.notifier)
          .initNationality(ref.read(userNotifierProvider).nationality);
    });

    _pseudoController =
        TextEditingController(text: ref.read(userNotifierProvider).pseudo);
    _pseudoFocusNode = FocusNode();
    _pseudoController.addListener(() {
      updatePseudo();
    });

    _bioController =
        TextEditingController(text: ref.read(userNotifierProvider).bio);
    _bioFocusNode = FocusNode();
    _bioController.addListener(() {
      updateBio();
    });
  }

  @override
  void deactivate() {
    _pseudoController.removeListener(() {
      updatePseudo();
    });
    _bioController.removeListener(() {
      updateBio();
    });
    super.deactivate();
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _pseudoFocusNode.dispose();
    _bioController.dispose();
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
    user = ref.watch(userNotifierProvider);
    editPictureProfile = ref.watch(editProfilePictureUserNotifierProvider);
    _selectedGender = ref.watch(editGenderUserNotifierProvider);
    _dateBirthday = ref.watch(editBirthdayUserNotifierProvider);
    _selectedCountry = ref.watch(editNationalityUserNotifierProvider);
    profilePictureAlreadyLoaded =
        ref.watch(profilePictureAlreadyLoadedNotifierProvider);
    connectivityStatusApp = ref.watch(connectivityStatusAppNotifierProvider);
    _isKeyboard = ref.watch(visibleKeyboardAppNotifierProvider);

    final editProfile = ref.watch(editProfileNotifierProvider);
    if (editProfile.asData != null) {
      isEdit = editProfile.asData!.value;
    }

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
                  leading: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                        onPressed: () => navAuthKey.currentState!.pop(),
                        icon: Icon(Icons.arrow_back_ios,
                            color: Helpers.uiApp(context))),
                  ),
                  title: Text(
                    AppLocalization.of(context)
                        .translate("edit_account_screen", "my_account"),
                    style: textStyleCustomBold(Helpers.uiApp(context), 20),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                  centerTitle: false,
                ),
              ),
            ),
          ),
          body: Stack(
            children: [
              _editAccount(),
              isEdit && !_isKeyboard ? _saveEditAccount() : const SizedBox()
            ],
          )),
    );
  }

  Widget _editAccount() {
    return SizedBox.expand(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20.0,
            MediaQuery.of(context).padding.top +
                appBar.preferredSize.height +
                20.0,
            20.0,
            isEdit
                ? MediaQuery.of(context).padding.bottom + 120.0
                : MediaQuery.of(context).padding.bottom + 20.0),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalization.of(context)
                  .translate("edit_account_screen", "content"),
              style: textStyleCustomRegular(Helpers.uiApp(context), 16),
              textScaler: const TextScaler.linear(1.0),
            ),
            const SizedBox(
              height: 25.0,
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
                  text: AppLocalization.of(context)
                      .translate("edit_account_screen", "picture_profile"),
                  style: textStyleCustomBold(Helpers.uiApp(context), 18),
                )
              ]),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1.0),
            ),
            const SizedBox(height: 10.0),
            Center(
              child: SizedBox(
                height: 145,
                width: 145,
                child: Stack(
                  children: [
                    editPictureProfile != null
                        ? Container(
                            height: 145,
                            width: 145,
                            foregroundDecoration: BoxDecoration(
                                color: cGrey.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: cBlue),
                                image: DecorationImage(
                                    image: FileImage(editPictureProfile!),
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
                          )
                        : user.profilePictureUrl.trim() == "" ||
                                (connectivityStatusApp ==
                                        ConnectivityResult.none &&
                                    !profilePictureAlreadyLoaded)
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
                            : CachedNetworkImage(
                                imageUrl: user.profilePictureUrl,
                                imageBuilder: ((context, imageProvider) {
                                  return Container(
                                      height: 145,
                                      width: 145,
                                      foregroundDecoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: cBlue),
                                          image: DecorationImage(
                                              image: imageProvider,
                                              fit: BoxFit.cover)),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: cBlue),
                                        color: cGrey.withOpacity(0.2),
                                      ),
                                      child: const Icon(Icons.person,
                                          color: cBlue, size: 55));
                                }),
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) {
                                  if (downloadProgress.progress == 1.0 &&
                                      !profilePictureAlreadyLoaded) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                      ref
                                          .read(
                                              profilePictureAlreadyLoadedNotifierProvider
                                                  .notifier)
                                          .profilePictureLoaded(true);
                                    });
                                  }

                                  return Container(
                                    height: 145,
                                    width: 145,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue),
                                      color: cGrey.withOpacity(0.2),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: cBlue, size: 55),
                                  );
                                },
                                errorWidget: (context, url, error) => Container(
                                  height: 145,
                                  width: 145,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cBlue),
                                    color: cGrey.withOpacity(0.2),
                                  ),
                                  child: const Icon(Icons.person,
                                      color: cBlue, size: 55),
                                ),
                              ),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: GestureDetector(
                            onTap: () async {
                              await EditPictureLib.showOptionsImageWithCropped(
                                  context);
                            },
                            child: Container(
                              height: 50.0,
                              width: 50.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
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
            const SizedBox(
              height: 20.0,
            ),
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
                      .translate("edit_account_screen", "pseudo_profile"),
                  style: textStyleCustomBold(Helpers.uiApp(context), 18),
                )
              ]),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1.0),
            ),
            const SizedBox(height: 10.0),
            Center(
              child: TextField(
                scrollPhysics: const BouncingScrollPhysics(),
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
                style: textStyleCustomRegular(
                    _pseudoFocusNode.hasFocus ? cBlue : cGrey,
                    MediaQuery.of(context).textScaler.scale(14)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  hintText: AppLocalization.of(context)
                      .translate("edit_account_screen", "pseudo_profile"),
                  hintStyle: textStyleCustomRegular(
                      cGrey, MediaQuery.of(context).textScaler.scale(14)),
                  labelStyle: textStyleCustomRegular(
                      cBlue, MediaQuery.of(context).textScaler.scale(14)),
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
            ),
            const SizedBox(
              height: 20.0,
            ),
            RichText(
                text: TextSpan(children: [
                  WidgetSpan(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Icon(Icons.rate_review,
                        color: Helpers.uiApp(context), size: 20),
                  )),
                  TextSpan(
                    text: "Biographie",
                    style: textStyleCustomBold(Helpers.uiApp(context), 18),
                  )
                ]),
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1.0)),
            const SizedBox(height: 10.0),
            Center(
              child: TextField(
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
                    MediaQuery.of(context).textScaler.scale(14)),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  hintText: "Biographie",
                  hintStyle: textStyleCustomRegular(
                      cGrey, MediaQuery.of(context).textScaler.scale(14)),
                  labelStyle: textStyleCustomRegular(
                      cBlue, MediaQuery.of(context).textScaler.scale(14)),
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
                  text: AppLocalization.of(context)
                      .translate("edit_account_screen", "gender_profile"),
                  style: textStyleCustomBold(Helpers.uiApp(context), 18),
                )
              ]),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1.0),
            ),
            const SizedBox(
              height: 10.0,
            ),
            GridView.builder(
                padding: EdgeInsets.zero,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: genders.length,
                itemBuilder: (_, int index) {
                  var element = genders[index];

                  return _selectedGender == element["id"]
                      ? Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                    color: cBlue,
                                    border: Border.all(color: cBlue),
                                    borderRadius: BorderRadius.circular(10.0)),
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
                            const SizedBox(height: 5.0),
                            Text(element["type"],
                                style: textStyleCustomBold(cBlue, 16),
                                textScaler: const TextScaler.linear(1.0))
                          ],
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  ref
                                      .read(editGenderUserNotifierProvider
                                          .notifier)
                                      .updateGender(element["id"]);
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
                                textScaler: const TextScaler.linear(1.0))
                          ],
                        );
                }),
            const SizedBox(
              height: 20.0,
            ),
            RichText(
              text: TextSpan(children: [
                WidgetSpan(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 5.0),
                  child: Icon(Icons.celebration,
                      size: 20, color: Helpers.uiApp(context)),
                )),
                TextSpan(
                  text: AppLocalization.of(context)
                      .translate("edit_account_screen", "birthday_profile"),
                  style: textStyleCustomBold(Helpers.uiApp(context), 18),
                )
              ]),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1.0),
            ),
            const SizedBox(
              height: 10.0,
            ),
            GestureDetector(
              onTap: () {
                picker.DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    locale: localeLanguage.languageCode == "fr"
                        ? picker.LocaleType.fr
                        : picker.LocaleType.en,
                    theme: picker.DatePickerTheme(
                      backgroundColor:
                          Theme.of(context).scaffoldBackgroundColor,
                      cancelStyle: textStyleCustomBold(cBlue, 16),
                      doneStyle: textStyleCustomBold(cBlue, 16),
                      itemStyle: textStyleCustomBold(
                          Theme.of(context).iconTheme.color!, 18),
                    ),
                    minTime: DateTime(1900, 1, 1),
                    maxTime: DateTime.now(), onConfirm: (date) {
                  //verif 18 years old or not
                  final verif =
                      DateTime.now().subtract(const Duration(days: 6570));
                  if (date.isBefore(verif)) {
                    ref
                        .read(editBirthdayUserNotifierProvider.notifier)
                        .updateBirthday(date);
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
                    Helpers.formattingDate(_dateBirthday ?? DateTime.now(),
                        localeLanguage.languageCode),
                    style: textStyleCustomBold(Helpers.uiApp(context), 20),
                    textScaler: const TextScaler.linear(1.0)),
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
                  child: Icon(Icons.travel_explore,
                      size: 20, color: Helpers.uiApp(context)),
                )),
                TextSpan(
                  text: AppLocalization.of(context)
                      .translate("edit_account_screen", "nationality_profile"),
                  style: textStyleCustomBold(Helpers.uiApp(context), 18),
                )
              ]),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1.0),
            ),
            const SizedBox(
              height: 10.0,
            ),
            Center(
              child: Container(
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
                      if (countryCode.code != null) {
                        ref
                            .read(editNationalityUserNotifierProvider.notifier)
                            .updateNationality(countryCode.code!);
                      }
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
                        textScaler: const TextScaler.linear(1.0)),
                  )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _saveEditAccount() {
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
                          await _saveModifUser();
                        },
                        child: Text(
                            AppLocalization.of(context)
                                .translate("general", "btn_save"),
                            style: textStyleCustomMedium(
                                Helpers.uiApp(context), 20),
                            textScaler: const TextScaler.linear(1.0)))),
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
                        onPressed: () async {
                          await _canceledModifUser();
                        },
                        child: Text(
                            AppLocalization.of(context)
                                .translate("general", "btn_cancel"),
                            style: textStyleCustomMedium(
                                Helpers.uiApp(context), 20),
                            textScaler: const TextScaler.linear(1.0)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
