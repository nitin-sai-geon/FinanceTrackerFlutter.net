import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:finance_tracker/login_page.dart';
import 'package:finance_tracker/provider/global_state.dart';
import 'package:finance_tracker/styles/homescreen_styles.dart';

class LogoutConfirmation extends ConsumerWidget {
  const LogoutConfirmation({super.key});

  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const LogoutConfirmation(),
    );
    if (confirmed == true && context.mounted) {
      await ref.read(currentUserProvider.notifier).clearUser();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: HomeScreenStyles.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Log Out',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: HomeScreenStyles.onBackground,
        ),
      ),
      content: const Text(
        'Are you sure you want to log out?',
        style: TextStyle(
          fontSize: 14,
          color: HomeScreenStyles.secondary,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(
            'Cancel',
            style: TextStyle(
              color: HomeScreenStyles.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text(
            'Log Out',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
