import 'package:flutter/material.dart';
import 'package:my_boilerplate/constantes/constantes.dart';

class ModifyProfile extends StatefulWidget {
  const ModifyProfile({Key? key}) : super(key: key);

  @override
  ModifyProfileState createState() => ModifyProfileState();
}

class ModifyProfileState extends State<ModifyProfile> {
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
        leading: IconButton(
          onPressed: () => navProfileKey.currentState!.pop(),
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
          ),
        ),
        title: const Text("Modify profile"),
      ),
    );
  }
}
