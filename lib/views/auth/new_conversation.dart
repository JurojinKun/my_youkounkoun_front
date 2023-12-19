import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/chat_provider.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/route_observer.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/auth/chat_details.dart';

class NewConversation extends ConsumerStatefulWidget {
  const NewConversation({super.key});

  @override
  NewConversationState createState() => NewConversationState();
}

class NewConversationState extends ConsumerState<NewConversation> {
  List<UserModel> recentSearchesUsers = [];
  List<UserModel> resultsSearch = [];
  bool searching = false;
  String currentSearch = "";
  Timer? _timer;
  String? choice;
  UserModel? choiceUser;

  late ScrollController _scrollController;

  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  bool _isKeyboard = false;

  AppBar appBar = AppBar();

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

  Future _conversationBottomSheet(
      BuildContext context, UserModel otherUser) async {
    //TODO replace this logic with logic firebase
    ConversationModel? currentConversation;
    bool convWithCurrentUser = false;
    bool convWithOtherUser = false;

    for (ConversationModel conversation
        in ref.read(conversationsNotifierProvider)!) {
      for (var user in conversation.users) {
        if (user["id"] == ref.read(userNotifierProvider).id) {
          convWithCurrentUser = true;
        }
        if (user["id"] == otherUser.id) {
          convWithOtherUser = true;
        }
      }

      if (convWithCurrentUser &&
          convWithOtherUser &&
          (conversation.lastMessageUserId ==
                  ref.read(userNotifierProvider).id ||
              conversation.lastMessageUserId == otherUser.id)) {
        currentConversation = conversation;
      }
    }

    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: false,
        builder: (context) {
          return RouteObserverWidget(
              name: chatDetails,
              child: ChatDetails(
                  user: otherUser,
                  openWithModal: true,
                  conversation: currentConversation ??
                      ConversationModel(
                          id: "temporary",
                          users: [],
                          lastMessageUserId: 0,
                          lastMessage: "",
                          isLastMessageRead: false,
                          timestampLastMessage: "",
                          typeLastMessage: "",
                          themeConv: [])));
        });
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
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
    _scrollController.dispose();

    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    recentSearchesUsers = ref.watch(recentSearchesNotifierProvider);
    _isKeyboard = ref.watch(visibleKeyboardAppNotifierProvider);

    return GestureDetector(
      onTap: () => Helpers.hideKeyboard(context),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _customAppBarNewConv(),
        body: _choiceNewConv(),
      ),
    );
  }

  PreferredSizeWidget _customAppBarNewConv() {
    return PreferredSize(
      preferredSize: Size(MediaQuery.of(context).size.width,
          appBar.preferredSize.height + 60.0),
      child: ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              systemOverlayStyle: Helpers.uiOverlayApp(context),
              title: Text(
                AppLocalization.of(context)
                    .translate("new_conversation_screen", "new_conversation"),
                style: textStyleCustomBold(Helpers.uiApp(context), 20),
              ),
              centerTitle: false,
              actions: [
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  clipBehavior: Clip.hardEdge,
                  child: IconButton(
                      onPressed: () => navAuthKey.currentState!.pop(),
                      icon: Icon(
                        Icons.clear,
                        color: Helpers.uiApp(context),
                        size: 30,
                      )),
                )
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                  child: Container(
                    height: 45.0,
                    alignment: Alignment.center,
                    child: TextField(
                      scrollPhysics: const BouncingScrollPhysics(),
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      cursorColor: Theme.of(context).colorScheme.primary,
                      textInputAction: TextInputAction.search,
                      maxLines: 1,
                      style: textStyleCustomMedium(
                          _searchFocusNode.hasFocus
                              ? Theme.of(context).colorScheme.primary
                              : cGrey,
                          MediaQuery.of(context).textScaler.scale(16)),
                      decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.only(top: 15.0, left: 15.0),
                          filled: true,
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
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
                            size: 23,
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
                                        Helpers.hideKeyboard(context);
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
                ),
              ),
            )),
      ),
    );
  }

  Widget _choiceNewConv() {
    return Stack(
      children: [
        SizedBox.expand(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.fromLTRB(
                10.0,
                MediaQuery.of(context).padding.top +
                    appBar.preferredSize.height +
                    80.0,
                10.0,
                choice != null
                    ? MediaQuery.of(context).padding.bottom + 120.0
                    : MediaQuery.of(context).padding.bottom + 20.0),
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: _searchController.text.isNotEmpty
                ? _searches()
                : _recentsInteractionsUsers(),
          ),
        ),
        choice == null || _isKeyboard
            ? const SizedBox()
            : Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 100 + MediaQuery.of(context).padding.bottom,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  alignment: Alignment.center,
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
                            child: Text(
                                AppLocalization.of(context).translate(
                                    "new_conversation_screen",
                                    "start_conversation"),
                                style: textStyleCustomMedium(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    20),
                                textScaler: const TextScaler.linear(1.0)))),
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
        Row(
          children: [
            Icon(Icons.history, color: Helpers.uiApp(context)),
            const SizedBox(width: 5.0),
            Text(
              AppLocalization.of(context)
                  .translate("new_conversation_screen", "recent_interactions"),
              style: textStyleCustomBold(Helpers.uiApp(context), 16),
              textScaler: const TextScaler.linear(1.0),
            ),
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
                    Icon(Icons.search, color: Helpers.uiApp(context), size: 40),
                    const SizedBox(height: 10.0),
                    Text(
                        AppLocalization.of(context).translate(
                            "new_conversation_screen",
                            "no_recent_interactions"),
                        style:
                            textStyleCustomMedium(Helpers.uiApp(context), 14),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1.0))
                  ],
                ))
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: recentSearchesUsers.length,
                itemBuilder: (_, index) {
                  UserModel user = recentSearchesUsers[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      onTap: () {
                        if (choice == null || choice != user.pseudo) {
                          setState(() {
                            choice = user.pseudo;
                            choiceUser = user;
                          });
                        } else if (choice != null && choice == user.pseudo) {
                          setState(() {
                            choice = null;
                            choiceUser = null;
                          });
                        }
                      },
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
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
                        style:
                            textStyleCustomMedium(Helpers.uiApp(context), 16),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      trailing: user.id == ref.read(userNotifierProvider).id
                          ? const SizedBox()
                          : Radio(
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
                      ? '${AppLocalization.of(context).translate("general", "search_of")}"${_searchController.text}.."'
                      : '${AppLocalization.of(context).translate("general", "search_of")}"${_searchController.text.substring(0, 10)}.."',
                  style: textStyleCustomMedium(Helpers.uiApp(context), 14),
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1.0),
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
        Row(
          children: [
            Icon(Icons.search, color: Helpers.uiApp(context)),
            const SizedBox(width: 5.0),
            Text(
              AppLocalization.of(context)
                  .translate("new_conversation_screen", "results"),
              style: textStyleCustomBold(Helpers.uiApp(context), 16),
              textScaler: const TextScaler.linear(1.0),
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
                    Icon(Icons.search, color: Helpers.uiApp(context), size: 40),
                    const SizedBox(height: 10.0),
                    Text(
                        AppLocalization.of(context)
                            .translate("new_conversation_screen", "no_results"),
                        style:
                            textStyleCustomMedium(Helpers.uiApp(context), 14),
                        textAlign: TextAlign.center,
                        textScaler: const TextScaler.linear(1.0))
                  ],
                ))
            : ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: resultsSearch.length,
                itemBuilder: (_, index) {
                  UserModel user = resultsSearch[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
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
                        style:
                            textStyleCustomMedium(Helpers.uiApp(context), 16),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                      trailing: user.id == ref.read(userNotifierProvider).id
                          ? const SizedBox()
                          : Radio(
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
