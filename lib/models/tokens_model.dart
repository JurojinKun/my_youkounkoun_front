class TokensModel {
  String? token;
  String? refreshToken;
  String? pushToken;

  TokensModel(
      {required this.token,
      required this.refreshToken,
      required this.pushToken});

  TokensModel.fromJSON(Map<String, dynamic> jsonMap)
      : token = jsonMap["token"] ?? "",
        refreshToken = jsonMap["refreshToken"] ?? "",
        pushToken = jsonMap["pushToken"] ?? "";

  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      "token": token,
      "refreshToken": refreshToken,
      "pushToken": pushToken
    };

    return map;
  }

  TokensModel copy(
      {String? newToken, String? newRefreshToken, String? newPushToken}) {
    if (newToken != null) {
      token = newToken;
    } else {
      token = token;
    }
    if (newRefreshToken != null) {
      refreshToken = newRefreshToken;
    } else {
      refreshToken = refreshToken;
    }
    if (newPushToken != null) {
      pushToken = newPushToken;
    } else {
      pushToken = pushToken;
    }
    return TokensModel(
        token: token, refreshToken: refreshToken, pushToken: pushToken);
  }
}
