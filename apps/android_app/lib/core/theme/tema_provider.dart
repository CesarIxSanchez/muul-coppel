// lib/core/theme/tema_provider.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppTema { mundial2026, diaDeMuertos, primavera, navidad }

class TemaColors {
  final Color primary;
  final Color secondary;
  final Color accent;
  final String nombre;

  const TemaColors({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.nombre,
  });
}

// Paletas de los 4 temas
const _temas = {
  AppTema.mundial2026: TemaColors(
    primary:   Color(0xFF273D6C),
    secondary: Color(0xFF599265),
    accent:    Color(0xFFFD495A),
    nombre:    'Muul 2026',
  ),
  AppTema.diaDeMuertos: TemaColors(
    primary:   Color(0xFF4A0E5C),
    secondary: Color(0xFFE040FB),
    accent:    Color(0xFFFF6F00),
    nombre:    'Día de Muertos',
  ),
  AppTema.primavera: TemaColors(
    primary:   Color(0xFF1B5E20),
    secondary: Color(0xFF66BB6A),
    accent:    Color(0xFFFFC107),
    nombre:    'Primavera',
  ),
  AppTema.navidad: TemaColors(
    primary:   Color(0xFF7F0000),
    secondary: Color(0xFF388E3C),
    accent:    Color(0xFFFFD700),
    nombre:    'Navidad',
  ),
};

class TemaNotifier extends Notifier<AppTema> {
  @override
  AppTema build() => AppTema.mundial2026;

  void cambiarTema(AppTema tema) => state = tema;

  TemaColors get colores => _temas[state]!;
}

final temaProvider = NotifierProvider<TemaNotifier, AppTema>(
  TemaNotifier.new,
);

// Selector conveniente para obtener los colores directamente
final temaColoresProvider = Provider<TemaColors>((ref) {
  final tema = ref.watch(temaProvider);
  return _temas[tema]!;
});