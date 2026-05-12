import 'package:flutter/material.dart';

enum EskoliaButtonVariant {
  /// Bouton principal — fond violet #6C63FF. Maximum 1 par écran.
  primary,
  /// Bouton secondaire — outlined, couleur contextuelle. Maximum 2 par écran.
  secondary,
  /// Bouton tertiaire — texte seul, sans fond ni border.
  ghost,
  /// Action destructrice — texte rouge discret, jamais prominent.
  destructive,
}

const Color _kPrimary = Color(0xFF6C63FF);
const Color _kDestructive = Color(0xFFEF4444);
const double _kRadius = 12;

/// Bouton Eskolia — 4 variantes sémantiques.
class EskoliaButton extends StatelessWidget {
  const EskoliaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = EskoliaButtonVariant.primary,
    this.icon,
    this.expand = false,
    this.color,
    this.textColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final EskoliaButtonVariant variant;
  final IconData? icon;
  final bool expand;
  /// Couleur de fond (primary/secondary) ou de texte (ghost) — override optionnel.
  final Color? color;
  /// Couleur du texte — override optionnel (ex: texte sombre sur fond clair).
  final Color? textColor;

  Widget _buildContent() {
    return Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 6),
        ],
        if (expand)
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(label, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    final bg = color ?? _kPrimary;
    final fg = textColor ?? Colors.white;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_kRadius),
    );

    switch (variant) {
      case EskoliaButtonVariant.primary:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: _buildContent(),
        );

      case EskoliaButtonVariant.secondary:
        final accent = color ?? _kPrimary;
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: textColor ?? accent,
            side: BorderSide(color: accent.withValues(alpha: 0.6)),
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: _buildContent(),
        );

      case EskoliaButtonVariant.ghost:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: textColor ?? (color ?? _kPrimary),
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: _buildContent(),
        );

      case EskoliaButtonVariant.destructive:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _kDestructive,
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: _buildContent(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);
    if (!expand) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}
