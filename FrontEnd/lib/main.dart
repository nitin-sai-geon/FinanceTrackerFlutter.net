import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:finance_tracker/auth/session_manager.dart';
import 'package:finance_tracker/login_page.dart';
import 'package:finance_tracker/screens/tabs.dart';
import 'package:finance_tracker/provider/global_state.dart';
import 'package:finance_tracker/themes/theme.dart';

class _ThemeModeNotifier extends Notifier<bool> {
  _ThemeModeNotifier(this._initial);
  final bool _initial;

  @override
  bool build() => _initial;

  Future<void> loadForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('dark_mode_$userId') ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    final userId = ref.read(currentUserProvider)?['email'] as String? ?? 'guest';
    prefs.setBool('dark_mode_$userId', state);
  }
}

final themeModeProvider =
    NotifierProvider<_ThemeModeNotifier, bool>(() => _ThemeModeNotifier(false));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final prefs = await SharedPreferences.getInstance();
  final savedDark = prefs.getBool('dark_mode') ?? false;

  try {
    await GoogleSignIn.instance.initialize(
      serverClientId: dotenv.env['GOOGLE_SERVER_CLIENT_ID'],
    );
  } catch (e) {
    debugPrint('GoogleSignIn init error: $e');
  }

  runApp(ProviderScope(
    overrides: [
      themeModeProvider.overrideWith(() => _ThemeModeNotifier(savedDark)),
    ],
    child: const _App(),
  ));
}

class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeModeProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const _SplashGate(),
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
      final userId = result.user!['email'] as String? ?? 'guest';
      await ref.read(themeModeProvider.notifier).loadForUser(userId);
      if (!mounted) return;
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
