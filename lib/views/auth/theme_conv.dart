import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/indicator_typing_component.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/conversation_model.dart';
import 'package:myyoukounkoun/providers/chat_details_provider.dart';
import 'package:myyoukounkoun/providers/chat_provider.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class ThemeConv extends ConsumerStatefulWidget {
  const ThemeConv({super.key});

  @override
  ThemeConvState createState() => ThemeConvState();
}

class ThemeConvState extends ConsumerState<ThemeConv> {
  final AppBar appBar = AppBar();

  late ConversationModel _currentConversation;

  late Color pickerColor1, pickerColor2;

  void changePickerColor1(Color color) {
    setState(() => pickerColor1 = color);
  }

  void changePickerColor2(Color color) {
    setState(() => pickerColor2 = color);
  }

  Future _showDialogPickerColor1() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          Color changeColor = pickerColor1;

          return StatefulBuilder(builder: (_, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              scrollable: true,
              title: Text(
                AppLocalization.of(context).translate(
                              "theme_conv_screen", "picker_color_1_title"),
                style: textStyleCustomBold(Helpers.uiApp(context), 16),
                textScaler: const TextScaler.linear(1.0),
              ),
              content: ColorPicker(
                  enableAlpha: false,
                  // ignore: deprecated_member_use
                  showLabel: false,
                  pickerAreaBorderRadius: BorderRadius.circular(10.0),
                  pickerAreaHeightPercent: 1.0,
                  pickerColor: changeColor,
                  onColorChanged: (color) {
                    setState(() => changeColor = color);
                  }),
              actions: [
                TextButton(
                    onPressed: () {
                      changePickerColor1(changeColor);
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

  Future _showDialogPickerColor2() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (context) {
          Color changeColor = pickerColor2;

          return StatefulBuilder(builder: (_, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              scrollable: true,
              title: Text(
                AppLocalization.of(context).translate(
                              "theme_conv_screen", "picker_color_2_title"),
                style: textStyleCustomBold(Helpers.uiApp(context), 16),
                textScaler: const TextScaler.linear(1.0),
              ),
              content: ColorPicker(
                  enableAlpha: false,
                  // ignore: deprecated_member_use
                  showLabel: false,
                  pickerAreaBorderRadius: BorderRadius.circular(10.0),
                  pickerAreaHeightPercent: 1.0,
                  pickerColor: changeColor,
                  onColorChanged: (color) {
                    setState(() => changeColor = color);
                  }),
              actions: [
                TextButton(
                    onPressed: () {
                      changePickerColor2(changeColor);
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
              AppLocalization.of(context).translate(
                              "theme_conv_screen", "title_screen"),
              style: textStyleCustomBold(Helpers.uiApp(context), 20),
              textAlign: TextAlign.center,
              textScaler: const TextScaler.linear(1.0),
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
                      size: 33,
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
            Row(
              children: [
                Expanded(
                    child: Text(AppLocalization.of(context).translate(
                              "theme_conv_screen", "picker_color_1_title"),
                        style: textStyleCustomBold(Helpers.uiApp(context), 16),
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1.0))),
                const SizedBox(width: 15.0),
                GestureDetector(
                  onTap: () async {
                    await _showDialogPickerColor1();
                  },
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                        color: pickerColor1, shape: BoxShape.circle),
                  ),
                )
              ],
            ),
            const SizedBox(height: 40.0),
            Row(
              children: [
                Expanded(
                    child: Text(AppLocalization.of(context).translate(
                              "theme_conv_screen", "picker_color_2_title"),
                        style: textStyleCustomBold(Helpers.uiApp(context), 16),
                        overflow: TextOverflow.ellipsis,
                        textScaler: const TextScaler.linear(1.0))),
                const SizedBox(width: 15.0),
                GestureDetector(
                  onTap: () async {
                    await _showDialogPickerColor2();
                  },
                  child: Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: BoxDecoration(
                        color: pickerColor2, shape: BoxShape.circle),
                  ),
                )
              ],
            ),
            const SizedBox(height: 40.0),
            Text(AppLocalization.of(context).translate(
                              "theme_conv_screen", "overview_theme"),
                style: textStyleCustomBold(Helpers.uiApp(context), 16.0),
                textScaler: const TextScaler.linear(1.0)),
            const SizedBox(height: 25.0),
            _previewTheme(),
            const SizedBox(height: 40.0),
            Text(AppLocalization.of(context).translate(
                              "theme_conv_screen", "overview_gradient"),
                style: textStyleCustomBold(Helpers.uiApp(context), 16.0),
                textScaler: const TextScaler.linear(1.0)),
            const SizedBox(height: 25.0),
            _previewGradient(),
          ],
        ),
      ),
    );
  }

  Widget _previewTheme() {
    return Center(
      child: Container(
          constraints: BoxConstraints(
              minWidth: 0, maxWidth: MediaQuery.of(context).size.width / 1.5),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [pickerColor1, pickerColor2],
              ),
              borderRadius: BorderRadius.circular(10.0)),
          child: IntrinsicWidth(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalization.of(context).translate(
                              "theme_conv_screen", "overview_message"),
                  style: textStyleCustomRegular(Helpers.uiApp(context), 14),
                  textScaler: const TextScaler.linear(1.0),
                ),
                const SizedBox(height: 5.0),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    Helpers.formatDateHoursMinutes(1681076523000,
                        ref.read(localeLanguageNotifierProvider).languageCode),
                    style: textStyleCustomBold(Helpers.uiApp(context), 10),
                    textScaler: const TextScaler.linear(1.0),
                  ),
                )
              ],
            ),
          )),
    );
  }

  Widget _previewGradient() {
    return Container(
      width: MediaQuery.of(context).size.width,
      alignment: Alignment.center,
      child: SizedBox(
        width: 105,
        child: TypingIndicator(
          showIndicator: true,
          bubbleColor: Theme.of(context).canvasColor,
          flashingCircleBrightColor:
              Color.lerp(pickerColor1, pickerColor2, 0.5)!,
          flashingCircleDarkColor: Theme.of(context).scaffoldBackgroundColor,
          colorThemeConv: Color.lerp(pickerColor1, pickerColor2, 0.5)!,
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
                            textScaler: const TextScaler.linear(1.0)))),
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
                            textScaler: const TextScaler.linear(1.0)))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
