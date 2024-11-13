// Interface de base pour les requêtes API
abstract class IApiService {
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? queryParameters});
  Future<dynamic> post(String endpoint, {dynamic data});
  Future<dynamic> put(String endpoint, {dynamic data});
  Future<dynamic> delete(String endpoint);
}