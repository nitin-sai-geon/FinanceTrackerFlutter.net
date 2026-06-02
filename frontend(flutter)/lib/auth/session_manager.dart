import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:finance_tracker/URLs/urls.dart';

const _storage = FlutterSecureStorage();

class SessionResult {
  final bool isValid;
  final Map<String, dynamic>? user;

  const SessionResult({required this.isValid, this.user});
}

bool isTokenExpired(String token) {
  try {
    final parts = token.split('.');
    if (parts.length != 3) return true;
    final payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;
    final exp = payload['exp'] as int?;
    if (exp == null) return true;
    return DateTime.now().millisecondsSinceEpoch / 1000 > exp;
  } catch (_) {
    return true;
  }
}

Future<SessionResult> tryRestoreSession() async {
  final token = await _storage.read(key: 'jwt');

  if (token == null) return const SessionResult(isValid: false);

  if (isTokenExpired(token)) {
    await _storage.delete(key: 'jwt');
    return const SessionResult(isValid: false);
  }

  try {
    final response = await http.get(
      Uri.parse(ApiUrls.profile),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return SessionResult(
        isValid: true,
        user: {
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'token': token,
        },
      );
    } else {
      await _storage.delete(key: 'jwt');
      return const SessionResult(isValid: false);
    }
  } catch (_) {
    return const SessionResult(isValid: false);
  }
}
