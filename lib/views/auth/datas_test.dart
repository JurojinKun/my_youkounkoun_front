import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:myyoukounkoun/components/bottom_sheet_mentions.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
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

  late PageController _pageController;
  bool hideAppBar = false;

  late int datasItemsCount;

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

  _showMentionsUser() {
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
          return const BottomSheetMentions();
        });
  }

  @override
  void initState() {
    super.initState();

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
