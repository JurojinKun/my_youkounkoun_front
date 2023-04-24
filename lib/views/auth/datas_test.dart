import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/datas_test_provider.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';

class DatasTest extends ConsumerStatefulWidget {
  final int index;

  const DatasTest({Key? key, required this.index}) : super(key: key);

  @override
  DatasTestState createState() => DatasTestState();
}

class DatasTestState extends ConsumerState<DatasTest>
    with SingleTickerProviderStateMixin {
  AppBar appBar = AppBar();

  late PageController _pageController;
  bool hideAppBar = false;

  late int datasItemsCount;

  late TextEditingController _mentionsController;
  late FocusNode _mentionsFocusNode;
  bool mentionsRecentInteractions = false;
  bool startSearchMention = false;
  List<UserModel> recentSearchesUsers = [];
  List<UserModel> resultsSearch = [];

  Future<void> _scrollPageControllerListener() async {
    if (_pageController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        !hideAppBar) {
      setState(() {
        hideAppBar = true;
      });
    }
    if (_pageController.position.userScrollDirection ==
            ScrollDirection.forward &&
        hideAppBar) {
      setState(() {
        hideAppBar = false;
      });
    }
  }

  //Logic "@" mention user
  Future<void> detectNewMentionUser() async {
    if (_mentionsController.text.endsWith("@")) {
      if (_mentionsController.text.length > 1) {
        final textAfterLastSign = _mentionsController.text
            .substring(_mentionsController.text.length - 2);
        if (RegExp(r'(?<=^|\s)@').firstMatch(textAfterLastSign) != null &&
            !mentionsRecentInteractions) {
          setState(() {
            mentionsRecentInteractions = true;
          });
        }
      } else {
        if (RegExp(r'(?<=^|\s)@').firstMatch(_mentionsController.text) !=
                null &&
            !mentionsRecentInteractions) {
          setState(() {
            mentionsRecentInteractions = true;
          });
        }
      }
    } else {
      if (mentionsRecentInteractions) {
        setState(() {
          mentionsRecentInteractions = false;
        });
      }
      final RegExp exp = RegExp(r'(?<=^|\s)@(\w+)$');
      final RegExpMatch? match = exp.firstMatch(_mentionsController.text);

      if (match != null) {
        if (!startSearchMention) {
          setState(() {
            startSearchMention = true;
          });
        }

        final Iterable<Match> matches =
            exp.allMatches(_mentionsController.text);
        final usernames = matches.map((match) => match.group(1));
        final uniqueUsernames = usernames.toSet().join(',');
        await _searchUsersMention(uniqueUsernames);
      } else if (match == null && startSearchMention) {
        setState(() {
          startSearchMention = false;
        });
      }
    }
  }

  Future<void> _searchUsersMention(String value) async {
    //à modifier plutôt avec la logique back
    resultsSearch.clear();
    for (var element in potentialsResultsSearchDatasMockes) {
      if (element.pseudo.toLowerCase().startsWith(value.toLowerCase())) {
        resultsSearch.add(element);
      }
    }
  }

  Future<void> setNewMention(UserModel user) async {
    final selection = _mentionsController.selection;
    final textBeforeCursor =
        _mentionsController.text.substring(0, selection.start);
    final lastAtSignIndex = textBeforeCursor.lastIndexOf('@');
    final prefix = _mentionsController.text.substring(0, lastAtSignIndex);

    final newText = '$prefix@${user.pseudo} ';

    _mentionsController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }

  _showMentionsUser() {
    double sizeModalMentions = Platform.isIOS
        ? MediaQuery.of(context).size.height / 2 + 20.0
        : MediaQuery.of(context).size.height / 2;

    return showMaterialModalBottomSheet(
        context: context,
        expand: false,
        enableDrag: true,
        elevation: 0,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        backgroundColor: Colors.transparent,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return SafeArea(
              left: false,
              right: false,
              bottom: false,
              top: true,
              child: GestureDetector(
                onTap: () {
                  Helpers.hideKeyboard(context);
                  sizeModalMentions = Platform.isIOS
                      ? MediaQuery.of(context).size.height / 2 + 20.0
                      : MediaQuery.of(context).size.height / 2;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 750),
                  height: sizeModalMentions,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Text("Mention(s) utilisateur(s)",
                                    style: textStyleCustomBold(
                                        Theme.of(context).brightness ==
                                                Brightness.light
                                            ? cBlack
                                            : cWhite,
                                        16),
                                    textAlign: TextAlign.left,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1.0),
                              ),
                            ),
                            Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: Icon(Icons.clear,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? cBlack
                                          : cWhite)),
                            )
                          ],
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: _mentionsController.text.isEmpty ||
                                          (!startSearchMention &&
                                              !mentionsRecentInteractions)
                                      ? Center(
                                          child: Text(
                                            'Mentionne un utilisateur à tout moment en utilisant "@"',
                                            style: textStyleCustomBold(
                                                Helpers.uiApp(context), 14.0),
                                            textAlign: TextAlign.center,
                                            textScaleFactor: 1.0,
                                          ),
                                        )
                                      : mentionsRecentInteractions
                                          ? recentSearchesUsers.isEmpty
                                              ? Center(
                                                  child: Text(
                                                      "Pas de récentes interactions avec des utilisateurs actuellement",
                                                      style:
                                                          textStyleCustomMedium(
                                                              Helpers.uiApp(
                                                                  context),
                                                              14),
                                                      textAlign:
                                                          TextAlign.center,
                                                      textScaleFactor: 1.0))
                                              : ListView.builder(
                                                  padding: EdgeInsets.zero,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: recentSearchesUsers
                                                      .length,
                                                  itemBuilder: (_, index) {
                                                    UserModel user =
                                                        recentSearchesUsers[
                                                            index];

                                                    return Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5.0),
                                                      child: ListTile(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 5.0),
                                                        onTap: () async {
                                                          await setNewMention(
                                                              user);
                                                          setState(() {
                                                            mentionsRecentInteractions =
                                                                false;
                                                            startSearchMention =
                                                                false;
                                                          });
                                                        },
                                                        leading: user
                                                                    .profilePictureUrl
                                                                    .trim() ==
                                                                ""
                                                            ? Container(
                                                                height: 65,
                                                                width: 65,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              cBlue),
                                                                  color: cGrey
                                                                      .withOpacity(
                                                                          0.2),
                                                                ),
                                                                child: const Icon(
                                                                    Icons
                                                                        .person,
                                                                    color:
                                                                        cBlue,
                                                                    size: 30),
                                                              )
                                                            : CachedNetworkImageCustom(
                                                                profilePictureUrl:
                                                                    user
                                                                        .profilePictureUrl,
                                                                heightContainer:
                                                                    65,
                                                                widthContainer:
                                                                    65,
                                                                iconSize: 30),
                                                        title: Text(
                                                          user.pseudo,
                                                          style:
                                                              textStyleCustomMedium(
                                                                  Helpers.uiApp(
                                                                      context),
                                                                  16),
                                                          textScaleFactor: 1.0,
                                                        ),
                                                      ),
                                                    );
                                                  })
                                          : resultsSearch.isEmpty
                                              ? Center(
                                                  child: Text(
                                                    "Pas d'utilisateurs pour cette mention",
                                                    style: textStyleCustomBold(
                                                        Helpers.uiApp(context),
                                                        14.0),
                                                    textAlign: TextAlign.center,
                                                    textScaleFactor: 1.0,
                                                  ),
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(
                                                          parent:
                                                              BouncingScrollPhysics()),
                                                  itemCount:
                                                      resultsSearch.length,
                                                  itemBuilder: (_, index) {
                                                    UserModel user =
                                                        resultsSearch[index];

                                                    return Padding(
                                                      padding: const EdgeInsets
                                                              .symmetric(
                                                          vertical: 5.0),
                                                      child: ListTile(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 5.0),
                                                        onTap: () async {
                                                          await setNewMention(
                                                              user);
                                                          setState(() {
                                                            startSearchMention =
                                                                false;
                                                            mentionsRecentInteractions =
                                                                false;
                                                          });
                                                        },
                                                        leading: user
                                                                    .profilePictureUrl
                                                                    .trim() ==
                                                                ""
                                                            ? Container(
                                                                height: 65,
                                                                width: 65,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  shape: BoxShape
                                                                      .circle,
                                                                  border: Border
                                                                      .all(
                                                                          color:
                                                                              cBlue),
                                                                  color: cGrey
                                                                      .withOpacity(
                                                                          0.2),
                                                                ),
                                                                child: const Icon(
                                                                    Icons
                                                                        .person,
                                                                    color:
                                                                        cBlue,
                                                                    size: 30),
                                                              )
                                                            : CachedNetworkImageCustom(
                                                                profilePictureUrl:
                                                                    user
                                                                        .profilePictureUrl,
                                                                heightContainer:
                                                                    65,
                                                                widthContainer:
                                                                    65,
                                                                iconSize: 30),
                                                        title: Text(
                                                          user.pseudo,
                                                          style:
                                                              textStyleCustomMedium(
                                                                  Helpers.uiApp(
                                                                      context),
                                                                  16),
                                                          textScaleFactor: 1.0,
                                                        ),
                                                      ),
                                                    );
                                                    ;
                                                  }),
                                ),
                                Container(
                                  height: 60.0,
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 5.0, horizontal: 5.0),
                                  child: TextField(
                                    scrollPhysics:
                                        const BouncingScrollPhysics(),
                                    controller: _mentionsController,
                                    focusNode: _mentionsFocusNode,
                                    maxLines: 1,
                                    textInputAction: TextInputAction.done,
                                    keyboardType: TextInputType.text,
                                    onTap: () async {
                                      if (Platform.isIOS) {
                                        sizeModalMentions = sizeModalMentions ==
                                                MediaQuery.of(context)
                                                            .size
                                                            .height /
                                                        2 +
                                                    20.0
                                            ? MediaQuery.of(context).size.height
                                            : MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2 +
                                                20.0;
                                      } else {
                                        sizeModalMentions = sizeModalMentions ==
                                                MediaQuery.of(context)
                                                        .size
                                                        .height /
                                                    2
                                            ? MediaQuery.of(context).size.height
                                            : MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                2;
                                      }
                                    },
                                    onChanged: (val) async {
                                      setState(() {
                                        val = _mentionsController.text;
                                      });

                                      await detectNewMentionUser();
                                    },
                                    onSubmitted: (val) {
                                      Helpers.hideKeyboard(context);
                                      sizeModalMentions = Platform.isIOS
                                          ? MediaQuery.of(context).size.height /
                                                  2 +
                                              20.0
                                          : MediaQuery.of(context).size.height /
                                              2;
                                    },
                                    style: textStyleCustomRegular(
                                        _mentionsFocusNode.hasFocus
                                            ? cBlue
                                            : cGrey,
                                        14 /
                                            MediaQuery.of(context)
                                                .textScaleFactor),
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          12, 12, 12, 12),
                                      hintText: "@mentionner un utilisateur",
                                      hintStyle: textStyleCustomRegular(
                                          cGrey,
                                          14 /
                                              MediaQuery.of(context)
                                                  .textScaleFactor),
                                      labelStyle: textStyleCustomRegular(
                                          cBlue,
                                          14 /
                                              MediaQuery.of(context)
                                                  .textScaleFactor),
                                      suffixIcon: _mentionsController
                                              .text.isEmpty
                                          ? const SizedBox()
                                          : Material(
                                              color: Colors.transparent,
                                              shape: const CircleBorder(),
                                              clipBehavior: Clip.hardEdge,
                                              child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      _mentionsController
                                                          .clear();
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.clear,
                                                    color: _mentionsFocusNode
                                                            .hasFocus
                                                        ? cBlue
                                                        : cGrey,
                                                  )),
                                            ),
                                      enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 2.0,
                                            color: _mentionsFocusNode.hasFocus
                                                ? cBlue
                                                : cGrey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 2.0,
                                            color: _mentionsFocusNode.hasFocus
                                                ? cBlue
                                                : cGrey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      errorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 2.0,
                                            color: _mentionsFocusNode.hasFocus
                                                ? cBlue
                                                : cGrey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                      focusedErrorBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            width: 2.0,
                                            color: _mentionsFocusNode.hasFocus
                                                ? cBlue
                                                : cGrey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10.0)),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: widget.index);
    _pageController.addListener(_scrollPageControllerListener);

    _mentionsController = TextEditingController();
    _mentionsFocusNode = FocusNode();
  }

  @override
  void deactivate() {
    _pageController.removeListener(_scrollPageControllerListener);
    super.deactivate();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mentionsController.dispose();
    _mentionsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    datasItemsCount = ref.watch(datasTestNotifierProvider);
    recentSearchesUsers = ref.watch(recentSearchesNotifierProvider);

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(appBar.preferredSize.height),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: Helpers.uiOverlayApp(context),
            title: AnimatedOpacity(
              opacity: hideAppBar ? 0 : 1,
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              child: Text("Datas test",
                  style: textStyleCustomBold(Helpers.uiApp(context), 20.0),
                  textScaleFactor: 1.0),
            ),
            centerTitle: true,
            actions: [
              AnimatedOpacity(
                  opacity: hideAppBar ? 0 : 1,
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                        onPressed: () => navAuthKey.currentState!.pop(),
                        icon: Icon(Icons.clear,
                            size: 30, color: Helpers.uiApp(context))),
                  )),
            ],
          ),
        ),
        body: Stack(
          children: [
            PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                itemCount: datasItemsCount,
                itemBuilder: (context, index) {
                  String dataTest = "Data test $index";

                  return Builder(builder: (_) {
                    return Hero(
                      tag: "data test ${widget.index}",
                      transitionOnUserGestures: true,
                      flightShuttleBuilder: (flightContext, animation,
                          flightDirection, fromHeroContext, toHeroContext) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                              border: Border.all(color: cBlue),
                              color: cBlue.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10.0)),
                          alignment: Alignment.center,
                          child: Material(
                            type: MaterialType.transparency,
                            child: Text(dataTest,
                                style: textStyleCustomBold(
                                    Helpers.uiApp(context), 18),
                                textAlign: TextAlign.center,
                                textScaleFactor: 1.0),
                          ),
                        );
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.all(2.5),
                        decoration: BoxDecoration(
                            border: Border.all(color: cBlue),
                            color: cBlue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10.0)),
                        alignment: Alignment.center,
                        child: Material(
                          type: MaterialType.transparency,
                          child: Text(dataTest,
                              style: textStyleCustomBold(
                                  Helpers.uiApp(context), 18),
                              textAlign: TextAlign.center,
                              textScaleFactor: 1.0),
                        ),
                      ),
                    );
                  });
                }),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  height: 70.0 + MediaQuery.of(context).padding.bottom,
                  alignment: Alignment.center,
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.8),
                  child: Container(
                    height: 45.0,
                    width: MediaQuery.of(context).size.width,
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: Theme.of(context).canvasColor,
                              foregroundColor: cBlue,
                              shadowColor: Colors.transparent,
                              side: const BorderSide(width: 1.0, color: cGrey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              )),
                          onPressed: () async {
                            await _showMentionsUser();
                            _mentionsController.clear();
                          },
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text("@mentionner un utilisateur",
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    14),
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: 1.0),
                          )),
                    ),
                  )),
            )
          ],
        ));
  }
}
