import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:finance_tracker/URLs/urls.dart';
import 'package:finance_tracker/main.dart' show themeModeProvider;
import 'package:finance_tracker/provider/global_state.dart';
import 'package:finance_tracker/screens/tabs.dart';

mixin GoogleSignInMixin<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool isGoogleLoading = false;

  Future<void> signInWithGoogle() async {
    if (!mounted) return;
    setState(() => isGoogleLoading = true);
    try {
      await GoogleSignIn.instance.signOut();
      final account = await GoogleSignIn.instance.authenticate();

      final idToken = account.authentication.idToken;
      if (idToken == null) throw Exception('No ID token received from Google');

      final dio = Dio(BaseOptions(contentType: 'application/json'));
      final response = await dio.post<dynamic>(
        ApiUrls.googleToken,
        data: {'idToken': idToken},
      );

      final token = response.data?['jwtToken'] as String?;
      if (token == null) throw Exception('No JWT received from server');

      const storage = FlutterSecureStorage();
      await storage.write(key: 'jwt', value: token);
      await storage.write(key: 'auth_provider', value: 'google');
      ref.read(currentUserProvider.notifier).setUser({
        'token': token,
        'email': account.email,
        'name': account.displayName ?? '',
        'authProvider': 'google',
      });
      await ref.read(themeModeProvider.notifier).loadForUser(account.email);

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const TabsScreen()),
        (_) => false,
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.description ?? 'Google sign-in failed'),
          backgroundColor: Colors.red[700],
        ),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg =
          e.response?.data?['message'] as String? ?? 'Google sign-in failed';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red[700]),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Google sign-in failed'),
          backgroundColor: Colors.red[700],
        ),
      );
    } finally {
      if (mounted) setState(() => isGoogleLoading = false);
    }
  }
}
