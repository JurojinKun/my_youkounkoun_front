import 'package:flutter/material.dart';
import 'package:my_boilerplate/constantes/constantes.dart';

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          await navAuthKey.currentState!
              .pushNamedAndRemoveUntil(bottomNav, (route) => false);
          return false;
        },
        child: Scaffold(
            appBar: AppBar(
          leading: IconButton(
              onPressed: () => navAuthKey.currentState!
                  .pushNamedAndRemoveUntil(bottomNav, (route) => false),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
              )),
          title: const Text("Notifications"),
        )));
  }
}
