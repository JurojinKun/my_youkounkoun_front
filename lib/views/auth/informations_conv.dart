import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/components/alert_dialog_custom.dart';

import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/chat_details_provider.dart';
import 'package:myyoukounkoun/providers/chat_provider.dart';
import 'package:myyoukounkoun/providers/search_enabled_provider.dart';
import 'package:myyoukounkoun/providers/user_provider.dart';
import 'package:myyoukounkoun/route_observer.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:myyoukounkoun/views/auth/multimedias.dart';
import 'package:myyoukounkoun/views/auth/search_messages.dart';
import 'package:myyoukounkoun/views/auth/theme_conv.dart';

class InformationsConv extends ConsumerStatefulWidget {
  final UserModel user;

  const InformationsConv({Key? key, required this.user}) : super(key: key);

  @override
  InformationsConvState createState() => InformationsConvState();
}

class InformationsConvState extends ConsumerState<InformationsConv> {
  final AppBar appBar = AppBar();

  late ConversationModel _currentConversation;
  int indexUserConv = 0;

  bool searchEnabled = false;
  late FocusNode _searchMessagesFocusNode;

  Future _themeConvBottomSheet(BuildContext context) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: true,
        builder: (context) {
          return const RouteObserverWidget(name: themeConv, child: ThemeConv());
        });
  }

  Future _searchMessagesBottomSheet(BuildContext context) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: true,
        builder: (context) {
          return RouteObserverWidget(
              name: searchMessages,
              child: SearchMessages(
                  keyWords: searchMessagesController!.text, user: widget.user));
        });
  }

  Future _multimediasBottomSheet(BuildContext context) async {
    return showMaterialModalBottomSheet(
        context: context,
        expand: true,
        enableDrag: true,
        builder: (context) {
          return RouteObserverWidget(
              name: multimedias, child: Multimedias(user: widget.user));
        });
  }

  Future _showDialogDeleteChat() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return StatefulBuilder(builder: (_, setState) {
            return AlertDialogCustom(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              title: Text(
                AppLocalization.of(context)
                    .translate("infos_conv_screen", "delete_conv_title"),
                style: textStyleCustomBold(Helpers.uiApp(context), 16),
                textScaler: const TextScaler.linear(1.0),
              ),
              content: Text(
                "${AppLocalization.of(context).translate("infos_conv_screen", "delete_conv_content_1")} ${widget.user.pseudo} ${AppLocalization.of(context).translate("infos_conv_screen", "delete_conv_content_2")}",
                style: textStyleCustomRegular(Helpers.uiApp(context), 14),
                textScaler: const TextScaler.linear(1.0),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalization.of(context)
                          .translate("general", "btn_confirm"),
                      style: textStyleCustomMedium(cBlue, 14),
                      textScaler: const TextScaler.linear(1.0),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalization.of(context)
                          .translate("general", "btn_cancel"),
                      style: textStyleCustomMedium(cRed, 14),
                      textScaler: const TextScaler.linear(1.0),
                    ))
              ],
            );
          });
        });
  }

  Future _showDialogReportUser() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return StatefulBuilder(builder: (_, setState) {
            return AlertDialogCustom(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              title: Text(
                "${AppLocalization.of(context).translate("infos_conv_screen", "report_user_title")} ${widget.user.pseudo}",
                style: textStyleCustomBold(Helpers.uiApp(context), 16),
                textScaler: const TextScaler.linear(1.0),
              ),
              content: Text(
                "${AppLocalization.of(context).translate("infos_conv_screen", "report_user_content")} ${widget.user.pseudo} ?",
                style: textStyleCustomRegular(Helpers.uiApp(context), 14),
                textScaler: const TextScaler.linear(1.0),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalization.of(context)
                          .translate("general", "btn_confirm"),
                      style: textStyleCustomMedium(cBlue, 14),
                      textScaler: const TextScaler.linear(1.0),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalization.of(context)
                          .translate("general", "btn_cancel"),
                      style: textStyleCustomMedium(cRed, 14),
                      textScaler: const TextScaler.linear(1.0),
                    ))
              ],
            );
          });
        });
  }

  Future _showDialogBlockUser() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          return StatefulBuilder(builder: (_, setState) {
            return AlertDialogCustom(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              title: Text(
                "${AppLocalization.of(context).translate("infos_conv_screen", "block_user_title")} ${widget.user.pseudo}",
                style: textStyleCustomBold(Helpers.uiApp(context), 16),
                textScaler: const TextScaler.linear(1.0),
              ),
              content: Text(
                "${AppLocalization.of(context).translate("infos_conv_screen", "block_user_content")} ${widget.user.pseudo} ?",
                style: textStyleCustomRegular(Helpers.uiApp(context), 14),
                textScaler: const TextScaler.linear(1.0),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalization.of(context)
                          .translate("general", "btn_confirm"),
                      style: textStyleCustomMedium(cBlue, 14),
                      textScaler: const TextScaler.linear(1.0),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      AppLocalization.of(context)
                          .translate("general", "btn_cancel"),
                      style: textStyleCustomMedium(cRed, 14),
                      textScaler: const TextScaler.linear(1.0),
                    ))
              ],
            );
          });
        });
  }

  @override
  void initState() {
    super.initState();

    for (var user in ref.read(currentConvNotifierProvider).users) {
      if (user["id"] == ref.read(userNotifierProvider).id) {
        indexUserConv =
            ref.read(currentConvNotifierProvider).users.indexOf(user);
      }
    }

    searchMessagesController = TextEditingController();
    _searchMessagesFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchMessagesFocusNode.dispose();
    searchMessagesController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _currentConversation = ref.watch(currentConvNotifierProvider);
    searchEnabled = ref.watch(searchEnabledNotifierProvider);

    return Stack(
      children: [
        Scaffold(
            extendBodyBehindAppBar: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: PreferredSize(
              preferredSize: Size(MediaQuery.of(context).size.width,
                  appBar.preferredSize.height),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    elevation: 0,
                    shadowColor: Colors.transparent,
                    backgroundColor: Colors.transparent,
                    systemOverlayStyle: Helpers.uiOverlayApp(context),
                    leading: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: IconButton(
                          onPressed: () => navAuthKey.currentState!.pop(),
                          icon: Icon(Icons.arrow_back_ios,
                              color: Helpers.uiApp(context))),
                    ),
                    title: Text(
                      AppLocalization.of(context)
                          .translate("infos_conv_screen", "title_screen"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 20),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    centerTitle: false,
                  ),
                ),
              ),
            ),
            body: SizedBox.expand(
              child: GlowingOverscrollIndicator(
                color: _currentConversation.themeConv.isEmpty
                    ? Color.lerp(
                        const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)!
                    : Color.lerp(
                        Helpers.stringToColor(
                            _currentConversation.themeConv[0]),
                        Helpers.stringToColor(
                            _currentConversation.themeConv[1]),
                        0.5)!,
                axisDirection: AxisDirection.down,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                      20.0,
                      MediaQuery.of(context).padding.top +
                          appBar.preferredSize.height +
                          20.0,
                      20.0,
                      MediaQuery.of(context).padding.bottom + 20.0),
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: infosConv(),
                ),
              ),
            )),
        if (searchEnabled)
          searchMessagesBar()
      ],
    );
  }

  Widget infosConv() {
    return Column(
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
                            const Color(0xFF00A9BC), 0.5)!
                        : Color.lerp(
                            Helpers.stringToColor(
                                _currentConversation.themeConv[0]),
                            Helpers.stringToColor(
                                _currentConversation.themeConv[1]),
                            0.5)!,
                    size: 55),
              )
            : CachedNetworkImageCustom(
                profilePictureUrl: widget.user.profilePictureUrl,
                heightContainer: 145,
                widthContainer: 145,
                iconSize: 55,
                colorTheme: _currentConversation.themeConv.isEmpty
                    ? Color.lerp(
                        const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)!
                    : Color.lerp(
                        Helpers.stringToColor(
                            _currentConversation.themeConv[0]),
                        Helpers.stringToColor(
                            _currentConversation.themeConv[1]),
                        0.5)!),
        const SizedBox(height: 10.0),
        Text(
          widget.user.pseudo,
          style: textStyleCustomBold(Helpers.uiApp(context), 20.0),
          textScaler: const TextScaler.linear(1.0),
        ),
        const SizedBox(height: 20.0),
        _currentConversation.id != "temporary"
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: _currentConversation
                                      .themeConv.isEmpty
                                  ? Color.lerp(const Color(0xFF4284C4),
                                          const Color(0xFF00A9BC), 0.5)!
                                      .withOpacity(0.5)
                                  : Color.lerp(
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[0]),
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[1]),
                                          0.5)!
                                      .withOpacity(0.5),
                              highlightColor: _currentConversation
                                      .themeConv.isEmpty
                                  ? Color.lerp(const Color(0xFF4284C4),
                                          const Color(0xFF00A9BC), 0.5)!
                                      .withOpacity(0.5)
                                  : Color.lerp(
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[0]),
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[1]),
                                          0.5)!
                                      .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15.0),
                              onTap: () => navAuthKey.currentState!.pushNamed(
                                  userProfile,
                                  arguments: [widget.user, false]),
                              child: Icon(Icons.person,
                                  color: Helpers.uiApp(context)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          AppLocalization.of(context)
                              .translate("infos_conv_screen", "profile"),
                          style:
                              textStyleCustomBold(Helpers.uiApp(context), 14),
                          textScaler: const TextScaler.linear(1.0),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 40.0,
                          width: 40.0,
                          decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(15.0)),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              splashColor: _currentConversation
                                      .themeConv.isEmpty
                                  ? Color.lerp(const Color(0xFF4284C4),
                                          const Color(0xFF00A9BC), 0.5)!
                                      .withOpacity(0.5)
                                  : Color.lerp(
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[0]),
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[1]),
                                          0.5)!
                                      .withOpacity(0.5),
                              highlightColor: _currentConversation
                                      .themeConv.isEmpty
                                  ? Color.lerp(const Color(0xFF4284C4),
                                          const Color(0xFF00A9BC), 0.5)!
                                      .withOpacity(0.5)
                                  : Color.lerp(
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[0]),
                                          Helpers.stringToColor(
                                              _currentConversation
                                                  .themeConv[1]),
                                          0.5)!
                                      .withOpacity(0.5),
                              borderRadius: BorderRadius.circular(15.0),
                              onTap: () {
                                if (_currentConversation.users[indexUserConv]
                                    ["convMute"]) {
                                  ref
                                      .read(conversationsNotifierProvider
                                          .notifier)
                                      .muteConversation(_currentConversation.id,
                                          indexUserConv, false);
                                  ref
                                      .read(
                                          currentConvNotifierProvider.notifier)
                                      .muteConversation(indexUserConv, false);
                                } else {
                                  ref
                                      .read(conversationsNotifierProvider
                                          .notifier)
                                      .muteConversation(_currentConversation.id,
                                          indexUserConv, true);
                                  ref
                                      .read(
                                          currentConvNotifierProvider.notifier)
                                      .muteConversation(indexUserConv, true);
                                }
                              },
                              child: Icon(
                                  _currentConversation.users[indexUserConv]
                                          ["convMute"]
                                      ? Icons.notifications_active
                                      : Icons.notifications_off,
                                  color: Helpers.uiApp(context)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5.0),
                        Text(
                          _currentConversation.users[indexUserConv]["convMute"]
                              ? AppLocalization.of(context).translate(
                                  "infos_conv_screen", "notif_unmute")
                              : AppLocalization.of(context)
                                  .translate("infos_conv_screen", "notif_mute"),
                          style:
                              textStyleCustomBold(Helpers.uiApp(context), 14),
                          textScaler: const TextScaler.linear(1.0),
                        )
                      ],
                    ),
                  )
                ],
              )
            : SizedBox(
                width: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(15.0)),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: _currentConversation.themeConv.isEmpty
                              ? Color.lerp(const Color(0xFF4284C4),
                                      const Color(0xFF00A9BC), 0.5)!
                                  .withOpacity(0.5)
                              : Color.lerp(
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[0]),
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[1]),
                                      0.5)!
                                  .withOpacity(0.5)
                                  .withOpacity(0.5),
                          highlightColor: _currentConversation.themeConv.isEmpty
                              ? Color.lerp(const Color(0xFF4284C4),
                                      const Color(0xFF00A9BC), 0.5)!
                                  .withOpacity(0.5)
                              : Color.lerp(
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[0]),
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[1]),
                                      0.5)!
                                  .withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15.0),
                          onTap: () => navAuthKey.currentState!.pushNamed(
                              userProfile,
                              arguments: [widget.user, false]),
                          child:
                              Icon(Icons.person, color: Helpers.uiApp(context)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5.0),
                    Text(
                      AppLocalization.of(context)
                          .translate("infos_conv_screen", "profile"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 14),
                      textScaler: const TextScaler.linear(1.0),
                    )
                  ],
                ),
              ),
        const SizedBox(
          height: 25.0,
        ),
        if (_currentConversation.id != "temporary") customization(),
        details(),
        othersActions()
      ],
    );
  }

  Widget customization() {
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                AppLocalization.of(context)
                    .translate("infos_conv_screen", "personnalisation"),
                style: textStyleCustomBold(cGrey, 14),
                textScaler: const TextScaler.linear(1.0),
              ),
            )),
        const SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(15.0)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: _currentConversation.themeConv.isEmpty
                  ? Color.lerp(const Color(0xFF4284C4), const Color(0xFF00A9BC),
                          0.5)!
                      .withOpacity(0.5)
                  : Color.lerp(
                          Helpers.stringToColor(
                              _currentConversation.themeConv[0]),
                          Helpers.stringToColor(
                              _currentConversation.themeConv[1]),
                          0.5)!
                      .withOpacity(0.5),
              highlightColor: _currentConversation.themeConv.isEmpty
                  ? Color.lerp(const Color(0xFF4284C4), const Color(0xFF00A9BC),
                          0.5)!
                      .withOpacity(0.5)
                  : Color.lerp(
                          Helpers.stringToColor(
                              _currentConversation.themeConv[0]),
                          Helpers.stringToColor(
                              _currentConversation.themeConv[1]),
                          0.5)!
                      .withOpacity(0.5),
              borderRadius: BorderRadius.circular(15.0),
              onTap: () {
                _themeConvBottomSheet(context);
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            height: 25.0,
                            width: 25.0,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(int.parse(
                                              _currentConversation.themeConv[0]
                                                  .substring(1, 7),
                                              radix: 16) +
                                          0xFF000000),
                                      Color(int.parse(
                                              _currentConversation.themeConv[1]
                                                  .substring(1, 7),
                                              radix: 16) +
                                          0xFF000000)
                                    ]),
                                shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 15.0),
                          Text(
                            AppLocalization.of(context)
                                .translate("infos_conv_screen", "theme_conv"),
                            style: textStyleCustomBold(
                                Helpers.uiApp(context), 16.0),
                            textScaler: const TextScaler.linear(1.0),
                          )
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Helpers.uiApp(context), size: 16)
                    ],
                  )),
            ),
          ),
        ),
        const SizedBox(height: 25.0),
      ],
    );
  }

  Widget details() {
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                AppLocalization.of(context)
                    .translate("infos_conv_screen", "details"),
                style: textStyleCustomBold(cGrey, 14),
                textScaler: const TextScaler.linear(1.0),
              ),
            )),
        const SizedBox(height: 10.0),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0))),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: _currentConversation.themeConv.isEmpty
                  ? Color.lerp(const Color(0xFF4284C4), const Color(0xFF00A9BC),
                          0.5)!
                      .withOpacity(0.5)
                  : Color.lerp(
                          Helpers.stringToColor(
                              _currentConversation.themeConv[0]),
                          Helpers.stringToColor(
                              _currentConversation.themeConv[1]),
                          0.5)!
                      .withOpacity(0.5),
              highlightColor: _currentConversation.themeConv.isEmpty
                  ? Color.lerp(const Color(0xFF4284C4), const Color(0xFF00A9BC),
                          0.5)!
                      .withOpacity(0.5)
                  : Color.lerp(
                          Helpers.stringToColor(
                              _currentConversation.themeConv[0]),
                          Helpers.stringToColor(
                              _currentConversation.themeConv[1]),
                          0.5)!
                      .withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15.0),
                  topRight: Radius.circular(15.0)),
              onTap: () {
                ref
                    .read(searchEnabledNotifierProvider.notifier)
                    .updateState(true);
              },
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.search, color: Helpers.uiApp(context)),
                          const SizedBox(width: 15.0),
                          Text(
                            AppLocalization.of(context).translate(
                                "infos_conv_screen", "search_messages"),
                            style: textStyleCustomBold(
                                Helpers.uiApp(context), 16.0),
                            textScaler: const TextScaler.linear(1.0),
                          )
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Helpers.uiApp(context), size: 16)
                    ],
                  )),
            ),
          ),
        ),
        const SizedBox(height: 2.0),
        Container(
          decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0))),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: _currentConversation.themeConv.isEmpty
                  ? Color.lerp(const Color(0xFF4284C4), const Color(0xFF00A9BC),
                          0.5)!
                      .withOpacity(0.5)
                  : Color.lerp(
                          Helpers.stringToColor(
                              _currentConversation.themeConv[0]),
                          Helpers.stringToColor(
                              _currentConversation.themeConv[1]),
                          0.5)!
                      .withOpacity(0.5),
              highlightColor: _currentConversation.themeConv.isEmpty
                  ? Color.lerp(const Color(0xFF4284C4), const Color(0xFF00A9BC),
                          0.5)!
                      .withOpacity(0.5)
                  : Color.lerp(
                          Helpers.stringToColor(
                              _currentConversation.themeConv[0]),
                          Helpers.stringToColor(
                              _currentConversation.themeConv[1]),
                          0.5)!
                      .withOpacity(0.5),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15.0),
                  bottomRight: Radius.circular(15.0)),
              onTap: () => _multimediasBottomSheet(context),
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.photo, color: Helpers.uiApp(context)),
                          const SizedBox(width: 15.0),
                          Text(
                            AppLocalization.of(context).translate(
                                "infos_conv_screen", "multimedias_conv"),
                            style: textStyleCustomBold(
                                Helpers.uiApp(context), 16.0),
                            textScaler: const TextScaler.linear(1.0),
                          )
                        ],
                      ),
                      Icon(Icons.arrow_forward_ios,
                          color: Helpers.uiApp(context), size: 16)
                    ],
                  )),
            ),
          ),
        ),
        const SizedBox(height: 25.0),
      ],
    );
  }

  Widget othersActions() {
    return Column(
      children: [
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: Text(
                AppLocalization.of(context)
                    .translate("infos_conv_screen", "others_actions"),
                style: textStyleCustomBold(cGrey, 14),
                textScaler: const TextScaler.linear(1.0),
              ),
            )),
        const SizedBox(height: 10.0),
        if (_currentConversation.id != "temporary")
          Column(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor,
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0))),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: cRed.withOpacity(0.2),
                    highlightColor: cRed.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                    onTap: () async {
                      await _showDialogDeleteChat();
                    },
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        child: Text(
                          AppLocalization.of(context).translate(
                              "infos_conv_screen", "delete_conv_title"),
                          style: textStyleCustomBold(cRed, 16.0),
                          textScaler: const TextScaler.linear(1.0),
                        )),
                  ),
                ),
              ),
              const SizedBox(height: 2.0),
            ],
          ),
        _currentConversation.id != "temporary"
            ? Container(
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).canvasColor,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: cRed.withOpacity(0.2),
                    highlightColor: cRed.withOpacity(0.2),
                    onTap: () async {
                      await _showDialogReportUser();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text(
                        "${AppLocalization.of(context).translate("infos_conv_screen", "report_user_title")} ${widget.user.pseudo}",
                        style: textStyleCustomBold(cRed, 16.0),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ),
                  ),
                ))
            : Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0)),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: cRed.withOpacity(0.2),
                    highlightColor: cRed.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(15.0),
                        topRight: Radius.circular(15.0)),
                    onTap: () async {
                      await _showDialogReportUser();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 10.0),
                      child: Text(
                        "${AppLocalization.of(context).translate("infos_conv_screen", "report_user_title")} ${widget.user.pseudo}",
                        style: textStyleCustomBold(cRed, 16.0),
                        textScaler: const TextScaler.linear(1.0),
                      ),
                    ),
                  ),
                )),
        const SizedBox(height: 2.0),
        Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0))),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: cRed.withOpacity(0.2),
                highlightColor: cRed.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15.0),
                    bottomRight: Radius.circular(15.0)),
                onTap: () async {
                  await _showDialogBlockUser();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 10.0),
                  child: Text(
                    "${AppLocalization.of(context).translate("infos_conv_screen", "block_user_title")} ${widget.user.pseudo}",
                    style: textStyleCustomBold(cRed, 16.0),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget searchMessagesBar() {
    return SizedBox.expand(
      child: Container(
          color: Colors.black.withOpacity(0.5),
          alignment: Alignment.topCenter,
          child: Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            height: appBar.preferredSize.height + 50.0,
            child: Row(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: Container(
                    height: 40.0,
                    alignment: Alignment.center,
                    child: Material(
                      color: Colors.transparent,
                      child: TextField(
                        scrollPhysics: const BouncingScrollPhysics(),
                        controller: searchMessagesController,
                        autofocus: true,
                        focusNode: _searchMessagesFocusNode,
                        cursorColor: _currentConversation.themeConv.isEmpty
                            ? Color.lerp(const Color(0xFF4284C4),
                                const Color(0xFF00A9BC), 0.5)!
                            : Color.lerp(
                                Helpers.stringToColor(
                                    _currentConversation.themeConv[0]),
                                Helpers.stringToColor(
                                    _currentConversation.themeConv[1]),
                                0.5)!,
                        textInputAction: TextInputAction.search,
                        maxLines: 1,
                        style: textStyleCustomMedium(
                            _searchMessagesFocusNode.hasFocus
                                ? _currentConversation.themeConv.isEmpty
                                    ? Color.lerp(const Color(0xFF4284C4),
                                        const Color(0xFF00A9BC), 0.5)!
                                    : Color.lerp(
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[0]),
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[1]),
                                        0.5)!
                                : cGrey,
                            MediaQuery.of(context).textScaler.scale(14)),
                        decoration: InputDecoration(
                            contentPadding:
                                const EdgeInsets.only(top: 15.0, left: 15.0),
                            filled: true,
                            fillColor:
                                Theme.of(context).scaffoldBackgroundColor,
                            hintText: AppLocalization.of(context).translate(
                                "infos_conv_screen", "search_messages"),
                            hintStyle: textStyleCustomMedium(
                                _searchMessagesFocusNode.hasFocus
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
                                14),
                            enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: cGrey),
                                borderRadius: BorderRadius.circular(10.0)),
                            focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
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
                                ),
                                borderRadius: BorderRadius.circular(10.0)),
                            prefixIcon: Icon(
                              Icons.search_sharp,
                              size: 20,
                              color: _currentConversation.themeConv.isEmpty
                                  ? Color.lerp(const Color(0xFF4284C4),
                                      const Color(0xFF00A9BC), 0.5)!
                                  : Color.lerp(
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[0]),
                                      Helpers.stringToColor(
                                          _currentConversation.themeConv[1]),
                                      0.5)!,
                            ),
                            suffixIcon: searchMessagesController!
                                    .text.isNotEmpty
                                ? Material(
                                    color: Colors.transparent,
                                    shape: const CircleBorder(),
                                    clipBehavior: Clip.hardEdge,
                                    child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            searchMessagesController!.clear();
                                          });
                                        },
                                        icon: Icon(
                                          Icons.clear,
                                          size: 20,
                                          color: _searchMessagesFocusNode
                                                  .hasFocus
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
                                        )),
                                  )
                                : const SizedBox()),
                        onTap: () {
                          setState(() {
                            FocusScope.of(context)
                                .requestFocus(_searchMessagesFocusNode);
                          });
                        },
                        onEditingComplete: () async {
                          Helpers.hideKeyboard(context);
                          ref
                              .read(searchEnabledNotifierProvider.notifier)
                              .updateState(false);
                          if (searchMessagesController!.text.isNotEmpty &&
                              searchMessagesController!.text.trim() != "") {
                            await _searchMessagesBottomSheet(context);
                          }
                          searchMessagesController!.clear();
                        },
                      ),
                    ),
                  ),
                )),
                Padding(
                  padding: const EdgeInsets.only(bottom: 5.0),
                  child: TextButton(
                    onPressed: () {
                      ref
                          .read(searchEnabledNotifierProvider.notifier)
                          .updateState(false);
                      searchMessagesController!.clear();
                    },
                    style: ButtonStyle(
                        overlayColor: MaterialStateProperty.all(
                            _currentConversation.themeConv.isEmpty
                                ? Color.lerp(const Color(0xFF4284C4),
                                        const Color(0xFF00A9BC), 0.5)!
                                    .withOpacity(0.5)
                                : Color.lerp(
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[0]),
                                        Helpers.stringToColor(
                                            _currentConversation.themeConv[1]),
                                        0.5)!
                                    .withOpacity(0.5))),
                    child: Text(
                      AppLocalization.of(context)
                          .translate("general", "btn_cancel"),
                      style: textStyleCustomMedium(Helpers.uiApp(context), 14),
                      textScaler: const TextScaler.linear(1.0),
                    ),
                  ),
                )
              ],
            ),
          )),
    );
  }
}
