import 'package:flutter/material.dart';

import '../../core/constants/eskolia_tokens.dart';

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

const Color _kPrimary = EskoliaTokens.violet;
const Color _kDestructive = EskoliaTokens.error;
const double _kRadius = EskoliaTokens.radiusMd;

/// Bouton Eskolia — 4 variantes sémantiques.
class EskoliaButton extends StatefulWidget {
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

  @override
  State<EskoliaButton> createState() => _EskoliaButtonState();
}

class _EskoliaButtonState extends State<EskoliaButton> {
  bool _pressed = false;

  Widget _buildContent() {
    return Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 18),
          const SizedBox(width: 8),
        ],
        if (widget.expand)
          Expanded(
            child: Text(
              widget.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        else
          Text(widget.label, textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    final fg = widget.textColor ?? EskoliaTokens.textPrimary;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_kRadius),
    );

    switch (widget.variant) {
      case EskoliaButtonVariant.primary:
        final bool isEnabled = widget.onPressed != null;
        final decoration = BoxDecoration(
          borderRadius: BorderRadius.circular(_kRadius),
          gradient: isEnabled
              ? LinearGradient(
                  colors: [
                    EskoliaTokens.violet,
                    Color.lerp(EskoliaTokens.violet, EskoliaTokens.pink, 0.45) ?? EskoliaTokens.violet,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isEnabled ? null : EskoliaTokens.textDisabled.withValues(alpha: 0.24),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: EskoliaTokens.violet.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        );

        return Container(
          decoration: decoration,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(_kRadius),
            child: InkWell(
              onTap: widget.onPressed,
              borderRadius: BorderRadius.circular(_kRadius),
              splashColor: Colors.white.withValues(alpha: 0.16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Outfit',
                    fontWeight: FontWeight.bold,
                    fontSize: 14.5,
                  ),
                  child: IconTheme(
                    data: const IconThemeData(color: Colors.white, size: 18),
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
          ),
        );

      case EskoliaButtonVariant.secondary:
        final accent = widget.color ?? _kPrimary;
        final isEnabled = widget.onPressed != null;
        return OutlinedButton(
          onPressed: widget.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.textColor ?? (isEnabled ? accent : EskoliaTokens.textDisabled),
            side: BorderSide(
              color: isEnabled ? accent.withValues(alpha: 0.5) : EskoliaTokens.textDisabled.withValues(alpha: 0.25),
              width: 1.25,
            ),
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            child: _buildContent(),
          ),
        );

      case EskoliaButtonVariant.ghost:
        final accent = widget.color ?? _kPrimary;
        return TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: widget.textColor ?? accent,
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            child: _buildContent(),
          ),
        );

      case EskoliaButtonVariant.destructive:
        return TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: _kDestructive,
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'Outfit',
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            child: _buildContent(),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = _buildButton(context);
    final sized = widget.expand ? SizedBox(width: double.infinity, child: button) : button;
    return Listener(
      onPointerDown: widget.onPressed != null ? (_) => setState(() => _pressed = true) : null,
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed && widget.onPressed != null ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: sized,
      ),
    );
  }
}
