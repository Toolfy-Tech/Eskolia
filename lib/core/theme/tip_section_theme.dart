import 'package:flutter/material.dart';

/// DA par section TIP — `blueprint v3.md` § Design ambiance par section (adapté réseau / TIP).
abstract final class TipSectionTheme {
  TipSectionTheme._();

  static String _norm(String raw) {
    var u = raw.trim().toUpperCase();
    if (u.length >= 3 && u.startsWith('O')) {
      final n = u.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
      if (n.isEmpty) return u;
      final v = int.tryParse(n) ?? 1;
      return 'S${v.toString().padLeft(2, '0')}';
    }
    if (u.length >= 3 && u.startsWith('S')) {
      final n = u.substring(1).replaceAll(RegExp(r'[^0-9]'), '');
      if (n.isEmpty) return u;
      return 'S${int.tryParse(n)?.toString().padLeft(2, '0') ?? n}';
    }
    return u;
  }

  /// Retourne couleurs d’accent pour la bordure / progression (id ex. `S01`, `S1`, `tip_...`).
  static ({Color primary, Color secondary, Color glow}) colorsFor(String sectionId) {
    final id = _norm(sectionId);
    return switch (id) {
      'S01' => (
          primary: const Color(0xFF3B82F6),
          secondary: const Color(0xFF60A5FA),
          glow: const Color(0xFF2563EB),
        ),
      'S02' => (
          primary: const Color(0xFF10B981),
          secondary: const Color(0xFF34D399),
          glow: const Color(0xFF059669),
        ),
      'S03' => (
          primary: const Color(0xFF8B5CF6),
          secondary: const Color(0xFFA78BFA),
          glow: const Color(0xFF7C3AED),
        ),
      'S04' => (
          primary: const Color(0xFF06B6D4),
          secondary: const Color(0xFF22D3EE),
          glow: const Color(0xFF0891B2),
        ),
      'S05' => (
          primary: const Color(0xFFF59E0B),
          secondary: const Color(0xFFFBBF24),
          glow: const Color(0xFFD97706),
        ),
      'S06' => (
          primary: const Color(0xFF6366F1),
          secondary: const Color(0xFF818CF8),
          glow: const Color(0xFF4F46E5),
        ),
      'S07' => (
          primary: const Color(0xFFEC4899),
          secondary: const Color(0xFFF472B6),
          glow: const Color(0xFFDB2777),
        ),
      'S08' => (
          primary: const Color(0xFF14B8A6),
          secondary: const Color(0xFF2DD4BF),
          glow: const Color(0xFF0D9488),
        ),
      'S09' => (
          primary: const Color(0xFFEF4444),
          secondary: const Color(0xFFF87171),
          glow: const Color(0xFFDC2626),
        ),
      'S10' => (
          primary: const Color(0xFFA78BFA),
          secondary: const Color(0xFFC4B5FD),
          glow: const Color(0xFF7C3AED),
        ),
      _ => (
          primary: const Color(0xFF6C63FF),
          secondary: const Color(0xFF43E97B),
          glow: const Color(0xFF6C63FF),
        ),
    };
  }

  static List<Color> gradientFor(String sectionId) {
    final c = colorsFor(sectionId);
    return [c.primary, c.secondary];
  }
}
