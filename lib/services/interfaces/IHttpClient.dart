// Interface pour la configuration du client HTTP
abstract class IHttpClient {
  Future<dynamic> request({
    required String method,
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, String>? headers,
  });
}