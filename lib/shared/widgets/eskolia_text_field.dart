import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';

/// Champ texte avec effet verre (blur + calque) aligné sur le thème.
class EskoliaTextField extends StatelessWidget {
  const EskoliaTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.autocorrect = true,
    this.borderRadius = 12,
    this.blurSigma = 10,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final int? minLines;
  final bool enabled;
  final bool autocorrect;
  final double borderRadius;
  final double blurSigma;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base = theme.inputDecorationTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          maxLines: obscureText ? 1 : maxLines,
          minLines: obscureText ? 1 : minLines,
          enabled: enabled,
          autocorrect: autocorrect,
          style: theme.textTheme.bodyLarge,
          cursorColor: primary,
          decoration: InputDecoration(
            hintText: hintText,
            labelText: labelText,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
          ).applyDefaults(base),
        ),
    );
  }
}
