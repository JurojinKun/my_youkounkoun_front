import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/providers/user_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends ConsumerStatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends ConsumerState<Profile>
    with AutomaticKeepAliveClientMixin {
  Future<void> _tryLogOut() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      ref.read(userNotifierProvider.notifier).clearUser();
      prefs.remove("token");
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

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

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Profile"),
        actions: [
          IconButton(
              onPressed: () =>
                  navProfileKey!.currentState!.pushNamed(modifyProfile),
              icon: const Icon(Icons.settings)),
          IconButton(
              onPressed: () async => await _tryLogOut(),
              icon: const Icon(Icons.logout))
        ],
      ),
    );
  }
}
