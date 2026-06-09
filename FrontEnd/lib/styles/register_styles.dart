import 'package:flutter/material.dart';

class RegisterStyles {
  static const Color backgroundColor = Color(0xFFF9F9F9);

  static const TextStyle headlineText = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.64,
    color: Color(0xFF1A1C1C),
  );

  static const TextStyle subtitleText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Color(0xFF5E5E5E),
  );

  static const TextStyle fieldLabelText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF5E5E5E),
  );

  static InputDecoration fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF7E7576)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFCFC4C5)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF000000), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8),
      );

  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      );

  static const TextStyle primaryButtonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
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
        side: const BorderSide(color: Color(0xFFCFC4C5)),
      );

  static const TextStyle footerText = TextStyle(
    fontSize: 16,
    color: Color(0xFF5E5E5E),
  );

  static const TextStyle signInText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Color(0xFF1A1C1C),
  );
}
