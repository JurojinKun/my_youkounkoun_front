import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/message_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/providers/chat_details_provider.dart';
import 'package:myyoukounkoun/providers/locale_language_provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';

class Multimedias extends ConsumerStatefulWidget {
  final UserModel user;

  const Multimedias({Key? key, required this.user}) : super(key: key);

  @override
  MultimediasState createState() => MultimediasState();
}

class MultimediasState extends ConsumerState<Multimedias> {
  final AppBar appBar = AppBar();

  bool multimediasEnabled = false;
  List<MessageModel> multimedias = [];

  late RefreshController refreshController;

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
    //TODO order by timestamp du plus récent au plus vieux
    messages.sort(
        (a, b) => int.parse(b.timestamp).compareTo(int.parse(a.timestamp)));

    return messages;
  }

  //TODO logic loading multimedias current conv
  Future<void> _initMultimedias() async {
    try {
      await Future.delayed(const Duration(seconds: 3));
      List<MessageModel> messages = getListMessagesUsers();
      for (var message in messages) {
        if (message.type != "text") {
          multimedias.add(message);
        }
      }
      setState(() {
        multimediasEnabled = true;
      });
      // TODO seulement si on atteint pas la limit de datas qu'on va cherché (par ex: si la length de multimédias est en dessous de 15 qui est la limite dans la recherche)
      refreshController.loadNoData();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  //TODO logic loading more multimedias current conv

  // Future<void> _loadMoreMultimedias() async {
  //   await Future.delayed(const Duration(seconds: 3));
  //   if (multimedias.length < 50) {
  //     for (var i = 0; i < 15; i++) {
  //       multimedias.add(i);
  //     }
  //     setState(() {});
  //     refreshController.loadComplete();
  //   } else {
  //     refreshController.loadNoData();
  //   }
  // }

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
                  30.0,
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
        : GlowingOverscrollIndicator(
            axisDirection: AxisDirection.down,
            color: cBlue,
            child: SmartRefresher(
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
              // onLoading: _loadMoreMultimedias,
              child: multimediasItems(),
            ),
          );
  }

  Widget multimediasItems() {
    return GridView.builder(
        padding: EdgeInsets.fromLTRB(
            20.0,
            MediaQuery.of(context).padding.top +
                appBar.preferredSize.height +
                30.0,
            20.0,
            MediaQuery.of(context).padding.bottom + 20.0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.0,
            mainAxisExtent: 200.0),
        itemCount: multimedias.length,
        itemBuilder: (_, int index) {
          return multimedia(multimedias[index]);
        });
  }

  Widget multimedia(MessageModel message) {
    switch (message.type) {
      case "image":
        return GestureDetector(
          onTap: () =>
              navAuthKey.currentState!.pushNamed(carousselPictures, arguments: [
            multimedias,
            message,
            widget.user,
            ref.read(currentConvNotifierProvider).themeConv.isEmpty
                ? Color.lerp(
                    const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)
                : Color.lerp(
                    Helpers.stringToColor(
                        ref.read(currentConvNotifierProvider).themeConv[0]),
                    Helpers.stringToColor(
                        ref.read(currentConvNotifierProvider).themeConv[1]),
                    0.5)
          ]),
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Hero(
                tag: "picture ${message.message}",
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
                          color: ref
                                  .read(currentConvNotifierProvider)
                                  .themeConv
                                  .isEmpty
                              ? Color.lerp(const Color(0xFF4284C4),
                                  const Color(0xFF00A9BC), 0.5)
                              : Color.lerp(
                                  Helpers.stringToColor(ref
                                      .read(currentConvNotifierProvider)
                                      .themeConv[0]),
                                  Helpers.stringToColor(ref
                                      .read(currentConvNotifierProvider)
                                      .themeConv[1]),
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
                            color:
                                Helpers.uiApp(context),
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
                        color: ref
                                .read(currentConvNotifierProvider)
                                .themeConv
                                .isEmpty
                            ? Color.lerp(const Color(0xFF4284C4),
                                const Color(0xFF00A9BC), 0.5)
                            : Color.lerp(
                                Helpers.stringToColor(ref
                                    .read(currentConvNotifierProvider)
                                    .themeConv[0]),
                                Helpers.stringToColor(ref
                                    .read(currentConvNotifierProvider)
                                    .themeConv[1]),
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
                          color:
                              Helpers.uiApp(context),
                          size: 33),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      case "gif":
        return GestureDetector(
          onTap: () =>
              navAuthKey.currentState!.pushNamed(carousselPictures, arguments: [
            multimedias,
            message,
            widget.user,
            ref.read(currentConvNotifierProvider).themeConv.isEmpty
                ? Color.lerp(
                    const Color(0xFF4284C4), const Color(0xFF00A9BC), 0.5)
                : Color.lerp(
                    Helpers.stringToColor(
                        ref.read(currentConvNotifierProvider).themeConv[0]),
                    Helpers.stringToColor(
                        ref.read(currentConvNotifierProvider).themeConv[1]),
                    0.5)
          ]),
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).canvasColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10.0)),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Hero(
                  tag: "gif ${message.message}",
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
                            color: ref
                                    .read(currentConvNotifierProvider)
                                    .themeConv
                                    .isEmpty
                                ? Color.lerp(const Color(0xFF4284C4),
                                    const Color(0xFF00A9BC), 0.5)
                                : Color.lerp(
                                    Helpers.stringToColor(ref
                                        .read(currentConvNotifierProvider)
                                        .themeConv[0]),
                                    Helpers.stringToColor(ref
                                        .read(currentConvNotifierProvider)
                                        .themeConv[1]),
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
                          color: ref
                                  .read(currentConvNotifierProvider)
                                  .themeConv
                                  .isEmpty
                              ? Color.lerp(const Color(0xFF4284C4),
                                  const Color(0xFF00A9BC), 0.5)
                              : Color.lerp(
                                  Helpers.stringToColor(ref
                                      .read(currentConvNotifierProvider)
                                      .themeConv[0]),
                                  Helpers.stringToColor(ref
                                      .read(currentConvNotifierProvider)
                                      .themeConv[1]),
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
                            color: Helpers.uiApp(context), size: 33),
                      );
                    },
                  ),
                )),
          ),
        );
      default:
        return const SizedBox();
    }
  }
}
