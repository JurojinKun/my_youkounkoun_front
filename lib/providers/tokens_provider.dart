import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myyoukounkoun/models/tokens_model.dart';

final tokenNotifierProvider =
    StateNotifierProvider<TokensProvider, TokensModel>(
        (ref) => TokensProvider());

class TokensProvider extends StateNotifier<TokensModel> {
  TokensProvider()
      : super(TokensModel(token: "", refreshToken: "", pushToken: ""));

  void setTokens(String? token, String? refreshToken, String? pushToken) {
    TokensModel newState = state.copy();
    if (token != null) {
      newState.token = token;
    }
    if (refreshToken != null) {
      newState.refreshToken = refreshToken;
    }
    if (pushToken != null) {
      newState.pushToken = pushToken;
    }
    state = newState;
  }

  void updateToken(String newToken) {
    state = state.copy(newToken: newToken);
  }

  void updatePushToken(String newPushToken) {
    state = state.copy(newPushToken: newPushToken);
  }

  void updateRefreshToken(String newRefreshToken) {
    state = state.copy(newRefreshToken: newRefreshToken);
  }

  void clearPushToken() {
    state = state.copy(newPushToken: "");
  }

  void clearTokens() {
    state = state.copy(newToken: "", newRefreshToken: "", newPushToken: "");
  }
}
