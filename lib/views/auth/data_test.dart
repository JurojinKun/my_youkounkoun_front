import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';

class DataTest extends ConsumerStatefulWidget {
  final int index;
  final String dataTestString;

  const DataTest({Key? key, required this.index, required this.dataTestString}) : super(key: key);

  @override
  DatatTestState createState() => DatatTestState();
}

class DatatTestState extends ConsumerState<DataTest> {
  AppBar appBar = AppBar();

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: "test ${widget.index}",
                  transitionOnUserGestures: true,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
            preferredSize: Size(
                MediaQuery.of(context).size.width, appBar.preferredSize.height),
            child: ClipRRect(
              child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AppBar(
                    automaticallyImplyLeading: false,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    elevation: 0,
                    systemOverlayStyle:
                        Theme.of(context).brightness == Brightness.light
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
                    leading: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: IconButton(
                          onPressed: () => navAuthKey.currentState!.pop(),
                          icon: Icon(Icons.arrow_back_ios,
                              color:
                                  Theme.of(context).brightness == Brightness.light
                                      ? cBlack
                                      : cWhite)),
                    ),
                    title: Text("Data test",
                        style: textStyleCustomBold(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            20.0),
                        textScaleFactor: 1.0),
                    centerTitle: false,
                  )),
            )),
        body: SizedBox.expand(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
                20.0,
                MediaQuery.of(context).padding.top +
                    appBar.preferredSize.height +
                    20.0,
                20.0,
                MediaQuery.of(context).padding.bottom + 20.0),
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            child: Container(
              height: MediaQuery.of(context).size.height -
                  (MediaQuery.of(context).padding.top +
                      appBar.preferredSize.height +
                      20.0 +
                      MediaQuery.of(context).padding.bottom +
                      20.0),
              alignment: Alignment.center,
              child: Material(
                type: MaterialType.transparency,
                child: Text(widget.dataTestString,
                    style: textStyleCustomBold(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        18),
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
