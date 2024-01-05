import 'package:myyoukounkoun/libraries/env_config_lib.dart';
import 'package:myyoukounkoun/libraries/hive_lib.dart';
import 'package:myyoukounkoun/services/dio_api_service.dart';

class TokenService {
  final _envConfigLib = EnvironmentConfigLib();

  Future<String?> getAccessToken() async {
    String? accessToken = await HiveLib.getDatasHive(true,
        _envConfigLib.getEnvironmentKeyEncryptedTokensBox, "tokensBox", "token");
    return accessToken;
  }

  Future<String?> refreshToken(DioApiService dioApiService) async {
    try {
      String? refreshToken = await HiveLib.getDatasHive(
          true,
          _envConfigLib.getEnvironmentKeyEncryptedTokensBox,
          "tokensBox",
          "refreshToken");
      if (refreshToken != null) {
        final response = await dioApiService.dio.post(
            'votre_endpoint_de_refresh',
            data: {'refreshToken': refreshToken});
        if (response.statusCode == 200) {
          // Supposons que le nouveau token d'accès est dans 'accessToken' de la réponse
          return response.data['accessToken'];
        }
      }
      return null;
    } catch (e) {
      // Gérer l'erreur
      return null;
    }
  }
}
