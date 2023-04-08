import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        body: PageView.builder(
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
                            style:
                                textStyleCustomBold(Helpers.uiApp(context), 18),
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
                          style:
                              textStyleCustomBold(Helpers.uiApp(context), 18),
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0),
                    ),
                  ),
                );
              });
            }));
  }
}
