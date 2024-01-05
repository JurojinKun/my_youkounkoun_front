import 'package:dio/dio.dart';

import 'package:myyoukounkoun/models/user_model.dart';
import 'package:myyoukounkoun/services/dio_api_service.dart';

class UserService {
  final Dio _dio;

  UserService() : _dio = DioApiService().dio;

  //JUSTE UN EXEMPLE
  Future<List<UserModel>> fetchUsers() async {
    try {
      final response = await _dio.get(
        'users',
        options: Options(extra: {'requiresToken': true}),
      );
      List<UserModel> users = (response.data as List)
          .map((data) => UserModel.fromJSON(data))
          .toList();
      return users;
    } catch (e) {
      throw Exception('Failed to load users: ${e.toString()}');
    }
  }
}
