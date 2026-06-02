import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/login_page.dart';
import 'package:finance_tracker/styles/register_styles.dart';
import 'package:finance_tracker/provider/global_state.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (name.isEmpty || username.isEmpty || password.isEmpty) return;

    final success = await ref
        .read(currentUserProvider.notifier)
        .registerUser(name, username, password);

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RegisterStyles.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text('Create Account', style: RegisterStyles.headlineText),
              const SizedBox(height: 4),
              const Text(
                'Enter your details to get started.',
                style: RegisterStyles.subtitleText,
              ),
              const SizedBox(height: 40),
              const Text('Name', style: RegisterStyles.fieldLabelText),
              const SizedBox(height: 4),
              TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1A1C1C)),
                decoration: RegisterStyles.fieldDecoration('Your full name'),
              ),
              const SizedBox(height: 32),
              const Text('Username', style: RegisterStyles.fieldLabelText),
              const SizedBox(height: 4),
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1A1C1C)),
                decoration: RegisterStyles.fieldDecoration('Enter your username'),
              ),
              const SizedBox(height: 32),
              const Text('Password', style: RegisterStyles.fieldLabelText),
              const SizedBox(height: 4),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1A1C1C)),
                decoration: RegisterStyles.fieldDecoration('Create a password').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF5E5E5E),
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: register,
                  style: RegisterStyles.primaryButtonStyle,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Sign Up', style: RegisterStyles.primaryButtonText),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
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
                    child: Text('OR', style: RegisterStyles.orDividerText),
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
                  style: RegisterStyles.googleButtonStyle,
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
                    const Text(
                      'Already have an account? ',
                      style: RegisterStyles.footerText,
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Sign In',
                        style: RegisterStyles.signInText,
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
