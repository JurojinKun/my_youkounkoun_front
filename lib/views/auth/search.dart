import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';

class Search extends ConsumerStatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  SearchState createState() => SearchState();
}

class SearchState extends ConsumerState<Search>
    with AutomaticKeepAliveClientMixin {
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

    return Scaffold(
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
            AppLocalization.of(context).translate("search_screen", "search"),
            style: textStyleCustomBold(
                Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite,
                20),
            textScaleFactor: 1.0),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(65.0),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              height: 65.0,
              alignment: Alignment.center,
              child: Padding(padding: const EdgeInsets.all(10.0), child: SizedBox(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 6,
                          backgroundColor: Theme.of(context).canvasColor,
                          foregroundColor: cBlue,
                          shadowColor: Colors.transparent,
                          side: BorderSide(color: Theme.of(context).brightness == Brightness.light ? cBlack : cWhite),
                          shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ) 
                        ),
                        onPressed: () => navSearchKey!.currentState!.pushNamed(recentSearches),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Theme.of(context).brightness == Brightness.light ? cBlack : cWhite),
                            const SizedBox(width: 15.0),
                            Expanded(child: Text(
                            "Recherche un utilisateur",
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                16),
                            textScaleFactor: 1.0))
                          ],
                        )))),
            )),
      ),
      body: SizedBox.expand(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: Column(
            children: [
              const SizedBox(height: 50.0),
              Text(
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
            ],
          )
        ),
      ),
    );
  }
}
