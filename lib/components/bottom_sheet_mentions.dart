import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/components/mention_text.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/comment_model.dart';
import 'package:myyoukounkoun/models/mention_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/recent_searches_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class BottomSheetMentions extends ConsumerStatefulWidget {
  const BottomSheetMentions({Key? key}) : super(key: key);

  @override
  BottomSheetMentionsState createState() => BottomSheetMentionsState();
}

class BottomSheetMentionsState extends ConsumerState<BottomSheetMentions> {
  bool isKeyboard = false;

  late TextEditingController _mentionsController;
  late FocusNode _mentionsFocusNode;
  bool mentionsRecentInteractions = false;
  bool startSearchMention = false;
  List<UserModel> recentSearchesUsers = [];
  List<UserModel> resultsSearch = [];
  List<MentionModel> mentions = [];
  String encryptionKey = "ENCRYPTUSERDATAS";
  List<CommentModel> mentionComments = [];

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

    final mentionAlreadyHere =
        mentions.where((element) => element.pseudo == user.pseudo);
    if (mentionAlreadyHere.isEmpty) {
      String encryptedUserDatas = await encryptUserData(user, encryptionKey);
      Map<String, dynamic> mapMention = {
        "pseudo": user.pseudo,
        "encryptedUserDatas": encryptedUserDatas
      };
      mentions.add(MentionModel.fromJSON(mapMention));
    }
  }

  Future<String> encryptUserData(UserModel user, String keyString) async {
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    final userDataString = jsonEncode(user.toJson());
    final encryptedUserData = encrypter.encrypt(userDataString, iv: iv);

    return encryptedUserData.base64;
  }

  Future<void> sendMentionText() async {
    String textSend = _mentionsController.text;
    RegExp pattern = RegExp(r'(?:(?<=\s)|^)@(\S+)');
    Iterable<RegExpMatch> matches = pattern.allMatches(textSend);

    for (final match in matches) {
      if (match.group(0) != null) {
        String pseudo = match.group(0)!.substring(1);
        MentionModel userMention = mentions.firstWhere(
            (element) => element.pseudo == pseudo,
            orElse: () => MentionModel(pseudo: "", encryptedUserDatas: ""));
        if (userMention.pseudo.trim() != "") {
          String encryptedUserDatas = userMention.encryptedUserDatas;
          String textReplace =
              textSend.replaceFirst(pseudo, encryptedUserDatas);
          textSend = textReplace;
        }
      }
    }

    mentionComments.insert(
        0,
        CommentModel.fromJSON(
            {"user": ref.read(userNotifierProvider), "comment": textSend}));
  }

  @override
  void initState() {
    super.initState();

    _mentionsController = TextEditingController();
    _mentionsFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _mentionsController.dispose();
    _mentionsFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    isKeyboard = ref.watch(visibleKeyboardAppNotifierProvider);
    recentSearchesUsers = ref.watch(recentSearchesNotifierProvider);

    return SafeArea(
      left: false,
      right: false,
      bottom: false,
      top: true,
      child: GestureDetector(
        onTap: () {
          Helpers.hideKeyboard(context);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 750),
          height: isKeyboard
              ? MediaQuery.of(context).size.height
              : Platform.isIOS
                  ? MediaQuery.of(context).size.height / 2 + 20.0
                  : MediaQuery.of(context).size.height / 2,
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
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(AppLocalization.of(context).translate("bottom_sheet_mentions", "title"),
                            style: textStyleCustomBold(
                                Theme.of(context).brightness == Brightness.light
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
                              ? comments()
                              : mentionsRecentInteractions
                                  ? recentSearches()
                                  : resultsSearches(),
                        ),
                        writeMention()
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
  }

  Widget comments() {
    return mentionComments.isEmpty
        ? Center(
            child: Text(
              AppLocalization.of(context).translate("bottom_sheet_mentions", "content"),
              style: textStyleCustomBold(Helpers.uiApp(context), 14.0),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            ),
          )
        : ListView.builder(
            key: UniqueKey(),
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            shrinkWrap: true,
            itemCount: mentionComments.length,
            itemBuilder: (_, index) {
              CommentModel mentionComment = mentionComments[index];

              return MentionText(
                  mentionComment: mentionComment, encryptionKey: encryptionKey);
            });
  }

  Widget recentSearches() {
    return recentSearchesUsers.isEmpty
        ? Center(
            child: Text(
                AppLocalization.of(context).translate("bottom_sheet_mentions", "no_recent_interactions"),
                style: textStyleCustomMedium(Helpers.uiApp(context), 14),
                textAlign: TextAlign.center,
                textScaleFactor: 1.0))
        : ListView.builder(
            padding: EdgeInsets.zero,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            shrinkWrap: true,
            itemCount: recentSearchesUsers.length,
            itemBuilder: (_, index) {
              UserModel user = recentSearchesUsers[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                  onTap: () async {
                    await setNewMention(user);
                    setState(() {
                      mentionsRecentInteractions = false;
                      startSearchMention = false;
                    });
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
                          child:
                              const Icon(Icons.person, color: cBlue, size: 30),
                        )
                      : CachedNetworkImageCustom(
                          profilePictureUrl: user.profilePictureUrl,
                          heightContainer: 65,
                          widthContainer: 65,
                          iconSize: 30),
                  title: Text(
                    user.pseudo,
                    style: textStyleCustomMedium(Helpers.uiApp(context), 16),
                    textScaleFactor: 1.0,
                  ),
                ),
              );
            });
  }

  Widget resultsSearches() {
    return resultsSearch.isEmpty
        ? Center(
            child: Text(
              AppLocalization.of(context).translate("bottom_sheet_mentions", "no_results"),
              style: textStyleCustomBold(Helpers.uiApp(context), 14.0),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            itemCount: resultsSearch.length,
            itemBuilder: (_, index) {
              UserModel user = resultsSearch[index];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5.0),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 5.0),
                  onTap: () async {
                    await setNewMention(user);
                    setState(() {
                      startSearchMention = false;
                      mentionsRecentInteractions = false;
                    });
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
                          child:
                              const Icon(Icons.person, color: cBlue, size: 30),
                        )
                      : CachedNetworkImageCustom(
                          profilePictureUrl: user.profilePictureUrl,
                          heightContainer: 65,
                          widthContainer: 65,
                          iconSize: 30),
                  title: Text(
                    user.pseudo,
                    style: textStyleCustomMedium(Helpers.uiApp(context), 16),
                    textScaleFactor: 1.0,
                  ),
                ),
              );
            });
  }

  Widget writeMention() {
    return Container(
        height: 60.0,
        color: Theme.of(context).scaffoldBackgroundColor,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                scrollPhysics: const BouncingScrollPhysics(),
                controller: _mentionsController,
                focusNode: _mentionsFocusNode,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                onChanged: (val) async {
                  setState(() {
                    val = _mentionsController.text;
                  });

                  await detectNewMentionUser();
                },
                onSubmitted: (val) {
                  Helpers.hideKeyboard(context);
                },
                style: textStyleCustomRegular(
                    _mentionsFocusNode.hasFocus ? cBlue : cGrey,
                    14 / MediaQuery.of(context).textScaleFactor),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  hintText: AppLocalization.of(context).translate("bottom_sheet_mentions", "write_mention"),
                  hintStyle: textStyleCustomRegular(
                      cGrey, 14 / MediaQuery.of(context).textScaleFactor),
                  labelStyle: textStyleCustomRegular(
                      cBlue, 14 / MediaQuery.of(context).textScaleFactor),
                  suffixIcon: _mentionsController.text.isEmpty
                      ? const SizedBox()
                      : Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _mentionsController.clear();
                                  if (mentions.isNotEmpty) {
                                    mentions.clear();
                                  }
                                });
                              },
                              icon: Icon(
                                Icons.clear,
                                color:
                                    _mentionsFocusNode.hasFocus ? cBlue : cGrey,
                              )),
                        ),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                        color: _mentionsFocusNode.hasFocus ? cBlue : cGrey,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                        color: _mentionsFocusNode.hasFocus ? cBlue : cGrey,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                        color: _mentionsFocusNode.hasFocus ? cBlue : cGrey,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                  focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        width: 2.0,
                        color: _mentionsFocusNode.hasFocus ? cBlue : cGrey,
                      ),
                      borderRadius: BorderRadius.circular(10.0)),
                ),
              ),
            ),
            if (_mentionsController.text.isNotEmpty)
              Row(
                children: [
                  const SizedBox(width: 10.0),
                  GestureDetector(
                    onTap: () async {
                      await sendMentionText();
                      setState(() {
                        if (mentions.isNotEmpty) {
                          mentions.clear();
                        }
                        _mentionsController.clear();
                      });
                      if (mounted) {
                        Helpers.hideKeyboard(context);
                      }
                    },
                    child: Container(
                      height: 40,
                      width: 40,
                      margin: const EdgeInsets.symmetric(horizontal: 10.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: cBlue, blurRadius: 3)
                          ]),
                      child: const Icon(
                        Icons.send,
                        color: cBlue,
                        size: 23,
                      ),
                    ),
                  )
                ],
              )
          ],
        ));
  }
}
