import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;

import 'package:age_calculator/age_calculator.dart';
import 'package:colorful_safe_area/colorful_safe_area.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart' as emoji;
import 'package:flag/flag_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:myyoukounkoun/components/indicator_typing_component.dart';
import 'package:myyoukounkoun/libraries/env_config_lib.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/components/no_recent_emoji.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/message_model.dart';
import 'package:myyoukounkoun/providers/chat_details_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/providers/visible_keyboard_app_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

import '../../models/user_model.dart';

class ChatDetails extends ConsumerStatefulWidget {
  final UserModel user;
  final bool openWithModal;
  final ConversationModel conversation;

  const ChatDetails(
      {Key? key,
      required this.user,
      required this.openWithModal,
      required this.conversation})
      : super(key: key);

  @override
  ChatDetailsState createState() => ChatDetailsState();
}

class ChatDetailsState extends ConsumerState<ChatDetails>
    with SingleTickerProviderStateMixin {
  AppBar appBar = AppBar();
  bool _isKeyboard = false;

  late ScrollController _scrollChatController;
  bool _scrollDown = false;

  late TextEditingController _chatController, _searchGifController;
  late FocusNode _chatFocusNode, _searchGifFocusNode;
  bool toolsStayHide = true;
  bool showEmotions = false;
  bool showPictures = false;
  bool startAudio = false;

  List<MessageModel> messagesUsers = [];
  List<MessageModel> messagesMediasUsers = [];

  GlobalKey keyChatField = GlobalKey();

  late TabController _tabControllerEmotions;
  bool _emojisCanBuild = false;

  GiphyClient gif = GiphyClient(
      apiKey: EnvironmentConfigLib().getEnvironmentConfigKeyApiGiphy);
  GiphyCollection? gifTrending;

  bool _openBottomSheetGif = false;
  GiphyCollection? searchGifsResults;
  String currentSearchGifs = "";
  Timer? _timer;

  late ConversationModel _currentConversation;

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

    //Bien vérifier que la logique de timestamps fonctionnent bien par rapport au grouped list view
    messages.sort(
        (a, b) => int.parse(a.timestamp).compareTo(int.parse(b.timestamp)));

    return messages;
  }

  Future _showBarBottomSheetSearchGif(BuildContext context) async {
    return showBarModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        barrierColor: Colors.black.withOpacity(0.5),
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
                              height: 45.0,
                              child: TextField(
                                minLines: 1,
                                maxLines: 1,
                                autofocus: true,
                                controller: _searchGifController,
                                focusNode: _searchGifFocusNode,
                                showCursor: true,
                                cursorColor: _currentConversation
                                        .themeConv.isEmpty
                                    ? Color.lerp(const Color(0xFF4284C4),
                                        const Color(0xFF00A9BC), 0.5)
                                    : Color.lerp(
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[0]),
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[1]),
                                        0.5),
                                textInputAction: TextInputAction.search,
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    MediaQuery.of(context).textScaler.scale(14)),
                                decoration: InputDecoration(
                                  fillColor: Theme.of(context).canvasColor,
                                  filled: true,
                                  contentPadding:
                                      const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                  hintText: AppLocalization.of(context).translate("chat_details_screen", "search_giphy_title"),
                                  hintStyle: textStyleCustomBold(
                                      cGrey,
                                      MediaQuery.of(context).textScaler.scale(14)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: _searchGifFocusNode.hasFocus
                                            ? _currentConversation
                                                    .themeConv.isEmpty
                                                ? Color.lerp(
                                                    const Color(0xFF4284C4),
                                                    const Color(0xFF00A9BC),
                                                    0.5)!
                                                : Color.lerp(
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[0]),
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[1]),
                                                    0.5)!
                                            : cGrey,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: _searchGifFocusNode.hasFocus
                                            ? _currentConversation
                                                    .themeConv.isEmpty
                                                ? Color.lerp(
                                                    const Color(0xFF4284C4),
                                                    const Color(0xFF00A9BC),
                                                    0.5)!
                                                : Color.lerp(
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[0]),
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[1]),
                                                    0.5)!
                                            : cGrey,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: _searchGifFocusNode.hasFocus
                                            ? _currentConversation
                                                    .themeConv.isEmpty
                                                ? Color.lerp(
                                                    const Color(0xFF4284C4),
                                                    const Color(0xFF00A9BC),
                                                    0.5)!
                                                : Color.lerp(
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[0]),
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[1]),
                                                    0.5)!
                                            : cGrey,
                                      ),
                                      borderRadius:
                                          BorderRadius.circular(10.0)),
                                  focusedErrorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                        width: 2.0,
                                        color: _searchGifFocusNode.hasFocus
                                            ? _currentConversation
                                                    .themeConv.isEmpty
                                                ? Color.lerp(
                                                    const Color(0xFF4284C4),
                                                    const Color(0xFF00A9BC),
                                                    0.5)!
                                                : Color.lerp(
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[0]),
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[1]),
                                                    0.5)!
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
                                                ? _currentConversation
                                                        .themeConv.isEmpty
                                                    ? Color.lerp(
                                                        const Color(0xFF4284C4),
                                                        const Color(0xFF00A9BC),
                                                        0.5)
                                                    : Color.lerp(
                                                        Helpers.stringToColor(
                                                            _currentConversation
                                                                .themeConv[0]),
                                                        Helpers.stringToColor(
                                                            _currentConversation
                                                                .themeConv[1]),
                                                        0.5)
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
                                        AppLocalization.of(context).translate("chat_details_screen", "search_giphy_content"),
                                        style: textStyleCustomBold(
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? cBlack
                                                : cWhite,
                                            14),
                                        textAlign: TextAlign.center,
                                        textScaler: const TextScaler.linear(1.0))
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
                                          textScaler: const TextScaler.linear(1.0),
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
                                               AppLocalization.of(context).translate("chat_details_screen", "no_results_giphy"),
                                                style: textStyleCustomMedium(
                                                    Theme.of(context)
                                                                .brightness ==
                                                            Brightness.light
                                                        ? cBlack
                                                        : cWhite,
                                                    14),
                                                textAlign: TextAlign.center,
                                                textScaler: const TextScaler.linear(1.0))
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
                                              ref
                                                  .read(
                                                      showEmotionsNotifierProvider
                                                          .notifier)
                                                  .updateShowEmotions(false);
                                            },
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .canvasColor
                                                      .withOpacity(0.2),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0)),
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
                                                  fit: BoxFit.fill,
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
                                                        color: _currentConversation
                                                                .themeConv
                                                                .isEmpty
                                                            ? Color.lerp(
                                                                const Color(
                                                                    0xFF4284C4),
                                                                const Color(
                                                                    0xFF00A9BC),
                                                                0.5)
                                                            : Color.lerp(
                                                                Helpers.stringToColor(
                                                                    _currentConversation
                                                                            .themeConv[
                                                                        0]),
                                                                Helpers.stringToColor(
                                                                    _currentConversation
                                                                        .themeConv[1]),
                                                                0.5),
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

  Future<File?> pickImage(ImageSource src) async {
    XFile? image;
    File? finalFile;
    try {
      if (Platform.isIOS) {
        image = await ImagePicker()
            .pickImage(source: src, maxHeight: 1080, maxWidth: 1080);
      } else {
        image = await ImagePicker().pickImage(
            source: src, imageQuality: 75, maxHeight: 1080, maxWidth: 1080);
      }

      if (image != null) {
        int random = math.Random().nextInt(1000000000);
        final tempDir = await getTemporaryDirectory();
        String nameImg =
            'img_${random}_chat_${ref.read(userNotifierProvider).id}_${widget.user.id}.jpg';

        final decodeImg = img.decodeImage(File(image.path).readAsBytesSync());
        finalFile = File('${tempDir.path}/$nameImg')
          ..writeAsBytesSync(img.encodeJpg(decodeImg!));
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    return finalFile;
  }

  @override
  void initState() {
    super.initState();

    messagesUsers = getListMessagesUsers();
    for (MessageModel message in messagesUsers) {
      if (message.type != "text") {
        messagesMediasUsers.add(message);
      }
    }

    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        ref
            .read(currentChatUserIdNotifierProvider.notifier)
            .setChatUserId(widget.user.id);
        ref
            .read(currentConvNotifierProvider.notifier)
            .setCurrentConv(widget.conversation);
        ref.read(toolsStayHideNotifierProvider.notifier).clearStayHide();
        ref.read(showEmotionsNotifierProvider.notifier).clearShowEmotions();
        ref.read(showPicturesNotifierProvider.notifier).clearShowPictures();
        setState(() {
          _emojisCanBuild = true;
        });
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
    _currentConversation = ref.watch(currentConvNotifierProvider);
    _isKeyboard = ref.watch(visibleKeyboardAppNotifierProvider);
    toolsStayHide = ref.watch(toolsStayHideNotifierProvider);
    showEmotions = ref.watch(showEmotionsNotifierProvider);
    gifTrending = ref.watch(gifTrendingsNotifierProvider);
    showPictures = ref.watch(showPicturesNotifierProvider);

    return GestureDetector(
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
        if (showPictures) {
          ref
              .read(showPicturesNotifierProvider.notifier)
              .updateShowPictures(false);
        }
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        resizeToAvoidBottomInset: _openBottomSheetGif ? false : true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: _customAppBarDetailsChat(),
        body: AnnotatedRegion<SystemUiOverlayStyle>(
          value: Helpers.uiOverlayApp(context),
          child: Stack(
            children: [
              messages(),
              ColorfulSafeArea(
                color: Theme.of(context).scaffoldBackgroundColor,
                top: false,
                left: false,
                right: false,
                bottom: true,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      opacity: _scrollDown ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      child: GestureDetector(
                        onTap: () => _scrollToDownChat(),
                        child: Container(
                          height: 35.0,
                          width: 35.0,
                          decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        _currentConversation.themeConv.isEmpty
                                            ? Color.lerp(
                                                const Color(0xFF4284C4),
                                                const Color(0xFF00A9BC),
                                                0.5)!
                                            : Color.lerp(
                                                Helpers.stringToColor(
                                                    _currentConversation
                                                        .themeConv[0]),
                                                Helpers.stringToColor(
                                                    _currentConversation
                                                        .themeConv[1]),
                                                0.5)!,
                                    blurRadius: 3)
                              ]),
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.arrow_downward,
                            color: _currentConversation.themeConv.isEmpty
                                ? Color.lerp(const Color(0xFF4284C4),
                                    const Color(0xFF00A9BC), 0.5)!
                                : Color.lerp(
                                    Helpers.stringToColor(
                                        _currentConversation.themeConv[0]),
                                    Helpers.stringToColor(
                                        _currentConversation.themeConv[1]),
                                    0.5)!,
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    writeMessage(),
                    Offstage(
                      offstage: !showEmotions,
                      child: emotionsCard(),
                    ),
                    Offstage(
                      offstage: !showPictures,
                      child: picturesCard(),
                    )
                  ],
                ),
              )
            ],
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
                          navAuthKey.currentState!.pushNamed(informationsConv,
                              arguments: [widget.user]);
                        },
                        child: Row(
                          children: [
                            widget.user.profilePictureUrl.trim() == ""
                                ? Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: _currentConversation
                                                  .themeConv.isEmpty
                                              ? Color.lerp(
                                                  const Color(0xFF4284C4),
                                                  const Color(0xFF00A9BC),
                                                  0.5)!
                                              : Color.lerp(
                                                  Helpers.stringToColor(
                                                      _currentConversation
                                                          .themeConv[0]),
                                                  Helpers.stringToColor(
                                                      _currentConversation
                                                          .themeConv[1]),
                                                  0.5)!),
                                      color: cGrey.withOpacity(0.2),
                                    ),
                                    child: Icon(Icons.person,
                                        color: _currentConversation
                                                .themeConv.isEmpty
                                            ? Color.lerp(
                                                const Color(0xFF4284C4),
                                                const Color(0xFF00A9BC),
                                                0.5)
                                            : Color.lerp(
                                                Helpers.stringToColor(
                                                    _currentConversation
                                                        .themeConv[0]),
                                                Helpers.stringToColor(
                                                    _currentConversation
                                                        .themeConv[1]),
                                                0.5),
                                        size: 23),
                                  )
                                : CachedNetworkImageCustom(
                                    profilePictureUrl:
                                        widget.user.profilePictureUrl,
                                    heightContainer: 45,
                                    widthContainer: 45,
                                    iconSize: 23,
                                    colorTheme:
                                        _currentConversation.themeConv.isEmpty
                                            ? Color.lerp(
                                                const Color(0xFF4284C4),
                                                const Color(0xFF00A9BC),
                                                0.5)
                                            : Color.lerp(
                                                Helpers.stringToColor(
                                                    _currentConversation
                                                        .themeConv[0]),
                                                Helpers.stringToColor(
                                                    _currentConversation
                                                        .themeConv[1]),
                                                0.5)),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Expanded(
                              child: Text(
                                widget.user.pseudo,
                                style: textStyleCustomBold(
                                    Helpers.uiApp(context), 20),
                                textScaler: const TextScaler.linear(1.0),
                                overflow: TextOverflow.ellipsis,
                              ),
                            )
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
    return LayoutBuilder(builder: (_, constraints) {
      return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              10.0,
              MediaQuery.of(context).padding.top +
                  appBar.preferredSize.height +
                  20.0,
              10.0,
              (showEmotions && !_isKeyboard) ||
                      (showEmotions && _openBottomSheetGif) ||
                      (showPictures && !_isKeyboard)
                  ? MediaQuery.of(context).padding.bottom +
                      70.0 +
                      (MediaQuery.of(context).size.height / 2.5)
                  : MediaQuery.of(context).padding.bottom + 70.0),
          controller: _scrollChatController,
          reverse: true,
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          child: ConstrainedBox(
            constraints: BoxConstraints(
                minHeight: (showEmotions && !_isKeyboard) ||
                        (showEmotions && _openBottomSheetGif) ||
                        (showPictures && !_isKeyboard)
                    ? constraints.maxHeight -
                        (MediaQuery.of(context).padding.top +
                            appBar.preferredSize.height +
                            20.0 +
                            MediaQuery.of(context).padding.bottom +
                            70.0 +
                            (MediaQuery.of(context).size.height / 2.5))
                    : constraints.maxHeight -
                        (MediaQuery.of(context).padding.top +
                            appBar.preferredSize.height +
                            20.0 +
                            MediaQuery.of(context).padding.bottom +
                            70.0)),
            child: Column(
              children: [
                seeProfile(),
                const SizedBox(height: 20.0),
                listMessages(),
                //add logic listener user write or not real time
                TypingIndicator(
                  showIndicator: true,
                  bubbleColor: Theme.of(context).canvasColor,
                  flashingCircleBrightColor:
                      _currentConversation.themeConv.isEmpty
                          ? Color.lerp(const Color(0xFF4284C4),
                              const Color(0xFF00A9BC), 0.5)!
                          : Color.lerp(
                              Helpers.stringToColor(
                                  _currentConversation.themeConv[0]),
                              Helpers.stringToColor(
                                  _currentConversation.themeConv[1]),
                              0.5)!,
                  flashingCircleDarkColor:
                      Theme.of(context).scaffoldBackgroundColor,
                  colorThemeConv: _currentConversation.themeConv.isEmpty
                      ? Color.lerp(const Color(0xFF4284C4),
                          const Color(0xFF00A9BC), 0.5)!
                      : Color.lerp(
                          Helpers.stringToColor(
                              _currentConversation.themeConv[0]),
                          Helpers.stringToColor(
                              _currentConversation.themeConv[1]),
                          0.5)!,
                  user: widget.user,
                ),
              ],
            ),
          ));
    });
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
                    border: Border.all(
                        color: _currentConversation.themeConv.isEmpty
                            ? Color.lerp(const Color(0xFF4284C4),
                                const Color(0xFF00A9BC), 0.5)!
                            : Color.lerp(
                                Helpers.stringToColor(
                                    _currentConversation.themeConv[0]),
                                Helpers.stringToColor(
                                    _currentConversation.themeConv[1]),
                                0.5)!),
                    color: cGrey.withOpacity(0.2),
                  ),
                  child: Icon(Icons.person,
                      color: _currentConversation.themeConv.isEmpty
                          ? Color.lerp(const Color(0xFF4284C4),
                              const Color(0xFF00A9BC), 0.5)
                          : Color.lerp(
                              Helpers.stringToColor(
                                  _currentConversation.themeConv[0]),
                              Helpers.stringToColor(
                                  _currentConversation.themeConv[1]),
                              0.5),
                      size: 55),
                )
              : CachedNetworkImageCustom(
                  profilePictureUrl: widget.user.profilePictureUrl,
                  heightContainer: 145,
                  widthContainer: 145,
                  iconSize: 55,
                  colorTheme: _currentConversation.themeConv.isEmpty
                      ? Color.lerp(
                          const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)
                      : Color.lerp(
                          Helpers.stringToColor(
                              _currentConversation.themeConv[0]),
                          Helpers.stringToColor(
                              _currentConversation.themeConv[1]),
                          0.5)),
          const SizedBox(
            height: 15.0,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.user.pseudo,
                style: textStyleCustomBold(Helpers.uiApp(context), 23),
                textScaler: const TextScaler.linear(1.0),
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
                  color: Helpers.uiApp(context)),
              Text(
                " - ",
                style: textStyleCustomBold(Helpers.uiApp(context), 18),
              ),
              Text(
                  AgeCalculator.age(Helpers.convertStringToDateTime(
                              widget.user.birthday))
                          .years
                          .toString() +
                      AppLocalization.of(context)
                          .translate("user_profile_screen", "years_old"),
                  style: textStyleCustomBold(Helpers.uiApp(context), 18.0))
            ],
          ),
          const SizedBox(height: 10.0),
          SizedBox(
              height: 30.0,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: _currentConversation.themeConv.isEmpty
                        ? Color.lerp(const Color(0xFF4284C4),
                            const Color(0xFF00A9BC), 0.5)
                        : Color.lerp(
                            Helpers.stringToColor(
                                _currentConversation.themeConv[0]),
                            Helpers.stringToColor(
                                _currentConversation.themeConv[1]),
                            0.5),
                    foregroundColor: Colors.white,
                    shadowColor: Colors.transparent,
                  ),
                  onPressed: () {
                    navAuthKey.currentState!.pushNamed(userProfile,
                        arguments: [widget.user, false]);
                  },
                  child: Text(AppLocalization.of(context).translate("chat_details_screen", "see_profile"),
                      style: textStyleCustomMedium(Helpers.uiApp(context), 18),
                      textScaler: const TextScaler.linear(1.0))))
        ],
      ),
    );
  }

  Widget listMessages() {
    return GroupedListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      elements: messagesUsers,
      groupBy: (MessageModel message) => Helpers.formatDateDayWeek(
          int.parse(message.timestamp),
          ref.read(localeLanguageNotifierProvider).languageCode,
          true),
      groupComparator: (String value1, String value2) {
        final timestamp1 = (DateFormat('EEE d MMM',
                    ref.read(localeLanguageNotifierProvider).languageCode)
                .parse(value1))
            .millisecondsSinceEpoch;
        final timestamp2 = (DateFormat('EEE d MMM',
                    ref.read(localeLanguageNotifierProvider).languageCode)
                .parse(value2))
            .millisecondsSinceEpoch;
        return timestamp2.compareTo(timestamp1);
      },
      // itemComparator: (MessageModel element1, MessageModel element2) {
      //   final date1 = DateTime.fromMillisecondsSinceEpoch(int.parse(element1.timestamp) * 1000).toLocal();
      //   final date2 = DateTime.fromMillisecondsSinceEpoch(int.parse(element2.timestamp) * 1000).toLocal();
      //   return date2.compareTo(date1);
      // },
      order: GroupedListOrder.DESC,
      sort: false,
      groupSeparatorBuilder: (String value) {
        return Center(
          child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(7.5),
                  child: Text(value,
                      style: textStyleCustomMedium(
                          _currentConversation.themeConv.isEmpty
                              ? Color.lerp(const Color(0xFF4284C4),
                                  const Color(0xFF00A9BC), 0.5)!
                              : Color.lerp(
                                  Helpers.stringToColor(
                                      _currentConversation.themeConv[0]),
                                  Helpers.stringToColor(
                                      _currentConversation.themeConv[1]),
                                  0.5)!,
                          14),
                      textScaler: const TextScaler.linear(1.0)),
                ),
              )),
        );
      },
      itemBuilder: (context, MessageModel message) {
        int index = messagesUsers.indexOf(message);

        return messageItem(messagesUsers, message, index);
      },
    );
  }

  Widget messageItem(
      List<MessageModel> messagesUsers, MessageModel message, int index) {
    return message.idSender != ref.read(userNotifierProvider).id
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
                                border: Border.all(
                                    color:
                                        _currentConversation.themeConv.isEmpty
                                            ? Color.lerp(
                                                const Color(0xFF4284C4),
                                                const Color(0xFF00A9BC),
                                                0.5)!
                                            : Color.lerp(
                                                Helpers.stringToColor(
                                                    _currentConversation
                                                        .themeConv[0]),
                                                Helpers.stringToColor(
                                                    _currentConversation
                                                        .themeConv[1]),
                                                0.5)!),
                                color: cGrey.withOpacity(0.2),
                              ),
                              child: Icon(Icons.person,
                                  color: _currentConversation.themeConv.isEmpty
                                      ? Color.lerp(const Color(0xFF4284C4),
                                          const Color(0xFF00A9BC), 0.5)
                                      : Color.lerp(
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[0]),
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[1]),
                                          0.5),
                                  size: 15),
                            )
                          : CachedNetworkImageCustom(
                              profilePictureUrl: widget.user.profilePictureUrl,
                              heightContainer: 25,
                              widthContainer: 25,
                              iconSize: 15,
                              colorTheme: _currentConversation.themeConv.isEmpty
                                  ? Color.lerp(const Color(0xFF4284C4),
                                      const Color(0xFF00A9BC), 0.5)
                                  : Color.lerp(
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[0]),
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[1]),
                                      0.5)),
                    ),
                  typeMessage(message, index),
                ],
              ),
            ],
          )
        : Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                typeMessage(message, index),
                if (message.isRead && messagesUsers.length == index + 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(AppLocalization.of(context).translate("chat_details_screen", "message_seen"),
                        style: textStyleCustomMedium(cGrey, 12),
                        textScaler: const TextScaler.linear(1.0)),
                  )
              ],
            ));
  }

  Widget typeMessage(MessageModel message, int index) {
    switch (message.type) {
      case "text":
        if (message.idSender != ref.read(userNotifierProvider).id) {
          return Container(
              constraints: BoxConstraints(
                  minWidth: 0,
                  maxWidth: MediaQuery.of(context).size.width / 1.5),
              margin: EdgeInsets.symmetric(
                  horizontal: messagesUsers.length != index + 1 &&
                          messagesUsers[index + 1].idSender !=
                              ref.read(userNotifierProvider).id
                      ? 35.0
                      : 10.0,
                  vertical: 5.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: BorderRadius.circular(10.0)),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: textStyleCustomRegular(Helpers.uiApp(context), 14),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    const SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        Helpers.formatDateHoursMinutes(
                            int.parse(message.timestamp),
                            ref
                                .read(localeLanguageNotifierProvider)
                                .languageCode),
                        style: textStyleCustomBold(Helpers.uiApp(context), 10),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    )
                  ],
                ),
              ));
        } else {
          return Container(
              constraints: BoxConstraints(
                  minWidth: 0,
                  maxWidth: MediaQuery.of(context).size.width / 1.5),
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: _currentConversation.themeConv.isEmpty
                        ? const [Color(0xFF4284C4), Color(0xFF00A9BC)]
                        : [
                            Helpers.stringToColor(
                                _currentConversation.themeConv[0]),
                            Helpers.stringToColor(
                                _currentConversation.themeConv[1])
                          ],
                  ),
                  borderRadius: BorderRadius.circular(10.0)),
              child: IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.message,
                      style: textStyleCustomRegular(Helpers.uiApp(context), 14),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    const SizedBox(height: 5.0),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        Helpers.formatDateHoursMinutes(
                            int.parse(message.timestamp),
                            ref
                                .read(localeLanguageNotifierProvider)
                                .languageCode),
                        style: textStyleCustomBold(Helpers.uiApp(context), 10),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    )
                  ],
                ),
              ));
        }
      case "image":
        if (message.idSender != ref.read(userNotifierProvider).id) {
          return GestureDetector(
            onTap: () => navAuthKey.currentState!
                .pushNamed(carousselPictures, arguments: [
              messagesMediasUsers,
              message,
              widget.user,
              "picture chat ${message.message}",
              _currentConversation.themeConv.isEmpty
                  ? Color.lerp(
                      const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)
                  : Color.lerp(
                      Helpers.stringToColor(_currentConversation.themeConv[0]),
                      Helpers.stringToColor(_currentConversation.themeConv[1]),
                      0.5)
            ]),
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
                  color: Theme.of(context).canvasColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  children: [
                    Hero(
                      tag: "picture chat ${message.message}",
                      transitionOnUserGestures: true,
                      flightShuttleBuilder: (flightContext, animation,
                          flightDirection, fromHeroContext, toHeroContext) {
                        return Image.network(
                          message.message,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                color: _currentConversation.themeConv.isEmpty
                                    ? Color.lerp(const Color(0xFF4284C4),
                                        const Color(0xFF00A9BC), 0.5)
                                    : Color.lerp(
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[0]),
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[1]),
                                        0.5),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
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
                        );
                      },
                      child: Image.network(
                        message.message,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              color: _currentConversation.themeConv.isEmpty
                                  ? Color.lerp(const Color(0xFF4284C4),
                                      const Color(0xFF00A9BC), 0.5)
                                  : Color.lerp(
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[0]),
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[1]),
                                      0.5),
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
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Text(
                        Helpers.formatDateHoursMinutes(
                            int.parse(message.timestamp),
                            ref
                                .read(localeLanguageNotifierProvider)
                                .languageCode),
                        style: textStyleCustomBold(Helpers.uiApp(context), 10),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        } else {
          return GestureDetector(
            onTap: () => navAuthKey.currentState!
                .pushNamed(carousselPictures, arguments: [
              messagesMediasUsers,
              message,
              widget.user,
              "picture chat ${message.message}",
              _currentConversation.themeConv.isEmpty
                  ? Color.lerp(
                      const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)
                  : Color.lerp(
                      Helpers.stringToColor(_currentConversation.themeConv[0]),
                      Helpers.stringToColor(_currentConversation.themeConv[1]),
                      0.5)
            ]),
            child: Container(
              height: 200,
              width: 150,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Stack(
                  children: [
                    Hero(
                      tag: "picture chat ${message.message}",
                      transitionOnUserGestures: true,
                      flightShuttleBuilder: (flightContext, animation,
                          flightDirection, fromHeroContext, toHeroContext) {
                        return Image.network(
                          message.message,
                          fit: BoxFit.cover,
                          height: double.infinity,
                          width: double.infinity,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                color: _currentConversation.themeConv.isEmpty
                                    ? Color.lerp(const Color(0xFF4284C4),
                                        const Color(0xFF00A9BC), 0.5)
                                    : Color.lerp(
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[0]),
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[1]),
                                        0.5),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
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
                        );
                      },
                      child: Image.network(
                        message.message,
                        fit: BoxFit.cover,
                        height: double.infinity,
                        width: double.infinity,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              color: _currentConversation.themeConv.isEmpty
                                  ? Color.lerp(const Color(0xFF4284C4),
                                      const Color(0xFF00A9BC), 0.5)
                                  : Color.lerp(
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[0]),
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[1]),
                                      0.5),
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
                    Positioned(
                      bottom: 5,
                      right: 5,
                      child: Text(
                        Helpers.formatDateHoursMinutes(
                            int.parse(message.timestamp),
                            ref
                                .read(localeLanguageNotifierProvider)
                                .languageCode),
                        style: textStyleCustomBold(Helpers.uiApp(context), 10),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }
      case "gif":
        if (message.idSender != ref.read(userNotifierProvider).id) {
          return GestureDetector(
            onTap: () => navAuthKey.currentState!
                .pushNamed(carousselPictures, arguments: [
              messagesMediasUsers,
              message,
              widget.user,
              "gif chat ${message.message}",
              _currentConversation.themeConv.isEmpty
                  ? Color.lerp(
                      const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)
                  : Color.lerp(
                      Helpers.stringToColor(_currentConversation.themeConv[0]),
                      Helpers.stringToColor(_currentConversation.themeConv[1]),
                      0.5)
            ]),
            child: Container(
              height: 200,
              width: 150,
              margin:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
              decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Stack(
                    children: [
                      Hero(
                        tag: "gif chat ${message.message}",
                        transitionOnUserGestures: true,
                        flightShuttleBuilder: (flightContext, animation,
                            flightDirection, fromHeroContext, toHeroContext) {
                          return Image.network(
                            message.message,
                            headers: const {'accept': 'image/*'},
                            filterQuality: FilterQuality.low,
                            fit: BoxFit.fill,
                            height: double.infinity,
                            width: double.infinity,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  color: _currentConversation.themeConv.isEmpty
                                      ? Color.lerp(const Color(0xFF4284C4),
                                          const Color(0xFF00A9BC), 0.5)
                                      : Color.lerp(
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[0]),
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[1]),
                                          0.5),
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
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
                                    color: Helpers.uiApp(context), size: 33),
                              );
                            },
                          );
                        },
                        child: Image.network(
                          message.message,
                          headers: const {'accept': 'image/*'},
                          filterQuality: FilterQuality.low,
                          fit: BoxFit.fill,
                          height: double.infinity,
                          width: double.infinity,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                color: _currentConversation.themeConv.isEmpty
                                    ? Color.lerp(const Color(0xFF4284C4),
                                        const Color(0xFF00A9BC), 0.5)
                                    : Color.lerp(
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[0]),
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[1]),
                                        0.5),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
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
                                  color: Helpers.uiApp(context), size: 33),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Text(
                          Helpers.formatDateHoursMinutes(
                              int.parse(message.timestamp),
                              ref
                                  .read(localeLanguageNotifierProvider)
                                  .languageCode),
                          style:
                              textStyleCustomBold(Helpers.uiApp(context), 10),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      )
                    ],
                  )),
            ),
          );
        } else {
          return GestureDetector(
            onTap: () => navAuthKey.currentState!
                .pushNamed(carousselPictures, arguments: [
              messagesMediasUsers,
              message,
              widget.user,
              "gif chat ${message.message}",
              _currentConversation.themeConv.isEmpty
                  ? Color.lerp(
                      const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)
                  : Color.lerp(
                      Helpers.stringToColor(_currentConversation.themeConv[0]),
                      Helpers.stringToColor(_currentConversation.themeConv[1]),
                      0.5)
            ]),
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
                  color: Theme.of(context).canvasColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10.0)),
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Stack(
                    children: [
                      Hero(
                        tag: "gif chat ${message.message}",
                        transitionOnUserGestures: true,
                        flightShuttleBuilder: (flightContext, animation,
                            flightDirection, fromHeroContext, toHeroContext) {
                          return Image.network(
                            message.message,
                            headers: const {'accept': 'image/*'},
                            filterQuality: FilterQuality.low,
                            fit: BoxFit.fill,
                            height: double.infinity,
                            width: double.infinity,
                            loadingBuilder: (BuildContext context, Widget child,
                                ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }
                              return Center(
                                child: CircularProgressIndicator(
                                  color: _currentConversation.themeConv.isEmpty
                                      ? Color.lerp(const Color(0xFF4284C4),
                                          const Color(0xFF00A9BC), 0.5)
                                      : Color.lerp(
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[0]),
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[1]),
                                          0.5),
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
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
                                    color: Helpers.uiApp(context), size: 33),
                              );
                            },
                          );
                        },
                        child: Image.network(
                          message.message,
                          headers: const {'accept': 'image/*'},
                          filterQuality: FilterQuality.low,
                          fit: BoxFit.fill,
                          height: double.infinity,
                          width: double.infinity,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                color: _currentConversation.themeConv.isEmpty
                                    ? Color.lerp(const Color(0xFF4284C4),
                                        const Color(0xFF00A9BC), 0.5)
                                    : Color.lerp(
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[0]),
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[1]),
                                        0.5),
                                value: loadingProgress.expectedTotalBytes !=
                                        null
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
                                  color: Helpers.uiApp(context), size: 33),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: Text(
                          Helpers.formatDateHoursMinutes(
                              int.parse(message.timestamp),
                              ref
                                  .read(localeLanguageNotifierProvider)
                                  .languageCode),
                          style:
                              textStyleCustomBold(Helpers.uiApp(context), 10),
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      )
                    ],
                  )),
            ),
          );
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
                            height: 35,
                            width: 35,
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_ios,
                              color: cGrey,
                              size: 20,
                            ),
                          ),
                        )
                      : Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (showEmotions) {
                                  ref
                                      .read(
                                          showEmotionsNotifierProvider.notifier)
                                      .updateShowEmotions(false);
                                }
                                if (!_chatFocusNode.hasFocus) {
                                  _chatFocusNode.requestFocus();
                                }
                                ref
                                    .read(showPicturesNotifierProvider.notifier)
                                    .updateShowPictures(!showPictures);
                              },
                              child: Container(
                                height: 35.0,
                                width: 35.0,
                                margin: const EdgeInsets.only(
                                    left: 10.0, right: 7.5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      if (showPictures)
                                        BoxShadow(
                                            color: _currentConversation
                                                    .themeConv.isEmpty
                                                ? Color.lerp(
                                                    const Color(0xFF4284C4),
                                                    const Color(0xFF00A9BC),
                                                    0.5)!
                                                : Color.lerp(
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[0]),
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[1]),
                                                    0.5)!,
                                            blurRadius: 3)
                                    ]),
                                child: Icon(
                                  showPictures ? Icons.clear : Icons.add,
                                  color: showPictures
                                      ? _currentConversation.themeConv.isEmpty
                                          ? Color.lerp(const Color(0xFF4284C4),
                                              const Color(0xFF00A9BC), 0.5)
                                          : Color.lerp(
                                              Helpers.stringToColor(
                                                  _currentConversation
                                                      .themeConv[0]),
                                              Helpers.stringToColor(
                                                  _currentConversation
                                                      .themeConv[1]),
                                              0.5)
                                      : cGrey,
                                  size: showPictures ? 25 : 30,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onLongPressStart: (details) async {
                                setState(() {
                                  startAudio = true;
                                });
                                do {
                                  print('long pressing');
                                  await Future.delayed(
                                      const Duration(seconds: 1));
                                } while (startAudio);
                              },
                              onLongPressEnd: (details) {
                                setState(() {
                                  startAudio = false;
                                });
                                print("long pressed end");
                              },
                              child: Container(
                                height: 35,
                                width: 35,
                                margin: const EdgeInsets.only(
                                    left: 7.5, right: 10.0),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      if (startAudio)
                                        BoxShadow(
                                            color: _currentConversation
                                                    .themeConv.isEmpty
                                                ? Color.lerp(
                                                    const Color(0xFF4284C4),
                                                    const Color(0xFF00A9BC),
                                                    0.5)!
                                                : Color.lerp(
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[0]),
                                                    Helpers.stringToColor(
                                                        _currentConversation
                                                            .themeConv[1]),
                                                    0.5)!,
                                            blurRadius: 3)
                                    ]),
                                child: Icon(
                                  Icons.mic_rounded,
                                  color: startAudio
                                      ? _currentConversation.themeConv.isEmpty
                                          ? Color.lerp(const Color(0xFF4284C4),
                                              const Color(0xFF00A9BC), 0.5)
                                          : Color.lerp(
                                              Helpers.stringToColor(
                                                  _currentConversation
                                                      .themeConv[0]),
                                              Helpers.stringToColor(
                                                  _currentConversation
                                                      .themeConv[1]),
                                              0.5)
                                      : cGrey,
                                  size: 25,
                                ),
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
                        readOnly: showEmotions || showPictures ? true : false,
                        showCursor: true,
                        cursorColor: _currentConversation.themeConv.isEmpty
                            ? Color.lerp(const Color(0xFF4284C4),
                                const Color(0xFF00A9BC), 0.5)
                            : Color.lerp(
                                Helpers.stringToColor(
                                    _currentConversation.themeConv[0]),
                                Helpers.stringToColor(
                                    _currentConversation.themeConv[1]),
                                0.5),
                        textInputAction: TextInputAction.newline,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: textStyleCustomBold(Helpers.uiApp(context),
                            MediaQuery.of(context).textScaler.scale(12)),
                        decoration: InputDecoration(
                          fillColor: Theme.of(context).scaffoldBackgroundColor,
                          filled: true,
                          contentPadding:
                              const EdgeInsets.fromLTRB(12, 12, 12, 12),
                          hintText: AppLocalization.of(context).translate("chat_details_screen", "write_message"),
                          hintStyle: textStyleCustomBold(cGrey,
                              MediaQuery.of(context).textScaler.scale(12)),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.0,
                                color: _chatFocusNode.hasFocus
                                    ? _currentConversation.themeConv.isEmpty
                                        ? Color.lerp(const Color(0xFF4284C4),
                                            const Color(0xFF00A9BC), 0.5)!
                                        : Color.lerp(
                                            Helpers.stringToColor(
                                                _currentConversation
                                                    .themeConv[0]),
                                            Helpers.stringToColor(
                                                _currentConversation
                                                    .themeConv[1]),
                                            0.5)!
                                    : cGrey,
                              ),
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.0,
                                color: _chatFocusNode.hasFocus
                                    ? _currentConversation.themeConv.isEmpty
                                        ? Color.lerp(const Color(0xFF4284C4),
                                            const Color(0xFF00A9BC), 0.5)!
                                        : Color.lerp(
                                            Helpers.stringToColor(
                                                _currentConversation
                                                    .themeConv[0]),
                                            Helpers.stringToColor(
                                                _currentConversation
                                                    .themeConv[1]),
                                            0.5)!
                                    : cGrey,
                              ),
                              borderRadius: BorderRadius.circular(10.0)),
                          errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.0,
                                color: _chatFocusNode.hasFocus
                                    ? _currentConversation.themeConv.isEmpty
                                        ? Color.lerp(const Color(0xFF4284C4),
                                            const Color(0xFF00A9BC), 0.5)!
                                        : Color.lerp(
                                            Helpers.stringToColor(
                                                _currentConversation
                                                    .themeConv[0]),
                                            Helpers.stringToColor(
                                                _currentConversation
                                                    .themeConv[1]),
                                            0.5)!
                                    : cGrey,
                              ),
                              borderRadius: BorderRadius.circular(10.0)),
                          focusedErrorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                width: 2.0,
                                color: _chatFocusNode.hasFocus
                                    ? _currentConversation.themeConv.isEmpty
                                        ? Color.lerp(const Color(0xFF4284C4),
                                            const Color(0xFF00A9BC), 0.5)!
                                        : Color.lerp(
                                            Helpers.stringToColor(
                                                _currentConversation
                                                    .themeConv[0]),
                                            Helpers.stringToColor(
                                                _currentConversation
                                                    .themeConv[1]),
                                            0.5)!
                                    : cGrey,
                              ),
                              borderRadius: BorderRadius.circular(10.0)),
                          suffixIcon: GestureDetector(
                            onTap: () async {
                              if (showPictures) {
                                ref
                                    .read(showPicturesNotifierProvider.notifier)
                                    .updateShowPictures(false);
                              }
                              if (!_chatFocusNode.hasFocus) {
                                _chatFocusNode.requestFocus();
                              }
                              ref
                                  .read(showEmotionsNotifierProvider.notifier)
                                  .updateShowEmotions(!showEmotions);
                            },
                            child: Icon(
                              showEmotions
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions,
                              color: _chatFocusNode.hasFocus
                                  ? _currentConversation.themeConv.isEmpty
                                      ? Color.lerp(const Color(0xFF4284C4),
                                          const Color(0xFF00A9BC), 0.5)
                                      : Color.lerp(
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[0]),
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[1]),
                                          0.5)
                                  : cGrey,
                            ),
                          ),
                        ),
                        onTap: () {
                          if (_chatFocusNode.hasFocus && showEmotions) {
                            ref
                                .read(showEmotionsNotifierProvider.notifier)
                                .updateShowEmotions(false);
                          }
                          if (_chatFocusNode.hasFocus && showPictures) {
                            ref
                                .read(showPicturesNotifierProvider.notifier)
                                .updateShowPictures(false);
                          }
                        },
                      ),
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
                        if (showPictures) {
                          ref
                              .read(showPicturesNotifierProvider.notifier)
                              .updateShowPictures(false);
                        }
                      },
                      child: Container(
                        height: 35,
                        width: 35,
                        margin: const EdgeInsets.symmetric(horizontal: 10.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).scaffoldBackgroundColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: _currentConversation.themeConv.isEmpty
                                      ? Color.lerp(const Color(0xFF4284C4),
                                          const Color(0xFF00A9BC), 0.5)!
                                      : Color.lerp(
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[0]),
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[1]),
                                          0.5)!,
                                  blurRadius: 3)
                            ]),
                        child: Icon(
                          Icons.send,
                          color: _currentConversation.themeConv.isEmpty
                              ? Color.lerp(const Color(0xFF4284C4),
                                  const Color(0xFF00A9BC), 0.5)
                              : Color.lerp(
                                  Helpers.stringToColor(
                                      _currentConversation.themeConv[0]),
                                  Helpers.stringToColor(
                                      _currentConversation.themeConv[1]),
                                  0.5),
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
        height: (showEmotions && !_isKeyboard) ||
                (showEmotions && _openBottomSheetGif)
            ? MediaQuery.of(context).size.height / 2.5
            : 0,
        color: Theme.of(context).scaffoldBackgroundColor,
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
                  labelColor: Helpers.uiApp(context),
                  unselectedLabelColor: cGrey,
                  labelStyle: textStyleCustomBold(Helpers.uiApp(context), 16),
                  unselectedLabelStyle: textStyleCustomBold(cGrey, 16),
                  indicator: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: _currentConversation.themeConv.isEmpty
                                  ? Color.lerp(const Color(0xFF4284C4),
                                      const Color(0xFF00A9BC), 0.5)!
                                  : Color.lerp(
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[0]),
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[1]),
                                      0.5)!,
                              width: 2.0))),
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
    return _emojisCanBuild
        ? emoji.EmojiPicker(
            textEditingController: _chatController,
            config: emoji.Config(
              columns: 7,
              emojiSizeMax: 30 * (Platform.isIOS ? 1.30 : 1.0),
              verticalSpacing: 0,
              horizontalSpacing: 0,
              gridPadding: EdgeInsets.zero,
              initCategory: emoji.Category.RECENT,
              bgColor: Colors.transparent,
              indicatorColor: _currentConversation.themeConv.isEmpty
                  ? Color.lerp(
                      const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)!
                  : Color.lerp(
                      Helpers.stringToColor(_currentConversation.themeConv[0]),
                      Helpers.stringToColor(_currentConversation.themeConv[1]),
                      0.5)!,
              iconColor: cGrey,
              iconColorSelected: _currentConversation.themeConv.isEmpty
                  ? Color.lerp(
                      const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)!
                  : Color.lerp(
                      Helpers.stringToColor(_currentConversation.themeConv[0]),
                      Helpers.stringToColor(_currentConversation.themeConv[1]),
                      0.5)!,
              enableSkinTones: true,
              recentTabBehavior: emoji.RecentTabBehavior.RECENT,
              recentsLimit: 28,
              replaceEmojiOnLimitExceed: true,
              noRecents: const NoRecentEmoji(),
              loadingIndicator: const SizedBox.shrink(),
              tabIndicatorAnimDuration: kTabScrollDuration,
              categoryIcons: const emoji.CategoryIcons(),
              buttonMode: emoji.ButtonMode.MATERIAL,
              checkPlatformCompatibility: true,
            ),
          )
        : const SizedBox();
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
                      foregroundColor: _currentConversation.themeConv.isEmpty
                          ? Color.lerp(const Color(0xFF4284C4),
                              const Color(0xFF00A9BC), 0.5)
                          : Color.lerp(
                              Helpers.stringToColor(
                                  _currentConversation.themeConv[0]),
                              Helpers.stringToColor(
                                  _currentConversation.themeConv[1]),
                              0.5),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      )),
                  onPressed: () async {
                    setState(() {
                      _openBottomSheetGif = true;
                    });
                    await _showBarBottomSheetSearchGif(context);
                    await Future.delayed(const Duration(milliseconds: 500));
                    if (_searchGifController.text.isNotEmpty) {
                      _searchGifController.clear();
                    }
                    setState(() {
                      _openBottomSheetGif = false;
                    });
                  },
                  child: SizedBox(
                    height: 40.0,
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Helpers.uiApp(context)),
                        const SizedBox(width: 15.0),
                        Expanded(
                            child: Text(AppLocalization.of(context).translate("chat_details_screen", "search_giphy_title"),
                                style: textStyleCustomBold(
                                    Helpers.uiApp(context), 16),
                                textScaler: const TextScaler.linear(1.0)))
                      ],
                    ),
                  )),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      color: Helpers.uiApp(context),
                      size: 30,
                    ),
                    const SizedBox(width: 5.0),
                    Text(
                      AppLocalization.of(context).translate("chat_details_screen", "headlines_giphy"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 18),
                      textScaler: const TextScaler.linear(1.0),
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
                            color:
                                Theme.of(context).canvasColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.network(
                              gif.images.original!.url!,
                              headers: const {'accept': 'image/*'},
                              filterQuality: FilterQuality.low,
                              fit: BoxFit.fill,
                              loadingBuilder: (BuildContext context,
                                  Widget child,
                                  ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Center(
                                  child: CircularProgressIndicator(
                                    color:
                                        _currentConversation.themeConv.isEmpty
                                            ? Color.lerp(
                                                const Color(0xFF4284C4),
                                                const Color(0xFF00A9BC),
                                                0.5)
                                            : Color.lerp(
                                                Helpers.stringToColor(
                                                    _currentConversation
                                                        .themeConv[0]),
                                                Helpers.stringToColor(
                                                    _currentConversation
                                                        .themeConv[1]),
                                                0.5),
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
        : Center(
            child: SizedBox(
              height: 25.0,
              width: 25.0,
              child: CircularProgressIndicator(
                color: _currentConversation.themeConv.isEmpty
                    ? Color.lerp(
                        const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)
                    : Color.lerp(
                        Helpers.stringToColor(
                            _currentConversation.themeConv[0]),
                        Helpers.stringToColor(
                            _currentConversation.themeConv[1]),
                        0.5),
                strokeWidth: 1.0,
              ),
            ),
          );
  }

  Widget picturesCard() {
    return Container(
      height: (showPictures && !_isKeyboard)
          ? MediaQuery.of(context).size.height / 2.5
          : 0,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    height: 45.0,
                    constraints: const BoxConstraints(maxWidth: 250.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          File? file;
                          file = await pickImage(ImageSource.gallery);
                          if (file != null) {
                            print(file.path);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                _currentConversation.themeConv.isEmpty
                                    ? Color.lerp(const Color(0xFF4284C4),
                                        const Color(0xFF00A9BC), 0.5)
                                    : Color.lerp(
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[0]),
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[1]),
                                        0.5),
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? cBlack
                                    : cWhite),
                            const SizedBox(width: 5.0),
                            Text(AppLocalization.of(context).translate("chat_details_screen", "gallery"),
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    18),
                                textScaler: const TextScaler.linear(1.0),
                                overflow: TextOverflow.ellipsis)
                          ],
                        )),
                  ),
                ),
                const SizedBox(
                  width: 10.0,
                ),
                Flexible(
                  child: Container(
                    height: 45.0,
                    constraints: const BoxConstraints(maxWidth: 250.0),
                    child: ElevatedButton(
                        onPressed: () async {
                          File? file;
                          file = await pickImage(ImageSource.camera);
                          if (file != null) {
                            print(file.path);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor:
                                _currentConversation.themeConv.isEmpty
                                    ? Color.lerp(const Color(0xFF4284C4),
                                        const Color(0xFF00A9BC), 0.5)
                                    : Color.lerp(
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[0]),
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[1]),
                                        0.5),
                            foregroundColor: Colors.white,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_camera,
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? cBlack
                                    : cWhite),
                            const SizedBox(width: 5.0),
                            Text(AppLocalization.of(context).translate("chat_details_screen", "camera"),
                                style: textStyleCustomBold(
                                    Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite,
                                    18),
                                textScaler: const TextScaler.linear(1.0),
                                overflow: TextOverflow.ellipsis)
                          ],
                        )),
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: GridView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      mainAxisExtent: 200),
                  physics: const BouncingScrollPhysics(),
                  itemCount: 69,
                  itemBuilder: ((context, index) {
                    return GestureDetector(
                      onTap: () async {
                        //send message type picture
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color:
                                Theme.of(context).canvasColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.0)),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    );
                  })))
        ],
      ),
    );
  }
}
