import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/message_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';

class PictureFullscreen extends ConsumerStatefulWidget {
  final MessageModel message;
  final UserModel user;

  const PictureFullscreen({Key? key, required this.message, required this.user})
      : super(key: key);

  @override
  PictureFullscreenState createState() => PictureFullscreenState();
}

class PictureFullscreenState extends ConsumerState<PictureFullscreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Hero(
        tag: "picture ${widget.message.message}",
        transitionOnUserGestures: true,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            children: [
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    widget.message.message,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return CircularProgressIndicator(
                        color: Helpers.uiApp(context),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.replay_outlined,
                          color: Helpers.uiApp(context), size: 33);
                    },
                  ),
                ),
              )),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 5.0,
                      right: 5.0),
                  child: SizedBox(
                    height: 70.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: GestureDetector(
                                onTap: () => navAuthKey.currentState!.pushNamed(userProfile, arguments: [widget.user, false]),
                                child: widget.user.profilePictureUrl.trim() == ""
                                  ? Container(
                                      height: 40,
                                      width: 40,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: cBlue),
                                        color: cGrey.withOpacity(0.2),
                                      ),
                                      child: const Icon(Icons.person,
                                          color: cBlue, size: 15),
                                    )
                                  : CachedNetworkImageCustom(
                                      profilePictureUrl:
                                          widget.user.profilePictureUrl,
                                      heightContainer: 40,
                                      widthContainer: 40,
                                      iconSize: 15),
                              )
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () => navAuthKey.currentState!.pushNamed(userProfile, arguments: [widget.user, false]),
                                  child: Text(widget.user.pseudo, style: textStyleCustomBold(Helpers.uiApp(context), 14), textScaleFactor: 1.0),
                                ),
                                Text(Helpers.readTimeStamp(context,
                                    int.parse(widget.message.timestamp)), style: textStyleCustomBold(cGrey, 14), textScaleFactor: 1.0)
                              ],
                            )
                          ],
                        ),
                        Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.hardEdge,
                          child: IconButton(
                            onPressed: () => navAuthKey.currentState!.pop(),
                            icon: Icon(
                              Icons.clear,
                              color: Helpers.uiApp(context),
                              size: 33,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
