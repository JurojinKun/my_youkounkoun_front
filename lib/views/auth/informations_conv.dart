import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/chat_details_provider.dart';
import 'package:myyoukounkoun/providers/chat_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';

class InformationsConv extends ConsumerStatefulWidget {
  final UserModel user;

  const InformationsConv({Key? key, required this.user}) : super(key: key);

  @override
  InformationsConvState createState() => InformationsConvState();
}

class InformationsConvState extends ConsumerState<InformationsConv> {
  final AppBar appBar = AppBar();

  late ConversationModel _currentConversation;

  int indexUserConv = 0;

  @override
  void initState() {
    super.initState();

    for (var user in ref.read(currentConvNotifierProvider).users) {
      if (user["id"] == ref.read(userNotifierProvider).id) {
        indexUserConv =
            ref.read(currentConvNotifierProvider).users.indexOf(user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _currentConversation = ref.watch(currentConvNotifierProvider);

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
                  "Informations conversation",
                  style: textStyleCustomBold(Helpers.uiApp(context), 20),
                  textScaleFactor: 1.0,
                ),
                centerTitle: false,
              ),
            ),
          ),
        ),
        body: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20.0,
                MediaQuery.of(context).padding.top + 20.0,
                20.0,
                MediaQuery.of(context).padding.bottom + 10.0),
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: constraints.maxHeight -
                        (MediaQuery.of(context).padding.top +
                            MediaQuery.of(context).padding.bottom)),
                child: infosConv()),
          );
        }));
  }

  Widget infosConv() {
    return Column(
      children: [
        widget.user.profilePictureUrl.trim() == ""
            ? Container(
                height: 145,
                width: 145,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cBlue),
                  color: cGrey.withOpacity(0.2),
                ),
                child: const Icon(Icons.person, color: cBlue, size: 55),
              )
            : CachedNetworkImageCustom(
                profilePictureUrl: widget.user.profilePictureUrl,
                heightContainer: 145,
                widthContainer: 145,
                iconSize: 55),
        const SizedBox(height: 10.0),
        Text(
          widget.user.pseudo,
          style: textStyleCustomBold(Helpers.uiApp(context), 20.0),
          textScaleFactor: 1.0,
        ),
        const SizedBox(height: 20.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: cBlue.withOpacity(0.5),
                        highlightColor: cBlue.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15.0),
                        onTap: () => navAuthKey.currentState!.pushNamed(
                            userProfile,
                            arguments: [widget.user, false]),
                        child:
                            Icon(Icons.person, color: Helpers.uiApp(context)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    "Profil",
                    style: textStyleCustomBold(Helpers.uiApp(context), 14),
                    textScaleFactor: 1.0,
                  )
                ],
              ),
            ),
            SizedBox(
              width: 100,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(15.0)),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: cBlue.withOpacity(0.5),
                        highlightColor: cBlue.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15.0),
                        onTap: () {
                          if (_currentConversation.users[indexUserConv]
                              ["convMute"]) {
                            ref
                                .read(conversationsNotifierProvider.notifier)
                                .muteConversation(_currentConversation.id,
                                    indexUserConv, false);
                            ref
                                .read(currentConvNotifierProvider.notifier)
                                .muteConversation(indexUserConv, false);
                          } else {
                            ref
                                .read(conversationsNotifierProvider.notifier)
                                .muteConversation(_currentConversation.id,
                                    indexUserConv, true);
                            ref
                                .read(currentConvNotifierProvider.notifier)
                                .muteConversation(indexUserConv, true);
                          }
                        },
                        child: Icon(
                            _currentConversation.users[indexUserConv]
                                    ["convMute"]
                                ? Icons.notifications_active
                                : Icons.notifications_off,
                            color: Helpers.uiApp(context)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5.0),
                  Text(
                    _currentConversation.users[indexUserConv]["convMute"]
                        ? "Réactiver"
                        : "Désactiver",
                    style: textStyleCustomBold(Helpers.uiApp(context), 14),
                    textScaleFactor: 1.0,
                  )
                ],
              ),
            )
          ],
        ),
        const SizedBox(
          height: 25.0,
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                "Personnalisation",
                style: textStyleCustomBold(cGrey, 14),
                textScaleFactor: 1.0,
              ),
            )),
        const SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(15.0)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: cBlue.withOpacity(0.5),
              highlightColor: cBlue.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15.0),
              onTap: () {
                ref
                    .read(conversationsNotifierProvider.notifier)
                    .newThemeConversation(
                        _currentConversation.id, ["#c442c2", "#5142c4"]);
                ref
                    .read(currentConvNotifierProvider.notifier)
                    .newThemeConversation(["#c442c2", "#5142c4"]);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                child: Row(
                  children: [
                    Container(
                      height: 25.0,
                      width: 25.0,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Color(int.parse(
                                        _currentConversation.themeConv[0]
                                            .substring(1, 7),
                                        radix: 16) +
                                    0xFF000000),
                                Color(int.parse(
                                        _currentConversation.themeConv[1]
                                            .substring(1, 7),
                                        radix: 16) +
                                    0xFF000000)
                              ]),
                          shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 15.0),
                    Text(
                      "Thème conversation",
                      style: textStyleCustomBold(Helpers.uiApp(context), 16.0),
                      textScaleFactor: 1.0,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25.0),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                "Détails",
                style: textStyleCustomBold(cGrey, 14),
                textScaleFactor: 1.0,
              ),
            )),
        const SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0))),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: cBlue.withOpacity(0.5),
              highlightColor: cBlue.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0)),
              onTap: () => print("rechercher message"),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                child: Row(
                  children: [
                    Icon(Icons.search, color: Helpers.uiApp(context)),
                    const SizedBox(width: 15.0),
                    Text(
                      "Rechercher message",
                      style: textStyleCustomBold(Helpers.uiApp(context), 16.0),
                      textScaleFactor: 1.0,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2.0),
        Container(
          color: Theme.of(context).canvasColor,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: cBlue.withOpacity(0.5),
              highlightColor: cBlue.withOpacity(0.5),
              onTap: () {
                if (_currentConversation.users[indexUserConv]["convMute"]) {
                  ref
                      .read(conversationsNotifierProvider.notifier)
                      .muteConversation(
                          _currentConversation.id, indexUserConv, false);
                  ref
                      .read(currentConvNotifierProvider.notifier)
                      .muteConversation(indexUserConv, false);
                } else {
                  ref
                      .read(conversationsNotifierProvider.notifier)
                      .muteConversation(
                          _currentConversation.id, indexUserConv, true);
                  ref
                      .read(currentConvNotifierProvider.notifier)
                      .muteConversation(indexUserConv, true);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                child: Row(
                  children: [
                    Icon(
                        _currentConversation.users[indexUserConv]["convMute"]
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: Helpers.uiApp(context)),
                    const SizedBox(width: 15.0),
                    Text(
                      _currentConversation.users[indexUserConv]["convMute"]
                          ? "Réactiver"
                          : "Désactiver",
                      style: textStyleCustomBold(Helpers.uiApp(context), 16.0),
                      textScaleFactor: 1.0,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2.0),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0))),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: cBlue.withOpacity(0.5),
              highlightColor: cBlue.withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0)),
              onTap: () => print("multimédias"),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10.0, vertical: 10.0),
                child: Row(
                  children: [
                    Icon(Icons.photo, color: Helpers.uiApp(context)),
                    const SizedBox(width: 15.0),
                    Text(
                      "Multimédias conversation",
                      style: textStyleCustomBold(Helpers.uiApp(context), 16.0),
                      textScaleFactor: 1.0,
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 25.0),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                "Autres actions",
                style: textStyleCustomBold(cGrey, 14),
                textScaleFactor: 1.0,
              ),
            )),
        const SizedBox(height: 10.0),
        Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0))),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: cRed.withOpacity(0.2),
              highlightColor: cRed.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0)),
              onTap: () => print("effacer conversation"),
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Text(
                    "Effacer conversation",
                    style: textStyleCustomBold(cRed, 16.0),
                    textScaleFactor: 1.0,
                  )),
            ),
          ),
        ),
        const SizedBox(height: 2.0),
        Container(
            width: MediaQuery.of(context).size.width,
            color: Theme.of(context).canvasColor,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: cRed.withOpacity(0.2),
                highlightColor: cRed.withOpacity(0.2),
                onTap: () => print("signaler user"),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Text(
                    "Signaler ${widget.user.pseudo}",
                    style: textStyleCustomBold(cRed, 16.0),
                    textScaleFactor: 1.0,
                  ),
                ),
              ),
            )),
        const SizedBox(height: 2.0),
        Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0))),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: cRed.withOpacity(0.2),
                highlightColor: cRed.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0)),
                onTap: () => print("bloquer user"),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Text(
                    "Bloquer ${widget.user.pseudo}",
                    style: textStyleCustomBold(cRed, 16.0),
                    textScaleFactor: 1.0,
                  ),
                ),
              ),
            )),
      ],
    );
  }
}
