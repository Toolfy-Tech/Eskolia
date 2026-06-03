import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../constants/eskolia_tokens.dart';
import '../data/eskolia_tips_data.dart';

const double kTipsBannerHeight = 44.0;

class EskoliaTipsBanner extends StatefulWidget {
  const EskoliaTipsBanner({super.key});

  @override
  State<EskoliaTipsBanner> createState() => _EskoliaTipsBannerState();
}

class _EskoliaTipsBannerState extends State<EskoliaTipsBanner> {
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
              const SizedBox(width: 16),
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
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
