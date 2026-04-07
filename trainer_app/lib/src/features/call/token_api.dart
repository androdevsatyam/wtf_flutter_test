import 'dart:convert';

import 'package:http/http.dart' as http;

class TokenApi {
  TokenApi(this.baseUrl);

  final String baseUrl;

  Future<String> fetchToken({
    required String roomId,
    required String userId,
    required String role,
  }) async {
    final uri = Uri.parse('$baseUrl/token');
    final res = await http.post(
      uri,
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({'roomId': roomId, 'userId': userId, 'role': role}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('Token server error ${res.statusCode}: ${res.body}');
    }
    final json = (jsonDecode(res.body) as Map).cast<String, Object?>();
    final token = json['token'];
    if (token is! String || token.isEmpty) {
      throw StateError('Token server returned invalid token');
    }
    return token;
  }
}

