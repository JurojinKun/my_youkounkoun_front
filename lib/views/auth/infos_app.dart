import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/providers/version_app_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class InfosApp extends ConsumerStatefulWidget {
  const InfosApp({super.key});

  @override
  InfosAppState createState() => InfosAppState();
}

class InfosAppState extends ConsumerState<InfosApp> {
  AppBar appBar = AppBar();

  String versionApp = "";

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
    versionApp = ref.watch(versionAppNotifierProvider);

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
                  title: Text(
                      AppLocalization.of(context)
                          .translate("infos_app_screen", "title"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 20),
                      textScaler: const TextScaler.linear(1.0)),
                  centerTitle: false,
                )),
          )),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20.0,
              MediaQuery.of(context).padding.top +
                  appBar.preferredSize.height +
                  20.0,
              20.0,
              MediaQuery.of(context).padding.bottom + 20.0),
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              cguApp(),
              const Divider(thickness: 0.5, color: cGrey),
              policyPrivacyApp(),
              const Divider(thickness: 0.5, color: cGrey),
              versionAppWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget cguApp() {
    return InkWell(
      onTap: () {
        //change url google to url cgu
        Helpers.launchMyUrl("https://www.google.fr/");
      },
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.description,
                    color: Helpers.uiApp(context),
                    size: 20,
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Text(
                        AppLocalization.of(context)
                            .translate("infos_app_screen", "cgu"),
                        style: textStyleCustomBold(Helpers.uiApp(context), 16),
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1.0)),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.5),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Helpers.uiApp(context),
                size: 18,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget policyPrivacyApp() {
    return InkWell(
      onTap: () {
        //change url google to url cgu
        Helpers.launchMyUrl("https://www.google.fr/");
      },
      child: SizedBox(
        height: 60.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.gavel,
                    color: Helpers.uiApp(context),
                    size: 20,
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Text(
                        AppLocalization.of(context)
                            .translate("infos_app_screen", "policy_privacy"),
                        style: textStyleCustomBold(Helpers.uiApp(context), 16),
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1.0)),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7.5),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Helpers.uiApp(context),
                size: 18,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget versionAppWidget() {
    return SizedBox(
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.smartphone,
                  color: Helpers.uiApp(context),
                  size: 20,
                ),
                const SizedBox(width: 15.0),
                Expanded(
                  child: Text(
                      AppLocalization.of(context)
                          .translate("infos_app_screen", "version"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 16),
                      overflow: TextOverflow.ellipsis,
                      textScaler: const TextScaler.linear(1.0)),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7.5),
            child: Text(versionApp,
                style: textStyleCustomBold(Helpers.uiApp(context), 16),
                textScaler: const TextScaler.linear(1.0)),
          )
        ],
      ),
    );
  }
}
