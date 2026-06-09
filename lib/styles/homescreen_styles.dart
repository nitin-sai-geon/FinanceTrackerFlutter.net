import 'package:flutter/material.dart';

class HomeScreenStyles {
  // ── Light mode constants (kept for legacy references) ──────────────────
  static const Color background = Color(0xFFF9F9F9);
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF5D5E60);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color borderSubtle = Color(0xFFE2E2E4);
  static const Color subtitleMuted = Color(0xFF838485);
  static const Color onBackground = Color(0xFF1B1B1B);

  // ── Dark mode constants ─────────────────────────────────────────────────
  static const Color _darkBg = Color(0xFF131315);
  static const Color _darkPrimary = Color(0xFFFFFFFF);
  static const Color _darkOnPrimary = Color(0xFF2F3131);
  static const Color _darkSecondary = Color(0xFFC6C6CF);
  static const Color _darkSurface = Color(0xFF201F22);
  static const Color _darkBorder = Color(0xFF444748);
  static const Color _darkMuted = Color(0xFFC4C7C8);
  static const Color _darkOnBg = Color(0xFFE5E1E4);

  // ── Context-aware color getters ─────────────────────────────────────────
  static bool _isDark(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark;

  static Color bgOf(BuildContext c) => _isDark(c) ? _darkBg : background;
  static Color primaryOf(BuildContext c) => _isDark(c) ? _darkPrimary : primary;
  static Color onPrimaryOf(BuildContext c) =>
      _isDark(c) ? _darkOnPrimary : onPrimary;
  static Color secondaryOf(BuildContext c) =>
      _isDark(c) ? _darkSecondary : secondary;
  static Color surfaceOf(BuildContext c) =>
      _isDark(c) ? _darkSurface : surfaceContainer;
  static Color borderOf(BuildContext c) =>
      _isDark(c) ? _darkBorder : borderSubtle;
  static Color mutedOf(BuildContext c) =>
      _isDark(c) ? _darkMuted : subtitleMuted;
  static Color onBgOf(BuildContext c) => _isDark(c) ? _darkOnBg : onBackground;

  // ── Context-aware text styles ───────────────────────────────────────────
  static TextStyle appBarTitleOf(BuildContext c) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: onBgOf(c),
        letterSpacing: -0.2,
      );

  static TextStyle fieldLabelOf(BuildContext c) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondaryOf(c),
        letterSpacing: 0.8,
      );

  static TextStyle transactionTitleOf(BuildContext c) => TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: onBgOf(c),
      );

  static TextStyle transactionSubtitleOf(BuildContext c) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: mutedOf(c),
      );

  static TextStyle transactionAmountOf(BuildContext c) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primaryOf(c),
      );

  static TextStyle chipSelectedOf(BuildContext c) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: onPrimaryOf(c),
        letterSpacing: 0.8,
      );

  static TextStyle chipUnselectedOf(BuildContext c) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: secondaryOf(c),
        letterSpacing: 0.8,
      );

  // ── Legacy const text styles (used outside home/profile screens) ────────
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

  // ── Context-aware decorations ───────────────────────────────────────────
  static BoxDecoration iconContainerOf(BuildContext c) => BoxDecoration(
        color: surfaceOf(c),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      );

  static BoxDecoration selectedChipOf(BuildContext c) => BoxDecoration(
        color: primaryOf(c),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: primaryOf(c), width: 2),
      );

  static BoxDecoration unselectedChipOf(BuildContext c) => BoxDecoration(
        color: bgOf(c),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderOf(c)),
      );

  static ButtonStyle analyticsButtonStyleOf(BuildContext c) =>
      OutlinedButton.styleFrom(
        side: BorderSide(color: borderOf(c)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      );

  static ButtonStyle formSaveButtonStyleOf(BuildContext c) =>
      ElevatedButton.styleFrom(
        backgroundColor: primaryOf(c),
        foregroundColor: onPrimaryOf(c),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      );

  // ── Legacy decorations ──────────────────────────────────────────────────
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

  // ── Form styles ─────────────────────────────────────────────────────────
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

  static UnderlineInputBorder formInputBorderOf(BuildContext c) =>
      UnderlineInputBorder(borderSide: BorderSide(color: borderOf(c)));

  static UnderlineInputBorder formFocusedBorderOf(BuildContext c) =>
      UnderlineInputBorder(
          borderSide: BorderSide(color: primaryOf(c), width: 1.5));

  static TextStyle formInputStyleOf(BuildContext c) =>
      TextStyle(fontSize: 16, color: onBgOf(c));

  static ThemeData datePickerTheme(BuildContext context) =>
      Theme.of(context).copyWith(
        colorScheme: ColorScheme(
          brightness: Theme.of(context).brightness,
          primary: primaryOf(context),
          onPrimary: onPrimaryOf(context),
          secondary: secondaryOf(context),
          onSecondary: onBgOf(context),
          error: const Color(0xFFB3261E),
          onError: Colors.white,
          surface: bgOf(context),
          onSurface: onBgOf(context),
        ),
      );

  static ButtonStyle get formSaveButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      );

  // ── Category icon mapping ───────────────────────────────────────────────
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
