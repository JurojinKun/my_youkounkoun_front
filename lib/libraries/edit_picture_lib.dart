import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/providers/current_route_app_provider.dart';
import 'package:myyoukounkoun/providers/edit_account_provider.dart';
import 'package:myyoukounkoun/providers/register_provider.dart';
import 'package:myyoukounkoun/translations/app_localizations.dart';

class EditPictureLib {
  static Future showOptionsImageWithCropped(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 6,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        builder: (BuildContext context) {
          return const EditPictureWidget(cropped: true);
        });
  }

  static Future showOptionsImageWithoutCropped(BuildContext context) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 6,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        builder: (BuildContext context) {
          return const EditPictureWidget(cropped: false);
        });
  }

  static pickImageWithCropped(BuildContext context, ImageSource src,
      bool mounted, WidgetRef ref) async {
    try {
      final image = await ImagePicker().pickImage(source: src);
      if (image != null) {
        if (mounted) {
          await cropImage(context, image.path, ref);
        }
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static pickImageWithoutCropped(BuildContext context, ImageSource src,
      bool mounted, WidgetRef ref) async {
    try {
      final image = await ImagePicker().pickImage(source: src);
      if (image != null) {
        File finalFile = File(image.path);
        ref.read(currentRouteAppNotifierProvider) == "register"
            ? ref
                .read(profilePictureRegisterNotifierProvider.notifier)
                .addNewProfilePicture(finalFile)
            : ref
                .read(editProfilePictureUserNotifierProvider.notifier)
                .editProfilePicture(finalFile);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  static cropImage(BuildContext context, String filePath, WidgetRef ref) async {
    try {
      final croppedImage = await ImageCropper().cropImage(
          uiSettings: [
            AndroidUiSettings(
              dimmedLayerColor: cBlack.withOpacity(0.8),
              toolbarTitle: AppLocalization.of(context)
                  .translate("general", "title_cropper"),
              toolbarColor: Theme.of(context).scaffoldBackgroundColor,
              toolbarWidgetColor: Helpers.uiApp(context),
              cropFrameColor: cWhite,
              cropGridColor: cWhite,
              activeControlsWidgetColor: cBlue,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              hideBottomControls: true,
            ),
            IOSUiSettings(
              title: AppLocalization.of(context)
                  .translate("general", "title_cropper"),
            ),
          ],
          sourcePath: filePath,
          compressFormat: ImageCompressFormat.jpg,
          cropStyle: CropStyle.circle);
      if (croppedImage != null) {
        File finalFile = File(croppedImage.path);
        ref.read(currentRouteAppNotifierProvider) == "register"
            ? ref
                .read(profilePictureRegisterNotifierProvider.notifier)
                .addNewProfilePicture(finalFile)
            : ref
                .read(editProfilePictureUserNotifierProvider.notifier)
                .editProfilePicture(finalFile);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

class EditPictureWidget extends ConsumerStatefulWidget {
  final bool cropped;

  const EditPictureWidget({super.key, required this.cropped});

  @override
  EditPictureWidgetState createState() => EditPictureWidgetState();
}

class EditPictureWidgetState extends ConsumerState<EditPictureWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: Platform.isIOS ? 180 : 160,
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
          boxShadow: [
            BoxShadow(
              color: cBlue.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0.0, -5.0),
            )
          ]),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      AppLocalization.of(context)
                          .translate("register_screen", "add_picture_profile"),
                      style: textStyleCustomBold(Helpers.uiApp(context), 16),
                      textScaler: const TextScaler.linear(1.0)),
                  Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.clear,
                            color:
                                Helpers.uiApp(context))),
                  )
                ],
              ),
            ),
            Expanded(
                child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: cBlue.withOpacity(0.1),
                highlightColor: cBlue.withOpacity(0.1),
                onTap: () async {
                  if (widget.cropped) {
                    await EditPictureLib.pickImageWithCropped(
                        context, ImageSource.gallery, mounted, ref);
                  } else {
                    await EditPictureLib.pickImageWithoutCropped(
                        context, ImageSource.gallery, mounted, ref);
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 15.0,
                    ),
                    const Icon(Icons.photo, color: cBlue, size: 36),
                    const SizedBox(
                      width: 25.0,
                    ),
                    Text(
                        AppLocalization.of(context)
                            .translate("register_screen", "galery"),
                        style: textStyleCustomBold(cBlue, 16),
                        textScaler: const TextScaler.linear(1.0))
                  ],
                ),
              ),
            )),
            Expanded(
                child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: cBlue.withOpacity(0.1),
                highlightColor: cBlue.withOpacity(0.1),
                onTap: () async {
                  if (widget.cropped) {
                    await EditPictureLib.pickImageWithCropped(
                        context, ImageSource.camera, mounted, ref);
                  } else {
                    await EditPictureLib.pickImageWithoutCropped(
                        context, ImageSource.camera, mounted, ref);
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 15.0,
                    ),
                    const Icon(Icons.photo_camera, color: cBlue, size: 36),
                    const SizedBox(
                      width: 25.0,
                    ),
                    Text(
                        AppLocalization.of(context)
                            .translate("register_screen", "camera"),
                        style: textStyleCustomBold(cBlue, 16),
                        textScaler: const TextScaler.linear(1.0))
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
