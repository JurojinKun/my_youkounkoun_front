import 'package:myyoukounkoun/libraries/env_config_lib.dart';
import 'package:myyoukounkoun/libraries/hive_lib.dart';
import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/services/dio_api_service.dart';

class TokenService {
  final _envConfigLib = EnvironmentConfigLib();

  Future<String?> getAccessToken() async {
    String? accessToken;
    UserModel? user = await HiveLib.getDatasHive(true,
        _envConfigLib.getEnvironmentKeyEncryptedUserBox, "userBox", "user");
    if (user != null) {
      accessToken = user.token;
    }
    return accessToken;
  }

  Future<String?> refreshToken(DioApiService dioApiService) async {
    try {
      UserModel? user = await HiveLib.getDatasHive(true,
          _envConfigLib.getEnvironmentKeyEncryptedUserBox, "userBox", "user");
      if (user != null) {
        final response = await dioApiService.dio.post('votre_endpoint_de_refresh',
            data: {'refreshToken': user.refreshToken});
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
