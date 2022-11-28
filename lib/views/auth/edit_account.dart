import 'dart:io';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/helpers/helpers.dart';
import 'package:my_boilerplate/models/user_model.dart';
import 'package:my_boilerplate/providers/locale_language_provider.dart';
import 'package:my_boilerplate/providers/user_provider.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';

class EditAccount extends ConsumerStatefulWidget {
  const EditAccount({Key? key}) : super(key: key);

  @override
  EditAccountState createState() => EditAccountState();
}

class EditAccountState extends ConsumerState<EditAccount>
    with WidgetsBindingObserver {
      late String localeLanguage;

  late User user;

  late TextEditingController _pseudoController;
  late FocusNode _pseudoFocusNode;

  List genders = [];

  DateTime? _dateBirthday;

  String? _selectedCountry;

  bool _isEdit = false;
  bool _isKeyboard = false;

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
          return SizedBox(
            height: Platform.isIOS ? 180 : 160,
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
                        IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.clear,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? cBlack
                                    : cWhite))
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
      final image =
          await ImagePicker().pickImage(source: src, imageQuality: 50);
      if (image != null) {
        if (mounted) {
          Navigator.pop(context);
        }
        // ref
        //     .read(profilePictureRegisterNotifierProvider.notifier)
        //     .addNewProfilePicture(File(image.path));
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pseudoController = TextEditingController();
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

    _pseudoController.dispose();
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
    user = ref.watch(userNotifierProvider);

    return GestureDetector(
      onTap: () => Helpers.hideKeyboard(context),
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            shadowColor: Colors.transparent,
            backgroundColor: Colors.transparent,
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
            title: Text(
              AppLocalization.of(context)
                  .translate("edit_account_screen", "my_account"),
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  20),
              textScaleFactor: 1.0,
            ),
          ),
          body: Stack(
            children: [
              _editAccount(),
              _isEdit && !_isKeyboard ? _saveEditAccount() : const SizedBox()
            ],
          )),
    );
  }

  Widget _editAccount() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: Padding(
        padding: EdgeInsets.only(bottom: _isEdit ? 110 : 10, left: 20, right: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20.0,
            ),
            Text(
              "Tu peux modifier tes informations de ton compte directement ici !",
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
              "Image de profil",
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  18),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            ),
            const SizedBox(height: 20.0),
            Center(
              child: SizedBox(
                height: 155,
                width: 155,
                child: Stack(
                  children: [
                    user.profilePictureUrl.trim() == ""
                        ? Container(
                            height: 155,
                            width: 155,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: cBlue)),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.person,
                              color: cBlue,
                              size: 60.0,
                            ),
                          )
                        : Container(
                            height: 155,
                            width: 155,
                            foregroundDecoration: BoxDecoration(
                                color: cGrey.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: cBlue),
                                image: DecorationImage(
                                    image: NetworkImage(user.profilePictureUrl),
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
                              size: 60.0,
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
                              decoration: const BoxDecoration(
                                  color: cWhite,
                                  shape: BoxShape.circle,
                                  boxShadow: [
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
            Text(
              "Pseudonyme",
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  18),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            ),
            const SizedBox(height: 20.0),
            Center(
              child: TextField(
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
                        Colors.grey, 14 / MediaQuery.of(context).textScaleFactor),
                    labelStyle: textStyleCustomRegular(
                        cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                    prefixIcon: Icon(Icons.person,
                        color: _pseudoFocusNode.hasFocus ? cBlue : Colors.grey),
                    suffixIcon: _pseudoController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _pseudoController.clear();
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color:
                                  _pseudoFocusNode.hasFocus ? cBlue : Colors.grey,
                            ))
                        : const SizedBox()),
              ),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Text(
              "Genre",
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  18),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            ),
            const SizedBox(
              height: 20.0,
            ),
            Center(
              child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10),
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: genders.length,
                  itemBuilder: (_, int index) {
                    var element = genders[index];

                    return user.gender == element["id"]
                        ? Column(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // ref
                                    //     .read(genderRegisterNotifierProvider
                                    //         .notifier)
                                    //     .clearGender();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: cBlue,
                                        border: Border.all(
                                            color: Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? cBlack
                                                : cWhite),
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
                                    // ref
                                    //     .read(genderRegisterNotifierProvider
                                    //         .notifier)
                                    //     .choiceGender(element["id"]);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius:
                                            BorderRadius.circular(10.0)),
                                    child: Center(
                                      child: Icon(
                                        element["icon"],
                                        color: Colors.grey,
                                        size: 50,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5.0),
                              Text(element["type"],
                                  style: textStyleCustomBold(Colors.grey, 16),
                                  textScaleFactor: 1.0)
                            ],
                          );
                  }),
            ),
            const SizedBox(
              height: 20.0,
            ),
            Text(
              "Date de naissance",
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  18),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            ),
            const SizedBox(
              height: 20.0,
            ),
            Center(
              child: GestureDetector(
                  onTap: () {
                    DatePicker.showDatePicker(context,
                        showTitleActions: true,
                        locale: localeLanguage == "fr"
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
                        // ref
                        //     .read(birthdayRegisterNotifierProvider.notifier)
                        //     .updateBirthday(true);
                      } else {
                        // ref
                        //     .read(birthdayRegisterNotifierProvider.notifier)
                        //     .updateBirthday(false);
                      }
                    }, currentTime: _dateBirthday ?? DateTime.now());
                  },
                  child: Container(
                    height: 34.0,
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              width: 1.0,
                              color:
                                  Theme.of(context).brightness == Brightness.light
                                      ? cBlack
                                      : cWhite)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                          Helpers.formattingDate(
                              _dateBirthday ?? DateTime.now(), localeLanguage),
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
            const SizedBox(
              height: 20.0,
            ),
            Text(
              "Nationnalité",
              style: textStyleCustomBold(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  18),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            ),
            const SizedBox(
              height: 20.0,
            ),
            Center(
              child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                      color: Theme.of(context).canvasColor,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5.0)),
                  child: CountryCodePicker(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    onChanged: (countryCode) {
                      setState(() {
                        _selectedCountry = countryCode.code;
                      });
                    },
                    initialSelection: user.nationality,
                    showCountryOnly: true,
                    showOnlyCountryWhenClosed: true,
                    alignLeft: true,
                    boxDecoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.circular(5.0)),
                    barrierColor: cBlack.withOpacity(0.5),
                    dialogSize: Size(MediaQuery.of(context).size.width - 20,
                        MediaQuery.of(context).size.height / 1.5),
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
                        AppLocalization.of(context)
                            .translate("register_screen", "empty_search_country"),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleSmall,
                        textScaleFactor: 1.0),
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
