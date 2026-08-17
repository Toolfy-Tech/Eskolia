import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/eskolia_tokens.dart';
import '../data/eskolia_tips_data.dart';
import '../theme/text_scale_provider.dart';

const double kTipsBannerHeight = 44.0;

class EskoliaTipsBanner extends ConsumerStatefulWidget {
  const EskoliaTipsBanner({super.key});

  @override
  ConsumerState<EskoliaTipsBanner> createState() => _EskoliaTipsBannerState();
}

class _EskoliaTipsBannerState extends ConsumerState<EskoliaTipsBanner> {
  late int _index;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _index = Random().nextInt(kEskoliaTips.length);
    _timer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (mounted) {
        setState(() => _index = (_index + 1) % kEskoliaTips.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final currentScale = ref.watch(textScaleProvider);
    final isZoomed = (currentScale - 1.0).abs() > 0.04;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          height: topPad + kTipsBannerHeight,
          decoration: BoxDecoration(
            color: EskoliaTokens.bgBase.withValues(alpha: 0.82),
            border: const Border(
              bottom: BorderSide(
                color: EskoliaTokens.borderSubtle,
                width: 0.5,
              ),
            ),
          ),
          padding: EdgeInsets.only(top: topPad),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Text('💡', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    kEskoliaTips[_index],
                    key: ValueKey(_index),
                    style: const TextStyle(
                      fontSize: 12,
                      color: EskoliaTokens.textSecondary,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // Bouton Zoom & Lisibilité toujours accessible en haut de l'écran
              Tooltip(
                message: 'Zoom & Lisibilité (${(currentScale * 100).round()}%)',
                child: InkWell(
                  onTap: () => showTextScaleDialog(context, ref),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: isZoomed
                          ? EskoliaTokens.cyan.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isZoomed
                            ? EskoliaTokens.cyan.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_rounded,
                          size: 14,
                          color: isZoomed ? EskoliaTokens.cyan : Colors.white70,
                        ),
                        if (isZoomed) ...[
                          const SizedBox(width: 4),
                          Text(
                            '${(currentScale * 100).round()}%',
                            style: const TextStyle(
                              color: EskoliaTokens.cyan,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
      ),
    );
  }
}
