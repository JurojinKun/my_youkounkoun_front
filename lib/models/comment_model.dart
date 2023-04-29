import 'package:myyoukounkoun/models/user_model.dart';

class CommentModel {
  UserModel user;
  String commentText;

  CommentModel({required this.user, required this.commentText});

  CommentModel.fromJSON(Map<String, dynamic> jsonMap)
      : user = jsonMap["user"] ?? UserModel.fromJSON({}),
        commentText = jsonMap["comment"] ?? "";

  CommentModel copy() {
    return CommentModel(user: user, commentText: commentText);
  }
}
