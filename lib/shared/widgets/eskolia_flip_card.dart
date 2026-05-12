import 'dart:math';
import 'package:flutter/material.dart';
import 'eskolia_card.dart';

/// Un widget de carte qui pivote à 180 degrés avec un effet 3D.
/// Parfait pour le mode "Mastery" (Face A: Question, Face B: Réponse).
class EskoliaFlipCard extends StatefulWidget {
  const EskoliaFlipCard({
    super.key,
    required this.front,
    required this.back,
    this.isFlipped = false,
    this.duration = const Duration(milliseconds: 600),
  });

  final Widget front;
  final Widget back;
  final bool isFlipped;
  final Duration duration;

  @override
  State<EskoliaFlipCard> createState() => _EskoliaFlipCardState();
}

class _EskoliaFlipCardState extends State<EskoliaFlipCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack),
    );
    
    if (widget.isFlipped) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(EskoliaFlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final double rotationValue = _animation.value * pi;
        final bool isBackVisible = rotationValue > pi / 2;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(rotationValue),
          alignment: Alignment.center,
          child: isBackVisible
              ? Transform(
                  // On retourne le contenu du dos pour qu'il soit lisible après la rotation
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: _buildCardContainer(widget.back, isBack: true),
                )
              : _buildCardContainer(widget.front, isBack: false),
        );
      },
    );
  }

  Widget _buildCardContainer(Widget content, {required bool isBack}) {
    return EskoliaCardContent(
      padding: const EdgeInsets.all(24),
      child: Container(
        constraints: const BoxConstraints(minHeight: 300),
        child: content,
      ),
    );
  }
}
