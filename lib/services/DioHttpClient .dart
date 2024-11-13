import 'interfaces/IHttpClient.dart';
import 'ApiException.dart';
import 'package:dio/dio.dart';
// Implémentation avec Dio

class DioHttpClient implements IHttpClient {
  final Dio _dio;

  DioHttpClient() : _dio = Dio() {
    _dio.options.baseUrl = 'https://votre-api.com';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);
  }

  @override
  Future<dynamic> request({
    required String method,
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _dio.request(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          method: method,
          headers: headers,
        ),
      );
      return response.data;
    } catch (e) {
      throw ApiException('Erreur lors de la requête: $e');
    }
  }
}
