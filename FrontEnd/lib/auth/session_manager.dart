import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
        contentType: 'application/json',
        headers: {'Authorization': 'Bearer $token'},
      ),
    );
    final response = await dio.get<dynamic>(ApiUrls.profile);
    final data = response.data as Map<String, dynamic>;
    final authProvider = await _storage.read(key: 'auth_provider') ?? 'email';
    return SessionResult(
      isValid: true,
      user: {
        'name': data['name'] ?? '',
        'email': data['email'] ?? '',
        'token': token,
        'authProvider': authProvider,
      },
    );
  } catch (_) {
    return const SessionResult(isValid: false);
  }
}
