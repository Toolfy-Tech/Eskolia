import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/colors.dart';

/// Texte avec dégradé (ex. titre marketing).
class EskoliaGradientText extends StatelessWidget {
  const EskoliaGradientText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.gradient,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    final base = style ??
        GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          height: 1.2,
        );
    final effectiveGradient = gradient ??
        const LinearGradient(
          colors: [primary, secondary],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        );

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => effectiveGradient.createShader(bounds),
      child: Text(
        text,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: base.copyWith(color: Colors.white),
      ),
    );
  }
}
