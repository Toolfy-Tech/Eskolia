import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/eskolia_tokens.dart';

// ---------------------------------------------------------------------------
// NetworkCalculatorSheet
// ---------------------------------------------------------------------------

class NetworkCalculatorSheet extends StatefulWidget {
  const NetworkCalculatorSheet({super.key});

  @override
  State<NetworkCalculatorSheet> createState() => _NetworkCalculatorSheetState();
}

class _NetworkCalculatorSheetState extends State<NetworkCalculatorSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // --- Tab 1 : binaire state
  final _decController  = TextEditingController();
  final _binController  = TextEditingController();
  final _ipController   = TextEditingController();
  int   _decValue       = 0;
  int   _binValue       = 0;
  bool  _decValid       = true;
  bool  _binValid       = true;
  List<int> _ipOctets   = [];

  // --- Tab 2 : sous-reseau state
  final _subnetIpController = TextEditingController(text: '192.168.1.100');
  String _subnetIp    = '192.168.1.100';
  int    _subnetCidr  = 24;
  String _networkAddr  = '';
  String _broadcastAddr = '';
  String _firstIp      = '';
  String _lastIp       = '';
  int    _hostCount    = 0;
  String _maskBinary   = '';
  bool   _hasResult    = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _decController.dispose();
    _binController.dispose();
    _ipController.dispose();
    _subnetIpController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------------ ip calc

  int _ipToInt(String ip) {
    final parts = ip.split('.').map(int.parse).toList();
    return (parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3];
  }

  String _intToIp(int n) {
    return '${(n >> 24) & 0xFF}.${(n >> 16) & 0xFF}.${(n >> 8) & 0xFF}.${n & 0xFF}';
  }

  int _cidrToMask(int cidr) =>
      cidr == 0 ? 0 : (0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF;

  String _maskToBinary(int mask) {
    final b = mask.toRadixString(2).padLeft(32, '0');
    return '${b.substring(0, 8)}.${b.substring(8, 16)}.${b.substring(16, 24)}.${b.substring(24, 32)}';
  }

  void _calculate() {
    try {
      final ipInt   = _ipToInt(_subnetIp.trim());
      final maskInt = _cidrToMask(_subnetCidr);
      final network   = ipInt & maskInt;
      final broadcast = network | (~maskInt & 0xFFFFFFFF);
      setState(() {
        _networkAddr   = _intToIp(network);
        _broadcastAddr = _intToIp(broadcast);
        _firstIp       = _intToIp(network + 1);
        _lastIp        = _intToIp(broadcast - 1);
        _hostCount     = (1 << (32 - _subnetCidr)) - 2;
        _maskBinary    = _maskToBinary(maskInt);
        _hasResult     = true;
      });
    } catch (_) {
      // IP invalide - silencieux
    }
  }

  // ------------------------------------------------------------------ conversions tab1

  void _onDecChanged(String v) {
    final n = int.tryParse(v);
    if (n == null || n < 0 || n > 255) {
      setState(() => _decValid = false);
      return;
    }
    setState(() {
      _decValid = true;
      _decValue = n;
      _binValue = n;
      _binController.text = n.toRadixString(2).padLeft(8, '0');
    });
  }

  void _onBinChanged(String v) {
    if (v.length > 8 || !RegExp(r'^[01]*$').hasMatch(v)) {
      setState(() => _binValid = false);
      return;
    }
    if (v.isEmpty) {
      setState(() { _binValid = true; _binValue = 0; });
      return;
    }
    final n = int.parse(v, radix: 2);
    setState(() {
      _binValid = true;
      _binValue = n;
      _decValue = n;
      _decController.text = n.toString();
    });
  }

  void _onIpChanged(String v) {
    final parts = v.split('.');
    if (parts.length != 4) {
      setState(() => _ipOctets = []);
      return;
    }
    final octets = parts.map((p) => int.tryParse(p)).toList();
    if (octets.any((o) => o == null || o < 0 || o > 255)) {
      setState(() => _ipOctets = []);
      return;
    }
    setState(() => _ipOctets = octets.cast<int>());
  }

  // ------------------------------------------------------------------ styling helpers

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: const TextStyle(
            color: EskoliaTokens.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _resultRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  color: EskoliaTokens.cyan,
                  fontSize: 13,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      );

  Widget _styledTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
    bool monospace = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: TextStyle(
        color: Colors.white,
        fontFamily: monospace ? 'monospace' : null,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _slate.withValues(alpha: 0.55)),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: EskoliaTokens.cyan, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        isDense: true,
      ),
    );
  }

  // ------------------------------------------------------------------ bit row

  Widget _bitRow(int value) {
    final bits = value.toRadixString(2).padLeft(8, '0').split('');
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(8, (i) {
        final isOne = bits[i] == '1';
        return Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isOne ? _cyan : _card,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isOne ? _cyan : Colors.white.withValues(alpha: 0.10),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            bits[i],
            style: TextStyle(
              color: isOne ? _bg : _slate,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        );
      }),
    );
  }

  // ------------------------------------------------------------------ ip bit row (4 octets)

  Widget _ipBitRow(List<int> octets) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(4, (oi) {
          final octet = octets[oi];
          final bits  = octet.toRadixString(2).padLeft(8, '0').split('');
          final boxes = Row(
            children: List.generate(8, (bi) {
              final isOne = bits[bi] == '1';
              return Container(
                width: 26,
                height: 26,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: isOne ? _cyan : _card,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isOne ? _cyan : Colors.white.withValues(alpha: 0.10),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  bits[bi],
                  style: TextStyle(
                    color: isOne ? _bg : _slate,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              );
            }),
          );
          return Row(
            children: [
              boxes,
              if (oi < 3)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    '.',
                    style: const TextStyle(
                      color: EskoliaTokens.textSecondary,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  // ------------------------------------------------------------------ Tab 1

  Widget _buildBinaireTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        // --- Section A
        _sectionLabel('DECIMAL → BINAIRE'),
        _styledTextField(
          controller: _decController,
          hint: 'Entrez un octet (0-255)',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: _onDecChanged,
        ),
        if (!_decValid) ...[
          const SizedBox(height: 6),
          Text(
            'Valeur entre 0 et 255',
            style: TextStyle(color: EskoliaTokens.error, fontSize: 12),
          ),
        ],
        const SizedBox(height: 16),
        _bitRow(_decValue),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Dec : ',
              style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 13),
            ),
            Text(
              '$_decValue',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 24),
            Text(
              'Bin : ',
              style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 13),
            ),
            Text(
              _decValue.toRadixString(2).padLeft(8, '0'),
              style: const TextStyle(
                color: EskoliaTokens.cyan,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Divider(color: Colors.white.withValues(alpha: 0.08)),
        const SizedBox(height: 24),

        // --- Section B
        _sectionLabel('BINAIRE → DECIMAL'),
        _styledTextField(
          controller: _binController,
          hint: 'Ex : 11000000',
          keyboardType: TextInputType.text,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[01]')),
            LengthLimitingTextInputFormatter(8),
          ],
          onChanged: _onBinChanged,
          monospace: true,
        ),
        if (!_binValid) ...[
          const SizedBox(height: 6),
          Text(
            'Utilisez uniquement les chiffres 0 et 1 (8 max)',
            style: TextStyle(color: EskoliaTokens.error, fontSize: 12),
          ),
        ],
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Decimal : ', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 14)),
            Text(
              '$_binValue',
              style: const TextStyle(
                color: EskoliaTokens.cyan,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Divider(color: Colors.white.withValues(alpha: 0.08)),
        const SizedBox(height: 24),

        // --- Section C
        _sectionLabel('ADRESSE IP (4 OCTETS)'),
        _styledTextField(
          controller: _ipController,
          hint: '192.168.1.100',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            LengthLimitingTextInputFormatter(15),
          ],
          onChanged: _onIpChanged,
        ),
        const SizedBox(height: 16),
        if (_ipOctets.length == 4) ...[
          _ipBitRow(_ipOctets),
          const SizedBox(height: 12),
          Text(
            'Representation 32 bits',
            textAlign: TextAlign.center,
            style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 6),
          Text(
            List.generate(
              4,
              (i) => _ipOctets[i].toRadixString(2).padLeft(8, '0'),
            ).join('.'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: EskoliaTokens.cyan,
              fontSize: 13,
              fontFamily: 'monospace',
              fontWeight: FontWeight.w600,
            ),
          ),
        ] else
          Center(
            child: Text(
              'Entrez une IP valide (ex : 192.168.1.1)',
              style: TextStyle(color: _slate.withValues(alpha: 0.6), fontSize: 13),
            ),
          ),
      ],
    );
  }

  // ------------------------------------------------------------------ Tab 2

  Widget _buildSousReseauTab() {
    final maskInt  = _cidrToMask(_subnetCidr);
    final maskStr  = _intToIp(maskInt);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      children: [
        _sectionLabel('ADRESSE IP'),
        _styledTextField(
          controller: _subnetIpController,
          hint: '192.168.1.100',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            LengthLimitingTextInputFormatter(15),
          ],
          onChanged: (v) => setState(() => _subnetIp = v),
        ),
        const SizedBox(height: 24),
        _sectionLabel('MASQUE CIDR'),
        Row(
          children: [
            Text(
              '/$_subnetCidr',
              style: const TextStyle(
                color: EskoliaTokens.cyan,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _cyan,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.12),
                  thumbColor: _cyan,
                  overlayColor: _cyan.withValues(alpha: 0.15),
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                ),
                child: Slider(
                  value: _subnetCidr.toDouble(),
                  min: 8,
                  max: 30,
                  divisions: 22,
                  onChanged: (v) => setState(() {
                    _subnetCidr = v.round();
                    _hasResult  = false;
                  }),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Text('Masque : ', style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 13)),
            Text(
              maskStr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.calculate_rounded, size: 18),
            label: const Text(
              'Calculer',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: _cyan,
              foregroundColor: EskoliaTokens.bgBase,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _calculate,
          ),
        ),
        if (_hasResult) ...[
          const SizedBox(height: 24),
          Divider(color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 16),
          _sectionLabel('RESULTATS'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                _resultRow('Adresse reseau', _networkAddr),
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                _resultRow('Adresse broadcast', _broadcastAddr),
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                _resultRow('Premiere IP utilisable', _firstIp),
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                _resultRow('Derniere IP utilisable', _lastIp),
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                _resultRow('Nombre d\'hotes', '$_hostCount'),
                Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                _resultRow('Masque en binaire', _maskBinary),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenH * 0.85),
      decoration: const BoxDecoration(
        color: EskoliaTokens.bgBase,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          const Text(
            'Calculatrice Reseau',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // Tab bar - pill style
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  color: EskoliaTokens.cyan,
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: EskoliaTokens.bgBase,
                unselectedLabelColor: _slate,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                unselectedLabelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                tabs: const [
                  Tab(text: 'Decimal ↔ Binaire'),
                  Tab(text: 'Sous-reseau'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBinaireTab(),
                _buildSousReseauTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
