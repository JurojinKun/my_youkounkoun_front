import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/user_model.dart';

class InformationsConv extends ConsumerStatefulWidget {
  final UserModel user;

  const InformationsConv({Key? key, required this.user}) : super(key: key);

  @override
  InformationsConvState createState() => InformationsConvState();
}

class InformationsConvState extends ConsumerState<InformationsConv> {
  final AppBar appBar = AppBar();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PreferredSize(
        preferredSize: Size(
            MediaQuery.of(context).size.width, appBar.preferredSize.height),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              automaticallyImplyLeading: false,
              elevation: 0,
              shadowColor: Colors.transparent,
              backgroundColor: Colors.transparent,
              systemOverlayStyle: Helpers.uiOverlayApp(context),
              leading: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                clipBehavior: Clip.hardEdge,
                child: IconButton(
                    onPressed: () => navAuthKey.currentState!.pop(),
                    icon: Icon(Icons.arrow_back_ios,
                        color: Helpers.uiApp(context))),
              ),
              title: Text(
                "Informations conversation",
                style: textStyleCustomBold(Helpers.uiApp(context), 20),
                textScaleFactor: 1.0,
              ),
              centerTitle: false,
            ),
          ),
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () => navAuthKey.currentState!
                    .pushNamed(userProfile, arguments: [widget.user, false]),
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10.0)),
                  alignment: Alignment.center,
                  child: Icon(Icons.person, color: Helpers.uiApp(context)),
                ),
              ),
              const SizedBox(height: 5.0),
              Text("Profil", style: textStyleCustomBold(Helpers.uiApp(context), 14),)
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  print("logique sourdine notifications chat");
                },
                child: Container(
                  height: 40.0,
                  width: 40.0,
                  decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10.0)),
                  alignment: Alignment.center,
                  child:
                      Icon(Icons.notifications, color: Helpers.uiApp(context)),
                ),
              ),
              const SizedBox(height: 5.0),
              Text("Sourdine", style: textStyleCustomBold(Helpers.uiApp(context), 14),)
            ],
          )
        ],
      ),
    );
  }
}
