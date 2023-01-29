import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';

class PictureFullscreen extends ConsumerStatefulWidget {
  final String imageUrl;

  const PictureFullscreen({Key? key, required this.imageUrl}) : super(key: key);

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
        tag: "picture ${widget.imageUrl}",
        transitionOnUserGestures: true,
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: Theme.of(context).scaffoldBackgroundColor,
          child: Stack(
            children: [
              Center(
                child: Image.network(
                  widget.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (BuildContext context, Widget child,
                      ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return CircularProgressIndicator(
                      color: Theme.of(context).brightness == Brightness.light
                          ? cBlack
                          : cWhite,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.replay_outlined,
                        color: Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        size: 33);
                  },
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 5.0,
                      right: 5.0),
                  child: Material(
                    color: Colors.transparent,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.hardEdge,
                    child: IconButton(
                      onPressed: () => navAuthKey.currentState!.pop(),
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).brightness == Brightness.light
                            ? cBlack
                            : cWhite,
                        size: 33,
                      ),
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
