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
          const SizedBox(width: 6),
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
    final bg = widget.color ?? _kPrimary;
    final fg = widget.textColor ?? Colors.white;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_kRadius),
    );

    switch (widget.variant) {
      case EskoliaButtonVariant.primary:
        return FilledButton(
          onPressed: widget.onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: _buildContent(),
        );

      case EskoliaButtonVariant.secondary:
        final accent = widget.color ?? _kPrimary;
        return OutlinedButton(
          onPressed: widget.onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.textColor ?? accent,
            side: BorderSide(color: accent.withValues(alpha: 0.6)),
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: _buildContent(),
        );

      case EskoliaButtonVariant.ghost:
        return TextButton(
          onPressed: widget.onPressed,
          style: TextButton.styleFrom(
            foregroundColor: widget.textColor ?? (widget.color ?? _kPrimary),
            shape: shape,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          child: _buildContent(),
        );

      case EskoliaButtonVariant.destructive:
        return TextButton(
          onPressed: widget.onPressed,
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
