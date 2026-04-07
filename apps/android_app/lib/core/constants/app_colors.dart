// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

/// Paleta base del tema Mundial 2026.
/// Los 4 temas cambian estos valores vía TemaProvider.
class AppColors {
  // Tema Mundial 2026 (por defecto)
  static const Color primary   = Color(0xFF273D6C); // 50% – botones, headers
  static const Color secondary = Color(0xFF599265); // 30% – rutas, badges
  static const Color accent    = Color(0xFFFD495A); // 20% – logo, highlights

  static const Color bgApp     = Color(0xFF111113);
  static const Color bgCard    = Color(0xFF1C1C1E);
  static const Color bgSidebar = Color(0xFF161618);
  static const Color bgInput   = Color(0xFF242426);

  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
}