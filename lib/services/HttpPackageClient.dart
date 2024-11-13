// Implémentation avec http package
import 'dart:convert'; // Import pour jsonEncode et jsonDecode
import 'package:http/http.dart' as http; // Import pour le package http
import 'ApiException.dart'; // Assurez-vous que le fichier ApiException.dart existe
import 'interfaces/IHttpClient.dart'; // Assurez-vous que l'interface IHttpClient est correctement définie


class HttpPackageClient implements IHttpClient {
  final String baseUrl;
  final http.Client _client;

  HttpPackageClient({
    required this.baseUrl,
  }) : _client = http.Client();

  @override
  Future<dynamic> request({
    required String method,
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, String>? headers,
  }) async {
    try {
      final uri =
          Uri.parse('$baseUrl$url').replace(queryParameters: queryParameters);
      late http.Response response;

      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers);
          break;
        case 'POST':
          response =
              await _client.post(uri, body: jsonEncode(data), headers: headers);
          break;
        case 'PUT':
          response =
              await _client.put(uri, body: jsonEncode(data), headers: headers);
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers);
          break;
        default:
          throw ApiException('Méthode HTTP non supportée');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw ApiException('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      throw ApiException('Erreur lors de la requête: $e');
    }
  }
}
