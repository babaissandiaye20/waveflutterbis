import 'package:http/http.dart' as http;
import 'interfaces/IHttpClient.dart';
import 'dart:convert';

class HttpClient implements IHttpClient {
  @override 
  Future<dynamic> request({
    required String method,
    required String url,
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, String>? headers,
  }) async {
    headers ??= {};
    headers['Content-Type'] = 'application/json';
    
    Uri uri = Uri.parse(url);
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    http.Response response;
    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(
          uri,
          headers: headers,
          body: json.encode(data),
        );
        break;
      case 'PUT':
        response = await http.put(
          uri,
          headers: headers,
          body: json.encode(data),
        );
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Méthode HTTP non supportée: $method');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isNotEmpty) {
        return json.decode(response.body);
      }
      return null;
    } else {
      throw Exception('Erreur HTTP ${response.statusCode}: ${response.body}');
    }
  }
}