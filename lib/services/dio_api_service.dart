import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:myyoukounkoun/services/token_service.dart';

class DioApiService {
  static final DioApiService _instance = DioApiService._internal();
  final Dio dio;
  final TokenService _tokenService = TokenService();

  factory DioApiService() {
    return _instance;
  }

  DioApiService._internal() : dio = Dio() {
    _setupDio();
  }

  void _setupDio() {
    dio
      ..options = BaseOptions(
        baseUrl: 'https://example.com/',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      )
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          bool requiresToken = options.extra['requiresToken'] ?? true;
          if (requiresToken) {
            final accessToken = await _tokenService.getAccessToken();
            if (accessToken != null) {
              options.headers['Authorization'] = 'Bearer $accessToken';
            }
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (_isConnectionError(error)) {
            await _waitForConnection();
            _retryRequest(error, handler);
          } else if (error.response?.statusCode == 401) {
            String? newAccessToken = await _tokenService.refreshToken(DioApiService._instance);
            if (newAccessToken != null) {
              _retryRequest(error, handler, newAccessToken);
            } else {
              //TODO GÉRER LA DÉCONNEXION DE L'UTILISATEUR
              handler.next(error); // ou gérer la déconnexion
            }
          } else {
            handler.next(error);
          }
        },
      ));
  }

  bool _isConnectionError(DioException error) {
    //TODO VOIR SI CE N'EST PAS MIEUX DE METTRE  UN AUTRE DIOEXCEPTIONTYPE À LA PLACE DE DIOEXCEPTIONTYPE.UNKNOWN (voir quelle exception apparaît)
    return error.type == DioExceptionType.unknown &&
        error.error != null &&
        error.error is SocketException;
  }

  Future<void> _waitForConnection() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.none) {
      return;
    }
    Completer<void> completer = Completer<void>();
    var subscription = Connectivity().onConnectivityChanged.listen((result) {
      if (result != ConnectivityResult.none) {
        completer.complete();
      }
    });
    await completer.future;
    await subscription.cancel();
  }

  Future<void> _retryRequest(
      DioException error, ErrorInterceptorHandler handler,
      [String? newAccessToken]) async {
    RequestOptions requestOptions = error.requestOptions;
    if (newAccessToken != null) {
      //TODO GÉRER LE RAFRAÎCHISSEMENT DU TOKEN => METTRE À JOUR LE TOKEN DANS LE LOCAL STORAGE
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
    }
    try {
      var response = await dio.request(
        requestOptions.path,
        options: Options(
            headers: requestOptions.headers, method: requestOptions.method),
        cancelToken: requestOptions.cancelToken,
        onSendProgress: requestOptions.onSendProgress,
        onReceiveProgress: requestOptions.onReceiveProgress,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
      );
      handler.resolve(response);
    } catch (e) {
      handler.reject(e as DioException);
    }
  }
}