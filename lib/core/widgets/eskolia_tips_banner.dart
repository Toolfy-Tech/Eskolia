import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

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
            color: const Color(0xFF0F0F1A).withValues(alpha: 0.82),
            border: const Border(
              bottom: BorderSide(
                color: Color(0x14FFFFFF),
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
                      color: Color(0xFF94A3B8),
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
