import 'package:flutter/material.dart';
import '../../core/constants/eskolia_tokens.dart';
import 'eskolia_card.dart';

/// Un widget de carte avec un effet de transition fade pour reveler la reponse.
class EskoliaFlipCard extends StatefulWidget {
  const EskoliaFlipCard({
    super.key,
    required this.front,
    required this.back,
    this.isFlipped = false,
    this.duration = const Duration(milliseconds: 250),
    this.useBlueprintStyle = false,
  });

  final Widget front;
  final Widget back;
  final bool isFlipped;
  final Duration duration;
  final bool useBlueprintStyle;

  @override
  State<EskoliaFlipCard> createState() => _EskoliaFlipCardState();
}

class _EskoliaFlipCardState extends State<EskoliaFlipCard> {

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.isFlipped ? "Carte de question - Réponse" : "Carte de question - Question",
      value: widget.isFlipped ? "La réponse est révélée." : "La réponse est masquée.",
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: widget.isFlipped
            ? KeyedSubtree(
                key: const ValueKey('back'),
                child: _buildCardContainer(widget.back, isBack: true),
              )
            : KeyedSubtree(
                key: const ValueKey('front'),
                child: _buildCardContainer(widget.front, isBack: false),
              ),
      ),
    );
  }

  Widget _buildCardContainer(Widget content, {required bool isBack}) {
    if (widget.useBlueprintStyle) {
      return CustomPaint(
        painter: _TechnicalViseurPainter(
          lineColor: Colors.white.withValues(alpha: 0.1),
          cornerColor: EskoliaTokens.cyan.withValues(alpha: 0.7),
        ),
        child: Container(
          constraints: const BoxConstraints(minHeight: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: EskoliaTokens.surface1.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: content,
          ),
        ),
      );
    }

    return EskoliaCardContent(
      padding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(minHeight: 300),
        child: content,
      ),
    );
  }
}

class _TechnicalViseurPainter extends CustomPainter {
  final Color lineColor;
  final Color cornerColor;

  _TechnicalViseurPainter({
    required this.lineColor,
    required this.cornerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintCorner = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    
    // Draw outer boundary line
    canvas.drawRRect(rrect, paintLine);

    // L-shaped markings at the corners (viseurs)
    const double tick = 10.0;
    const double offset = 0.0;

    // Top-Left corner
    canvas.drawLine(
      Offset(offset, offset + tick),
      Offset(offset, offset),
      paintCorner,
    );
    canvas.drawLine(
      Offset(offset, offset),
      Offset(offset + tick, offset),
      paintCorner,
    );

    // Top-Right corner
    canvas.drawLine(
      Offset(size.width - offset, offset + tick),
      Offset(size.width - offset, offset),
      paintCorner,
    );
    canvas.drawLine(
      Offset(size.width - offset, offset),
      Offset(size.width - offset - tick, offset),
      paintCorner,
    );

    // Bottom-Left corner
    canvas.drawLine(
      Offset(offset, size.height - offset - tick),
      Offset(offset, size.height - offset),
      paintCorner,
    );
    canvas.drawLine(
      Offset(offset, size.height - offset),
      Offset(offset + tick, size.height - offset),
      paintCorner,
    );

    // Bottom-Right corner
    canvas.drawLine(
      Offset(size.width - offset, size.height - offset - tick),
      Offset(size.width - offset, size.height - offset),
      paintCorner,
    );
    canvas.drawLine(
      Offset(size.width - offset, size.height - offset),
      Offset(size.width - offset - tick, size.height - offset),
      paintCorner,
    );
    
    // Side cross-hair ticks
    const double sideTick = 4.0;
    // Top
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, sideTick), paintCorner);
    // Bottom
    canvas.drawLine(Offset(size.width / 2, size.height), Offset(size.width / 2, size.height - sideTick), paintCorner);
    // Left
    canvas.drawLine(Offset(0, size.height / 2), Offset(sideTick, size.height / 2), paintCorner);
    // Right
    canvas.drawLine(Offset(size.width, size.height / 2), Offset(size.width - sideTick, size.height / 2), paintCorner);
  }

  @override
  bool shouldRepaint(covariant _TechnicalViseurPainter oldDelegate) {
    return oldDelegate.lineColor != lineColor || oldDelegate.cornerColor != cornerColor;
  }
}
