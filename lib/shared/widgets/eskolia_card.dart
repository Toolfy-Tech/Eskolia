import 'package:flutter/material.dart';

import '../../core/constants/eskolia_tokens.dart';

// ────────────────────────────────────────────────────────────────────────────
// Système de 3 niveaux de cartes — Eskolia Design System
//
// L1 Hero    : max 1 par écran — fond violet 8%, border violet 35%, radius 20
// L2 Content : cartes standard — fond surface1, border blanc 10%, radius 16
// L3 ListItem: items de liste  — transparent, border-bottom blanc 8%, radius 0
// ────────────────────────────────────────────────────────────────────────────

/// Carte L1 — Hero (maximum 1 par écran, action principale mise en avant).
class EskoliaCardHero extends StatelessWidget {
  const EskoliaCardHero({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(EskoliaTokens.spaceLg - 4),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(EskoliaTokens.radiusXl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EskoliaTokens.radiusXl),
        splashColor: EskoliaTokens.violet.withValues(alpha: 0.12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: EskoliaTokens.violet.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(EskoliaTokens.radiusXl),
            border: Border.all(
              color: EskoliaTokens.violet.withValues(alpha: 0.35),
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
    this.padding = const EdgeInsets.all(EskoliaTokens.spaceMd),
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
    final decoration = accentBorderColor != null
        ? BoxDecoration(
            color: EskoliaTokens.surface1,
            border: Border(
              left: BorderSide(color: accentBorderColor!, width: 3),
              top: BorderSide(
                  color: EskoliaTokens.borderSubtle, width: 0.5),
              right: BorderSide(
                  color: EskoliaTokens.borderSubtle, width: 0.5),
              bottom: BorderSide(
                  color: EskoliaTokens.borderSubtle, width: 0.5),
            ),
          )
        : BoxDecoration(
            color: EskoliaTokens.surface1,
            borderRadius: BorderRadius.circular(EskoliaTokens.radiusLg),
            border: Border.all(
              color: EskoliaTokens.borderSubtle,
              width: 0.5,
            ),
          );

    final container = ClipRRect(
      borderRadius: BorderRadius.circular(EskoliaTokens.radiusLg),
      child: Container(
        padding: padding,
        decoration: decoration,
        child: child,
      ),
    );

    if (onTap == null) return container;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(EskoliaTokens.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: EskoliaTokens.borderSubtle,
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
    this.padding = const EdgeInsets.symmetric(vertical: EskoliaTokens.spaceMd - 4),
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
            color: EskoliaTokens.borderSubtle,
            width: 0.5,
          ),
        ),
      ),
      child: child,
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      splashColor: EskoliaTokens.borderSubtle,
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
    this.borderRadius = EskoliaTokens.radiusLg,
    this.padding = const EdgeInsets.all(EskoliaTokens.spaceMd),
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
