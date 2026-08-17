import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/eskolia_tokens.dart';
import '../../core/utils/feature_info_resolver.dart';
import '../../features/home/presentation/providers/home_providers.dart';
import '../../features/home/presentation/widgets/home_card_settings_dialog.dart';
import 'eskolia_card.dart';

/// Widget de carte section interactive unifié pour l'ensemble des 7 hubs Eskolia
class EskoliaSectionCard extends ConsumerWidget {
  const EskoliaSectionCard({
    super.key,
    required this.cardKey,
    required this.badge,
    required this.title,
    required this.accentColor,
    required this.body,
    this.isPinned = false,
    this.onTogglePin,
    this.isAddedToHome = false,
    this.onToggleHome,
    this.extraHeaderActions = const [],
    this.onInfoTap,
    this.defaultEmoji,
  });

  final String cardKey;
  final String badge;
  final String title;
  final Color accentColor;
  final Widget body;
  final bool isPinned;
  final VoidCallback? onTogglePin;
  final bool isAddedToHome;
  final VoidCallback? onToggleHome;
  final List<Widget> extraHeaderActions;
  final VoidCallback? onInfoTap;
  final String? defaultEmoji;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final settings = settingsMap[cardKey];
    final displayTitle = settings?.title.isNotEmpty == true ? settings!.title : title;
    final isCollapsed = settings?.isCollapsed ?? false;

    final displayAccentColor = settings != null
        ? Color(settings.colorHex)
        : (isPinned ? EskoliaTokens.cyan : accentColor);

    final info = FeatureInfoResolver.getInfo(cardKey);

    return EskoliaCardContent(
      accentBorderColor: displayAccentColor,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Ligne 1 : Badge + Titre + Info
          Row(
            children: [
              EskoliaCardSectionBadge(
                sectionName: badge,
                color: displayAccentColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse(cardKey),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      displayTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              if (info != null || onInfoTap != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  padding: EdgeInsets.zero,
                  tooltip: 'Comment ça marche ?',
                  onPressed: onInfoTap ?? () => _showDefaultInfoDialog(context, info!),
                  icon: const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white60,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // Header Ligne 2 : Actions (Plier, Personnaliser, Épingler, Ajouter Accueil, etc.)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Extra header actions (e.g. shuffle)
              ...extraHeaderActions,

              // Bouton Réduire / Déplier
              IconButton(
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                tooltip: isCollapsed ? 'Déplier la carte' : 'Plier la carte',
                onPressed: () => ref.read(homeCardSettingsProvider.notifier).toggleCollapse(cardKey),
                icon: Icon(
                  isCollapsed ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: isCollapsed ? Colors.white54 : displayAccentColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 2),

              // Bouton Personnaliser
              IconButton(
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                padding: EdgeInsets.zero,
                tooltip: 'Personnaliser',
                onPressed: () => showHomeCardSettingsDialog(
                  context,
                  ref,
                  cardKey,
                  defaultTitleOverride: title,
                  defaultColorOverride: accentColor,
                ),
                icon: const Icon(
                  Icons.edit_note_rounded,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
              const SizedBox(width: 2),

              // Bouton Épingler localement
              if (onTogglePin != null) ...[
                IconButton(
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  tooltip: isPinned ? 'Désépingler' : 'Épingler en haut',
                  onPressed: onTogglePin,
                  icon: Icon(
                    isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                    color: isPinned ? displayAccentColor : Colors.white38,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 2),
              ],

              // Bouton Ajouter / Retirer de l'accueil
              if (onToggleHome != null)
                IconButton(
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  padding: EdgeInsets.zero,
                  tooltip: isAddedToHome ? 'Retirer de l\'accueil' : 'Ajouter à l\'accueil',
                  onPressed: onToggleHome,
                  icon: Icon(
                    isAddedToHome ? Icons.add_circle_rounded : Icons.add_circle_outline_rounded,
                    color: isAddedToHome ? EskoliaTokens.success : Colors.white54,
                    size: 17,
                  ),
                ),
            ],
          ),

          // Body Content (collapsible)
          if (!isCollapsed) ...[
            const SizedBox(height: 14),
            body,
          ],
        ],
      ),
    );
  }

  void _showDefaultInfoDialog(BuildContext context, FeatureInfo info) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: EskoliaTokens.surface1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              if (info.emoji.isNotEmpty) ...[
                Text(info.emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  info.title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: FeatureInfoResolver.buildRichDescription(
            info.description,
            const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.45),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Compris',
                style: TextStyle(
                  color: EskoliaTokens.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
