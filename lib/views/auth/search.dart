import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/providers/datas_test_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class Search extends ConsumerStatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  SearchState createState() => SearchState();
}

class SearchState extends ConsumerState<Search>
    with AutomaticKeepAliveClientMixin {
  AppBar appBar = AppBar();

  late RefreshController refreshController;

  late int datasItemsCount;
  bool datasEnabled = false;

  Future<void> initDatasSearch() async {
    datasItemsCount = ref.read(datasTestNotifierProvider);
    await Future.delayed(const Duration(seconds: 6), () {
      setState(() {
        datasEnabled = true;
      });
    });
  }

  //logic pull to refresh
  Future<void> _refreshDatasSearch() async {
    await Future.delayed(const Duration(seconds: 3));
    ref.read(datasTestNotifierProvider.notifier).refreshDatasTest();
    refreshController.refreshCompleted(resetFooterState: true);
  }

  //logic load more datas
  Future<void> _loadMoreDatasSearch() async {
    await Future.delayed(const Duration(seconds: 3));
    if (datasItemsCount < 50) {
      ref.read(datasTestNotifierProvider.notifier).loadMoreDatasTest();
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }

  @override
  void initState() {
    super.initState();

    initDatasSearch();

    refreshController = RefreshController(initialRefresh: false);
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    datasItemsCount = ref.watch(datasTestNotifierProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width,
            appBar.preferredSize.height + 65.0),
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
                  AppLocalization.of(context)
                      .translate("search_screen", "search"),
                  style: textStyleCustomBold(Helpers.uiApp(context), 20),
                  textScaleFactor: 1.0),
              centerTitle: false,
              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(65.0),
                  child: SizedBox(
                    height: 65.0,
                    child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                elevation: 6,
                                backgroundColor: Theme.of(context).canvasColor,
                                foregroundColor: cBlue,
                                shadowColor: Colors.transparent,
                                side:
                                    const BorderSide(width: 2.0, color: cBlue),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                            onPressed: () => navSearchKey!.currentState!
                                .pushNamed(recentSearches),
                            child: Row(
                              children: [
                                Icon(Icons.search,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? cBlack
                                        : cWhite),
                                const SizedBox(width: 15.0),
                                Expanded(
                                    child: Text(
                                        AppLocalization.of(context).translate(
                                            "general", "search_user"),
                                        style: textStyleCustomBold(
                                            Theme.of(context).brightness ==
                                                    Brightness.light
                                                ? cBlack
                                                : cWhite,
                                            16),
                                        textScaleFactor: 1.0))
                              ],
                            ))),
                  )),
            ),
          ),
        ),
      ),
      body: SizedBox.expand(
        child: !datasEnabled
            ? SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                    20.0,
                    MediaQuery.of(context).padding.top +
                        appBar.preferredSize.height +
                        85.0,
                    20.0,
                    90.0),
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        AppLocalization.of(context)
                            .translate("search_screen", "explore"),
                        style:
                            textStyleCustomBold(Helpers.uiApp(context), 20.0),
                        textScaleFactor: 1.0),
                    const SizedBox(height: 25.0),
                    datasShimmer()
                  ],
                ))
            : SmartRefresher(
                controller: refreshController,
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropMaterialHeader(
                  offset: MediaQuery.of(context).padding.top +
                      appBar.preferredSize.height +
                      65.0,
                  distance: 40.0,
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  color: cBlue,
                ),
                footer: ClassicFooter(
                  height: MediaQuery.of(context).padding.bottom + 110.0,
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
                      AppLocalization.of(context)
                          .translate("general", "no_more_data"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 14),
                      textScaleFactor: 1.0,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                onRefresh: _refreshDatasSearch,
                onLoading: _loadMoreDatasSearch,
                child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20.0,
                        MediaQuery.of(context).padding.top +
                            appBar.preferredSize.height +
                            85.0,
                        20.0,
                        20.0),
                    physics: const NeverScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            AppLocalization.of(context)
                                .translate("search_screen", "explore"),
                            style: textStyleCustomBold(
                                Helpers.uiApp(context), 20.0),
                            textScaleFactor: 1.0),
                        const SizedBox(height: 25.0),
                        datasItems()
                      ],
                    )),
              ),
      ),
    );
  }

  Widget datasShimmer() {
    return Shimmer.fromColors(
        baseColor: Theme.of(context).scaffoldBackgroundColor,
        highlightColor: cBlue.withOpacity(0.5),
        direction: ShimmerDirection.ltr,
        period: const Duration(milliseconds: 1500),
        child: GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.0,
                mainAxisExtent: 200.0),
            itemCount: 10,
            itemBuilder: (_, int index) {
              return Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10.0)),
              );
            }));
  }

  Widget datasItems() {
    return GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.0,
            mainAxisExtent: 200.0),
        itemCount: datasItemsCount,
        itemBuilder: (_, int index) {
          String dataTestString = "Data test $index";
          return InkWell(
            splashColor: cBlue.withOpacity(0.3),
            highlightColor: cBlue.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10.0),
            onTap: () => navAuthKey.currentState!
                .pushNamed(dataTest, arguments: [index]),
            child: Hero(
              tag: "data test $index",
              transitionOnUserGestures: true,
              child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: cBlue),
                    color: cBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.0)),
                padding: const EdgeInsets.all(8.0),
                alignment: Alignment.center,
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(dataTestString,
                      style: textStyleCustomBold(Helpers.uiApp(context), 16),
                      textAlign: TextAlign.center,
                      textScaleFactor: 1.0),
                ),
              ),
            ),
          );
        });
  }
}
