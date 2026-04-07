import 'dart:convert';

import 'package:http/http.dart' as http;

import 'room_provisioner.dart';

class TokenServerRoomProvisioner implements RoomProvisioner {
  TokenServerRoomProvisioner({
    required this.baseUrl,
    this.templateId,
  });

  final String baseUrl;
  final String? templateId;

  @override
  Future<String> createRoomId({
    required String callRequestId,
    required String name,
  }) async {
    final uri = Uri.parse('$baseUrl/rooms');
    final res = await http.post(
      uri,
      headers: const {'content-type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'description': 'CallRequest $callRequestId',
        if (templateId != null) 'templateId': templateId,
      }),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw StateError('Room create failed ${res.statusCode}: ${res.body}');
    }
    final json = (jsonDecode(res.body) as Map).cast<String, Object?>();
    final roomId = json['roomId'];
    if (roomId is! String || roomId.isEmpty) {
      throw StateError('Invalid roomId response: ${res.body}');
    }
    return roomId;
  }
}

