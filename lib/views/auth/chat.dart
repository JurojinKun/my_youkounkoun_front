import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class Chat extends ConsumerStatefulWidget {
  const Chat({Key? key}) : super(key: key);

  @override
  ChatState createState() => ChatState();
}

class ChatState extends ConsumerState<Chat> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          10.0,
          MediaQuery.of(context).padding.top + 20.0,
          10.0,
          MediaQuery.of(context).padding.bottom + 90.0),
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      child: SizedBox(
        height: MediaQuery.of(context).size.height -
            (MediaQuery.of(context).padding.top +
                20.0 +
                MediaQuery.of(context).padding.bottom +
                90.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.send,
              color: Theme.of(context).brightness == Brightness.light
                  ? cBlack
                  : cWhite,
              size: 40,
            ),
            const SizedBox(height: 15.0),
            Text(
              AppLocalization.of(context)
                  .translate("activities_screen", "no_chat"),
              style: textStyleCustomMedium(
                  Theme.of(context).brightness == Brightness.light
                      ? cBlack
                      : cWhite,
                  14),
              textAlign: TextAlign.center,
              textScaleFactor: 1.0,
            )
          ],
        ),
      ),
    );
  }
}
