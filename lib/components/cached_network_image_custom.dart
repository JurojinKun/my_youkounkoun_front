import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';

class CachedNetworkImageCustom extends StatefulWidget {
  final String profilePictureUrl;
  final double heightContainer;
  final double widthContainer;
  final double iconSize;

  const CachedNetworkImageCustom(
      {Key? key,
      required this.profilePictureUrl,
      required this.heightContainer,
      required this.widthContainer,
      required this.iconSize})
      : super(key: key);

  @override
  CachedNetworkImageCustomState createState() =>
      CachedNetworkImageCustomState();
}

class CachedNetworkImageCustomState extends State<CachedNetworkImageCustom> {
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.profilePictureUrl,
      imageBuilder: ((context, imageProvider) {
        return Container(
            height: widget.heightContainer,
            width: widget.widthContainer,
            foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: cBlue),
                image:
                    DecorationImage(image: imageProvider, fit: BoxFit.cover)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: cBlue),
              color: cGrey.withOpacity(0.2),
            ),
            child: Icon(Icons.person, color: cBlue, size: widget.iconSize));
      }),
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Container(
          height: widget.heightContainer,
          width: widget.widthContainer,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: cBlue),
            color: cGrey.withOpacity(0.2),
          ),
          child: Icon(Icons.person, color: cBlue, size: widget.iconSize),
        );
      },
      errorWidget: (context, url, error) => Container(
        height: widget.heightContainer,
        width: widget.widthContainer,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: cBlue),
          color: cGrey.withOpacity(0.2),
        ),
        child: Icon(Icons.person, color: cBlue, size: widget.iconSize),
      ),
    );
  }
}