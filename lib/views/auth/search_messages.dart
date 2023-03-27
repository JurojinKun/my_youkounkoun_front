import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';

class SearchMessages extends ConsumerStatefulWidget {
  const SearchMessages({Key? key}) : super(key: key);

  @override
  SearchMessagesState createState() => SearchMessagesState();
}

class SearchMessagesState extends ConsumerState<SearchMessages> {
  final AppBar appBar = AppBar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: appBarSearchMessages(),
      body: bodySearchMessages(),
    );
  }

  PreferredSizeWidget appBarSearchMessages() {
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
              "Rechercher messages",
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

  Widget bodySearchMessages() {
    return SizedBox.expand(
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
        child: Column(
          children: [],
        ),
      ),
    );
  }
}
