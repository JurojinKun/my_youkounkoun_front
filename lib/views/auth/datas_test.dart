import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/providers/datas_test_provider.dart';

class DatasTest extends ConsumerStatefulWidget {
  final int index;

  const DatasTest({Key? key, required this.index}) : super(key: key);

  @override
  DatasTestState createState() => DatasTestState();
}

class DatasTestState extends ConsumerState<DatasTest>
    with SingleTickerProviderStateMixin {
  AppBar appBar = AppBar();

  late AnimationController animationController;
  late Animation<double> animationAppBar;
  late PageController _pageController;

  late int datasItemsCount;

  Future<void> _scrollPageControllerListener() async {
    if (_pageController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      await animationController.forward();
    }
    if (_pageController.position.userScrollDirection ==
        ScrollDirection.forward) {
      await animationController.reverse();
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animationAppBar = Tween(begin: appBar.preferredSize.height, end: 0.0)
        .animate(CurvedAnimation(
            parent: animationController, curve: Curves.linear, reverseCurve: Curves.linear));

    _pageController = PageController(initialPage: widget.index);
    _pageController.addListener(_scrollPageControllerListener);
  }

  @override
  void deactivate() {
    _pageController.removeListener(_scrollPageControllerListener);
    super.deactivate();
  }

  @override
  void dispose() {
    animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    datasItemsCount = ref.watch(datasTestNotifierProvider);

    return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(animationAppBar.value),
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: Theme.of(context).brightness == Brightness.light
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
                      color: Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite)),
            ),
            title: Text("Datas test",
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    20.0),
                textScaleFactor: 1.0),
            centerTitle: false,
          ),
        ),
        body: Hero(
          tag: "data test ${widget.index}",
          transitionOnUserGestures: true,
          child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              itemCount: datasItemsCount,
              itemBuilder: (context, index) {
                String dataTest = "Data test $index";

                return Container(
                  height: MediaQuery.of(context).size.height,
                  margin: const EdgeInsets.all(5.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: cBlue),
                      color: cBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10.0)),
                  alignment: Alignment.center,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Text(dataTest,
                        style: textStyleCustomBold(
                            Theme.of(context).brightness == Brightness.light
                                ? cBlack
                                : cWhite,
                            18),
                        textAlign: TextAlign.center,
                        textScaleFactor: 1.0),
                  ),
                );
              }),
        ));
  }
}
