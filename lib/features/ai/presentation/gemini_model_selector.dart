import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../data/gemini_model_info.dart';

/// Selecteur de modele Gemini avec tier list visuelle.
/// Recupere la liste depuis l'API Google et trie S > A > B > C.
/// Rapporte le modelId (sans prefixe 'models/') via [onChanged].
class GeminiModelSelector extends StatefulWidget {
  const GeminiModelSelector({
    super.key,
    required this.apiKey,
    required this.initialModel,
    required this.onChanged,
  });

  final String apiKey;
  final String initialModel;
  final ValueChanged<String> onChanged;

  @override
  State<GeminiModelSelector> createState() => _GeminiModelSelectorState();
}

class _GeminiModelSelectorState extends State<GeminiModelSelector> {
  List<GeminiModelInfo> _models = [];
  late String _selected;
  bool _loading = true;
  bool _offline  = false;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialModel;
    _fetch();
  }

  @override
  void didUpdateWidget(GeminiModelSelector old) {
    super.didUpdateWidget(old);
    if (old.apiKey != widget.apiKey) _fetch();
  }

  Future<void> _fetch() async {
    if (widget.apiKey.length < 10) return;

    if (!mounted) return;
    setState(() {
      _loading = true;
      _offline  = false;
    });

    try {
      final dio = Dio();
      final resp = await dio.get<dynamic>(
        'https://generativelanguage.googleapis.com/v1beta/models',
        queryParameters: {'key': widget.apiKey},
        options: Options(
          sendTimeout:    const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );

      if (!mounted) return;

      final data = resp.data is Map
          ? resp.data as Map<String, dynamic>
          : jsonDecode(resp.data.toString()) as Map<String, dynamic>;

      final rawList = data['models'];
      if (rawList is! List) throw const FormatException('format inattendu');

      final models = rawList
          .whereType<Map>()
          .where((m) {
            final name = m['name'] as String? ?? '';
            // Filtrer sur supportedGenerationMethods si disponible.
            final methods = m['supportedGenerationMethods'];
            if (methods is List) {
              if (!methods.contains('generateContent')) return false;
            }
            return name.contains('gemini') &&
                !name.contains('embedding') &&
                !name.contains('-aqa') &&
                !name.contains('vision') &&
                !name.contains('bison') &&
                !name.contains('gecko');
          })
          .map((m) => GeminiModelInfo.from(m['name'] as String))
          .toList()
        ..sort((a, b) {
          final t = a.sortOrder.compareTo(b.sortOrder);
          return t != 0 ? t : b.modelId.compareTo(a.modelId);
        });

      if (models.isEmpty) throw const FormatException('liste vide');
      _applyModels(models);
    } catch (_) {
      _applyModels(GeminiModelInfo.defaults(), offline: true);
    }
  }

  void _applyModels(List<GeminiModelInfo> models, {bool offline = false}) {
    if (!mounted) return;

    final inList = models.any((m) => m.modelId == _selected);
    if (!inList) {
      final aTier = models.where((m) => m.tier == 'A').toList();
      _selected = aTier.isNotEmpty ? aTier.first.modelId : models.first.modelId;
    }

    setState(() {
      _models  = models;
      _loading = false;
      _offline  = offline;
    });

    // Notifier le parent apres le setState pour eviter les conflits de frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onChanged(_selected);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tete
        Row(children: [
          const Text(
            'MODELE GEMINI',
            style: TextStyle(
              color: EskoliaTokens.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          if (_loading) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                color: EskoliaTokens.textSecondary.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (!_loading && _offline) ...[
            const SizedBox(width: 8),
            Icon(Icons.wifi_off_rounded, size: 11, color: EskoliaTokens.textSecondary.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(
              'Liste locale',
              style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.5), fontSize: 10),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        // Corps
        if (_loading)
          _buildSkeleton()
        else if (_models.isEmpty)
          _buildEmpty()
        else
          _buildDropdown(),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: EskoliaTokens.textSecondary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Chargement des modeles...',
            style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.info_outline_rounded, size: 15, color: EskoliaTokens.textSecondary.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Text(
            'Aucun modele compatible trouve.',
            style: TextStyle(color: EskoliaTokens.textSecondary.withValues(alpha: 0.7), fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    final firstATier = _models.firstWhere(
      (m) => m.tier == 'A',
      orElse: () => _models.first,
    );

    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: EskoliaTokens.surface2,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selected,
            isExpanded: true,
            itemHeight: 56,
            icon: Icon(
              Icons.expand_more_rounded,
              color: EskoliaTokens.textSecondary.withValues(alpha: 0.7),
              size: 20,
            ),
            items: _models.map((m) {
              final isDefaultA = m.modelId == firstATier.modelId;
              return DropdownMenuItem<String>(
                value: m.modelId,
                child: Row(
                  children: [
                    _TierBadge(tier: m.tier, color: m.tierColor),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.simpleName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            m.tierLabel,
                            style: TextStyle(
                              color: EskoliaTokens.textSecondary.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDefaultA)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: m.tierColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: m.tierColor.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          'DEFAUT',
                          style: TextStyle(
                            color: m.tierColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val == null) return;
              setState(() => _selected = val);
              widget.onChanged(val);
            },
          ),
        ),
      ),
    );
  }
}

// ── Badge tier ────────────────────────────────────────────────────────────────

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier, required this.color});

  final String tier;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Center(
        child: Text(
          tier,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
