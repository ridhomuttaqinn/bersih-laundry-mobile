import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';

class ApiClient {
  static const Duration _timeout = Duration(seconds: 20);

  static Future<dynamic> get(
    String path, {
    Map<String, String>? queryParameters,
  }) {
    return _send('GET', path, queryParameters: queryParameters);
  }

  static Future<dynamic> post(String path, {Map<String, dynamic>? body}) {
    return _send('POST', path, body: body);
  }

  static Future<dynamic> put(String path, {Map<String, dynamic>? body}) {
    return _send('PUT', path, body: body);
  }

  static Future<dynamic> patch(String path, {Map<String, dynamic>? body}) {
    return _send('PATCH', path, body: body);
  }

  static Future<dynamic> delete(String path) {
    return _send('DELETE', path);
  }

  static Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters:
          queryParameters?.isEmpty == true ? null : queryParameters,
    );
    final request = http.Request(method, uri)
      ..headers.addAll({
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'X-Deploy-Test-Token': ApiConfig.testToken,
      });
    if (body != null) {
      request.body = jsonEncode(body);
    }

    final streamed = await request.send().timeout(_timeout);
    final response = await http.Response.fromStream(streamed).timeout(_timeout);
    dynamic decoded;
    if (response.body.trim().isNotEmpty) {
      try {
        decoded = jsonDecode(response.body);
      } on FormatException {
        throw Exception('Server tidak mengembalikan JSON yang valid');
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded is Map ? decoded['message'] : null;
      throw Exception(message?.toString() ??
          'Permintaan gagal (HTTP ${response.statusCode})');
    }

    if (decoded is Map && decoded.containsKey('data')) {
      return decoded['data'];
    }
    return decoded;
  }
}
