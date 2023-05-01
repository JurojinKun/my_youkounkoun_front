import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

import 'package:myyoukounkoun/components/cached_network_image_custom.dart';
import 'package:myyoukounkoun/constantes/constantes.dart';
import 'package:myyoukounkoun/helpers/helpers.dart';
import 'package:myyoukounkoun/models/comment_model.dart';
import 'package:myyoukounkoun/models/user_model.dart';

class MentionText extends ConsumerStatefulWidget {
  final CommentModel mentionComment;
  final String encryptionKey;

  const MentionText(
      {Key? key, required this.mentionComment, required this.encryptionKey})
      : super(key: key);

  @override
  MentionTextState createState() => MentionTextState();
}

class MentionTextState extends ConsumerState<MentionText> {
  List<String> segmentsComment = [];

  List<String> splitTextWithMentions(String input) {
    RegExp pattern = RegExp(r'\s+');
    List<String> segments = input.split(pattern);
    return segments.map((segment) {
      return segment;
    }).toList();
  }

  UserModel? decryptedUserMention(
      BuildContext context, String encryptedUserData) {
    try {
      final key = encrypt.Key.fromUtf8(widget.encryptionKey);
    final iv = encrypt.IV.fromLength(16);

    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final decryptedUserDataString =
        encrypter.decrypt64(encryptedUserData, iv: iv);

    UserModel userData =
        UserModel.fromJSON(jsonDecode(decryptedUserDataString));
    return userData;
    } catch (e) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    segmentsComment = splitTextWithMentions(widget.mentionComment.commentText);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => navAuthKey.currentState!.pushNamed(userProfile,
                arguments: [widget.mentionComment.user, false]),
            child: widget.mentionComment.user.profilePictureUrl.trim() == ""
                ? Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cBlue),
                      color: cGrey.withOpacity(0.2),
                    ),
                    child: const Icon(Icons.person, color: cBlue, size: 20),
                  )
                : CachedNetworkImageCustom(
                    profilePictureUrl:
                        widget.mentionComment.user.profilePictureUrl,
                    heightContainer: 40,
                    widthContainer: 40,
                    iconSize: 20),
          ),
          const SizedBox(width: 7.5),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => navAuthKey.currentState!.pushNamed(userProfile,
                    arguments: [widget.mentionComment.user, false]),
                child: Text(widget.mentionComment.user.pseudo,
                    style: textStyleCustomBold(Helpers.uiApp(context), 14.0),
                    textScaleFactor: 1.0),
              ),
              const SizedBox(height: 2.0),
              Wrap(
                children: segmentsComment.map<Widget>((segment) {
                  if (segment.startsWith("@")) {
                    String encryptedDatas = segment.substring(1);
                    UserModel? userMention =
                        decryptedUserMention(context, encryptedDatas);
                    if (userMention != null) {
                      return GestureDetector(
                      onTap: () => navAuthKey.currentState!.pushNamed(
                          userProfile,
                          arguments: [userMention, false]),
                      child: Text("@${userMention.pseudo} ",
                          style: textStyleCustomBold(cBlue, 14.0, TextDecoration.none, cBlue.withOpacity(0.3)),
                          textScaleFactor: 1.0),
                    );
                    } else {
                      return Text("$segment ",
                        style: textStyleCustomRegular(
                            Helpers.uiApp(context), 14.0),
                        textScaleFactor: 1.0);
                    }
                  } else {
                    return Text("$segment ",
                        style: textStyleCustomRegular(
                            Helpers.uiApp(context), 14.0),
                        textScaleFactor: 1.0);
                  }
                }).toList(),
              )
            ],
          ))
        ],
      ),
    );
  }
}
