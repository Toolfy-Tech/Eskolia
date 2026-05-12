import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/eskolia_tips_data.dart';

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
    return Container(
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        border: Border(
          bottom: BorderSide(
            color: Color(0x14FFFFFF),
            width: 0.5,
          ),
        ),
      ),
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
    );
  }
}
