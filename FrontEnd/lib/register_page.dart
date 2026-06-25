import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/auth/google_sign_in_mixin.dart';
import 'package:finance_tracker/login_page.dart';
import 'package:finance_tracker/styles/register_styles.dart';
import 'package:finance_tracker/provider/global_state.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage>
    with GoogleSignInMixin<RegisterPage> {
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
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Create Account', style: RegisterStyles.headlineOf(context)),
              const SizedBox(height: 4),
              Text(
                'Enter your details to get started.',
                style: RegisterStyles.subtitleOf(context),
              ),
              const SizedBox(height: 40),
              Text('Name', style: RegisterStyles.fieldLabelOf(context)),
              const SizedBox(height: 4),
              TextField(
                controller: _nameController,
                style: TextStyle(fontSize: 16, color: cs.onSurface),
                decoration:
                    RegisterStyles.fieldDecorationOf(context, 'Your full name'),
              ),
              const SizedBox(height: 32),
              Text('Username', style: RegisterStyles.fieldLabelOf(context)),
              const SizedBox(height: 4),
              TextField(
                controller: _usernameController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(fontSize: 16, color: cs.onSurface),
                decoration: RegisterStyles.fieldDecorationOf(
                    context, 'Enter your username'),
              ),
              const SizedBox(height: 32),
              Text('Password', style: RegisterStyles.fieldLabelOf(context)),
              const SizedBox(height: 4),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: TextStyle(fontSize: 16, color: cs.onSurface),
                decoration: RegisterStyles.fieldDecorationOf(
                        context, 'Create a password')
                    .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: cs.secondary,
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
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Sign Up',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(child: Divider(color: cs.outlineVariant)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR',
                        style: RegisterStyles.orDividerOf(context)),
                  ),
                  Expanded(child: Divider(color: cs.outlineVariant)),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: isGoogleLoading ? null : signInWithGoogle,
                  child: isGoogleLoading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.onSurface,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata,
                                size: 28, color: cs.onSurface),
                            const SizedBox(width: 8),
                            Text(
                              'Continue with Google',
                              style:
                                  TextStyle(color: cs.onSurface, fontSize: 16),
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
                      'Already have an account? ',
                      style: RegisterStyles.footerOf(context),
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
                      child: Text(
                        'Sign In',
                        style: RegisterStyles.signInOf(context),
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
