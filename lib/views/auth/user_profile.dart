import 'dart:io';
import 'dart:ui';

import 'package:age_calculator/age_calculator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flag/flag.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/auth/chat_details.dart';

class UserProfile extends ConsumerStatefulWidget {
  final User user;
  final bool bottomNav;

  const UserProfile({Key? key, required this.user, required this.bottomNav})
      : super(key: key);

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends ConsumerState<UserProfile> {
  AppBar appBar = AppBar();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _conversationBottomSheet(BuildContext context) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: false,
        builder: (context) {
          return ChatDetails(user: widget.user, openWithModal: true);
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        int sensitivity = 8;
        if (Platform.isIOS &&
            details.delta.dx > sensitivity &&
            details.globalPosition.dx <= 70) {
          if (ref.read(afterChatDetailsNotifierProvider)) {
            ref
                .read(afterChatDetailsNotifierProvider.notifier)
                .clearAfterChat();
            ref
                .read(inChatDetailsNotifierProvider.notifier)
                .inChatDetails("ChatDetails", widget.user.id.toString());
          }
          Navigator.pop(context);
        }
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
                  leading: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                        onPressed: () {
                          if (ref.read(afterChatDetailsNotifierProvider)) {
                            ref
                                .read(afterChatDetailsNotifierProvider.notifier)
                                .clearAfterChat();
                            ref
                                .read(inChatDetailsNotifierProvider.notifier)
                                .inChatDetails(
                                    "ChatDetails", widget.user.id.toString());
                          }
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                        )),
                  ),
                  title: Text(
                      "${AppLocalization.of(context).translate("user_profile_screen", "profile_of")} ${widget.user.pseudo}",
                      style: textStyleCustomBold(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          20),
                      textScaleFactor: 1.0),
                  centerTitle: false,
                  actions: [
                    widget.user.id == ref.read(userNotifierProvider).id
                        ? const SizedBox()
                        : Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: IconButton(
                                onPressed: () => _conversationBottomSheet(
                                    navAuthKey.currentContext!),
                                icon: Icon(Icons.edit_note,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    size: 33)),
                          )
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
                  widget.bottomNav
                      ? MediaQuery.of(context).padding.bottom + 90.0
                      : MediaQuery.of(context).padding.bottom + 20.0),
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              child: Column(
                children: [
                  widget.user.profilePictureUrl.trim() == ""
                      ? Container(
                          height: 175,
                          width: 175,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cBlue),
                            color: cGrey.withOpacity(0.2),
                          ),
                          child:
                              const Icon(Icons.person, color: cBlue, size: 75),
                        )
                      : CachedNetworkImage(
                          imageUrl: widget.user.profilePictureUrl,
                          imageBuilder: ((context, imageProvider) {
                            return Container(
                                height: 175,
                                width: 175,
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
                                    color: cBlue, size: 75));
                          }),
                          progressIndicatorBuilder:
                              (context, url, downloadProgress) {
                            return Container(
                              height: 175,
                              width: 175,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: cBlue),
                                color: cGrey.withOpacity(0.2),
                              ),
                              child: const Icon(Icons.person,
                                  color: cBlue, size: 75),
                            );
                          },
                          errorWidget: (context, url, error) => Container(
                            height: 175,
                            width: 175,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cBlue),
                              color: cGrey.withOpacity(0.2),
                            ),
                            child: const Icon(Icons.person,
                                color: cBlue, size: 75),
                          ),
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
                      Flag.flagsCode
                              .contains(widget.user.nationality.toUpperCase())
                          ? Flag.fromString(
                              widget.user.nationality.toUpperCase(),
                              height: 25,
                              width: 50,
                              fit: BoxFit.contain,
                              replacement: const SizedBox(),
                            )
                          : Flag.flagsCode.contains(
                                  widget.user.nationality.toLowerCase())
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
                      Icon(
                          widget.user.gender == "Male"
                              ? Icons.male
                              : Icons.female,
                          color:
                              Theme.of(context).brightness == Brightness.light
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
                              AppLocalization.of(context).translate(
                                  "user_profile_screen", "years_old"),
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
          )),
    );
  }
}
