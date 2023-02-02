import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:age_calculator/age_calculator.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flag/flag_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/components/no_recent_emoji.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/message_model.dart';
import 'package:myyoukounkoun/providers/chat_details_provider.dart';
import 'package:myyoukounkoun/providers/notifications_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:sticky_headers/sticky_headers.dart';

import '../../models/user_model.dart';

class ChatDetails extends ConsumerStatefulWidget {
  final UserModel user;
  final bool openWithModal;

  const ChatDetails({Key? key, required this.user, required this.openWithModal})
      : super(key: key);

  @override
  ChatDetailsState createState() => ChatDetailsState();
}

class ChatDetailsState extends ConsumerState<ChatDetails>
    with SingleTickerProviderStateMixin {
  AppBar appBar = AppBar();

  late ScrollController _scrollChatController;
  bool _scrollDown = false;

  late TextEditingController _chatController, _searchGifController;
  late FocusNode _chatFocusNode, _searchGifFocusNode;
  bool toolsStayHide = true;
  bool showEmotions = false;

  List<MessageModel> messagesUsers = [];

  GlobalKey keyChatField = GlobalKey();

  late TabController _tabControllerEmotions;

  GiphyClient gif = GiphyClient(apiKey: apiKeyGiphy);
  GiphyCollection? gifTrending;

  bool _openBottomSheetGif = false;
  GiphyCollection? searchGifsResults;
  String currentSearchGifs = "";
  Timer? _timer;

  void _scrollChatListener() {
    if (_scrollChatController.position.pixels >=
            _scrollChatController.position.minScrollExtent + 100 &&
        !_scrollDown) {
      setState(() {
        _scrollDown = true;
      });
    } else if (_scrollChatController.position.pixels <
            _scrollChatController.position.minScrollExtent + 100 &&
        _scrollDown) {
      setState(() {
        _scrollDown = false;
      });
    }

    if (_scrollChatController.offset != 0.0) {
      if (_chatFocusNode.hasFocus) {
        if (toolsStayHide) {
          ref
              .read(toolsStayHideNotifierProvider.notifier)
              .updateStayHide(false);
        }
        Helpers.hideKeyboard(context);
      } else {
        if (toolsStayHide) {
          ref
              .read(toolsStayHideNotifierProvider.notifier)
              .updateStayHide(false);
        }
        if (showEmotions) {
          ref
              .read(showEmotionsNotifierProvider.notifier)
              .updateShowEmotions(false);
        }
      }
    }
  }

  Future<void> _tabEmotionsListener() async {
    if (_tabControllerEmotions.indexIsChanging) {
      if (_tabControllerEmotions.index == 1 &&
          _tabControllerEmotions.previousIndex == 0 &&
          gifTrending == null) {
        GiphyCollection gifsCollection = await gif.trending(limit: 69);
        ref
            .read(gifTrendingsNotifierProvider.notifier)
            .setGifTrendings(gifsCollection);
      }
    }
  }

  void _scrollToDownChat() {
    _scrollChatController.animateTo(
        _scrollChatController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastOutSlowIn);
  }

  Future<void> _searchGifs() async {
    searchGifsResults =
        await gif.search(_searchGifController.text.toLowerCase(), limit: 69);
  }

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

    messages.sort(
        (a, b) => int.parse(a.timestamp).compareTo(int.parse(b.timestamp)));

    return messages;
  }

  Future _showBarBottomSheetSearchGif(BuildContext context) async {
    return showBarModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        barrierColor: Colors.black54,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return GestureDetector(
              onTap: () => Helpers.hideKeyboard(context),
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 1.2,
                child: SingleChildScrollView(
                    controller: ModalScrollController.of(context),
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: StickyHeader(
                        header: Container(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 40.0,
                              child: TextField(
                                minLines: 1,
                                maxLines: 1,
                                autofocus: true,
                                controller: _searchGifController,
                                focusNode: _searchGifFocusNode,
                                showCursor: true,
                                cursorColor: cBlue,
                                textInputAction: TextInputAction.search,
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    12 /
                                        MediaQuery.of(context).textScaleFactor),
                                decoration: InputDecoration(
                                  fillColor: Theme.of(context).canvasColor,
                                  filled: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                  hintText: "Rechercher dans Giphy",
                                  hintStyle: textStyleCustomBold(
                                      cGrey,
                                      12 /
                                          MediaQuery.of(context)
                                              .textScaleFactor),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: _searchGifFocusNode.hasFocus
                                            ? cBlue
                                            : cGrey,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: _searchGifFocusNode.hasFocus
                                            ? cBlue
                                            : cGrey,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: _searchGifFocusNode.hasFocus
                                            ? cBlue
                                            : cGrey,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: _searchGifFocusNode.hasFocus
                                            ? cBlue
                                            : cGrey,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  suffixIcon: _searchGifController
                                          .text.isNotEmpty
                                      ? GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _searchGifController.clear();
                                            });
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: _searchGifFocusNode.hasFocus
                                                ? cBlue
                                                : cGrey,
                                          ),
                                        )
                                      : const SizedBox(),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    value = _searchGifController.text;
                                  });

                                  if (_timer != null && _timer!.isActive) {
                                    _timer!.cancel();
                                  }
                                  _timer = Timer(const Duration(seconds: 1),
                                      () async {
                                    if (_searchGifController.text.isNotEmpty &&
                                        currentSearchGifs !=
                                            _searchGifController.text) {
                                      await _searchGifs();
                                      setState(() {
                                        currentSearchGifs =
                                            _searchGifController.text;
                                      });
                                    }
                                  });
                                },
                                onEditingComplete: () {
                                  _searchGifFocusNode.unfocus();
                                },
                              ),
                            ),
                          ),
                        ),
                        content: _searchGifController.text.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 25.0, vertical: 15.0),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.search,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? cBlack
                                          : cWhite,
                                      size: 45,
                                    ),
                                    const SizedBox(height: 15.0),
                                    Text(
                                        "Recherche et trouve le GIF qui illustre ton humeur du moment",
                                        style: textStyleCustomBold(
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? cBlack
                                                : cWhite,
                                            14),
                                        textAlign: TextAlign.center,
                                        textScaleFactor: 1.0)
                                  ],
                                ),
                              )
                            : currentSearchGifs != _searchGifController.text
                                ? Container(
                                    height: 150,
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 15.0,
                                          width: 15.0,
                                          child: CircularProgressIndicator(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            strokeWidth: 1.0,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10.0,
                                        ),
                                        Text(
                                          _searchGifController.text.length < 10
                                              ? '${AppLocalization.of(context).translate("general", "search_of")}"${_searchGifController.text}.."'
                                              : '${AppLocalization.of(context).translate("general", "search_of")}"${_searchGifController.text.substring(0, 10)}.."',
                                          style: textStyleCustomMedium(
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? cBlack
                                                  : cWhite,
                                              14),
                                          textAlign: TextAlign.center,
                                          textScaleFactor: 1.0,
                                        )
                                      ],
                                    ),
                                  )
                                : searchGifsResults == null ||
                                        (searchGifsResults != null &&
                                            searchGifsResults!.data.isEmpty)
                                    ? Container(
                                        height: 150.0,
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.search,
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.light
                                                    ? cBlack
                                                    : cWhite,
                                                size: 40),
                                            const SizedBox(height: 10.0),
                                            Text(
                                                "Pas de résultats dans Giphy pour cette recherche",
                                                style: textStyleCustomMedium(
                                                    Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? cBlack
                                                        : cWhite,
                                                    14),
                                                textAlign: TextAlign.center,
                                                textScaleFactor: 1.0)
                                          ],
                                        ))
                                    : GridView.builder(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0, vertical: 10.0),
                                        shrinkWrap: true,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 2,
                                                crossAxisSpacing: 10,
                                                mainAxisSpacing: 10,
                                                mainAxisExtent: 200),
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            searchGifsResults!.data.length,
                                        itemBuilder: (context, index) {
                                          GiphyGif gif =
                                              searchGifsResults!.data[index];

                                          return GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                              //send message on click gif => url gif and type: "gif"
                                              print(gif.images.original!.url);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: cGrey.withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  border:
                                                      Border.all(color: cGrey)),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                                child: Image.network(
                                                  gif.images.original!.url!,
                                                  headers: const {
                                                    'accept': 'image/*'
                                                  },
                                                  filterQuality:
                                                      FilterQuality.low,
                                                  fit: BoxFit.cover,
                                                  loadingBuilder:
                                                      (BuildContext context,
                                                          Widget child,
                                                          ImageChunkEvent?
                                                              loadingProgress) {
                                                    if (loadingProgress ==
                                                        null) {
                                                      return child;
                                                    }
                                                    return Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                        color: cBlue,
                                                        value: loadingProgress
                                                                    .expectedTotalBytes !=
                                                                null
                                                            ? loadingProgress
                                                                    .cumulativeBytesLoaded /
                                                                loadingProgress
                                                                    .expectedTotalBytes!
                                                            : null,
                                                        strokeWidth: 2.0,
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Center(
                                                      child: Icon(
                                                          Icons.error_outline,
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .light
                                                              ? cBlack
                                                              : cWhite,
                                                          size: 33),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ))),
              ),
            );
          });
        });
  }

  @override
  void initState() {
    super.initState();

    messagesUsers = getListMessagesUsers();

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref.read(inChatDetailsNotifierProvider.notifier).inChatDetails(
            context.widget.toString(), widget.user.id.toString());

        ref.read(toolsStayHideNotifierProvider.notifier).clearStayHide();
        ref.read(showEmotionsNotifierProvider.notifier).clearShowEmotions();
      });
    }

    _scrollChatController = ScrollController();
    _scrollChatController.addListener(_scrollChatListener);

    _chatController = TextEditingController();
    _chatController.addListener(() {
      if (!ref.read(toolsStayHideNotifierProvider)) {
        ref.read(toolsStayHideNotifierProvider.notifier).updateStayHide(true);
      }
      setState(() {});
    });
    _chatFocusNode = FocusNode();
    _chatFocusNode.addListener(() {
      if (_chatFocusNode.hasFocus && showEmotions) {
        ref
            .read(showEmotionsNotifierProvider.notifier)
            .updateShowEmotions(false);
      }
    });

    _tabControllerEmotions = TabController(length: 2, vsync: this);
    _tabControllerEmotions.addListener(_tabEmotionsListener);

    _searchGifController = TextEditingController();
    _searchGifFocusNode = FocusNode();
  }

  @override
  void deactivate() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }

    _chatController.removeListener(() {
      if (!ref.read(toolsStayHideNotifierProvider)) {
        ref.read(toolsStayHideNotifierProvider.notifier).updateStayHide(true);
      }
      setState(() {});
    });
    _chatFocusNode.removeListener(() {
      if (_chatFocusNode.hasFocus && showEmotions) {
        ref
            .read(showEmotionsNotifierProvider.notifier)
            .updateShowEmotions(false);
      }
    });

    _scrollChatController.removeListener(_scrollChatListener);
    _tabControllerEmotions.removeListener(_tabEmotionsListener);

    super.deactivate();
  }

  @override
  void dispose() {
    _chatFocusNode.dispose();
    _chatController.dispose();
    _scrollChatController.dispose();
    _tabControllerEmotions.dispose();
    _searchGifController.dispose();
    _searchGifFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    toolsStayHide = ref.watch(toolsStayHideNotifierProvider);
    showEmotions = ref.watch(showEmotionsNotifierProvider);
    gifTrending = ref.watch(gifTrendingsNotifierProvider);

    return ColorfulSafeArea(
      top: false,
      left: false,
      right: false,
      bottom: true,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: GestureDetector(
        onTap: () {
          if (toolsStayHide) {
            ref
                .read(toolsStayHideNotifierProvider.notifier)
                .updateStayHide(false);
          }
          Helpers.hideKeyboard(context);
          if (showEmotions) {
            ref
                .read(showEmotionsNotifierProvider.notifier)
                .updateShowEmotions(false);
          }
        },
        onHorizontalDragUpdate: (details) {
          int sensitivity = 8;
          if (Platform.isIOS &&
              details.delta.dx > sensitivity &&
              details.globalPosition.dx <= 70) {
            if (ref.read(inChatDetailsNotifierProvider)["screen"] ==
                "ChatDetails") {
              ref
                  .read(inChatDetailsNotifierProvider.notifier)
                  .outChatDetails("", "");
            }
            Navigator.pop(context);
          }
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: _openBottomSheetGif ? false : true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: _customAppBarDetailsChat(),
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
            child: Stack(
              children: [
                messages(),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (_scrollDown)
                      GestureDetector(
                        onTap: () => _scrollToDownChat(),
                        child: Container(
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                    color: cBlue,
                                    blurRadius: 6,
                                    spreadRadius: 2)
                              ]),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.arrow_downward,
                            color: cBlue,
                            size: 23,
                          ),
                        ),
                      ),
                    const SizedBox(height: 10.0),
                    writeMessage(),
                    Offstage(
                      offstage: !showEmotions,
                      child: emotionsCard(),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _customAppBarDetailsChat() {
    return PreferredSize(
      preferredSize:
          Size(MediaQuery.of(context).size.width, appBar.preferredSize.height),
      child: ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              alignment: Alignment.bottomCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  widget.openWithModal
                      ? const SizedBox()
                      : Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: IconButton(
                              onPressed: () {
                                ref
                                    .read(
                                        inChatDetailsNotifierProvider.notifier)
                                    .outChatDetails("", "");
                                Navigator.pop(context);
                              },
                              icon: Icon(Icons.arrow_back_ios,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? cBlack
                                      : cWhite)),
                        ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: widget.openWithModal ? 15.0 : 0.0),
                      child: GestureDetector(
                        onTap: () {
                          ref
                              .read(afterChatDetailsNotifierProvider.notifier)
                              .updateAfterChat(true);
                          ref
                              .read(inChatDetailsNotifierProvider.notifier)
                              .outChatDetails(
                                  "UserProfile", widget.user.id.toString());
                          navAuthKey.currentState!.pushNamed(userProfile,
                              arguments: [widget.user, false]);
                        },
                        child: Row(
                          children: [
                            widget.user.profilePictureUrl.trim() == ""
                                ? Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: cBlue),
                                      color: cGrey.withOpacity(0.2),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: cBlue, size: 23),
                                  )
                                : CachedNetworkImageCustom(
                                    profilePictureUrl:
                                        widget.user.profilePictureUrl,
                                    heightContainer: 45,
                                    widthContainer: 45,
                                    iconSize: 23),
                            const SizedBox(
                              width: 15.0,
                            ),
                            Text(widget.user.pseudo,
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    20),
                                textScaleFactor: 1.0)
                          ],
                        ),
                      ),
                    ),
                  ),
                  widget.openWithModal
                      ? Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: IconButton(
                              onPressed: () {
                                ref
                                    .read(
                                        inChatDetailsNotifierProvider.notifier)
                                    .outChatDetails("", "");
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? cBlack
                                    : cWhite,
                                size: 30,
                              )),
                        )
                      : const SizedBox()
                ],
              ),
            )),
      ),
    );
  }

  Widget messages() {
    return SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            10.0,
            MediaQuery.of(context).padding.top +
                appBar.preferredSize.height +
                20.0,
            10.0,
            showEmotions
                ? MediaQuery.of(context).padding.bottom +
                    70.0 +
                    (MediaQuery.of(context).size.height / 2.0)
                : MediaQuery.of(context).padding.bottom + 70.0),
        controller: _scrollChatController,
        reverse: true,
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            seeProfile(),
            const SizedBox(height: 20.0),
            listMessages()
          ],
        ));
  }

  Widget seeProfile() {
    return Center(
      child: Column(
        children: [
          widget.user.profilePictureUrl.trim() == ""
              ? Container(
                  height: 145,
                  width: 145,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: cBlue),
                    color: cGrey.withOpacity(0.2),
                  ),
                  child: const Icon(Icons.person, color: cBlue, size: 55),
                )
              : CachedNetworkImageCustom(
                  profilePictureUrl: widget.user.profilePictureUrl,
                  heightContainer: 145,
                  widthContainer: 145,
                  iconSize: 55),
          const SizedBox(
            height: 15.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.user.pseudo,
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    23),
                textScaleFactor: 1.0,
                textAlign: TextAlign.center,
              ),
              Flag.flagsCode.contains(widget.user.nationality.toUpperCase())
                  ? Flag.fromString(
                      widget.user.nationality.toUpperCase(),
                      height: 25,
                      width: 50,
                      fit: BoxFit.contain,
                      replacement: const SizedBox(),
                    )
                  : Flag.flagsCode
                          .contains(widget.user.nationality.toLowerCase())
                      ? Flag.fromString(
                          widget.user.nationality.toLowerCase(),
                          height: 25,
                          width: 50,
                          fit: BoxFit.contain,
                          replacement: const SizedBox(),
                        )
                      : const SizedBox()
            ],
          ),
          const SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.user.gender == "Male" ? Icons.male : Icons.female,
                  color: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite),
              Text(
                " - ",
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    18),
              ),
              Text(
                  AgeCalculator.age(Helpers.convertStringToDateTime(
                              widget.user.birthday))
                          .years
                          .toString() +
                      AppLocalization.of(context)
                          .translate("user_profile_screen", "years_old"),
                  style: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      18.0))
            ],
          ),
          const SizedBox(height: 10.0),
          SizedBox(
              height: 30.0,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: cBlue,
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    ref
                        .read(afterChatDetailsNotifierProvider.notifier)
                        .updateAfterChat(true);
                    ref
                        .read(inChatDetailsNotifierProvider.notifier)
                        .outChatDetails(
                            "UserProfile", widget.user.id.toString());
                    navAuthKey.currentState!.pushNamed(userProfile,
                        arguments: [widget.user, false]);
                  },
                  child: Text("Voir profil",
                      style: textStyleCustomMedium(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          18),
                      textScaleFactor: 1.0)))
        ],
      ),
    );
  }

  Widget listMessages() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: messagesUsers.length,
      itemBuilder: (context, index) {
        MessageModel message = messagesUsers[index];

        return messageItem(messagesUsers, message, index);
      },
    );
  }

  Widget messageItem(
      List<MessageModel> messagesUsers, MessageModel message, int index) {
    return message.idSender != ref.read(userNotifierProvider).id
        ? Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (messagesUsers.length == index + 1 ||
                  messagesUsers[index + 1].idSender ==
                      ref.read(userNotifierProvider).id)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: widget.user.profilePictureUrl.trim() == ""
                      ? Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: cBlue),
                            color: cGrey.withOpacity(0.2),
                          ),
                          child:
                              const Icon(Icons.person, color: cBlue, size: 15),
                        )
                      : CachedNetworkImageCustom(
                          profilePictureUrl: widget.user.profilePictureUrl,
                          heightContainer: 25,
                          widthContainer: 25,
                          iconSize: 15),
                ),
              typeMessage(message, index),
            ],
          )
        : Align(
            alignment: Alignment.centerRight,
            child: typeMessage(message, index));
  }

  Widget typeMessage(MessageModel message, int index) {
    switch (message.type) {
      case "text":
        if (message.idSender != ref.read(userNotifierProvider).id) {
          return Container(
            constraints: BoxConstraints(
                minWidth: 0, maxWidth: MediaQuery.of(context).size.width / 1.5),
            margin: EdgeInsets.symmetric(
                horizontal: messagesUsers.length != index + 1 &&
                        messagesUsers[index + 1].idSender !=
                            ref.read(userNotifierProvider).id
                    ? 35.0
                    : 10.0,
                vertical: 5.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: cBlue),
                borderRadius: BorderRadius.circular(10.0)),
            child: Text(
              message.message,
              style: textStyleCustomRegular(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  14),
              textScaleFactor: 1.0,
            ),
          );
        } else {
          return Container(
            constraints: BoxConstraints(
                minWidth: 0, maxWidth: MediaQuery.of(context).size.width / 1.5),
            margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
                color: cBlue, borderRadius: BorderRadius.circular(10.0)),
            child: Text(
              message.message,
              style: textStyleCustomRegular(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  14),
              textScaleFactor: 1.0,
            ),
          );
        }
      case "image":
        if (message.idSender != ref.read(userNotifierProvider).id) {
          return GestureDetector(
            onTap: () => navAuthKey.currentState!
                .pushNamed(pictureFullscreen, arguments: [message.message]),
            child: Container(
                height: 200,
                width: 150,
                margin: EdgeInsets.symmetric(
                    horizontal: messagesUsers.length != index + 1 &&
                            messagesUsers[index + 1].idSender !=
                                ref.read(userNotifierProvider).id
                        ? 35.0
                        : 10.0,
                    vertical: 5.0),
                decoration: BoxDecoration(
                    color: cGrey.withOpacity(0.2),
                    border: Border.all(color: cBlue),
                    borderRadius: BorderRadius.circular(10.0)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Hero(
                    tag: "picture ${message.message}",
                    transitionOnUserGestures: true,
                    child: Image.network(
                      message.message,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            color: cBlue,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2.0,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.replay_outlined,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? cBlack
                                  : cWhite,
                              size: 33),
                        );
                      },
                    ),
                  ),
                )),
          );
        } else {
          return GestureDetector(
            onTap: () => navAuthKey.currentState!
                .pushNamed(pictureFullscreen, arguments: [message.message]),
            child: Container(
                height: 200,
                width: 150,
                margin: EdgeInsets.symmetric(
                    horizontal: messagesUsers.length != index + 1 &&
                            messagesUsers[index + 1].idSender !=
                                ref.read(userNotifierProvider).id
                        ? 35.0
                        : 10.0,
                    vertical: 5.0),
                decoration: BoxDecoration(
                    color: cGrey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10.0)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Hero(
                    tag: "picture ${message.message}",
                    transitionOnUserGestures: true,
                    child: Image.network(
                      message.message,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        }
                        return Center(
                          child: CircularProgressIndicator(
                            color: cBlue,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2.0,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(Icons.replay_outlined,
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? cBlack
                                  : cWhite,
                              size: 33),
                        );
                      },
                    ),
                  ),
                )),
          );
        }
      case "gif":
        if (message.idSender != ref.read(userNotifierProvider).id) {
          return Container(
              height: 200,
              width: 150,
              margin: EdgeInsets.symmetric(
                  horizontal: messagesUsers.length != index + 1 &&
                          messagesUsers[index + 1].idSender !=
                              ref.read(userNotifierProvider).id
                      ? 35.0
                      : 10.0,
                  vertical: 5.0),
              decoration: BoxDecoration(
                  color: cGrey.withOpacity(0.2),
                  border: Border.all(color: cBlue),
                  borderRadius: BorderRadius.circular(10.0)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  message.message,
                  headers: const {'accept': 'image/*'},
                  filterQuality: FilterQuality.low,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: cBlue,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2.0,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.replay_outlined,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                          size: 33),
                    );
                  },
                ),
              ));
        } else {
          return Container(
              height: 200,
              width: 150,
              margin: EdgeInsets.symmetric(
                  horizontal: messagesUsers.length != index + 1 &&
                          messagesUsers[index + 1].idSender !=
                              ref.read(userNotifierProvider).id
                      ? 35.0
                      : 10.0,
                  vertical: 5.0),
              decoration: BoxDecoration(
                  color: cGrey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.network(
                  message.message,
                  headers: const {'accept': 'image/*'},
                  filterQuality: FilterQuality.low,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return Center(
                      child: CircularProgressIndicator(
                        color: cBlue,
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        strokeWidth: 2.0,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Icon(Icons.replay_outlined,
                          color:
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                          size: 33),
                    );
                  },
                ),
              ));
        }
      default:
        return const SizedBox();
    }
  }

  Widget writeMessage() {
    return ClipRRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: SizedBox(
              height: 60,
              child: Row(
                children: [
                  _chatController.text.isNotEmpty &&
                          _chatController.text.trim() != "" &&
                          toolsStayHide
                      ? GestureDetector(
                          onTap: () {
                            ref
                                .read(toolsStayHideNotifierProvider.notifier)
                                .updateStayHide(false);
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                      color: cBlue,
                                      blurRadius: 6,
                                      spreadRadius: 2)
                                ]),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: cBlue,
                              size: 20,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              margin:
                                  const EdgeInsets.only(left: 10.0, right: 7.5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: cBlue,
                                        blurRadius: 6,
                                        spreadRadius: 2)
                                  ]),
                              child: const Icon(
                                Icons.add,
                                color: cBlue,
                                size: 20,
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              margin:
                                  const EdgeInsets.only(left: 7.5, right: 10.0),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).scaffoldBackgroundColor,
                                  shape: BoxShape.circle,
                                  boxShadow: const [
                                    BoxShadow(
                                        color: cBlue,
                                        blurRadius: 6,
                                        spreadRadius: 2)
                                  ]),
                              child: const Icon(
                                Icons.mic_rounded,
                                color: cBlue,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: TextField(
                          key: keyChatField,
                          minLines: 1,
                          maxLines: null,
                          controller: _chatController,
                          focusNode: _chatFocusNode,
                          showCursor: true,
                          cursorColor: cBlue,
                          textInputAction: TextInputAction.newline,
                          keyboardType: TextInputType.multiline,
                          style: textStyleCustomBold(
                              Theme.of(context).brightness == Brightness.light
                                  ? cBlack
                                  : cWhite,
                              12 / MediaQuery.of(context).textScaleFactor),
                          decoration: InputDecoration(
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            filled: true,
                            contentPadding:
                                const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            hintText: "Écrire un message...",
                            hintStyle: textStyleCustomBold(cGrey,
                                12 / MediaQuery.of(context).textScaleFactor),
                            enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color:
                                      _chatFocusNode.hasFocus ? cBlue : cGrey,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color:
                                      _chatFocusNode.hasFocus ? cBlue : cGrey,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color:
                                      _chatFocusNode.hasFocus ? cBlue : cGrey,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color:
                                      _chatFocusNode.hasFocus ? cBlue : cGrey,
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            suffixIcon: GestureDetector(
                              onTap: () async {
                                if (showEmotions) {
                                  _chatFocusNode.requestFocus();
                                } else {
                                  Helpers.hideKeyboard(context);
                                  await Future.delayed(
                                      const Duration(milliseconds: 250));
                                }
                                ref
                                    .read(showEmotionsNotifierProvider.notifier)
                                    .updateShowEmotions(!showEmotions);
                              },
                              child: Icon(
                                showEmotions
                                    ? Icons.keyboard
                                    : Icons.emoji_emotions,
                                color: _chatFocusNode.hasFocus ? cBlue : cGrey,
                              ),
                            ),
                          )),
                    ),
                  ),
                  if (_chatController.text.isNotEmpty &&
                      _chatController.text.trim() != "")
                    GestureDetector(
                      onTap: () {
                        _scrollToDownChat();
                        if (toolsStayHide) {
                          ref
                              .read(toolsStayHideNotifierProvider.notifier)
                              .updateStayHide(false);
                        }
                        setState(() {
                          _chatController.clear();
                        });
                        Helpers.hideKeyboard(context);
                        if (showEmotions) {
                          ref
                              .read(showEmotionsNotifierProvider.notifier)
                              .updateShowEmotions(false);
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
                              BoxShadow(
                                  color: cBlue, blurRadius: 6, spreadRadius: 2)
                            ]),
                        child: const Icon(
                          Icons.send,
                          color: cBlue,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            )));
  }

  Widget emotionsCard() {
    return Container(
        height: MediaQuery.of(context).size.height / 2.0,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: Column(
          children: [
            Container(
              height: 40.0,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: cGrey, width: 0.2)),
              ),
              child: TabBar(
                  controller: _tabControllerEmotions,
                  indicatorColor: Colors.transparent,
                  labelColor: Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  unselectedLabelColor: cGrey,
                  labelStyle: textStyleCustomBold(
                      Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      16),
                  unselectedLabelStyle: textStyleCustomBold(cGrey, 16),
                  indicator: const BoxDecoration(
                      border:
                          Border(bottom: BorderSide(color: cBlue, width: 2.0))),
                  tabs: const [
                    SizedBox.expand(
                      child: Center(
                        child: Text(
                          "Emojis",
                        ),
                      ),
                    ),
                    SizedBox.expand(child: Center(child: Text("GIFs")))
                  ]),
            ),
            Expanded(
                child: TabBarView(
                    controller: _tabControllerEmotions,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [emojis(), gifs()])),
          ],
        ));
  }

  Widget emojis() {
    return EmojiPicker(
      textEditingController: _chatController,
      config: Config(
        columns: 7,
        emojiSizeMax: 30 * (Platform.isIOS ? 1.30 : 1.0),
        verticalSpacing: 0,
        horizontalSpacing: 0,
        gridPadding: EdgeInsets.zero,
        initCategory: Category.RECENT,
        bgColor: Colors.transparent,
        indicatorColor: cBlue,
        iconColor: cGrey,
        iconColorSelected: cBlue,
        enableSkinTones: true,
        showRecentsTab: true,
        recentsLimit: 28,
        replaceEmojiOnLimitExceed: true,
        noRecents: const NoRecentEmoji(),
        loadingIndicator: const SizedBox.shrink(),
        tabIndicatorAnimDuration: kTabScrollDuration,
        categoryIcons: const CategoryIcons(),
        buttonMode: ButtonMode.MATERIAL,
        checkPlatformCompatibility: true,
      ),
    );
  }

  Widget gifs() {
    return gifTrending != null
        ? ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 10.0),
            physics: const BouncingScrollPhysics(),
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 6,
                      backgroundColor: Theme.of(context).canvasColor,
                      foregroundColor: cBlue,
                      shadowColor: Colors.transparent,
                      side: const BorderSide(width: 1.0, color: cGrey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      )),
                  onPressed: () async {
                    setState(() {
                      _openBottomSheetGif = true;
                    });
                    await _showBarBottomSheetSearchGif(context);
                    await Future.delayed(const Duration(milliseconds: 250));
                    if (_searchGifController.text.isNotEmpty) {
                      _searchGifController.clear();
                    }
                    setState(() {
                      _openBottomSheetGif = false;
                    });
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: cGrey),
                      const SizedBox(width: 15.0),
                      Expanded(
                          child: Text("Rechercher dans Giphy",
                              style: textStyleCustomBold(cGrey, 16),
                              textScaleFactor: 1.0))
                    ],
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      size: 30,
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      "À la une",
                      style: textStyleCustomBold(
                          Theme.of(context).brightness == Brightness.light
                              ? cBlack
                              : cWhite,
                          18),
                      textScaleFactor: 1.0,
                    )
                  ],
                ),
              ),
              GridView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 200),
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: gifTrending!.data.length,
                  itemBuilder: ((context, index) {
                    var gif = gifTrending!.data[index];
                    return GestureDetector(
                      onTap: () {
                        //send message on click gif => url gif and type: "gif"
                        print(gif.images.original!.url);
                        ref
                            .read(showEmotionsNotifierProvider.notifier)
                            .updateShowEmotions(false);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: cGrey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(color: cGrey)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              gif.images.original!.url!,
                              headers: const {'accept': 'image/*'},
                              filterQuality: FilterQuality.low,
                              fit: BoxFit.cover,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: cBlue,
                                    value: loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                .cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 2.0,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(Icons.error_outline,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? cBlack
                                          : cWhite,
                                      size: 33),
                                );
                              },
                            )),
                      ),
                    );
                  }))
            ],
          )
        : const Center(
            child: SizedBox(
              height: 25.0,
              width: 25.0,
              child: CircularProgressIndicator(
                color: cBlue,
                strokeWidth: 1.0,
              ),
            ),
          );
  }
}
