import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/auth/chat_details.dart';

class NewConversation extends ConsumerStatefulWidget {
  const NewConversation({Key? key}) : super(key: key);

  @override
  NewConversationState createState() => NewConversationState();
}

class NewConversationState extends ConsumerState<NewConversation>
    with WidgetsBindingObserver {
  List<User> recentSearchesUsers = [];
  List<User> resultsSearch = [];
  bool searching = false;
  String currentSearch = "";
  Timer? _timer;
  String? choice;
  User? choiceUser;

  late ScrollController _scrollController;

  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  bool _isKeyboard = false;

  void _scrollListener() {
    if (_scrollController.offset != 0.0 && _searchFocusNode.hasFocus) {
      Helpers.hideKeyboard(context);
    }
  }

  Future<void> _searchUsers() async {
    setState(() {
      searching = true;
    });

    //à modifier plutôt avec la logique back
    resultsSearch.clear();
    for (var element in potentialsResultsSearchDatasMockes) {
      if (element.pseudo
          .toLowerCase()
          .startsWith(_searchController.text.toLowerCase())) {
        resultsSearch.add(element);
      }
    }

    setState(() {
      searching = false;
    });
  }

  Future _conversationBottomSheet(BuildContext context, User user) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: false,
        builder: (context) {
          return ChatDetails(user: user, openWithModal: true);
        });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboard) {
      setState(() {
        _isKeyboard = newValue;
      });
    }
    super.didChangeMetrics();
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
    WidgetsBinding.instance.removeObserver(this);

    _scrollController.dispose();

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
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _customAppBarNewConv(),
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
            child: _choiceNewConv()),
      ),
    );
  }

  PreferredSizeWidget _customAppBarNewConv() {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width, 60),
      child: ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
                color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.2),
                alignment: Alignment.bottomCenter,
                child: AppBar(
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  backgroundColor: Colors.transparent,
                  title: Text(
                    AppLocalization.of(context).translate(
                        "new_conversation_screen", "new_conversation"),
                    style: textStyleCustomBold(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        20),
                  ),
                  centerTitle: false,
                  actions: [
                    IconButton(
                        onPressed: () => navAuthKey.currentState!.pop(),
                        icon: Icon(
                          Icons.clear,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                        ))
                  ],
                ))),
      ),
    );
  }

  Widget _choiceNewConv() {
    return Stack(
      children: [
        Column(
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
                  const SizedBox(height: 25.0),
                  Container(
                    height: 40.0,
                    alignment: Alignment.center,
                    child: TextField(
                      controller: _searchController,
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
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
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
                                    Helpers.hideKeyboard(context);
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
                          FocusScope.of(context).requestFocus(_searchFocusNode);
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
                            currentSearch = _searchController.text;
                          }
                        });
                      },
                      onEditingComplete: () {
                        Helpers.hideKeyboard(context);
                      },
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  _searchController.text.isNotEmpty
                      ? _searches()
                      : _recentsInteractionsUsers()
                ],
              ),
            ))
          ],
        ),
        choice == null || _isKeyboard
            ? const SizedBox()
            : Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 90,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: SizedBox(
                        height: 50.0,
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _conversationBottomSheet(
                                  navAuthKey.currentContext!, choiceUser!);
                            },
                            child: Text("Démarrer conversation",
                                style: textStyleCustomMedium(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    20),
                                textScaleFactor: 1.0))),
                  ),
                ),
              )
      ],
    );
  }

  Widget _recentsInteractionsUsers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Interactions récentes",
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
                child: Text(
                    "Pas encore d'interactions récentes avec des utilisateurs",
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      leading: user.profilePictureUrl.trim() != ""
                          ? Container(
                              height: 65,
                              width: 65,
                              foregroundDecoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cBlue),
                                  image: DecorationImage(
                                      image:
                                          NetworkImage(user.profilePictureUrl),
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
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            16),
                        textScaleFactor: 1.0,
                      ),
                      trailing: Radio(
                          activeColor: cBlue,
                          toggleable: true,
                          value: user.pseudo,
                          groupValue: choice,
                          onChanged: (String? value) {
                            setState(() {
                              choice = value;
                              choiceUser = user;
                            });
                          }),
                    ),
                  );
                })
      ],
    );
  }

  Widget _searches() {
    return currentSearch != _searchController.text
        ? Container(
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
          )
        : _resultsSearch();
  }

  Widget _resultsSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                child: Text("Pas encore de résultats pour cette recherche",
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
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                      leading: user.profilePictureUrl.trim() != ""
                          ? Container(
                              height: 65,
                              width: 65,
                              foregroundDecoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cBlue),
                                  image: DecorationImage(
                                      image:
                                          NetworkImage(user.profilePictureUrl),
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
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            16),
                        textScaleFactor: 1.0,
                      ),
                      trailing: Radio(
                          activeColor: cBlue,
                          toggleable: true,
                          value: user.pseudo,
                          groupValue: choice,
                          onChanged: (String? value) {
                            setState(() {
                              choice = value;
                              choiceUser = user;
                            });
                          }),
                    ),
                  );
                })
      ],
    );
  }
}
