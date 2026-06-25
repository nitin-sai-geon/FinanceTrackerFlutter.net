import 'package:flutter/material.dart';

class HomeScreenStyles {
  // ── Context-aware color getters ─────────────────────────────────────────
  static Color bgOf(BuildContext c) => Theme.of(c).colorScheme.surface;
  static Color primaryOf(BuildContext c) => Theme.of(c).colorScheme.primary;
  static Color onPrimaryOf(BuildContext c) => Theme.of(c).colorScheme.onPrimary;
  static Color secondaryOf(BuildContext c) => Theme.of(c).colorScheme.secondary;
  static Color surfaceOf(BuildContext c) => Theme.of(c).colorScheme.surfaceContainer;
  static Color borderOf(BuildContext c) => Theme.of(c).colorScheme.outlineVariant;
  static Color mutedOf(BuildContext c) => Theme.of(c).colorScheme.tertiary;
  static Color onBgOf(BuildContext c) => Theme.of(c).colorScheme.onSurface;

  // ── Context-aware text styles ───────────────────────────────────────────
  static TextStyle appBarTitleOf(BuildContext c) =>
      Theme.of(c).textTheme.titleLarge!;

  static TextStyle fieldLabelOf(BuildContext c) =>
      Theme.of(c).textTheme.labelSmall!;

  static TextStyle transactionTitleOf(BuildContext c) =>
      Theme.of(c).textTheme.titleMedium!;

  static TextStyle transactionSubtitleOf(BuildContext c) =>
      Theme.of(c).textTheme.bodyMedium!;

  static TextStyle transactionAmountOf(BuildContext c) => TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Theme.of(c).colorScheme.primary,
      );

  static TextStyle chipSelectedOf(BuildContext c) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Theme.of(c).colorScheme.onPrimary,
        letterSpacing: 0.8,
      );

  static TextStyle chipUnselectedOf(BuildContext c) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Theme.of(c).colorScheme.secondary,
        letterSpacing: 0.8,
      );

  // ── Context-aware decorations ───────────────────────────────────────────
  static BoxDecoration iconContainerOf(BuildContext c) => BoxDecoration(
        color: Theme.of(c).colorScheme.surfaceContainer,
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

  // ── Form input styles ────────────────────────────────────────────────────
  static UnderlineInputBorder formInputBorderOf(BuildContext c) =>
      UnderlineInputBorder(borderSide: BorderSide(color: borderOf(c)));

  static UnderlineInputBorder formFocusedBorderOf(BuildContext c) =>
      UnderlineInputBorder(
          borderSide: BorderSide(color: primaryOf(c), width: 1.5));

  static TextStyle formInputStyleOf(BuildContext c) =>
      TextStyle(fontSize: 16, color: onBgOf(c));

  static ThemeData datePickerTheme(BuildContext context) =>
      Theme.of(context);

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
