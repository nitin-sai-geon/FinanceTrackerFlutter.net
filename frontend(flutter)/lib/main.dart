import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:finance_tracker/auth/session_manager.dart';
import 'package:finance_tracker/login_page.dart';
import 'package:finance_tracker/screens/tabs.dart';
import 'package:finance_tracker/provider/global_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  runApp(const ProviderScope(child: _App()));
}

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _SplashGate(),
    );
  }
}

class _SplashGate extends ConsumerStatefulWidget {
  const _SplashGate();

  @override
  ConsumerState<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<_SplashGate> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final result = await tryRestoreSession();
    if (!mounted) return;

    if (result.isValid && result.user != null) {
      ref.read(currentUserProvider.notifier).setUser(result.user!);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TabsScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: Center(
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );
  }
}
