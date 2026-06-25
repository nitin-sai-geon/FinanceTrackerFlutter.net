import 'package:flutter/material.dart';

class LoginStyles {
  static TextStyle headlineOf(BuildContext c) => TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.64,
        color: Theme.of(c).colorScheme.onSurface,
      );

  static TextStyle subtitleOf(BuildContext c) =>
      TextStyle(fontSize: 16, color: Theme.of(c).colorScheme.secondary);

  static InputDecoration emailDecorationOf(BuildContext c) => InputDecoration(
        labelText: 'Email Address',
        hintText: 'name@example.com',
        enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(c).colorScheme.outlineVariant),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(c).colorScheme.primary, width: 1.5),
        ),
      );

  static InputDecoration passwordDecorationOf(BuildContext c) =>
      InputDecoration(
        labelText: 'Password',
        hintText: '••••••••',
        enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(c).colorScheme.outlineVariant),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(c).colorScheme.primary, width: 1.5),
        ),
      );

  static TextStyle forgotPasswordOf(BuildContext c) => TextStyle(
        color: Theme.of(c).colorScheme.secondary,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static TextStyle orDividerOf(BuildContext c) => TextStyle(
        color: Theme.of(c).colorScheme.tertiary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      );

  static TextStyle footerOf(BuildContext c) =>
      TextStyle(color: Theme.of(c).colorScheme.secondary, fontSize: 16);

  static TextStyle signUpOf(BuildContext c) => TextStyle(
        color: Theme.of(c).colorScheme.primary,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      );
}
