import 'package:flutter/material.dart';

class HomeScreenStyles {
  // Colors
  static const Color background = Color(0xFFF9F9F9);
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF5D5E60);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color borderSubtle = Color(0xFFE2E2E4);
  static const Color subtitleMuted = Color(0xFF838485);
  static const Color onBackground = Color(0xFF1B1B1B);

  // Text styles
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: onBackground,
    letterSpacing: -0.2,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: secondary,
    letterSpacing: 0.8,
  );

  static const TextStyle transactionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: onBackground,
  );

  static const TextStyle transactionSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: subtitleMuted,
  );

  static const TextStyle transactionAmount = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: primary,
  );

  static const TextStyle analyticsButtonLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: secondary,
    letterSpacing: 0.5,
  );

  static const TextStyle chipSelected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: onPrimary,
    letterSpacing: 0.8,
  );

  static const TextStyle chipUnselected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: secondary,
    letterSpacing: 0.8,
  );

  static const TextStyle fabLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: onPrimary,
    letterSpacing: 1.5,
  );

  // Decorations
  static BoxDecoration get iconContainer => const BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      );

  static BoxDecoration get selectedChip => BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primary, width: 2),
      );

  static BoxDecoration get unselectedChip => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderSubtle),
      );

  static ButtonStyle get analyticsButtonStyle => OutlinedButton.styleFrom(
        side: const BorderSide(color: borderSubtle),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      );

  // Shared form styles (used by add/edit transaction screens)
  static const UnderlineInputBorder formInputBorder = UnderlineInputBorder(
    borderSide: BorderSide(color: borderSubtle),
  );

  static const UnderlineInputBorder formFocusedBorder = UnderlineInputBorder(
    borderSide: BorderSide(color: primary, width: 1.5),
  );

  static const TextStyle formInputStyle = TextStyle(
    fontSize: 16,
    color: onBackground,
  );

  static ThemeData datePickerTheme(BuildContext context) =>
      Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: primary,
          onPrimary: onPrimary,
          surface: background,
          onSurface: onBackground,
        ),
      );

  static ButtonStyle get formSaveButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      );

  // Category → icon mapping
  static IconData iconForCategory(String category, int categoryType) {
    if (categoryType == 0) return Icons.payments_outlined;
    final lower = category.toLowerCase();
    if (lower.contains('transport') ||
        lower.contains('uber') ||
        lower.contains('auto') ||
        lower.contains('bus') ||
        lower.contains('car') ||
        lower.contains('ev')) {
      return Icons.directions_car_outlined;
    } else if (lower.contains('food') ||
        lower.contains('lunch') ||
        lower.contains('dinner') ||
        lower.contains('restaurant') ||
        lower.contains('pizza')) {
      return Icons.restaurant_outlined;
    } else if (lower.contains('grocer') ||
        lower.contains('ration') ||
        lower.contains('utilit')) {
      return Icons.shopping_basket_outlined;
    } else if (lower.contains('entertainment') ||
        lower.contains('movie') ||
        lower.contains('netflix')) {
      return Icons.movie_outlined;
    } else if (lower.contains('health') || lower.contains('medical')) {
      return Icons.medical_services_outlined;
    } else {
      return Icons.receipt_long_outlined;
    }
  }
}
