import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/eskolia_tokens.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../docs_mini_course_dialog.dart';

class DocsSearchCardBody extends ConsumerStatefulWidget {
  const DocsSearchCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<DocsSearchCardBody> createState() => _DocsSearchCardBodyState();
}

class _DocsSearchCardBodyState extends ConsumerState<DocsSearchCardBody> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _search() {
    final query = _searchCtrl.text.trim();
    context.go('/docs'); // Goes to docs page
  }

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:docs_search']?.isCollapsed ?? false);

    final searchField = Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        controller: _searchCtrl,
        onSubmitted: (_) => _search(),
        style: const TextStyle(color: Colors.white, fontSize: 12.5),
        decoration: InputDecoration(
          hintText: 'Rechercher un mémo (ex: OSI, RGPD)...',
          hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
          prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 16),
          suffixIcon: IconButton(
            icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 16),
            onPressed: _search,
            padding: EdgeInsets.zero,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
    );

    if (isCollapsed) {
      return searchField;
    }

    // Extended Mode: search field + 3 quick links
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        searchField,
        const SizedBox(height: 12),
        const Text(
          'Mémos rapides',
          style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 10.5, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        _buildShortcutItem(
          title: 'RGPD',
          subtitle: 'Règlement européen sur les données',
          color: EskoliaTokens.violetSoft,
          onTap: () => showDocsMiniCourseDialog(
            context,
            title: 'Mini-formation — RGPD',
            assetPath: 'data/docs/mini_formation_rgpd.md',
            officialUrl: 'https://www.cnil.fr/fr/reglement-europeen-protection-donnees',
            officialLinkLabel: 'Fiche CNIL sur le règlement européen',
          ),
        ),
        const SizedBox(height: 6),
        _buildShortcutItem(
          title: 'ANSSI',
          subtitle: 'Bonnes pratiques de sécurité ops',
          color: EskoliaTokens.success,
          onTap: () => showDocsMiniCourseDialog(
            context,
            title: 'Mini-formation — ANSSI',
            assetPath: 'data/docs/mini_formation_anssi.md',
            officialUrl: 'https://www.ssi.gouv.fr/',
            officialLinkLabel: 'Site de l\'ANSSI',
          ),
        ),
        const SizedBox(height: 6),
        _buildShortcutItem(
          title: 'Modèle OSI',
          subtitle: 'Les 7 couches et l\'encapsulation',
          color: EskoliaTokens.cyan,
          onTap: () => showDocsMiniCourseDialog(
            context,
            title: 'Mini-formation — Modèle OSI',
            assetPath: 'data/docs/mini_formation_osi.md',
            officialUrl: null,
            officialLinkLabel: null,
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutItem({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.school_outlined, color: Colors.white30, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
