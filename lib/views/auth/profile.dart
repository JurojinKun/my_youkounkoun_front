import 'dart:io';
import 'dart:ui';

import 'package:age_calculator/age_calculator.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends ConsumerState<Profile>
    with AutomaticKeepAliveClientMixin {
  late User user;

  AppBar appBar = AppBar();

  @override
  void initState() {
    super.initState();
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
              title: Text(
                  AppLocalization.of(context)
                      .translate("profile_screen", "profile"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      20),
                  textScaleFactor: 1.0),
              centerTitle: false,
              actions: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: IconButton(
                      onPressed: () =>
                          navProfileKey!.currentState!.pushNamed(settingsUser),
                      icon: Icon(
                        Icons.settings,
                        color: Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20.0,
              MediaQuery.of(context).padding.top +
                  appBar.preferredSize.height +
                  20.0,
              20.0,
              MediaQuery.of(context).padding.bottom + 90.0),
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              user.profilePictureUrl.trim() != ""
                  ? Container(
                      height: 175,
                      width: 175,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: cBlue),
                        color: cGrey.withOpacity(0.2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          user.profilePictureUrl,
                          fit: BoxFit.cover,
                          frameBuilder:
                              (context, child, frame, wasSynchronouslyLoaded) {
                            if (frame == null && !wasSynchronouslyLoaded) {
                              return const Center(
                                  child: Icon(Icons.person,
                                      color: cBlue, size: 75));
                            }
                            return child;
                          },
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                color: cBlue,
                                strokeWidth: 2.0,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                                child:
                                    Icon(Icons.person, color: cBlue, size: 75));
                          },
                        ),
                      ),
                    )
                  : Container(
                      height: 175,
                      width: 175,
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
                    user.pseudo,
                    style: textStyleCustomBold(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        23),
                    textScaleFactor: 1.0,
                    textAlign: TextAlign.center,
                  ),
                  Flag.flagsCode.contains(user.nationality.toUpperCase())
                      ? Flag.fromString(
                          user.nationality.toUpperCase(),
                          height: 25,
                          width: 50,
                          fit: BoxFit.contain,
                          replacement: const SizedBox(),
                        )
                      : Flag.flagsCode.contains(user.nationality.toLowerCase())
                          ? Flag.fromString(
                              user.nationality.toLowerCase(),
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
                  Icon(user.gender == "Male" ? Icons.male : Icons.female,
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
                                  user.birthday))
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
    );
  }
}
