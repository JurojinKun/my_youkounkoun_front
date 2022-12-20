import 'dart:io';

import 'package:age_calculator/age_calculator.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class UserProfile extends ConsumerStatefulWidget {
  final User user;

  const UserProfile({Key? key, required this.user}) : super(key: key);

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends ConsumerState<UserProfile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            onPressed: () => navSearchKey!.currentState!.pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).brightness == Brightness.light
                  ? cBlack
                  : cWhite,
            )),
        title: Text("Profil de ${widget.user.pseudo}",
            style: textStyleCustomBold(
                Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite,
                20),
            textScaleFactor: 1.0),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SizedBox.expand(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Center(
                child: Column(
                  children: [
                    widget.user.profilePictureUrl.trim() != ""
                        ? Container(
                            height: 155,
                            width: 155,
                            foregroundDecoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: cBlue),
                                image: DecorationImage(
                                    image: NetworkImage(widget.user.profilePictureUrl),
                                    fit: BoxFit.cover)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cBlue),
                              color: cGrey.withOpacity(0.2),
                            ),
                            child: const Icon(Icons.person, color: cBlue, size: 75),
                          )
                        : Container(
                            height: 155,
                            width: 155,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cBlue),
                              color: cGrey.withOpacity(0.2),
                            ),
                            child: const Icon(Icons.person, color: cBlue, size: 75),
                          ),
                    const SizedBox(
                      height: 15.0,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.user.pseudo,
                          style: textStyleCustomBold(
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                              23),
                          textScaleFactor: 1.0,
                          textAlign: TextAlign.center,
                        ),
                        Flag.flagsCode.contains(widget.user.nationality.toUpperCase())
                            ? Flag.fromString(
                                widget.user.nationality.toUpperCase(),
                                height: 25,
                                width: 50,
                                fit: BoxFit.contain,
                                replacement: const SizedBox(),
                              )
                            : Flag.flagsCode
                                    .contains(widget.user.nationality.toLowerCase())
                                ? Flag.fromString(
                                    widget.user.nationality.toLowerCase(),
                                    height: 25,
                                    width: 50,
                                    fit: BoxFit.contain,
                                    replacement: const SizedBox(),
                                  )
                                : const SizedBox()
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(widget.user.gender == "Male" ? Icons.male : Icons.female,
                            color: Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite),
                        Text(
                          " - ",
                          style: textStyleCustomBold(
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                              18),
                        ),
                        Text(
                            AgeCalculator.age(Helpers.convertStringToDateTime(
                                        widget.user.birthday))
                                    .years
                                    .toString() +
                                AppLocalization.of(context)
                                    .translate("profile_screen", "years_old"),
                            style: textStyleCustomBold(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                18.0))
                      ],
                    ),
                    Container(
                      height: 150.0,
                      alignment: Alignment.center,
                      child: Text(
                        AppLocalization.of(context)
                            .translate("general", "message_continue"),
                        style: textStyleCustomMedium(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            14),
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.0,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
