import 'dart:io';

import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/models/user_model.dart';
import 'package:my_boilerplate/providers/user_provider.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends ConsumerState<Profile>
    with AutomaticKeepAliveClientMixin {
  late User user;
  late IconData _gender;

  @override
  void initState() {
    super.initState();

    if (ref.read(userNotifierProvider).gender == "Male") {
      _gender = Icons.male;
    } else {
      _gender = Icons.female;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    user = ref.watch(userNotifierProvider);

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
        title: Text(
            AppLocalization.of(context).translate("profile_screen", "profile"),
            style: textStyleCustomBold(
                Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite,
                20),
            textScaleFactor: 1.0),
        actions: [
          IconButton(
              onPressed: () =>
                  navProfileKey!.currentState!.pushNamed(settingsUser),
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite,
              )),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                user.profilePictureUrl.trim() != ""
                    ? Container(
                        height: 125,
                        width: 125,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cBlue),
                            color: cGrey,
                            image: DecorationImage(
                                image: NetworkImage(user.profilePictureUrl),
                                fit: BoxFit.cover)),
                      )
                    : Container(
                        height: 125,
                        width: 125,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: cBlue),
                          color: cGrey,
                        ),
                        child: const Icon(Icons.person, color: cGrey, size: 75),
                      ),
                const SizedBox(
                  height: 15.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flag.fromString(
                      user.nationality,
                      height: 25,
                      width: 50,
                      fit: BoxFit.contain,
                      replacement: const SizedBox(),
                    ),
                    Text(
                      user.pseudo,
                      style: textStyleCustomBold(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          23),
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_gender,
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
                        user.age.toString() +
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
                        .translate("profile_screen", "message_continue"),
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
    );
  }
}
