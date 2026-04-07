import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MuulTheme {
  static const bg = Color(0xFF0A0D17);
  static const card = Color(0xFF151A27);
  static const border = Color(0xFF2B3142);
  static const accent = Color(0xFF3D63B8);
  static const textPrimary = Color(0xFFF3F5FA);
  static const textMuted = Color(0xFFA1A8B8);

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      textTheme: GoogleFonts.montserratTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: accent,
        surface: card,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1D2230),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
      ),
    );
  }
}
