import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/helpers/helpers.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ValidateUser extends ConsumerStatefulWidget {
  const ValidateUser({Key? key}) : super(key: key);

  @override
  ValidateUserState createState() => ValidateUserState();
}

class ValidateUserState extends ConsumerState<ValidateUser> {
  late TextEditingController _codeController;

  @override
  void initState() {
    super.initState();

    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Helpers.hideKeyboard(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          title: Text(
            "Vérifier mon compte",
            style: textStyleCustomBold(
                Theme.of(context).brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                20),
            textAlign: TextAlign.center,
            textScaleFactor: 1.0,
          ),
          actions: [
            IconButton(
                onPressed: () => navAuthKey.currentState!.pop(),
                icon: Icon(
                  Icons.clear,
                  color: Theme.of(context).brightness == Brightness.light
                      ? Colors.black
                      : Colors.white,
                ))
          ],
          centerTitle: false,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
          child: Column(
            children: [
              Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Afin de valider ton compte, tu peux demander un code qui te sera envoyé sur l'adresse mail lié à celui-ci.",
                    style: textStyleCustomMedium(
                        Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        14),
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.0,
                  ),
                  TextButton(
                      onPressed: () {},
                      child: Text("M'envoyer un code",
                          style: textStyleCustomBold(cBlue, 14.0),
                          textAlign: TextAlign.center,
                          textScaleFactor: 1.0)),
                ],
              )),
              Expanded(child: Center(
                child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PinCodeTextField(
                          appContext: context,
                          textStyle: textStyleCustomBold(Colors.white,
                              18 / MediaQuery.of(context).textScaleFactor),
                          length: 6,
                          animationType: AnimationType.fade,
                          autoDisposeControllers: false,
                          pinTheme: PinTheme(
                              shape: PinCodeFieldShape.underline,
                              fieldHeight: 30,
                              fieldWidth: 30,
                              activeColor: Colors.white,
                              inactiveColor: Colors.white,
                              selectedColor: Colors.white),
                          cursorColor: Colors.white,
                          animationDuration: const Duration(milliseconds: 300),
                          controller: _codeController,
                          keyboardType: TextInputType.number,
                          onCompleted: (value) {
                            Helpers.hideKeyboard(context);
                          },
                          onChanged: (value) {
                            setState(() {
                              value = _codeController.text;
                            });
                          },
                          enablePinAutofill: false,
                        )),
              )),
              Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: cBlue,
                                foregroundColor: cWhite,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                            child: Text(
                              "Vérifier",
                              textScaleFactor: 1.0,
                              style: textStyleCustomBold(
                                  Theme.of(context).brightness == Brightness.light
                                      ? cBlack
                                      : cWhite,
                                  20),
                            )),
                      ),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
