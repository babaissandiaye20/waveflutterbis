import 'interfaces/IHttpClient.dart';
import 'interfaces/IApiService.dart';
// Implémentation du service API

class ApiService implements IApiService {
  final IHttpClient _httpClient;

  ApiService(this._httpClient);

  @override
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParameters}) async {
    return await _httpClient.request(
      method: 'GET',
      url: endpoint,
      queryParameters: queryParameters,
    );
  }

  @override
  Future<dynamic> post(String endpoint, {dynamic data}) async {
    return await _httpClient.request(
      method: 'POST',
      url: endpoint,
      data: data,
    );
  }

  @override
  Future<dynamic> put(String endpoint, {dynamic data}) async {
    return await _httpClient.request(
      method: 'PUT',
      url: endpoint,
      data: data,
    );
  }

  @override
  Future<dynamic> delete(String endpoint) async {
    return await _httpClient.request(
      method: 'DELETE',
      url: endpoint,
    );
  }
}
