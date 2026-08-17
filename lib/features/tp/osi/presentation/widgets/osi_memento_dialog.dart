import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:eskolia/core/constants/eskolia_tokens.dart';
import 'package:eskolia/features/tp/osi/data/osi_layers_data.dart';
import 'package:eskolia/features/tp/osi/models/osi_layer_model.dart';
import 'package:eskolia/features/tp/osi/presentation/widgets/osi_layer_badge.dart';

class OsiMementoDialog extends StatefulWidget {
  const OsiMementoDialog({super.key, this.initialLayer});

  final int? initialLayer;

  static Future<void> show(BuildContext context, {int? initialLayer}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OsiMementoDialog(initialLayer: initialLayer),
    );
  }

  @override
  State<OsiMementoDialog> createState() => _OsiMementoDialogState();
}

class _OsiMementoDialogState extends State<OsiMementoDialog> {
  String _searchQuery = '';
  int? _selectedLayerFilter;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedLayerFilter = widget.initialLayer;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 800;

    final filteredLayers = OsiLayersData.layers.where((layer) {
      if (_selectedLayerFilter != null && layer.number != _selectedLayerFilter) {
        return false;
      }
      if (_searchQuery.isEmpty) return true;

      final q = _searchQuery.toLowerCase();
      final inName = layer.name.toLowerCase().contains(q) || layer.englishName.toLowerCase().contains(q);
      final inPdu = layer.pdu.toLowerCase().contains(q);
      final inRole = layer.role.toLowerCase().contains(q) || layer.concreteExplanation.toLowerCase().contains(q);
      final inAnalogy = layer.analogy.toLowerCase().contains(q);
      final inProtocols = layer.keyProtocols.any((p) => p.toLowerCase().contains(q));
      final inHardware = layer.keyHardware.any((h) => h.toLowerCase().contains(q));
      final inTools = layer.diagnosticTools.any((t) => t.toLowerCase().contains(q));
      final inBreakdowns = layer.typicalBreakdowns.any((b) => b.toLowerCase().contains(q));

      return inName || inPdu || inRole || inAnalogy || inProtocols || inHardware || inTools || inBreakdowns;
    }).toList();

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isDesktop ? 900 : double.infinity,
          maxHeight: height * 0.90,
        ),
        margin: isDesktop ? const EdgeInsets.all(24) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: EskoliaTokens.cyan.withValues(alpha: 0.35), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header with title and Close button
            _buildHeader(context),

            // Search Bar & Quick Filter Chips
            _buildSearchAndFilters(),

            // Content List
            Expanded(
              child: filteredLayers.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                      itemCount: filteredLayers.length,
                      itemBuilder: (context, index) {
                        return _buildLayerCard(filteredLayers[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: EskoliaTokens.cyan.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_book_rounded, color: EskoliaTokens.cyan, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mémento Complet du Modèle OSI',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Guide pratique, analogies concrètes, outils CLI et pannes réelles',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            tooltip: 'Fermer',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Column(
        children: [
          // Search TextField
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val),
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: InputDecoration(
              hintText: 'Rechercher un protocole (DNS, TCP...), un matériel (Switch, Câble...), une commande...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35), fontSize: 12.5),
              prefixIcon: const Icon(Icons.search_rounded, color: EskoliaTokens.cyan, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, color: Colors.white54, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: EskoliaTokens.cyan),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Layer Filters FilterChips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(label: 'Toutes (7 ➔ 1)', layerNum: null),
                for (int i = 7; i >= 1; i--)
                  _buildFilterChip(label: 'L$i ${OsiLayersData.getLayer(i).name}', layerNum: i),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required int? layerNum}) {
    final isSelected = _selectedLayerFilter == layerNum;
    final color = layerNum != null ? OsiLayersData.getLayer(layerNum).accentColor : EskoliaTokens.cyan;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedLayerFilter = isSelected ? null : layerNum),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 11.5,
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.05),
        selectedColor: color,
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: isSelected ? color : Colors.white.withValues(alpha: 0.1)),
        ),
      ),
    );
  }

  Widget _buildLayerCard(OsiLayerModel layer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: EskoliaTokens.surface1,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: layer.accentColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          tilePadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OsiLayerBadge(layerNumber: layer.number),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: layer.accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: layer.accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      layer.pdu,
                      style: TextStyle(
                        color: layer.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${layer.name} (${layer.englishName})',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              layer.role,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12.5,
                height: 1.35,
              ),
            ),
          ),
          children: [
            const Divider(color: Colors.white12, height: 20),

            // 1. Analogie concrète & vulgarisation
            _buildSection(
              icon: Icons.lightbulb_outline_rounded,
              iconColor: Colors.amberAccent,
              title: 'Analogie concrète (L\'image mentale)',
              content: Text(
                layer.analogy,
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 13,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 2. Explication technique détaillée
            _buildSection(
              icon: Icons.info_outline_rounded,
              iconColor: EskoliaTokens.cyan,
              title: 'Fonctionnement concret en entreprise',
              content: Text(
                layer.concreteExplanation,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // 3. Matériels & Équipements
            _buildSection(
              icon: Icons.router_rounded,
              iconColor: EskoliaTokens.violet,
              title: 'Équipements & Matériels associés',
              content: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: layer.keyHardware.map((h) => _buildPill(h, EskoliaTokens.violet)).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // 4. Protocoles clés & Ports
            _buildSection(
              icon: Icons.alt_route_rounded,
              iconColor: layer.accentColor,
              title: 'Protocoles standards & Ports',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: layer.keyProtocols.map((p) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ', style: TextStyle(color: layer.accentColor, fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            p,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // 5. Outils CLI & Commandes de diagnostic
            _buildSection(
              icon: Icons.terminal_rounded,
              iconColor: Colors.greenAccent,
              title: 'Outils & Commandes de diagnostic',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: layer.diagnosticTools.map((tool) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chevron_right_rounded, color: Colors.greenAccent, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            tool,
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 12,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // 6. Pannes typiques en entreprise
            _buildSection(
              icon: Icons.warning_amber_rounded,
              iconColor: EskoliaTokens.error,
              title: 'Pannes typiques en support IT',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: layer.typicalBreakdowns.map((b) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('⚠️ ', style: TextStyle(fontSize: 12)),
                        Expanded(
                          child: Text(
                            b,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 16),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        content,
      ],
    );
  }

  Widget _buildPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, color: Colors.white24, size: 48),
            const SizedBox(height: 12),
            Text(
              'Aucun résultat pour « $_searchQuery »',
              style: const TextStyle(color: Colors.white70, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              'Essaie de chercher un protocole comme HTTP, DNS, TCP, ou un matériel comme Switch, Routeur.',
              style: TextStyle(color: Colors.white38, fontSize: 12.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
