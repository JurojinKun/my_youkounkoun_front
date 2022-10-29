import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_boilerplate/constantes/constantes.dart';
import 'package:my_boilerplate/helpers/helpers.dart';
import 'package:my_boilerplate/models/user_model.dart';
import 'package:my_boilerplate/providers/user_provider.dart';

class Register extends ConsumerStatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  RegisterState createState() => RegisterState();
}

class RegisterState extends ConsumerState<Register>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  late TextEditingController _mailController,
      _passwordController,
      _pseudoController;
  late FocusNode _mailFocusNode, _passwordFocusNode, _pseudoFocusNode;

  bool _isKeyboard = false;
  bool _passwordObscure = true;
  bool _loadingStepOne = false;
  bool _loadingStepTwo = false;
  bool _loadingStepThree = false;
  bool _loadingStepFourth = false;
  bool _loadingStepFifth = false;
  bool _loadingStepSixth = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 6, vsync: this);

    _mailController = TextEditingController();
    _passwordController = TextEditingController();
    _pseudoController = TextEditingController();
    _mailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _pseudoFocusNode = FocusNode();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    final newValue = bottomInset > 0.0;
    if (newValue != _isKeyboard) {
      setState(() {
        _isKeyboard = newValue;
      });
    }
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _tabController.dispose();

    _mailController.dispose();
    _passwordController.dispose();
    _pseudoController.dispose();
    _mailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _pseudoFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Helpers.hideKeyboard(context),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          leading: IconButton(
              onPressed: () => navNonAuthKey.currentState!.pop(),
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.black,
              )),
          title: Text(
            "Inscription",
            style: textStyleCustomBold(Colors.black, 23),
          ),
          centerTitle: false,
          actions: [stepRegister()],
        ),
        body: TabBarView(
            controller: _tabController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              firstStepRegister(),
              secondStepRegister(),
              thirdStepRegister(),
              fourthStepRegister(),
              fifthStepRegister(),
              sixthStepRegister()
            ]),
      ),
    );
  }

  Widget stepRegister() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: TabPageSelector(
        controller: _tabController,
        selectedColor: Colors.blue,
        color: Colors.transparent,
        indicatorSize: 14,
      ),
    );
  }

  firstStepRegister() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 25.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 25.0,
          ),
          Text(
            "Première étape, entre ton adresse mail ainsi que ton mot de passe pour la création de ton compte.",
            style: textStyleCustomMedium(Colors.black, 14),
          ),
          Expanded(
              child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            children: [
              const SizedBox(height: 55.0),
              TextField(
                controller: _mailController,
                focusNode: _mailFocusNode,
                maxLines: 1,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                onChanged: (val) {
                  setState(() {
                    val = _mailController.text;
                  });
                },
                onSubmitted: (val) {
                  FocusScope.of(context).requestFocus(_passwordFocusNode);
                },
                decoration: InputDecoration(
                    hintText: "Email",
                    hintStyle: textStyleCustomRegular(Colors.grey, 14),
                    prefixIcon: Icon(Icons.mail,
                        color: _mailFocusNode.hasFocus
                            ? Colors.blue
                            : Colors.grey),
                    suffixIcon: _mailController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _mailController.clear();
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color: _mailFocusNode.hasFocus
                                  ? Colors.blue
                                  : Colors.grey,
                            ))
                        : const SizedBox()),
              ),
              const SizedBox(
                height: 55.0,
              ),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                obscureText: _passwordObscure,
                onChanged: (val) {
                  setState(() {
                    val = _passwordController.text;
                  });
                },
                onSubmitted: (val) {
                  Helpers.hideKeyboard(context);
                },
                decoration: InputDecoration(
                    hintText: "Mot de passe",
                    hintStyle: textStyleCustomRegular(Colors.grey, 14),
                    prefixIcon: Icon(Icons.lock,
                        color: _passwordFocusNode.hasFocus
                            ? Colors.blue
                            : Colors.grey),
                    suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordObscure = !_passwordObscure;
                          });
                        },
                        icon: Icon(
                          _passwordObscure
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: _passwordFocusNode.hasFocus
                              ? Colors.blue
                              : Colors.grey,
                        ))),
              ),
            ],
          )),
          _isKeyboard
              ? const SizedBox()
              : Container(
                  height: 150,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.center,
                  child: SizedBox(
                      height: 50.0,
                      width: MediaQuery.of(context).size.width / 2,
                      child: ElevatedButton(
                          onPressed: () async {
                            if (_mailController.text.isNotEmpty &&
                                EmailValidator.validate(_mailController.text) &&
                                _passwordController.text.isNotEmpty) {
                              setState(() {
                                _loadingStepOne = true;
                              });
                              _tabController.index += 1;
                              setState(() {
                                _loadingStepOne = false;
                              });
                            }
                          },
                          child: _loadingStepOne
                              ? const SizedBox(
                                  height: 15,
                                  width: 15,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 1.0,
                                    ),
                                  ),
                                )
                              : Text(
                                  "Suivant",
                                  style:
                                      textStyleCustomMedium(Colors.white, 23),
                                ))),
                )
        ],
      ),
    );
  }

  secondStepRegister() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 25.0,
          ),
          Text(
            "Seconde étape, entre le pseudonyme qui te servira d'identifiant pour ton compte.",
            style: textStyleCustomMedium(Colors.black, 14),
          ),
          Expanded(
              child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            children: [
              const SizedBox(
                height: 55.0,
              ),
              TextField(
                controller: _pseudoController,
                focusNode: _pseudoFocusNode,
                maxLines: 1,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                onChanged: (val) {
                  setState(() {
                    val = _pseudoController.text;
                  });
                },
                onSubmitted: (val) {
                  Helpers.hideKeyboard(context);
                },
                decoration: InputDecoration(
                    hintText: "Pseudonyme",
                    hintStyle: textStyleCustomRegular(Colors.grey, 14),
                    prefixIcon: Icon(Icons.person,
                        color: _pseudoFocusNode.hasFocus
                            ? Colors.blue
                            : Colors.grey),
                    suffixIcon: _pseudoController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _pseudoController.clear();
                              });
                            },
                            icon: Icon(
                              Icons.clear,
                              color: _pseudoFocusNode.hasFocus
                                  ? Colors.blue
                                  : Colors.grey,
                            ))
                        : const SizedBox()),
              ),
            ],
          )),
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: _isKeyboard
                ? const SizedBox()
                : Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _tabController.index -= 1;
                            });
                          },
                          child: Text(
                            "Précédent",
                            style: textStyleCustomBold(
                                Colors.black, 14, TextDecoration.underline),
                          )),
                      SizedBox(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width / 2,
                          child: ElevatedButton(
                              onPressed: () async {
                                if (_pseudoController.text.isNotEmpty) {
                                  setState(() {
                                    _loadingStepTwo = true;
                                  });
                                  _tabController.index += 1;
                                  setState(() {
                                    _loadingStepTwo = false;
                                  });
                                }
                              },
                              child: _loadingStepTwo
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 1.0,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Suivant",
                                      style: textStyleCustomMedium(
                                          Colors.white, 23),
                                    ))),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  thirdStepRegister() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 25.0,
          ),
          Text(
            "Troisième étape, renseigne ton genre.",
            style: textStyleCustomMedium(Colors.black, 14),
          ),
          Expanded(
              child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            children: [
              const SizedBox(
                height: 55.0,
              ),
            ],
          )),
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: _isKeyboard
                ? const SizedBox()
                : Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _tabController.index -= 1;
                            });
                          },
                          child: Text(
                            "Précédent",
                            style: textStyleCustomBold(
                                Colors.black, 14, TextDecoration.underline),
                          )),
                      SizedBox(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width / 2,
                          child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _loadingStepThree = true;
                                });
                                _tabController.index += 1;
                                setState(() {
                                  _loadingStepThree = false;
                                });
                              },
                              child: _loadingStepThree
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 1.0,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Suivant",
                                      style: textStyleCustomMedium(
                                          Colors.white, 23),
                                    ))),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  fourthStepRegister() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 25.0,
          ),
          Text(
            "Quatrième étape, renseigne ton âge.",
            style: textStyleCustomMedium(Colors.black, 14),
          ),
          Expanded(
              child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            children: [
              const SizedBox(
                height: 55.0,
              ),
            ],
          )),
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: _isKeyboard
                ? const SizedBox()
                : Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _tabController.index -= 1;
                            });
                          },
                          child: Text(
                            "Précédent",
                            style: textStyleCustomBold(
                                Colors.black, 14, TextDecoration.underline),
                          )),
                      SizedBox(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width / 2,
                          child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _loadingStepFourth = true;
                                });
                                _tabController.index += 1;
                                setState(() {
                                  _loadingStepFourth = false;
                                });
                              },
                              child: _loadingStepFourth
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 1.0,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Suivant",
                                      style: textStyleCustomMedium(
                                          Colors.white, 23),
                                    ))),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  fifthStepRegister() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 25.0,
          ),
          Text(
            "Cinquième étape, renseigne ta nationnalité.",
            style: textStyleCustomMedium(Colors.black, 14),
          ),
          Expanded(
              child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            children: [
              const SizedBox(
                height: 55.0,
              ),
            ],
          )),
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: _isKeyboard
                ? const SizedBox()
                : Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _tabController.index -= 1;
                            });
                          },
                          child: Text(
                            "Précédent",
                            style: textStyleCustomBold(
                                Colors.black, 14, TextDecoration.underline),
                          )),
                      SizedBox(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width / 2,
                          child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _loadingStepFifth = true;
                                });
                                _tabController.index += 1;
                                setState(() {
                                  _loadingStepFifth = false;
                                });
                              },
                              child: _loadingStepFifth
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 1.0,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "Suivant",
                                      style: textStyleCustomMedium(
                                          Colors.white, 23),
                                    ))),
                    ],
                  ),
          )
        ],
      ),
    );
  }

  sixthStepRegister() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 25.0,
          ),
          Text(
            "Et enfin dernière étape, ajoute une photo de profil afin de finaliser ton inscription.",
            style: textStyleCustomMedium(Colors.black, 14),
          ),
          Expanded(
              child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            children: [
              const SizedBox(
                height: 55.0,
              ),
            ],
          )),
          Container(
            height: 150,
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.center,
            child: _isKeyboard
                ? const SizedBox()
                : Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _tabController.index -= 1;
                            });
                          },
                          child: Text(
                            "Précédent",
                            style: textStyleCustomBold(
                                Colors.black, 14, TextDecoration.underline),
                          )),
                      SizedBox(
                          height: 50.0,
                          width: MediaQuery.of(context).size.width / 2,
                          child: ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _loadingStepSixth = true;
                                });
                                ref
                                    .read(userNotifierProvider.notifier)
                                    .initUser(User(
                                        id: 1,
                                        token: "tokenTest1234",
                                        email: "ccommunay@gmail.com",
                                        pseudo: "0ruj",
                                        gender: "male",
                                        age: 25,
                                        nationality: "French",
                                        profilePictureUrl:
                                            "https://pbs.twimg.com/media/FRMrb3IXEAMZfQU.jpg:large"));
                                setState(() {
                                  _loadingStepSixth = false;
                                });
                              },
                              child: _loadingStepSixth
                                  ? const SizedBox(
                                      height: 15,
                                      width: 15,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 1.0,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      "S'inscrire",
                                      style: textStyleCustomMedium(
                                          Colors.white, 23),
                                    ))),
                    ],
                  ),
          )
        ],
      ),
    );
  }
}
