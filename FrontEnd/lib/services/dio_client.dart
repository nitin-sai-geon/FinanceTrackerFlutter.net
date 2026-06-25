import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finance_tracker/URLs/urls.dart';
import 'package:finance_tracker/login_page.dart';
import 'package:finance_tracker/main.dart';
import 'package:finance_tracker/provider/global_state.dart';

Dio buildDio(Ref ref) {
  final dio = Dio(
    BaseOptions(baseUrl: ApiUrls.baseUrl, contentType: 'application/json'),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        const storage = FlutterSecureStorage();
        final token = await storage.read(key: 'jwt') ?? '';
        options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await ref.read(currentUserProvider.notifier).clearUser();
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (_) => false,
          );
        }
        handler.next(error);
      },
    ),
  );

  return dio;
}
