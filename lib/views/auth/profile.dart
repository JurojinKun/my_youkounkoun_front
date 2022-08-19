import 'package:flutter/material.dart';
import 'package:my_boilerplate/constantes/constantes.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profile"),
        actions: [
          IconButton(
              onPressed: () =>
                  navAuthKey.currentState!.pushNamed(modifyProfile),
              icon: const Icon(Icons.settings)),
          IconButton(
              onPressed: () =>
                  navAuthKey.currentState!.pushNamed(notifications),
              icon: const Icon(Icons.notifications_active))
        ],
      ),
    );
  }
}
