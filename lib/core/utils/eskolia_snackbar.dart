import 'package:flutter/material.dart';

import '../constants/eskolia_tokens.dart';

void showEskoliaSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: EskoliaTokens.violet,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

void showStreakBanner(BuildContext context, int streak) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '🔥 Série de $streak jour${streak > 1 ? 's' : ''} — continue aujourd\'hui !',
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      backgroundColor: EskoliaTokens.error,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

void showAchievementSnackBar(BuildContext context, String emoji, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Haut fait débloqué !',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white70),
                ),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: EskoliaTokens.violet,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
