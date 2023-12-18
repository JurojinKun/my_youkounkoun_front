import 'dart:ui';

import 'package:age_calculator/age_calculator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/libraries/env_config_lib.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/connectivity_status_app_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends ConsumerState<Profile>
    with AutomaticKeepAliveClientMixin {
  late UserModel user;

  AppBar appBar = AppBar();

  ConnectivityResult? connectivityStatusApp;
  bool profilePictureAlreadyLoaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    user = ref.watch(userNotifierProvider);
    connectivityStatusApp = ref.watch(connectivityStatusAppNotifierProvider);
    profilePictureAlreadyLoaded =
        ref.watch(profilePictureAlreadyLoadedNotifierProvider);

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
              systemOverlayStyle: Helpers.uiOverlayApp(context),
              title: Text(
                  AppLocalization.of(context)
                      .translate("profile_screen", "profile"),
                  style: textStyleCustomBold(Helpers.uiApp(context), 20),
                  textScaler: const TextScaler.linear(1.0)),
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
                        color: Helpers.uiApp(context),
                      )),
                ),
                if (!EnvironmentConfigLib().getEnvironmentBottomNavBar)
                  Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: IconButton(
                          onPressed: () {
                            drawerScaffoldKey.currentState!.openEndDrawer();
                          },
                          icon: SizedBox(
                              height: 25.0,
                              width: 25.0,
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Icon(
                                    Icons.menu,
                                    color: Helpers.uiApp(context),
                                    size: 25,
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 0,
                                    child: Container(
                                      height: 10.0,
                                      width: 10.0,
                                      decoration: const BoxDecoration(
                                          color: cBlue,
                                          shape: BoxShape.circle),
                                    ),
                                  )
                                ],
                              ))))
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
              topProfile(),
              const SizedBox(height: 10.0),
              bodyProfile()
            ],
          ),
        ),
      ),
    );
  }

  Widget topProfile() {
    return Column(
      children: [
        Row(
          children: [
            user.profilePictureUrl.trim() == "" ||
                    (connectivityStatusApp == ConnectivityResult.none &&
                        !profilePictureAlreadyLoaded)
                ? Container(
                    height: 145,
                    width: 145,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cBlue),
                      color: cGrey.withOpacity(0.2),
                    ),
                    child: const Icon(Icons.person, color: cBlue, size: 75),
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
                                  image: imageProvider, fit: BoxFit.cover)),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cBlue),
                            color: cGrey.withOpacity(0.2),
                          ),
                          child:
                              const Icon(Icons.person, color: cBlue, size: 55));
                    }),
                    progressIndicatorBuilder: (context, url, downloadProgress) {
                      if (downloadProgress.progress == 1.0 &&
                          !profilePictureAlreadyLoaded) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ref
                              .read(profilePictureAlreadyLoadedNotifierProvider
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
                        child: const Icon(Icons.person, color: cBlue, size: 55),
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
                      child: const Icon(Icons.person, color: cBlue, size: 55),
                    ),
                  ),
            const SizedBox(width: 25.0),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      user.pseudo,
                      style: textStyleCustomBold(Helpers.uiApp(context), 20),
                      textScaler: const TextScaler.linear(1.0),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(width: 5.0),
                    Flag.flagsCode.contains(user.nationality.toUpperCase())
                        ? Flag.fromString(
                            user.nationality.toUpperCase(),
                            height: 15,
                            width: 20,
                            fit: BoxFit.contain,
                            replacement: const SizedBox(),
                          )
                        : Flag.flagsCode
                                .contains(user.nationality.toLowerCase())
                            ? Flag.fromString(
                                user.nationality.toLowerCase(),
                                height: 15,
                                width: 20,
                                fit: BoxFit.contain,
                                replacement: const SizedBox(),
                              )
                            : const SizedBox()
                  ],
                ),
                const SizedBox(height: 5.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Icon(
                      user.gender == "Male" ? Icons.male : Icons.female,
                      color: Helpers.uiApp(context),
                      size: 20,
                    ),
                    Text(
                      " - ",
                      style: textStyleCustomBold(Helpers.uiApp(context), 16),
                    ),
                    Text(
                        AgeCalculator.age(Helpers.convertStringToDateTime(
                                    user.birthday))
                                .years
                                .toString() +
                            AppLocalization.of(context)
                                .translate("profile_screen", "years_old"),
                        style:
                            textStyleCustomBold(Helpers.uiApp(context), 16.0))
                  ],
                ),
                const SizedBox(height: 5.0),
                Text("${Helpers.formatNumber(user.followers.length)} ${AppLocalization.of(context).translate("profile_screen", "followers")}",
                    style: textStyleCustomBold(Helpers.uiApp(context), 14),
                    textScaler: const TextScaler.linear(1.0),
                    maxLines: 2,
                    overflow: TextOverflow.clip),
                const SizedBox(height: 5.0),
                Text("${Helpers.formatNumber(user.followings.length)} ${AppLocalization.of(context).translate("profile_screen", "followings")}",
                    style: textStyleCustomBold(Helpers.uiApp(context), 14),
                    textScaler: const TextScaler.linear(1.0),
                    maxLines: 2,
                    overflow: TextOverflow.clip),
              ],
            ))
          ],
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: Text(user.bio,
                style: textStyleCustomMedium(Helpers.uiApp(context), 14),
                textScaler: const TextScaler.linear(1.0)),
          ),
        )
      ],
    );
  }

  Widget bodyProfile() {
    return Container(
      height: 150.0,
      alignment: Alignment.center,
      child: Text(
        AppLocalization.of(context).translate("general", "message_continue"),
        style: textStyleCustomMedium(Helpers.uiApp(context), 14),
        textAlign: TextAlign.center,
        textScaler: const TextScaler.linear(1.0),
      ),
    );
  }
}
