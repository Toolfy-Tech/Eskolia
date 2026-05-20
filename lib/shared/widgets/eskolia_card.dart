import 'package:flutter/material.dart';

// ────────────────────────────────────────────────────────────────────────────
// Système de 3 niveaux de cartes — Eskolia Design System
//
// L1 Hero    : max 1 par écran — fond violet 8%, border violet 35%, radius 20
// L2 Content : cartes standard — fond #1A1A2E, border blanc 10%, radius 16
// L3 ListItem: items de liste  — transparent, border-bottom blanc 8%, radius 0
// ────────────────────────────────────────────────────────────────────────────

const Color _kSurface = Color(0xFF1E1E38);
const Color _kViolet = Color(0xFF6C63FF);

/// Carte L1 — Hero (maximum 1 par écran, action principale mise en avant).
class EskoliaCardHero extends StatelessWidget {
  const EskoliaCardHero({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: _kViolet.withValues(alpha: 0.12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: _kViolet.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _kViolet.withValues(alpha: 0.35),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Carte L2 — Content (cartes de contenu et navigation standard).
class EskoliaCardContent extends StatelessWidget {
  const EskoliaCardContent({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.accentBorderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  /// Couleur optionnelle pour la border gauche (section accent).
  final Color? accentBorderColor;

  @override
  Widget build(BuildContext context) {
    // BoxDecoration with non-uniform border widths cannot use borderRadius —
    // Flutter's Border.paint() assertion forbids it. Use ClipRRect for radius instead.
    final decoration = accentBorderColor != null
        ? BoxDecoration(
            color: _kSurface,
            border: Border(
              left: BorderSide(color: accentBorderColor!, width: 3),
              top: BorderSide(color: Colors.white.withValues(alpha: 0.10), width: 0.5),
              right: BorderSide(color: Colors.white.withValues(alpha: 0.10), width: 0.5),
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.10), width: 0.5),
            ),
          )
        : BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
              width: 0.5,
            ),
          );

    final container = ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: padding,
        decoration: decoration,
        child: child,
      ),
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.06),
        child: container,
      ),
    );
  }
}

/// Carte L3 — List item (items de liste, chapitres, hauts faits).
class EskoliaCardListItem extends StatelessWidget {
  const EskoliaCardListItem({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 12),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: padding,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.white.withValues(alpha: 0.05),
      child: content,
    );
  }
}

/// Alias rétrocompatible — redirige vers L2 Content.
/// @deprecated Utiliser [EskoliaCardContent] directement.
class EskoliaCard extends StatelessWidget {
  const EskoliaCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: EskoliaCardContent(padding: padding, onTap: onTap, child: child),
    );
  }
}
