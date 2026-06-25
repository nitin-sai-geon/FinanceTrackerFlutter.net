import 'package:flutter/material.dart';

class RegisterStyles {
  static TextStyle headlineOf(BuildContext c) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64,
        color: Theme.of(c).colorScheme.onSurface,
      );

  static TextStyle subtitleOf(BuildContext c) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Theme.of(c).colorScheme.secondary,
      );

  static TextStyle fieldLabelOf(BuildContext c) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Theme.of(c).colorScheme.secondary,
      );

  static InputDecoration fieldDecorationOf(BuildContext c, String hint) =>
      InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Theme.of(c).colorScheme.tertiary),
        enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(c).colorScheme.outlineVariant),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(c).colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      );

  static TextStyle orDividerOf(BuildContext c) => TextStyle(
        color: Theme.of(c).colorScheme.tertiary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      );

  static TextStyle footerOf(BuildContext c) => TextStyle(
        fontSize: 16,
        color: Theme.of(c).colorScheme.secondary,
      );

  static TextStyle signInOf(BuildContext c) => TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Theme.of(c).colorScheme.primary,
      );
}
