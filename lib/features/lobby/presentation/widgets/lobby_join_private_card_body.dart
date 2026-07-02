import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/eskolia_tokens.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../data/lobby_repository.dart';

class LobbyJoinPrivateCardBody extends ConsumerStatefulWidget {
  const LobbyJoinPrivateCardBody({super.key, this.isExpandedOverride});
  final bool? isExpandedOverride;

  @override
  ConsumerState<LobbyJoinPrivateCardBody> createState() => _LobbyJoinPrivateCardBodyState();
}

class _LobbyJoinPrivateCardBodyState extends ConsumerState<LobbyJoinPrivateCardBody> {
  late final TextEditingController _codeController;
  bool _loading = false;
  final LobbyRepository _repo = LobbyRepository();

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _joinLobby() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir un code'),
          backgroundColor: EskoliaTokens.error,
        ),
      );
      return;
    }

    if (code.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le code doit contenir au moins 4 caractères'),
          backgroundColor: EskoliaTokens.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final foundId = await _repo.findLobbyIdByJoinCode(code);
      if (!mounted) return;

      if (foundId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code introuvable ou salon fermé.'),
            backgroundColor: EskoliaTokens.error,
          ),
        );
        return;
      }

      _codeController.clear();
      context.push('/lobby/$foundId');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la recherche : $e'),
            backgroundColor: EskoliaTokens.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsMap = ref.watch(homeCardSettingsProvider);
    final isCollapsed = widget.isExpandedOverride != null
        ? !widget.isExpandedOverride!
        : (settingsMap['feature:lobbys_join_private']?.isCollapsed ?? false);

    const cyanColor = EskoliaTokens.cyan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Saisis le code d\'accès pour rejoindre la partie :',
          style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 11),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                maxLength: 8,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'EX: A2K9P',
                  hintStyle: TextStyle(
                    color: EskoliaTokens.textSecondary.withValues(alpha: 0.35),
                    fontSize: 14,
                    letterSpacing: 2,
                  ),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.03),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: cyanColor),
                  ),
                ),
                onSubmitted: (_) => _joinLobby(),
              ),
            ),
            if (!isCollapsed) ...[
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _joinLobby,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cyanColor,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.arrow_forward_rounded, size: 20),
                ),
              ),
            ],
          ],
        ),
        if (isCollapsed) ...[
          const SizedBox(height: 10),
          ElevatedButton.icon(
            onPressed: _loading ? null : _joinLobby,
            style: ElevatedButton.styleFrom(
              backgroundColor: cyanColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
            icon: _loading
                ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Icon(Icons.vpn_key_rounded, size: 16),
            label: const Text('Rejoindre le salon', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ],
    );
  }
}
