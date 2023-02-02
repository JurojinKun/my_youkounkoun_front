import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class RecentSearches extends ConsumerStatefulWidget {
  const RecentSearches({Key? key}) : super(key: key);

  @override
  RecentSearchesState createState() => RecentSearchesState();
}

class RecentSearchesState extends ConsumerState<RecentSearches> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late ScrollController _scrollController;

  List<UserModel> recentSearchesUsers = [];
  List<UserModel> resultsSearch = [];
  String currentSearch = "";
  Timer? _timer;

  AppBar appBar = AppBar();

  void _scrollListener() {
    if (_scrollController.offset != 0.0 && _searchFocusNode.hasFocus) {
      Helpers.hideKeyboard(context);
    }
  }

  Future<void> _searchUsers() async {
    //à modifier plutôt avec la logique back
    resultsSearch.clear();
    for (var element in potentialsResultsSearchDatasMockes) {
      if (element.pseudo
          .toLowerCase()
          .startsWith(_searchController.text.toLowerCase())) {
        resultsSearch.add(element);
      }
    }
  }

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void deactivate() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    _scrollController.removeListener(_scrollListener);
    super.deactivate();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    recentSearchesUsers = ref.watch(recentSearchesNotifierProvider);

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
            child: _searchController.text.isNotEmpty
                ? _searches()
                : _recentSearches()),
      ),
    );
  }

  PreferredSizeWidget _customAppBarSearch() {
    return PreferredSize(
      preferredSize:
          Size(MediaQuery.of(context).size.width, appBar.preferredSize.height),
      child: ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
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
                        scrollPhysics: const BouncingScrollPhysics(),
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
                            14 / MediaQuery.of(context).textScaleFactor),
                        decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(top: 15.0, left: 15.0),
                            filled: true,
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintText: AppLocalization.of(context)
                                .translate("general", "search_user"),
                            hintStyle: textStyleCustomMedium(
                                _searchFocusNode.hasFocus ? cBlue : cGrey, 14),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: cGrey),
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
                                ? Material(
                                    color: Colors.transparent,
                                    shape: const CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    child: IconButton(
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
                                        )),
                                  )
                                : const SizedBox()),
                        onTap: () {
                          setState(() {
                            FocusScope.of(context)
                                .requestFocus(_searchFocusNode);
                          });
                        },
                        onChanged: (value) async {
                          setState(() {
                            value = _searchController.text;
                          });

                          if (_timer != null && _timer!.isActive) {
                            _timer!.cancel();
                          }
                          _timer = Timer(const Duration(seconds: 1), () async {
                            if (_searchController.text.isNotEmpty &&
                                currentSearch != _searchController.text) {
                              await _searchUsers();
                              setState(() {
                                currentSearch = _searchController.text;
                              });
                            }
                          });
                        },
                        onEditingComplete: () {
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
                        AppLocalization.of(context)
                            .translate("general", "btn_cancel"),
                        style: textStyleCustomMedium(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            14),
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
    return SizedBox.expand(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            10.0,
            MediaQuery.of(context).padding.top +
                appBar.preferredSize.height +
                20.0,
            10.0,
            MediaQuery.of(context).padding.bottom + 90.0),
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history,
                    color: Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite),
                const SizedBox(width: 5.0),
                Text(
                  AppLocalization.of(context)
                      .translate("recent_searches_screen", "recent_searches"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      16),
                  textScaleFactor: 1.0,
                )
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            recentSearchesUsers.isEmpty
                ? Container(
                    height: 150.0,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                            size: 40),
                        const SizedBox(height: 10.0),
                        Text(
                            AppLocalization.of(context).translate(
                                "recent_searches_screen", "no_recent_searches"),
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                14),
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.0)
                      ],
                    ))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: recentSearchesUsers.length,
                    itemBuilder: (_, index) {
                      UserModel user = recentSearchesUsers[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5.0),
                          onTap: () {
                            ref
                                .read(recentSearchesNotifierProvider.notifier)
                                .updateRecentSearches(user);
                            navSearchKey!.currentState!.pushNamed(userProfile,
                                arguments: [user, true]);
                          },
                          leading: user.profilePictureUrl.trim() == ""
                              ? Container(
                                  height: 65,
                                  width: 65,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cBlue),
                                    color: cGrey.withOpacity(0.2),
                                  ),
                                  child: const Icon(Icons.person,
                                      color: cBlue, size: 30),
                                )
                              : CachedNetworkImageCustom(
                                  profilePictureUrl: user.profilePictureUrl,
                                  heightContainer: 65,
                                  widthContainer: 65,
                                  iconSize: 30),
                          title: Text(
                            user.pseudo,
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                16),
                            textScaleFactor: 1.0,
                          ),
                          trailing: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            clipBehavior: Clip.hardEdge,
                            child: IconButton(
                                onPressed: () {
                                  //add logic back
                                  ref
                                      .read(recentSearchesNotifierProvider
                                          .notifier)
                                      .deleteRecentSearches(user);
                                },
                                icon: Icon(Icons.clear,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite)),
                          ),
                        ),
                      );
                    })
          ],
        ),
      ),
    );
  }

  Widget _searches() {
    return currentSearch != _searchController.text
        ? Column(
            children: [
              Expanded(
                child: Container(
                  height: 150,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 15.0,
                        width: 15.0,
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                          strokeWidth: 1.0,
                        ),
                      ),
                      const SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        _searchController.text.length < 10
                            ? '${AppLocalization.of(context).translate("general", "search_of")}"${_searchController.text}.."'
                            : '${AppLocalization.of(context).translate("general", "search_of")}"${_searchController.text.substring(0, 10)}.."',
                        style: textStyleCustomMedium(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            14),
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.0,
                      )
                    ],
                  ),
                ),
              ),
            ],
          )
        : _resultsSearch();
  }

  Widget _resultsSearch() {
    return SizedBox.expand(
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(
            10.0,
            MediaQuery.of(context).padding.top +
                appBar.preferredSize.height +
                20.0,
            10.0,
            MediaQuery.of(context).padding.bottom + 90.0),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search,
                    color: Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite),
                const SizedBox(width: 5.0),
                Text(
                  AppLocalization.of(context)
                      .translate("recent_searches_screen", "results"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      16),
                  textScaleFactor: 1.0,
                ),
              ],
            ),
            const SizedBox(
              height: 10.0,
            ),
            resultsSearch.isEmpty
                ? Container(
                    height: 150.0,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search,
                            color:
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                            size: 40),
                        const SizedBox(height: 10.0),
                        Text(
                            AppLocalization.of(context).translate(
                                "recent_searches_screen", "no_results"),
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                14),
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.0)
                      ],
                    ))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: resultsSearch.length,
                    itemBuilder: (_, index) {
                      UserModel user = resultsSearch[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5.0),
                        child: ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 5.0),
                          onTap: () {
                            if (!resultsSearch
                                .any((element) => element.id == user.id)) {
                              ref
                                  .read(recentSearchesNotifierProvider.notifier)
                                  .addRecentSearches(user);
                            } else {
                              ref
                                  .read(recentSearchesNotifierProvider.notifier)
                                  .updateRecentSearches(user);
                            }
                            navSearchKey!.currentState!.pushNamed(userProfile,
                                arguments: [user, true]);
                          },
                          leading: user.profilePictureUrl.trim() == ""
                              ? Container(
                                  height: 65,
                                  width: 65,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: cBlue),
                                    color: cGrey.withOpacity(0.2),
                                  ),
                                  child: const Icon(Icons.person,
                                      color: cBlue, size: 30),
                                )
                              : CachedNetworkImageCustom(
                                  profilePictureUrl: user.profilePictureUrl,
                                  heightContainer: 65,
                                  widthContainer: 65,
                                  iconSize: 30),
                          title: Text(
                            user.pseudo,
                            style: textStyleCustomMedium(
                                Theme.of(context).brightness == Brightness.light
                                    ? cBlack
                                    : cWhite,
                                16),
                            textScaleFactor: 1.0,
                          ),
                        ),
                      );
                    })
          ],
        ),
      ),
    );
  }
}
