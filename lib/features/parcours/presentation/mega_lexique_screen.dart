import 'package:flutter/material.dart';

import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../data/optimus_content_models.dart';
import 'widgets/lexique_section.dart';

const Color _cyan = Color(0xFF00BCD4);
const Color _slate = Color(0xFF94A3B8);

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

class MegaLexiqueScreen extends StatefulWidget {
  const MegaLexiqueScreen({super.key});

  @override
  State<MegaLexiqueScreen> createState() => _MegaLexiqueScreenState();
}

class _MegaLexiqueScreenState extends State<MegaLexiqueScreen> {
  late final Future<List<ModuleLexique>> _future =
      OptimusLexiqueRepository.loadAll();
  String? _filter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(context, title: 'Mega Lexique'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          SafeArea(
            top: false,
            child: FutureBuilder<List<ModuleLexique>>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: _cyan));
                }
                final all = snap.data ?? const [];
                final shown = _filter == null
                    ? all
                    : all.where((m) => m.moduleId == _filter).toList();
                final totalTerms =
                    shown.fold(0, (sum, m) => sum + m.terms.length);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _FilterBar(
                      selected: _filter,
                      onSelect: (id) =>
                          setState(() => _filter = _filter == id ? null : id),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                      child: Text(
                        '$totalTerms terme${totalTerms > 1 ? 's' : ''}',
                        style: TextStyle(color: _slate, fontSize: 12),
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 80),
                        itemCount: shown.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final mod = shown[i];
                          final label = _labels.firstWhere(
                              (l) => l.id == mod.moduleId,
                              orElse: () =>
                                  _ModuleLabel(mod.moduleId, mod.moduleId));
                          return LexiqueSection(
                            terms: mod.terms,
                            title:
                                '${label.id} — ${label.name}',
                            initiallyExpanded: _filter != null,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.selected, required this.onSelect});

  final String? selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
        scrollDirection: Axis.horizontal,
        children: _labels
            .map(
              (l) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _Chip(
                  label: l.id,
                  active: selected == l.id,
                  onTap: () => onSelect(l.id),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(
      {required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: active
              ? _cyan.withValues(alpha: 0.18)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? _cyan.withValues(alpha: 0.55)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? _cyan : _slate,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ModuleLabel {
  const _ModuleLabel(this.id, this.name);

  final String id;
  final String name;
}
