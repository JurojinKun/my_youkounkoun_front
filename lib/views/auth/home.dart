import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/providers/token_notifications_provider.dart';

class Home extends ConsumerStatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends ConsumerState<Home> with AutomaticKeepAliveClientMixin {
  String tokenNotif = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    tokenNotif = ref.watch(tokenNotificationsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Home"),
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Push token du device pour tester les notifs push via Firebase Cloud Messaging:",
                style: textStyleCustomMedium(Colors.black, 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 5.0,
              ),
              tokenNotif.trim() != ""
                  ? SelectableText(
                      tokenNotif,
                      textAlign: TextAlign.center,
                    )
                  : const Text("Pas de token"),
            ],
          )),
    );
  }
}
