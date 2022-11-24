import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/translations/app_localizations.dart';

class EditSecurity extends ConsumerStatefulWidget {
  const EditSecurity({Key? key}) : super(key: key);

  @override
  EditSecurityState createState() => EditSecurityState();
}

class EditSecurityState extends ConsumerState<EditSecurity> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        leading: IconButton(
            onPressed: () => navAuthKey.currentState!.pop(),
            icon: Icon(Icons.arrow_back_ios,
                color: Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite)),
        centerTitle: false,
        title: Text(AppLocalization.of(context).translate("edit_security_screen", "security_account"),
            style: textStyleCustomBold(
                Theme.of(context).brightness == Brightness.light
                    ? cBlack
                    : cWhite,
                20),
            textScaleFactor: 1.0),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20.0,),
              Text("Tu peux modifier la sécurité de ton compte directement ici !", style: textStyleCustomRegular(Theme.of(context).brightness == Brightness.light ? cBlack : cWhite, 16), textScaleFactor: 1.0,),
              const SizedBox(height: 25.0,),
              Text(
                "Email",
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    18),
                textAlign: TextAlign.center,
                textScaleFactor: 1.0,
              ),
              const SizedBox(height: 15.0,),
              Text(
                "Mot de passe",
                style: textStyleCustomBold(
                    Theme.of(context).brightness == Brightness.light
                        ? cBlack
                        : cWhite,
                    18),
                textAlign: TextAlign.center,
                textScaleFactor: 1.0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
