import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:finance_tracker/register_page.dart';
import 'package:finance_tracker/styles/login_styles.dart';
import 'package:finance_tracker/screens/tabs.dart';
import 'package:finance_tracker/provider/global_state.dart';
import 'package:finance_tracker/URLs/urls.dart';
import 'package:http/http.dart' as http;

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isLoading = false;

  Future<void> login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse(ApiUrls.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': email, 'password': password}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final token = data['jwtToken'] as String?;
        if (token != null) {
          await const FlutterSecureStorage().write(key: 'jwt', value: token);
        }
        final user = {
          'email': email,
          'name': data['name'] ?? data['userName'] ?? email,
          'token': token,
        };
        ref.read(currentUserProvider.notifier).setUser(user);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TabsScreen()),
        );
      } else {
        final errorMsg = response.body.trim().isNotEmpty
            ? response.body.trim()
            : 'Invalid email or password';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } catch (e) {
      debugPrint('Login error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Could not connect to server'),
            backgroundColor: Colors.red[700],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: LoginStyles.brandMarkDecoration,
                alignment: Alignment.center,
                child: const Text('B.', style: LoginStyles.brandMarkText),
              ),
              const SizedBox(height: 40),
              const Text('Welcome Back', style: LoginStyles.headlineText),
              const SizedBox(height: 4),
              Text(
                'Enter your details to access your account.',
                style: LoginStyles.subtitleText,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: LoginStyles.emailDecoration,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: LoginStyles.passwordDecoration.copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Forgot Password?',
                    style: LoginStyles.forgotPasswordText,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : login,
                  style: LoginStyles.signInButtonStyle,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Sign In', style: LoginStyles.signInText),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR', style: LoginStyles.orDividerText),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: () {},
                  style: LoginStyles.googleButtonStyle,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.g_mobiledata, size: 28, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Continue with Google',
                        style: TextStyle(color: Colors.black, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account?",
                      style: LoginStyles.footerText,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Sign Up',
                        style: LoginStyles.signUpText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
