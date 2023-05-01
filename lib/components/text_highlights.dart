import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';

class TextHighlight extends ConsumerStatefulWidget {
  final String text;
  final String keyword;
  final Brightness brightness;

  const TextHighlight(
      {Key? key,
      required this.text,
      required this.keyword,
      required this.brightness})
      : super(key: key);

  @override
  TextHighlightState createState() => TextHighlightState();
}

class TextHighlightState extends ConsumerState<TextHighlight> {
  Future<List<TextSpan>> _highlightText(BuildContext context) async {
    final int keywordLength = widget.keyword.length;
    final List<TextSpan> spans = [];
    int startIndex = 0;
    const int blockSize = 100;

    while (startIndex < widget.text.length) {
      final int index = widget.text
          .toLowerCase()
          .indexOf(widget.keyword.toLowerCase(), startIndex);

      if (index == -1) {
        // Le mot-clé n'a pas été trouvé dans le reste du texte
        spans.add(TextSpan(
          text: widget.text.substring(startIndex),
          style: textStyleCustomRegular(cGrey, 14),
        ));
        break;
      } else {
        final int endIndex = index + keywordLength;

        if (startIndex != index) {
          // Ajouter du texte avant la prochaine occurrence du mot-clé
          spans.add(TextSpan(
            text: widget.text.substring(startIndex, index),
            style: textStyleCustomRegular(cGrey, 14),
          ));
        }

        // Ajouter le mot-clé en surbrillance
        spans.add(TextSpan(
          text: widget.text.substring(index, endIndex),
          style: textStyleCustomBold(
              widget.brightness == Brightness.light ? cBlack : cWhite, 14),
        ));

        startIndex = endIndex;
      }

      if (startIndex % blockSize == 0) {
        // Attendre une fraction de seconde pour ne pas bloquer le thread principal
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<TextSpan>>(
      future: _highlightText(context),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return RichText(
            text: TextSpan(children: snapshot.data!),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: 1.0,
          );
        } else {
          return Text(
            widget.text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textScaleFactor: 1.0,
          );
        }
      },
    );
  }
}
