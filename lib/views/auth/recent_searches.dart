import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/helpers/helpers.dart';
import 'package:my_boilerplate/models/user_model.dart';
import 'package:my_boilerplate/providers/recent_searches_provider.dart';

class RecentSearches extends ConsumerStatefulWidget {
  const RecentSearches({Key? key}) : super(key: key);

  @override
  RecentSearchesState createState() => RecentSearchesState();
}

class RecentSearchesState extends ConsumerState<RecentSearches> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;
  late ScrollController _scrollController;

  List<User> recentSearchesUsers = [];
  List<User> resultsSearch = [];
  bool searching = false;
  Timer? _timer;
  String currentSearch = "";

  void _scrollListener() {
    if (_scrollController.offset != 0.0 && _searchFocusNode.hasFocus) {
      Helpers.hideKeyboard(context);
    }
  }

  void _searchListener() {
    if (!searching) {
      if (_timer != null && _timer!.isActive) _timer!.cancel();
      _timer = Timer(const Duration(seconds: 1), () async {
        if (_searchController.text.isNotEmpty &&
            currentSearch != _searchController.text) {
          await _searchUsers();
          currentSearch = _searchController.text;
        }
      });
    }

    if (_searchController.text.isEmpty) {
      resultsSearch.clear();
    }
  }

  Future<void> _searchUsers() async {
    setState(() {
      searching = true;
    });
    //à modifier plutôt avec la logique back
    for (var element in potentialsResultsSearchDatasMockes) {
      if (element.pseudo.toLowerCase().startsWith(_searchController.text.toLowerCase()) && !resultsSearch.contains(element)) {
        resultsSearch.add(element);
      }
    }
    setState(() {
      searching = false;
    });
  }

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _searchController.addListener(_searchListener);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void deactivate() {
    _searchController.removeListener(_searchListener);
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
                          if (_timer != null && _timer!.isActive) {
                            _timer?.cancel();
                          }
                          Helpers.hideKeyboard(context);
                          if (_searchController.text.isNotEmpty &&
                              !searching &&
                              currentSearch != _searchController.text) {
                            await _searchUsers();
                            currentSearch = _searchController.text;
                          }
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
    return Column(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ListView(
            controller: _scrollController,
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
              recentSearchesUsers.isEmpty
                  ? Container(
                      height: 150.0,
                      alignment: Alignment.center,
                      child: Text("Pas encore de recherches récentes",
                          style: textStyleCustomMedium(
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                              14),
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0))
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: recentSearchesUsers.length,
                      itemBuilder: (_, index) {
                        User user = recentSearchesUsers[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 5.0),
                            onTap: () => navSearchKey!.currentState!
                                .pushNamed(userProfile, arguments: [user]),
                            leading: user.profilePictureUrl.trim() != ""
                                ? Container(
                                    height: 65,
                                    width: 65,
                                    foregroundDecoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: cBlue),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                user.profilePictureUrl),
                                            fit: BoxFit.cover)),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue),
                                      color: cGrey.withOpacity(0.2),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: cBlue, size: 30),
                                  )
                                : Container(
                                    height: 65,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue),
                                      color: cGrey.withOpacity(0.2),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: cBlue, size: 30),
                                  ),
                            title: Text(
                              user.pseudo,
                              style: textStyleCustomMedium(
                                  Theme.of(context).brightness ==
                                          Brightness.light
                                      ? cBlack
                                      : cWhite,
                                  16),
                              textScaleFactor: 1.0,
                            ),
                            trailing: IconButton(
                                onPressed: () {
                                  //add logic back
                                  ref.read(recentSearchesNotifierProvider.notifier).deleteRecentSearches(user);
                                },
                                icon: Icon(Icons.clear,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite)),
                          ),
                        );
                      })
            ],
          ),
        ))
      ],
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
                            ? 'Recherche de "${_searchController.text}.."'
                            : 'Recherche de "${_searchController.text.substring(0, 10)}.."',
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
    return Column(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: ListView(
            controller: _scrollController,
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            children: [
              const SizedBox(height: 15.0),
              Text(
                "Résultats",
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    16),
                textScaleFactor: 1.0,
              ),
              resultsSearch.isEmpty
                  ? Container(
                      height: 150.0,
                      alignment: Alignment.center,
                      child: Text("Pas de résultats pour cette recherche",
                          style: textStyleCustomMedium(
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                              14),
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0))
                  : ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: resultsSearch.length,
                      itemBuilder: (_, index) {
                        User user = resultsSearch[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 5.0),
                            onTap: () {
                              ref.read(recentSearchesNotifierProvider.notifier).addRecentSearches(user);
                              navSearchKey!.currentState!
                                .pushNamed(userProfile, arguments: [user]);
                            },
                            leading: user.profilePictureUrl.trim() != ""
                                ? Container(
                                    height: 65,
                                    width: 65,
                                    foregroundDecoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: cBlue),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                user.profilePictureUrl),
                                            fit: BoxFit.cover)),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue),
                                      color: cGrey.withOpacity(0.2),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: cBlue, size: 30),
                                  )
                                : Container(
                                    height: 65,
                                    width: 65,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue),
                                      color: cGrey.withOpacity(0.2),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: cBlue, size: 30),
                                  ),
                            title: Text(
                              user.pseudo,
                              style: textStyleCustomMedium(
                                  Theme.of(context).brightness ==
                                          Brightness.light
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
        ))
      ],
    );
  }
}
