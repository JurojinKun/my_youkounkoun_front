import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/helpers/helpers.dart';

class RecentSearches extends ConsumerStatefulWidget {
  const RecentSearches({Key? key}) : super(key: key);

  @override
  RecentSearchesState createState() => RecentSearchesState();
}

class RecentSearchesState extends ConsumerState<RecentSearches> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Helpers.hideKeyboard(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: _customAppBarSearch(),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
            value: Theme.of(context).brightness == Brightness.light
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
            child: _recentSearches()),
      ),
    );
  }

  PreferredSizeWidget _customAppBarSearch() {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 60),
      child: ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Theme.of(context).canvasColor.withOpacity(0.2),
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Expanded(
                      child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Container(
                      height: 40.0,
                      alignment: Alignment.center,
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        focusNode: _searchFocusNode,
                        cursorColor: Theme.of(context).colorScheme.primary,
                        textInputAction: TextInputAction.search,
                        maxLines: 1,
                        style: textStyleCustomMedium(
                            _searchFocusNode.hasFocus
                                ? Theme.of(context).colorScheme.primary
                                : cGrey,
                            14),
                        decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(top: 15.0, left: 15.0),
                            filled: true,
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintText: 'Rechercher un utilisateur',
                            hintStyle: textStyleCustomMedium(
                                _searchFocusNode.hasFocus
                                    ? cBlue
                                    : cGrey,
                                14),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    const BorderSide(color: cGrey),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: cBlue,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            prefixIcon: const Icon(
                              Icons.search_sharp,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _searchController.clear();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.clear,
                                      size: 20,
                                      color: _searchFocusNode.hasFocus
                                          ? cBlue
                                          : cGrey,
                                    ))
                                : const SizedBox()),
                        onTap: () {
                          setState(() {
                            FocusScope.of(context)
                                .requestFocus(_searchFocusNode);
                          });
                        },
                        onChanged: (value) {
                          setState(() {
                            value = _searchController.text;
                          });
                        },
                        onEditingComplete: () async {
                          Helpers.hideKeyboard(context);
                        },
                      ),
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: TextButton(
                      onPressed: () => navSearchKey!.currentState!.pop(),
                      child: Text(
                        "Annuler",
                        style: textStyleCustomMedium(Theme.of(context).brightness == Brightness.light ? cBlack : cWhite, 14),
                        textScaleFactor: 1.0,
                      ),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }

  Widget _recentSearches() {
    return Column(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            children: [
              const SizedBox(height: 15.0),
              Text(
                "Recherches récentes",
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    16),
                textScaleFactor: 1.0,
              ),
              SizedBox(
                height: 150.0,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search,
                      color: Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      size: 33,
                    ),
                    const SizedBox(
                      height: 5.0,
                    ),
                    Text("Work in progress",
                        style: textStyleCustomMedium(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            14),
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.0)
                  ],
                ),
              )
            ],
          ),
        ))
      ],
    );
  }
}
