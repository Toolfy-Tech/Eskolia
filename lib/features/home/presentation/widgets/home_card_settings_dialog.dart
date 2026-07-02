import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/eskolia_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../../core/theme/eskolia_visual.dart';
import '../providers/home_providers.dart';

void showHomeCardSettingsDialog(
  BuildContext context,
  WidgetRef ref,
  String cardKey, {
  String? defaultTitleOverride,
  Color? defaultColorOverride,
}) {
  final settingsMap = ref.read(homeCardSettingsProvider);
  final currentSettings = settingsMap[cardKey];

  // Valeurs par défaut selon la clé de la carte
  String defaultTitle = defaultTitleOverride ?? 'Veille Générale';
  String defaultEmoji = '🖥️';
  Color defaultColor = defaultColorOverride ?? EskoliaTokens.cyan;
  int defaultLimit = 8;
  bool hasLimit = true;

  if (cardKey == 'it_pro') {
    defaultTitle = 'Veille Générale';
    defaultEmoji = '🖥️';
    defaultColor = EskoliaTokens.cyan;
    defaultLimit = 5;
  } else if (cardKey == 'favoris') {
    defaultTitle = 'Articles Favoris';
    defaultEmoji = '❤️';
    defaultColor = EskoliaTokens.violet;
    defaultLimit = 5;
  } else if (cardKey == 'messages') {
    defaultTitle = 'Messages d\'accueil';
    defaultEmoji = '👋';
    defaultColor = EskoliaTokens.success;
    defaultLimit = 5;
  } else if (cardKey == 'astuces') {
    defaultTitle = 'Astuces Pro';
    defaultEmoji = '💡';
    defaultColor = EskoliaTokens.amber;
    defaultLimit = 5;
  } else if (cardKey == 'security') {
    defaultTitle = 'Sécurité & Menaces';
    defaultEmoji = '🛡️';
    defaultColor = EskoliaTokens.error;
    defaultLimit = 5;
  } else if (cardKey == 'it') {
    defaultTitle = 'Veille IT';
    defaultEmoji = '💻';
    defaultColor = EskoliaTokens.cyan;
    defaultLimit = 5;
  } else if (cardKey == 'hardware') {
    defaultTitle = 'Veille Hardware';
    defaultEmoji = '🔌';
    defaultColor = Colors.orange;
    defaultLimit = 5;
  } else if (cardKey == 'software') {
    defaultTitle = 'Veille Software';
    defaultEmoji = '💿';
    defaultColor = Colors.purpleAccent;
    defaultLimit = 5;
  } else if (cardKey.startsWith('note:')) {
    defaultTitle = defaultTitleOverride ?? 'Note';
    defaultEmoji = '📝';
    defaultColor = defaultColorOverride ?? EskoliaTokens.violetSoft;
    defaultLimit = 5;
    hasLimit = false;
  } else if (cardKey.startsWith('source:')) {
    final srcName = cardKey.substring(7);
    String label = srcName;
    if (srcName.startsWith('custom:')) {
      try {
        final map = jsonDecode(srcName.substring(7)) as Map<String, dynamic>;
        label = map['label'] as String? ?? 'Flux perso';
      } catch (_) {}
    }
    defaultTitle = 'Veille $label';
    defaultEmoji = '📡';
    defaultColor = EskoliaTokens.cyan;
    defaultLimit = 5;
  } else if (cardKey.startsWith('feature:')) {
    final featId = cardKey.substring(8);
    switch (featId) {
      case 'ai':
        defaultTitle = 'Mon Tuteur IA';
        defaultEmoji = '🧠';
        defaultColor = EskoliaTokens.violet;
        break;
      case 'solo':
        defaultTitle = 'Mode Solo (Quiz)';
        defaultEmoji = '🎮';
        defaultColor = EskoliaTokens.cyan;
        break;
      case 'solo_quiz':
        defaultTitle = 'Générateur de Quiz';
        defaultEmoji = '🎮';
        defaultColor = EskoliaTokens.cyan;
        break;
      case 'solo_quiz_ai':
        defaultTitle = 'Génération avec IA';
        defaultEmoji = '🧠';
        defaultColor = EskoliaTokens.violet;
        break;
      case 'solo_true_false':
        defaultTitle = 'Vrai / Faux Express';
        defaultEmoji = '⚡';
        defaultColor = EskoliaTokens.cyan;
        break;
      case 'solo_lacunes':
        defaultTitle = 'Mes fautes';
        defaultEmoji = '❌';
        defaultColor = EskoliaTokens.error;
        break;
      case 'solo_pool':
        defaultTitle = 'À revoir';
        defaultEmoji = '📌';
        defaultColor = EskoliaTokens.success;
        break;
      case 'tp':
        defaultTitle = 'Travaux Pratiques';
        defaultEmoji = '🛠️';
        defaultColor = Colors.blueAccent;
        break;
      case 'flashcards':
        defaultTitle = 'Flashcards';
        defaultEmoji = '📚';
        defaultColor = EskoliaTokens.success;
        break;
      case 'examen_blanc':
        defaultTitle = 'Validation TIP';
        defaultEmoji = '🏆';
        defaultColor = EskoliaTokens.amber;
        break;
      case 'lexique':
        defaultTitle = 'Lexique TIP';
        defaultEmoji = '📖';
        defaultColor = EskoliaTokens.orange;
        break;
      case 'mediatheque':
        defaultTitle = 'Média TIP';
        defaultEmoji = '📁';
        defaultColor = EskoliaTokens.violetSoft;
        break;
      case 'parcours':
        defaultTitle = 'Cours formation TIP';
        defaultEmoji = '🎓';
        defaultColor = EskoliaTokens.cyan;
        break;
      case 'podcasts':
        defaultTitle = 'Podcast TIP';
        defaultEmoji = '📡';
        defaultColor = Colors.pinkAccent;
        break;
      case 'notebook':
        defaultTitle = 'Mon Bloc-notes';
        defaultEmoji = '📝';
        defaultColor = EskoliaTokens.success;
        break;
      case 'docs':
      case 'docs_search':
        defaultTitle = 'Documentation IT';
        defaultEmoji = '📖';
        defaultColor = Colors.orange;
        break;
      case 'docs_mes_cours':
        defaultTitle = 'Mes cours sauvegardés';
        defaultEmoji = '📚';
        defaultColor = EskoliaTokens.violetSoft;
        break;
      case 'docs_rgpd':
        defaultTitle = 'RGPD (UE)';
        defaultEmoji = '⚖️';
        defaultColor = EskoliaVisual.neonViolet;
        break;
      case 'docs_cnil':
        defaultTitle = 'CNIL';
        defaultEmoji = '🏢';
        defaultColor = EskoliaVisual.neonCyan;
        break;
      case 'docs_anssi':
        defaultTitle = 'ANSSI & bonnes pratiques';
        defaultEmoji = '🛡️';
        defaultColor = EskoliaVisual.neonGreen;
        break;
      case 'docs_itil':
        defaultTitle = 'ITIL 4 (Services IT)';
        defaultEmoji = '🎟️';
        defaultColor = const Color(0xFF60A5FA);
        break;
      case 'docs_osi':
        defaultTitle = 'Modèle OSI & réseaux';
        defaultEmoji = '🌐';
        defaultColor = const Color(0xFF34D399);
        break;
      case 'docs_technician':
        defaultTitle = 'Technicien - Bonnes pratiques';
        defaultEmoji = '💡';
        defaultColor = const Color(0xFFFFB74D);
        break;
      case 'labo':
      case 'labo_contrib':
        defaultTitle = 'Le Labo';
        defaultEmoji = '🧪';
        defaultColor = Colors.tealAccent;
        break;
      case 'classement':
        defaultTitle = 'Progression & Rang';
        defaultEmoji = '🏆';
        defaultColor = EskoliaTokens.amber;
        break;
      case 'lobby':
      case 'lobbys':
        defaultTitle = 'Lobbys Multijoueur';
        defaultEmoji = '👥';
        defaultColor = Colors.pinkAccent;
        break;
      default:
        defaultTitle = 'Lobbys Multijoueur';
        defaultEmoji = '👥';
        defaultColor = Colors.pinkAccent;
    }
    defaultLimit = 5;
    hasLimit = false;
  }

  final titleController = TextEditingController(text: currentSettings?.title.isNotEmpty == true ? currentSettings!.title : defaultTitle);
  String selectedEmoji = currentSettings?.emoji ?? defaultEmoji;
  int selectedColorValue = currentSettings?.colorHex ?? defaultColor.value;
  final isTipsOrMessages = cardKey == 'astuces' || cardKey == 'messages';
  double initialLimit = (currentSettings?.limit ?? defaultLimit).toDouble();
  if (isTipsOrMessages) {
    initialLimit = initialLimit.clamp(1.0, 10.0);
  }
  double selectedLimit = initialLimit;
  String selectedSortBy = currentSettings?.sortBy ?? 'newest';
  double selectedScrollInterval = (currentSettings?.scrollInterval ?? 12).toDouble().clamp(3.0, 30.0);

  final emojis = ['💻', '🛡️', '📡', '🔌', '💿', '🚀', '💡', '🎓', '🖥️', '❤️', '🌟', '🔍', '📂', '⚡', '🤖'];
  final colorList = [
    const Color(0xFF00E5FF), // Hyper Cyan
    const Color(0xFF8B5CF6), // Indigo / Violet
    const Color(0xFFD946EF), // Cyber Pink
    const Color(0xFF10B981), // Emerald Green
    const Color(0xFFFF9F0A), // Amber
    const Color(0xFFF97316), // Neon Orange
    const Color(0xFFEF4444), // Crimson Red
    const Color(0xFF3B82F6), // Dodger Blue
    const Color(0xFFFFD700), // Gold
  ];

  showDialog<void>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: EskoliaTokens.surface1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Color(selectedColorValue).withValues(alpha: 0.35), width: 1.5),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Personnaliser la carte',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded, color: Colors.white60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Nom de la carte',
                        labelStyle: const TextStyle(color: Colors.white60),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(selectedColorValue)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Couleur de la bordure', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: colorList.map((c) {
                        final isSelected = selectedColorValue == c.value;
                        return InkWell(
                          onTap: () => setDialogState(() => selectedColorValue = c.value),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: c,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (hasLimit) ...[
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            cardKey == 'astuces'
                                ? 'Nombre d\'astuces'
                                : (cardKey == 'messages' ? 'Nombre de messages' : 'Nombre d\'articles'),
                            style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            cardKey == 'astuces'
                                ? '${selectedLimit.toInt()} astuces'
                                : (cardKey == 'messages' ? '${selectedLimit.toInt()} messages' : '${selectedLimit.toInt()} articles'),
                            style: TextStyle(color: Color(selectedColorValue), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                      Slider(
                        value: selectedLimit,
                        min: isTipsOrMessages ? 1 : 3,
                        max: isTipsOrMessages ? 10 : 15,
                        divisions: isTipsOrMessages ? 9 : 4,
                        activeColor: Color(selectedColorValue),
                        inactiveColor: Colors.white12,
                        onChanged: (val) {
                          setDialogState(() => selectedLimit = val);
                        },
                      ),
                    ],
                    if (isTipsOrMessages) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Temps de défilement', style: TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('${selectedScrollInterval.toInt()} s', style: TextStyle(color: Color(selectedColorValue), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Slider(
                        value: selectedScrollInterval,
                        min: 3,
                        max: 30,
                        divisions: 27,
                        activeColor: Color(selectedColorValue),
                        inactiveColor: Colors.white12,
                        onChanged: (val) {
                          setDialogState(() => selectedScrollInterval = val);
                        },
                      ),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final nextSettings = HomeCardSettings(
                          title: titleController.text.trim(),
                          emoji: selectedEmoji,
                          colorHex: selectedColorValue,
                          limit: selectedLimit.toInt(),
                          sortBy: selectedSortBy,
                          scrollInterval: selectedScrollInterval.toInt(),
                        );
                        ref.read(homeCardSettingsProvider.notifier).updateSettings(cardKey, nextSettings);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(selectedColorValue),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Enregistrer',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

bool _isVeilleKey(String key) {
  return key == 'it_pro' ||
      key == 'security' ||
      key == 'it' ||
      key == 'hardware' ||
      key == 'software' ||
      key.startsWith('source:') ||
      key.startsWith('merge:');
}

void showMergeCardDialog(BuildContext context, WidgetRef ref, String currentKey) {
  final order = ref.read(homeCardsOrderProvider);
  final settingsMap = ref.read(homeCardSettingsProvider);

  String getCardTitle(String key) {
    final s = settingsMap[key];
    if (s?.title.isNotEmpty == true) return s!.title;
    if (key == 'it_pro') return 'Veille Générale';
    if (key == 'favoris') return 'Articles Favoris';
    if (key == 'messages') return 'Messages d\'accueil';
    if (key == 'astuces') return 'Astuces Pro';
    if (key.startsWith('source:')) {
      final srcName = key.substring(7);
      String label = srcName;
      if (srcName.startsWith('custom:')) {
        try {
          final map = jsonDecode(srcName.substring(7)) as Map<String, dynamic>;
          label = map['label'] as String? ?? 'Flux perso';
        } catch (_) {}
      }
      return 'Veille $label';
    }
    if (key == 'security') return 'Sécurité & Menaces';
    if (key == 'it') return 'Veille IT';
    if (key == 'hardware') return 'Veille Hardware';
    if (key == 'software') return 'Veille Software';
    if (key.startsWith('feature:')) {
      final featId = key.substring(8);
      return featId == 'ai'
          ? 'Mon Tuteur IA'
          : (featId == 'solo'
              ? 'Mode Solo (Quiz)'
              : (featId == 'classement'
                  ? 'Progression & Rang'
                  : (featId == 'tp'
                      ? 'Travaux Pratiques'
                      : (featId == 'notebook'
                          ? 'Mon Bloc-notes'
                          : (featId == 'flashcards'
                              ? 'Révisions Flashcards'
                              : (featId == 'docs'
                                  ? 'Documentation IT'
                                  : (featId == 'labo'
                                      ? 'Le Labo'
                                      : 'Lobbys Multijoueur')))))));
    }
    if (key.startsWith('merge:')) {
      final parts = key.substring(6).split('+');
      return 'Fusion : ${parts.map(getCardTitle).join(' + ')}';
    }
    return key;
  }

  final otherKeys = order.where((k) => k != currentKey && _isVeilleKey(k)).toList();

  showDialog<void>(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: EskoliaTokens.surface1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white12, width: 1.5),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 450),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Fusionner la carte',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sélectionnez une autre carte pour la fusionner avec celle-ci et regrouper leurs contenus.',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
                ),
              const SizedBox(height: 16),
              if (otherKeys.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    'Aucune autre carte disponible pour la fusion.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white38),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: SingleChildScrollView(
                    child: Column(
                      children: otherKeys.map((k) {
                        return ListTile(
                          title: Text(
                            getCardTitle(k),
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white30),
                          onTap: () {
                            ref.read(homeCardsOrderProvider.notifier).mergeCards(currentKey, k);
                            Navigator.of(context).pop();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Annuler', style: TextStyle(color: Colors.white60)),
              ),
            ],
          ),
        ),
       ),
      );
    },
  );
}

