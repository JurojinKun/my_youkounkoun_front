import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/icons_app_model.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class IconsApp extends ConsumerStatefulWidget {
  const IconsApp({super.key});

  @override
  IconsAppState createState() => IconsAppState();
}

class IconsAppState extends ConsumerState<IconsApp> {
  AppBar appBar = AppBar();

  List<IconsAppModel> icons = [
    IconsAppModel(asset: "assets/icons_app/ic_default.png", name: "Default"),
    IconsAppModel(
        asset: "assets/icons_app/ic_just_black.png", name: "Just black"),
    IconsAppModel(
        asset: "assets/icons_app/ic_just_blue.png", name: "Just blue"),
    IconsAppModel(asset: "assets/icons_app/ic_space.png", name: "Space"),
  ];

  String choiceIcon = "Default";

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
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
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
                centerTitle: false,
                title: Text(
                    AppLocalization.of(context)
                        .translate("icons_app_screen", "title_screen"),
                    style: textStyleCustomBold(Helpers.uiApp(context), 20),
                    textScaler: const TextScaler.linear(1.0)),
              ),
            ),
          ),
        ),
        body: SizedBox.expand(
            child: ListView.builder(
          padding: EdgeInsets.fromLTRB(
              20.0,
              MediaQuery.of(context).padding.top +
                  appBar.preferredSize.height +
                  20.0,
              20.0,
              MediaQuery.of(context).padding.bottom + 20.0),
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            IconsAppModel icon = icons[index];
            return iconItem(icon);
          },
        )));
  }

  Widget iconItem(IconsAppModel icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: ListTile(
        onTap: () {
          setState(() {
            choiceIcon = icon.name;
          });
        },
        contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Image.asset(
            icon.asset,
            height: 65,
            width: 65,
          ),
        ),
        title: Text(
          icon.name,
          style: textStyleCustomMedium(Helpers.uiApp(context), 16),
          textScaler: const TextScaler.linear(1.0),
        ),
        trailing: Radio(
            activeColor: cBlue,
            toggleable: true,
            value: icon.name,
            groupValue: choiceIcon,
            onChanged: (String? value) {
              setState(() {
                choiceIcon = icon.name;
              });
            }),
      ),
    );
  }
}
