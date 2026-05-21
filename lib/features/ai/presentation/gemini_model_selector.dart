import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/gemini_model_info.dart';

const Color _slate  = Color(0xFF94A3B8);

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
      final data = resp.data is Map
          ? resp.data as Map<String, dynamic>
          : jsonDecode(resp.data.toString()) as Map<String, dynamic>;

      final rawList = data['models'];
      if (rawList is! List) throw const FormatException('format inattendu');

      final models = rawList
          .whereType<Map>()
          .map((m) => m['name'] as String?)
          .where((n) =>
              n != null &&
              n.contains('gemini') &&
              !n.contains('embedding') &&
              !n.contains('-aqa') &&
              !n.contains('vision') &&
              !n.contains('bison') &&
              !n.contains('gecko'))
          .map((n) => GeminiModelInfo.from(n!))
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
    final inList = models.any((m) => m.modelId == _selected);
    if (!inList) {
      final aTier = models.where((m) => m.tier == 'A').toList();
      _selected = aTier.isNotEmpty ? aTier.first.modelId : models.first.modelId;
    }
    widget.onChanged(_selected);
    setState(() {
      _models  = models;
      _loading = false;
      _offline  = offline;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text(
            'MODELE GEMINI',
            style: TextStyle(
              color: _slate,
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
                color: _slate.withValues(alpha: 0.6),
              ),
            ),
          ],
          if (!_loading && _offline) ...[
            const SizedBox(width: 8),
            Icon(Icons.wifi_off_rounded, size: 11, color: _slate.withValues(alpha: 0.5)),
            const SizedBox(width: 4),
            Text(
              'Liste locale',
              style: TextStyle(color: _slate.withValues(alpha: 0.5), fontSize: 10),
            ),
          ],
        ]),
        const SizedBox(height: 8),
        if (_loading && _models.isEmpty)
          _buildSkeleton()
        else
          _buildDropdown(),
      ],
    );
  }

  Widget _buildSkeleton() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: _slate.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selected,
          isExpanded: true,
          itemHeight: null,
          dropdownColor: const Color(0xFF1E2D40),
          icon: Icon(Icons.expand_more_rounded, color: _slate.withValues(alpha: 0.7), size: 20),
          selectedItemBuilder: (context) =>
              _models.map((m) => _buildSelectedItem(m)).toList(),
          items: _models
              .map((m) => DropdownMenuItem<String>(
                    value: m.modelId,
                    child: _buildDropdownItem(m),
                  ))
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selected = val);
              widget.onChanged(val);
            }
          },
        ),
      ),
    );
  }

  Widget _buildSelectedItem(GeminiModelInfo m) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          _TierBadge(tier: m.tier, color: m.tierColor),
          const SizedBox(width: 8),
          Text(
            m.simpleName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(GeminiModelInfo m) {
    final isFirstA = m.tier == 'A' &&
        _models.indexWhere((x) => x.tier == 'A') ==
            _models.indexOf(m);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Row(
        children: [
          _TierBadge(tier: m.tier, color: m.tierColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  m.simpleName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  m.tierLabel,
                  style: TextStyle(
                    color: _slate.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isFirstA)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: m.tierColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: m.tierColor.withValues(alpha: 0.4)),
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
  }
}

// ── Badge tier ───────────────────────────────────────────────────────────────

class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier, required this.color});

  final String tier;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
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
            fontSize: 11,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
