import 'package:flutter/material.dart';

import '../../data/optimus_content_models.dart';
import '../../data/parcours_repository.dart';

const List<_ModuleLabel> _labels = [
  _ModuleLabel('M01', 'Support utilisateur'),
  _ModuleLabel('M02', 'Hardware & Architecture'),
  _ModuleLabel('M03', 'Systeme d\'exploitation'),
  _ModuleLabel('M04', 'Reseaux & Infrastructure'),
  _ModuleLabel('M05', 'Maintenance & Sauvegarde'),
  _ModuleLabel('M06', 'Administration Windows'),
  _ModuleLabel('M07', 'Cybersecurite & RGPD'),
  _ModuleLabel('M08', 'Utiliser l\'IA'),
];

class MegaLexiqueCardBody extends StatefulWidget {
  const MegaLexiqueCardBody({super.key, required this.accentColor});
  final Color accentColor;

  @override
  State<MegaLexiqueCardBody> createState() => _MegaLexiqueCardBodyState();
}

class _MegaLexiqueCardBodyState extends State<MegaLexiqueCardBody> {
  late final Future<List<ModuleLexique>> _future = OptimusLexiqueRepository.loadAll();
  String _selectedModuleId = 'M01';
  final Map<String, bool> _expandedChapters = {};

  String _getChapterSlug(ModuleModel ch, String moduleId) {
    final prefix = 'optimus_${moduleId}_';
    if (ch.id.startsWith(prefix)) {
      return ch.id.substring(prefix.length);
    }
    return ch.id;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ModuleLexique>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2, color: widget.accentColor),
            ),
          );
        }
        if (snap.hasError || !snap.hasData) {
          return const Center(
            child: Text(
              'Erreur de chargement du lexique',
              style: TextStyle(color: Colors.redAccent, fontSize: 12),
            ),
          );
        }

        final all = snap.data!;
        final activeModule = all.firstWhere(
          (m) => m.moduleId == _selectedModuleId,
          orElse: () => ModuleLexique(moduleId: _selectedModuleId, terms: const []),
        );

        final label = _labels.firstWhere(
          (l) => l.id == _selectedModuleId,
          orElse: () => _ModuleLabel(_selectedModuleId, _selectedModuleId),
        );

        final section = ParcoursRepository.sectionByCompoundKey['optimus::$_selectedModuleId'];
        final chapters = section?.modules ?? [];

        // Group terms by chapter slug
        final Map<String, List<LexiqueEntry>> groupedTerms = {};
        final List<LexiqueEntry> generalTerms = [];

        for (final t in activeModule.terms) {
          if (t.chapterSlug == null || t.chapterSlug!.isEmpty) {
            generalTerms.add(t);
          } else {
            groupedTerms.putIfAbsent(t.chapterSlug!, () => []).add(t);
          }
        }

        final List<Widget> chapterWidgets = [];

        // General terms (if any)
        if (generalTerms.isNotEmpty) {
          final isExpanded = _expandedChapters['general'] ?? true; // default general to open
          chapterWidgets.add(
            _buildChapterCollapseTile(
              title: 'Termes généraux',
              index: 0,
              isExpanded: isExpanded,
              accentColor: widget.accentColor,
              onTap: () => setState(() => _expandedChapters['general'] = !isExpanded),
              children: generalTerms.map((t) => _buildTermTile(t)).toList(),
            ),
          );
          chapterWidgets.add(const SizedBox(height: 8));
        }

        // Chapters
        for (var i = 0; i < chapters.length; i++) {
          final ch = chapters[i];
          final slug = _getChapterSlug(ch, _selectedModuleId);
          final terms = groupedTerms[slug] ?? [];
          if (terms.isEmpty) continue;

          final isExpanded = _expandedChapters[slug] ?? false; // default chapters to closed
          chapterWidgets.add(
            _buildChapterCollapseTile(
              title: ch.title,
              index: i + 1,
              isExpanded: isExpanded,
              accentColor: widget.accentColor,
              onTap: () => setState(() => _expandedChapters[slug] = !isExpanded),
              children: terms.map((t) => _buildTermTile(t)).toList(),
            ),
          );
          chapterWidgets.add(const SizedBox(height: 8));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Module Filter pills
            SizedBox(
              height: 38,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _labels.length,
                itemBuilder: (context, idx) {
                  final l = _labels[idx];
                  final isActive = l.id == _selectedModuleId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _selectedModuleId = l.id;
                        _expandedChapters.clear();
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? widget.accentColor.withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? widget.accentColor.withValues(alpha: 0.55)
                                : Colors.white.withValues(alpha: 0.10),
                            width: isActive ? 1.5 : 1.0,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            l.id,
                            style: TextStyle(
                              color: isActive ? widget.accentColor : Colors.white60,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            // Header of selected module
            Text(
              '${label.id} — ${label.name}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            if (chapterWidgets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Aucun terme pour ce module',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: chapterWidgets,
              ),
          ],
        );
      },
    );
  }

  Widget _buildChapterCollapseTile({
    required String title,
    required int index,
    required bool isExpanded,
    required Color accentColor,
    required VoidCallback onTap,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: isExpanded
                  ? accentColor.withValues(alpha: 0.06)
                  : Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isExpanded
                    ? accentColor.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                if (index > 0) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'CH.$index',
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.white70,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
          crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildTermTile(LexiqueEntry t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.term,
            style: TextStyle(
              color: widget.accentColor.withValues(alpha: 0.95),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            t.definition,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.80),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleLabel {
  const _ModuleLabel(this.id, this.name);
  final String id;
  final String name;
}
