import 'package:flutter/material.dart';

class LoginStyles {
  static BoxDecoration get brandMarkDecoration => BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      );

  static const TextStyle brandMarkText = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineText = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
    color: Color(0xFF1A1C1C),
  );

  static TextStyle get subtitleText =>
      TextStyle(fontSize: 16, color: Colors.grey[600]);

  static InputDecoration get emailDecoration => InputDecoration(
        labelText: 'Email Address',
        hintText: 'name@example.com',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
        ),
      );

  static InputDecoration get passwordDecoration => InputDecoration(
        labelText: 'Password',
        hintText: '••••••••',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[400]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black, width: 1.5),
        ),
      );

  static TextStyle get forgotPasswordText => TextStyle(
        color: Colors.grey[600],
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      );

  static ButtonStyle get signInButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      );

  static const TextStyle signInText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static TextStyle get orDividerText => TextStyle(
        color: Colors.grey[500],
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      );

  static ButtonStyle get googleButtonStyle => OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(color: Colors.grey[300]!),
      );

  static TextStyle get footerText =>
      TextStyle(color: Colors.grey[600], fontSize: 16);

  static const TextStyle signUpText = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
}
