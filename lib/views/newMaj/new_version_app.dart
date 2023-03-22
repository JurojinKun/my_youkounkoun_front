import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import 'package:myyoukounkoun/components/alert_dialog_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/main.dart';
import 'package:myyoukounkoun/providers/new_maj_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class NewVersionApp extends ConsumerStatefulWidget {
  const NewVersionApp({Key? key}) : super(key: key);

  @override
  NewVersionAppState createState() => NewVersionAppState();
}

class NewVersionAppState extends ConsumerState<NewVersionApp>
    with SingleTickerProviderStateMixin {
  bool _alreadyCliked = false;

  Future _showDialogMajAvailable() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        builder: (context) {
          return StatefulBuilder(builder: ((context, setState) {
            return AlertDialogCustom(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              title: Text(
                AppLocalization.of(context)
                    .translate("new_maj_screen", "title"),
                style: textStyleCustomBold(Helpers.uiApp(context), 16),
              ),
              content: Text(
                AppLocalization.of(context)
                    .translate("new_maj_screen", "content_available"),
                style: textStyleCustomRegular(Helpers.uiApp(context), 14),
              ),
              actions: [
                TextButton(
                    onPressed: () async {
                      if (!_alreadyCliked) {
                        setState(() {
                          _alreadyCliked = true;
                        });
                        await Helpers.launchStore(
                            ref.read(
                                newMajInfosNotifierProvider)["linkAndroid"],
                            ref.read(newMajInfosNotifierProvider)["linkIOS"]);
                        if (mounted) {
                          setState(() {
                            _alreadyCliked = false;
                          });
                        }
                      }
                    },
                    child: Text(
                      AppLocalization.of(context)
                          .translate("new_maj_screen", "go_now"),
                      style: textStyleCustomMedium(cBlue, 14),
                    )),
                TextButton(
                    onPressed: () async {
                      if (!_alreadyCliked) {
                        setState(() {
                          _alreadyCliked = true;
                        });
                        await loadDataUser(ref);
                        ref
                            .read(
                                newMajInfosAlreadySeenNotifierProvider.notifier)
                            .newMajInfosAlreadySeen();
                        if (mounted) {
                          Navigator.pop(context);
                          setState(() {
                            _alreadyCliked = false;
                          });
                        }
                      }
                    },
                    child: Text(
                      AppLocalization.of(context)
                          .translate("new_maj_screen", "later"),
                      style: textStyleCustomMedium(cRed, 14),
                    ))
              ],
            );
          }));
        });
  }

  Future _showDialogMajRequired() {
    return showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Theme.of(context).brightness == Brightness.light
            ? Colors.black.withOpacity(0.1)
            : Colors.white.withOpacity(0.1),
        builder: (context) {
          return AlertDialogCustom(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            title: Text(
              AppLocalization.of(context).translate("new_maj_screen", "title"),
              style: textStyleCustomBold(Helpers.uiApp(context), 16),
            ),
            content: Text(
              AppLocalization.of(context)
                  .translate("new_maj_screen", "content_required"),
              style: textStyleCustomRegular(Helpers.uiApp(context), 14),
            ),
            actions: [
              TextButton(
                  onPressed: () async {
                    if (!_alreadyCliked) {
                      setState(() {
                        _alreadyCliked = true;
                      });
                      await Helpers.launchStore(
                          ref.read(newMajInfosNotifierProvider)["linkAndroid"],
                          ref.read(newMajInfosNotifierProvider)["linkIOS"]);
                      setState(() {
                        _alreadyCliked = false;
                      });
                    }
                  },
                  child: Text(
                    AppLocalization.of(context)
                        .translate("new_maj_screen", "go_now"),
                    style: textStyleCustomMedium(cBlue, 14),
                  )),
            ],
          );
        });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      ref.read(newMajInfosNotifierProvider)["newMajRequired"]
          ? await _showDialogMajRequired()
          : await _showDialogMajAvailable();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: Helpers.uiOverlayApp(context),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }
}
