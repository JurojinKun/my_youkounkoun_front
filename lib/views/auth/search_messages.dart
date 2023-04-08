import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/message_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchMessages extends ConsumerStatefulWidget {
  final String keyWords;
  final UserModel user;

  const SearchMessages({Key? key, required this.keyWords, required this.user})
      : super(key: key);

  @override
  SearchMessagesState createState() => SearchMessagesState();
}

class SearchMessagesState extends ConsumerState<SearchMessages> {
  final AppBar appBar = AppBar();

  late RefreshController refreshController;

  bool _loadedSearchedMessages = false;
  List<MessageModel> searchedMessages = [];

  //fake fct => get datas mockés switch id user
  List<MessageModel> getListMessagesUsers() {
    List<MessageModel> messages = [];

    switch (widget.user.id) {
      case 186:
        messages = [...listMessagesWith186DatasMockes];
        break;
      case 4:
        messages = [...listMessagesWith4DatasMockes];
        break;
      default:
        messages = [];
        break;
    }

    //Bien vérifier que la logique de timestamps fonctionnent bien par rapport au grouped list view
    //TODO order by timestamp du plus récent au plus vieux
    messages.sort(
        (a, b) => int.parse(b.timestamp).compareTo(int.parse(a.timestamp)));

    return messages;
  }

  //TODO logic searched messages via keyWords
  Future<void> _initSearchedMessages() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      List<MessageModel> messages = getListMessagesUsers();
      for (var message in messages) {
        if (message.type == "text" &&
            (message.message.toLowerCase())
                .contains(widget.keyWords.toLowerCase())) {
          searchedMessages.add(message);
        }
      }
      // TODO seulement si on atteint pas la limit de datas qu'on va cherché (par ex: si la length de searchedMessages est en dessous de 15 qui est la limite dans la recherche)
      refreshController.loadNoData();
      setState(() {
        _loadedSearchedMessages = true;
      });
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  //TODO logic load more searched messages
  // Future<void> _loadMoreSearchMessages() async {
  // }

  @override
  void initState() {
    super.initState();
    refreshController = RefreshController(initialRefresh: false);

    _initSearchedMessages();
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: appBarSearchMessages(),
      body: bodySearchMessages(),
    );
  }

  PreferredSizeWidget appBarSearchMessages() {
    return PreferredSize(
      preferredSize:
          Size(MediaQuery.of(context).size.width, appBar.preferredSize.height),
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
              widget.keyWords,
              style: textStyleCustomBold(Helpers.uiApp(context), 20),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            ),
            centerTitle: false,
            actions: [
              Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: IconButton(
                    onPressed: () async {
                      navAuthKey.currentState!.pop();
                    },
                    icon: Icon(
                      Icons.clear,
                      color: Helpers.uiApp(context),
                    )),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget bodySearchMessages() {
    return SizedBox.expand(
      child: !_loadedSearchedMessages
          ? const Center(
              child: CircularProgressIndicator(color: cBlue, strokeWidth: 1.0),
            )
          : searchedMessagesConv(),
    );
  }

  Widget searchedMessagesConv() {
    return searchedMessages.isEmpty
        ? Center(
            child: Text("Pas de résultats pour cette recherche",
                style: textStyleCustomBold(Helpers.uiApp(context), 16),
                textAlign: TextAlign.center,
                textScaleFactor: 1.0),
          )
        : GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: cBlue,
            child: SmartRefresher(
                controller: refreshController,
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                enablePullDown: false,
                enablePullUp: true,
                footer: ClassicFooter(
                  height: MediaQuery.of(context).padding.bottom + 30.0,
                  iconPos: IconPosition.top,
                  loadingText: "",
                  loadingIcon: const Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                        height: 20.0,
                        width: 20.0,
                        child: CircularProgressIndicator(
                            color: cBlue, strokeWidth: 1.0)),
                  ),
                  noDataText: "",
                  noMoreIcon: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "Pas plus de résultats actuellement",
                      style: textStyleCustomBold(Helpers.uiApp(context), 14),
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  canLoadingIcon: const SizedBox(),
                  idleIcon: const SizedBox(),
                  idleText: "",
                  canLoadingText: "",
                ),
                // onLoading: _loadMoreSearchMessages,
                child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(
                        10.0,
                        MediaQuery.of(context).padding.top +
                            appBar.preferredSize.height +
                            10.0,
                        10.0,
                        MediaQuery.of(context).padding.bottom + 20.0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchedMessages.length,
                    itemBuilder: (_, index) {
                      MessageModel searchedMessage = searchedMessages[index];
                      return searchedMessageItem(searchedMessage, index);
                    })),
          );
  }

  Widget searchedMessageItem(MessageModel message, int index) {
    return Column(children: [
      message.idReceiver == widget.user.id
          ? Container(
              margin: const EdgeInsets.symmetric(vertical: 7.5),
              child: Row(
                children: [
                  SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: widget.user.profilePictureUrl.trim() == ""
                        ? Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cBlue),
                              color: cGrey.withOpacity(0.2),
                            ),
                            child: const Icon(Icons.person,
                                color: cBlue, size: 28),
                          )
                        : CachedNetworkImageCustom(
                            profilePictureUrl: widget.user.profilePictureUrl,
                            heightContainer: 45,
                            widthContainer: 45,
                            iconSize: 28),
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.user.pseudo,
                            style: textStyleCustomBold(
                                Helpers.uiApp(context),
                                16),
                            textScaleFactor: 1.0),
                        const SizedBox(width: 5.0),
                        Wrap(
                          children: [
                            message.message.length <= 40
                                ? Text(message.message,
                                    style: textStyleCustomRegular(cGrey, 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1.0)
                                : RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              message.message.substring(0, 40),
                                          style:
                                              textStyleCustomRegular(cGrey, 14),
                                        ),
                                        TextSpan(
                                          text: '...',
                                          style:
                                              textStyleCustomRegular(cGrey, 14),
                                        ),
                                        TextSpan(
                                          text: message.message.substring(40),
                                          style:
                                              textStyleCustomRegular(cGrey, 14),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            Container(
                              height: 14.0,
                              width: 10.0,
                              alignment: Alignment.center,
                              child: Container(
                                height: 2.5,
                                width: 2.5,
                                decoration: const BoxDecoration(
                                    color: cGrey, shape: BoxShape.circle),
                              ),
                            ),
                            Text(
                                Helpers.formatDateDayWeek(
                                    int.parse(message.timestamp),
                                    ref
                                        .read(localeLanguageNotifierProvider)
                                        .languageCode,
                                    false),
                                style: textStyleCustomRegular(cGrey, 14),
                                textScaleFactor: 1.0)
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              margin: const EdgeInsets.symmetric(vertical: 7.5),
              child: Row(
                children: [
                  SizedBox(
                    height: 50.0,
                    width: 50.0,
                    child: ref
                                .read(userNotifierProvider)
                                .profilePictureUrl
                                .trim() ==
                            ""
                        ? Container(
                            height: 45,
                            width: 45,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: cBlue),
                              color: cGrey.withOpacity(0.2),
                            ),
                            child: const Icon(Icons.person,
                                color: cBlue, size: 28),
                          )
                        : CachedNetworkImageCustom(
                            profilePictureUrl: ref
                                .read(userNotifierProvider)
                                .profilePictureUrl,
                            heightContainer: 45,
                            widthContainer: 45,
                            iconSize: 28),
                  ),
                  const SizedBox(width: 15.0),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ref.read(userNotifierProvider).pseudo,
                            style: textStyleCustomBold(
                                Helpers.uiApp(context),
                                16),
                            textScaleFactor: 1.0),
                        const SizedBox(width: 5.0),
                        Wrap(
                          children: [
                            message.message.length <= 40
                                ? Text(message.message,
                                    style: textStyleCustomRegular(cGrey, 14),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textScaleFactor: 1.0)
                                : RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              message.message.substring(0, 40),
                                          style:
                                              textStyleCustomRegular(cGrey, 14),
                                        ),
                                        TextSpan(
                                          text: '...',
                                          style:
                                              textStyleCustomRegular(cGrey, 14),
                                        ),
                                        TextSpan(
                                          text: message.message.substring(40),
                                          style:
                                              textStyleCustomRegular(cGrey, 14),
                                        ),
                                      ],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                            Container(
                              height: 14.0,
                              width: 10.0,
                              alignment: Alignment.center,
                              child: Container(
                                height: 2.5,
                                width: 2.5,
                                decoration: const BoxDecoration(
                                    color: cGrey, shape: BoxShape.circle),
                              ),
                            ),
                            Text(
                                Helpers.formatDateDayWeek(
                                    int.parse(message.timestamp),
                                    ref
                                        .read(localeLanguageNotifierProvider)
                                        .languageCode,
                                    false),
                                style: textStyleCustomRegular(cGrey, 14),
                                textScaleFactor: 1.0)
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
      if (index != searchedMessages.length - 1)
        const Divider(thickness: 0.5, color: cGrey)
    ]);
  }
}
