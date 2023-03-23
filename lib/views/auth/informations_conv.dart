import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';

class InformationsConv extends ConsumerStatefulWidget {
  final UserModel user;

  const InformationsConv({Key? key, required this.user}) : super(key: key);

  @override
  InformationsConvState createState() => InformationsConvState();
}

class InformationsConvState extends ConsumerState<InformationsConv> {
  final AppBar appBar = AppBar();

  @override
  Widget build(BuildContext context) {
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
              child: Column(
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
                          child:
                              const Icon(Icons.person, color: cBlue, size: 55),
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
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
                                child: Icon(Icons.person,
                                    color: Helpers.uiApp(context)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "Profil",
                            style:
                                textStyleCustomBold(Helpers.uiApp(context), 14),
                            textScaleFactor: 1.0,
                          )
                        ],
                      ),
                      const SizedBox(width: 40.0),
                      Column(
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
                                onTap: () => print("sourdine"),
                                child: Icon(Icons.notifications_active,
                                    color: Helpers.uiApp(context)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5.0),
                          Text(
                            "Sourdine",
                            style:
                                textStyleCustomBold(Helpers.uiApp(context), 14),
                            textScaleFactor: 1.0,
                          )
                        ],
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
                        onTap: () => print("thème conv"),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Row(
                            children: [
                              Container(
                                height: 25.0,
                                width: 25.0,
                                decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.blue, cBlue]),
                                    shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 15.0),
                              Text(
                                "Thème conversation",
                                style: textStyleCustomBold(
                                    Helpers.uiApp(context), 16.0),
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
                                style: textStyleCustomBold(
                                    Helpers.uiApp(context), 16.0),
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
                        onTap: () => print("sourdine"),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Row(
                            children: [
                              Icon(Icons.notifications_active,
                                  color: Helpers.uiApp(context)),
                              const SizedBox(width: 15.0),
                              Text(
                                "Sourdine",
                                style: textStyleCustomBold(
                                    Helpers.uiApp(context), 16.0),
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
                                style: textStyleCustomBold(
                                    Helpers.uiApp(context), 16.0),
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
              ),
            ),
          );
        }));
  }
}
