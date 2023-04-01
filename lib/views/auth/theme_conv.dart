// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';
import 'package:myyoukounkoun/providers/chat_details_provider.dart';
import 'package:myyoukounkoun/providers/chat_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class ThemeConv extends ConsumerStatefulWidget {
  const ThemeConv({Key? key}) : super(key: key);

  @override
  ThemeConvState createState() => ThemeConvState();
}

class ThemeConvState extends ConsumerState<ThemeConv> {
  final AppBar appBar = AppBar();

  late ConversationModel _currentConversation;

  late Color pickerColor1, pickerColor2;

  void changeColor1(Color color) {
    setState(() => pickerColor1 = color);
  }

  void changeColor2(Color color) {
    setState(() => pickerColor2 = color);
  }

  @override
  void initState() {
    super.initState();

    pickerColor1 = Helpers.stringToColor(
        ref.read(currentConvNotifierProvider).themeConv[0]);
    pickerColor2 = Helpers.stringToColor(
        ref.read(currentConvNotifierProvider).themeConv[1]);
  }

  @override
  Widget build(BuildContext context) {
    _currentConversation = ref.watch(currentConvNotifierProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: appBarThemeConv(),
      body: bodyThemeConv(),
    );
  }

  PreferredSizeWidget appBarThemeConv() {
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
              "Thème conversation",
              style: textStyleCustomBold(Helpers.uiApp(context), 20),
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

  Widget bodyThemeConv() {
    return Stack(
      children: [
        _chooseThemeConv(),
        if (pickerColor1 !=
                Helpers.stringToColor(_currentConversation.themeConv[0]) ||
            pickerColor2 !=
                Helpers.stringToColor(_currentConversation.themeConv[1]))
          _saveNewTheme()
      ],
    );
  }

  Widget _chooseThemeConv() {
    return SizedBox.expand(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            20.0,
            MediaQuery.of(context).padding.top +
                appBar.preferredSize.height +
                20.0,
            20.0,
            pickerColor1 !=
                        Helpers.stringToColor(
                            _currentConversation.themeConv[0]) ||
                    pickerColor2 !=
                        Helpers.stringToColor(_currentConversation.themeConv[1])
                ? MediaQuery.of(context).padding.bottom + 120.0
                : MediaQuery.of(context).padding.bottom + 20.0),
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Choix première couleur du thème",
                style: textStyleCustomBold(Helpers.uiApp(context), 16),
                textScaleFactor: 1.0),
                const SizedBox(height: 20.0),
            ColorPicker(
                enableAlpha: false,
                showLabel: false,
                pickerAreaBorderRadius: BorderRadius.circular(10.0),
                pickerColor: pickerColor1,
                onColorChanged: changeColor1),
                const SizedBox(height: 20.0),
            Text("Choix seconde couleur du thème",
                style: textStyleCustomBold(Helpers.uiApp(context), 16),
                textScaleFactor: 1.0),
                const SizedBox(height: 20.0),
            ColorPicker(
                enableAlpha: false,
                showLabel: false,
                pickerColor: pickerColor2,
                pickerAreaBorderRadius: BorderRadius.circular(10.0),
                onColorChanged: changeColor2),
          ],
        ),
      ),
    );
  }

  Widget _saveNewTheme() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        height: 100.0 + MediaQuery.of(context).padding.bottom,
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                        onPressed: () async {
                          ref
                              .read(conversationsNotifierProvider.notifier)
                              .newThemeConversation(_currentConversation.id, [
                            Helpers.colorToString(pickerColor1),
                            Helpers.colorToString(pickerColor2)
                          ]);
                          ref
                              .read(currentConvNotifierProvider.notifier)
                              .newThemeConversation([
                            Helpers.colorToString(pickerColor1),
                            Helpers.colorToString(pickerColor2)
                          ]);
                        },
                        child: Text(
                            AppLocalization.of(context)
                                .translate("general", "btn_save"),
                            style: textStyleCustomMedium(
                                Helpers.uiApp(context), 20),
                            textScaleFactor: 1.0))),
              ),
              const SizedBox(width: 15.0),
              Expanded(
                child: SizedBox(
                    height: 50.0,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: cRed,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                        ),
                        onPressed: () {
                          setState(() {
                            pickerColor1 = Helpers.stringToColor(
                                _currentConversation.themeConv[0]);
                            pickerColor2 = Helpers.stringToColor(
                                _currentConversation.themeConv[1]);
                          });
                        },
                        child: Text(
                            AppLocalization.of(context)
                                .translate("general", "btn_cancel"),
                            style: textStyleCustomMedium(
                                Helpers.uiApp(context), 20),
                            textScaleFactor: 1.0))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
