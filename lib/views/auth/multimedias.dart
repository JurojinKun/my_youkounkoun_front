import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class Multimedias extends ConsumerStatefulWidget {
  const Multimedias({Key? key}) : super(key: key);

  @override
  MultimediasState createState() => MultimediasState();
}

class MultimediasState extends ConsumerState<Multimedias> {
  final AppBar appBar = AppBar();

  bool multimediasEnabled = false;
  List multimedias = [];

  late RefreshController refreshController;

  //TODO logic loading multimedias current conv
  Future<void> _initMultimedias() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      for (var i = 0; i < 15; i++) {
        multimedias.add(i);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    setState(() {
      multimediasEnabled = true;
    });
  }

  //TODO logic loading more multimedias current conv
  Future<void> _loadMoreMultimedias() async {
    await Future.delayed(const Duration(seconds: 3));
    if (multimedias.length < 50) {
      for (var i = 0; i < 15; i++) {
        multimedias.add(i);
      }
      setState(() {});
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }

  @override
  void initState() {
    super.initState();

    _initMultimedias();

    refreshController = RefreshController(initialRefresh: false);
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
      appBar: appBarMultimedias(),
      body: bodyMultimedias(),
    );
  }

  PreferredSizeWidget appBarMultimedias() {
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
              "Multimédias conversation",
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

  Widget bodyMultimedias() {
    return SizedBox.expand(
        child: !multimediasEnabled ? multimediasShimmer() : multimediasConv());
  }

  Widget multimediasShimmer() {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).canvasColor,
      highlightColor: cBlue.withOpacity(0.5),
      child: GridView.builder(
          padding: EdgeInsets.fromLTRB(
              20.0,
              MediaQuery.of(context).padding.top +
                  appBar.preferredSize.height +
                  20.0,
              20.0,
              MediaQuery.of(context).padding.bottom + 20.0),
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.0,
              mainAxisExtent: 200.0),
          itemCount: 6,
          itemBuilder: (_, int index) {
            return Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10.0)),
            );
          }),
    );
  }

  Widget multimediasConv() {
    return multimedias.isEmpty
        ? Center(
            child: Text(
              "Aucun multimédia pour cette conversation actuellement",
              style: textStyleCustomBold(Helpers.uiApp(context), 16),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            ),
          )
        : SmartRefresher(
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
                  "Pas plus de multimédias actuellement",
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
            onLoading: _loadMoreMultimedias,
            child: multimediasItems(),
          );
  }

  Widget multimediasItems() {
    return GridView.builder(
        padding: EdgeInsets.fromLTRB(
            20.0,
            MediaQuery.of(context).padding.top +
                appBar.preferredSize.height +
                20.0,
            20.0,
            MediaQuery.of(context).padding.bottom + 20.0),
        shrinkWrap: true,
        physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics()),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.0,
            mainAxisExtent: 200.0),
        itemCount: multimedias.length,
        itemBuilder: (_, int index) {
          return Container(
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor,
                borderRadius: BorderRadius.circular(10.0)),
          );
        });
  }
}
