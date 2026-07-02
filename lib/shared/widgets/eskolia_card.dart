import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/constants/eskolia_tokens.dart';

// ────────────────────────────────────────────────────────────────────────────
// Système de 3 niveaux de cartes — Eskolia Design System (Premium Néo-Glassmorphic)
//
// L1 Hero    : max 1 par écran — fond violet 6%, border violet 30%, radius Lg (20)
// L2 Content : cartes standard — fond surface1 55% + blur 18, border blanc 8%, radius Md (16)
// L3 ListItem: items de liste  — transparent, border-bottom blanc 6%, padding vertical
// ────────────────────────────────────────────────────────────────────────────

const Color _kViolet = EskoliaTokens.violet;

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
    final radius = BorderRadius.circular(EskoliaTokens.radiusLg);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        splashColor: _kViolet.withValues(alpha: 0.12),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: _kViolet.withValues(alpha: 0.06),
                borderRadius: radius,
                border: Border.all(
                  color: _kViolet.withValues(alpha: 0.3),
                  width: 1.0,
                ),
              ),
              child: child,
            ),
          ),
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
    final radius = BorderRadius.circular(EskoliaTokens.radiusMd);
    final borderCol = Colors.white.withValues(alpha: 0.08);

    final decoration = accentBorderColor != null
        ? BoxDecoration(
            color: Color.alphaBlend(
              accentBorderColor!.withValues(alpha: 0.04),
              EskoliaTokens.surface1.withValues(alpha: 0.55),
            ),
            borderRadius: radius,
            border: Border.all(
              color: accentBorderColor!,
              width: 1.5,
            ),
          )
        : BoxDecoration(
            color: EskoliaTokens.surface1.withValues(alpha: 0.55),
            borderRadius: radius,
            border: Border.all(
              color: borderCol,
              width: 0.8,
            ),
          );

    final container = ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: decoration,
          child: child,
        ),
      ),
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      borderRadius: radius,
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
            color: Colors.white.withValues(alpha: 0.06),
            width: 0.8,
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

class EskoliaCardSectionBadge extends StatelessWidget {
  const EskoliaCardSectionBadge({
    super.key,
    required this.sectionName,
    required this.color,
  });

  final String sectionName;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Text(
        sectionName.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
