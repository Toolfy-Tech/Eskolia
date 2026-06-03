import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import '../data/practical_catalog_repository.dart';
import '../data/practical_missions_progress_repository.dart';
import '../data/practical_track_models.dart';

const Color _slate = EskoliaTokens.textSecondary;

/// Parcours missions sur VM : texte + étapes, validation manuelle, mission suivante.
class PracticalMissionsScreen extends StatefulWidget {
  const PracticalMissionsScreen({super.key, required this.trackId});

  final String trackId;

  @override
  State<PracticalMissionsScreen> createState() => _PracticalMissionsScreenState();
}

class _PracticalMissionsScreenState extends State<PracticalMissionsScreen> {
  final _progress = PracticalMissionsProgressRepository();

  PracticalTrackManifest? _manifest;
  PracticalMissionsPack? _pack;
  int _nextIndex = 0;
  Object? _error;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final manifest =
          await PracticalCatalogRepository.loadTrackManifest(widget.trackId);
      final asset = manifest.missionsAsset;
      if (asset == null || asset.isEmpty) {
        if (mounted) {
          setState(() {
            _manifest = manifest;
            _pack = null;
            _error = StateError('Pas de parcours missions pour ce thème.');
            _loading = false;
          });
        }
        return;
      }
      final pack = await PracticalCatalogRepository.loadMissionsPack(asset);
      final next = await _progress.readNextMissionIndex(widget.trackId);
      if (!mounted) return;
      setState(() {
        _manifest = manifest;
        _pack = pack;
        _nextIndex = next.clamp(0, pack.missions.length);
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  Future<void> _validateMission() async {
    final pack = _pack;
    if (pack == null || _saving) return;
    if (_nextIndex >= pack.missions.length) return;
    setState(() => _saving = true);
    await _progress.setNextMissionIndex(widget.trackId, _nextIndex + 1);
    if (!mounted) return;
    setState(() {
      _nextIndex = (_nextIndex + 1).clamp(0, pack.missions.length);
      _saving = false;
    });
  }

  Future<void> _confirmReset() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: EskoliaTokens.surface1,
        title: const Text(
          'Réinitialiser ?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'La progression des missions pour ce thème repart à zéro.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await _progress.clearTrack(widget.trackId);
    if (!mounted) return;
    setState(() => _nextIndex = 0);
  }

  @override
  Widget build(BuildContext context) {
    final hPad = EskoliaLayout.lessonHorizontalPadding(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EskoliaAppBar.standard(
                  context,
                  title: _pack?.title ?? 'Missions',
                  actions: [
                    if (_pack != null && _pack!.missions.isNotEmpty)
                      IconButton(
                        tooltip: 'Réinitialiser la progression',
                        icon: const Icon(Icons.restart_alt_rounded),
                        onPressed: _saving ? null : _confirmReset,
                      ),
                  ],
                ),
                Expanded(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: EskoliaVisual.neonCyan,
                          ),
                        )
                      : _error != null
                          ? _error is UnimplementedError
                              ? _buildComingSoon(context, hPad)
                              : Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(hPad),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '$_error',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.red.shade200,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        EskoliaButton(
                                          label: 'Retour',
                                          variant: EskoliaButtonVariant.secondary,
                                          onPressed: () => context.pop(),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                          : _buildContent(context, hPad),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoon(BuildContext context, double hPad) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(hPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: EskoliaVisual.neonCyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: EskoliaVisual.neonCyan.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.construction_rounded,
                color: EskoliaVisual.neonCyan,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Contenu en cours de preparation',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Ce parcours missions sera disponible prochainement.',
              style: TextStyle(
                color: _slate.withValues(alpha: 0.85),
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            EskoliaButton(
              label: 'Retour aux TP',
              variant: EskoliaButtonVariant.secondary,
              icon: Icons.arrow_back_rounded,
              onPressed: () => context.go('/tp'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, double hPad) {
    final pack = _pack!;
    final manifest = _manifest;
    final total = pack.missions.length;
    final done = _nextIndex >= total;

    return ListView(
      padding: EdgeInsets.fromLTRB(
        hPad,
        8,
        hPad,
        kEskoliaBottomNavReserve,
      ),
      children: [
        if (manifest != null)
          Text(
            manifest.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        if (manifest != null) const SizedBox(height: 4),
        Text(
          pack.subtitle,
          style: TextStyle(
            color: _slate.withValues(alpha: 0.92),
            fontSize: 13,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        if (total > 0)
          Text(
            done
                ? 'Parcours terminé'
                : 'Mission ${_nextIndex + 1} / $total',
            style: TextStyle(
              color: EskoliaVisual.neonCyan.withValues(alpha: 0.95),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        if (total > 0 && !done) const SizedBox(height: 12),
        if (total == 0)
          Text(
            'Aucune mission dans ce fichier.',
            style: TextStyle(color: _slate.withValues(alpha: 0.9)),
          )
        else if (done)
          GradientBorderCard(
            gradientColors: const [
              EskoliaTokens.success,
              EskoliaTokens.violetSoft,
            ],
            glowColor: EskoliaTokens.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Bravo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu as parcouru toutes les missions sur ta VM. '
                  'Tu peux enchaîner avec les QCM ou les TP du thème, ou recommencer le parcours depuis le menu.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                EskoliaButton(
                  label: 'Recommencer les missions',
                  variant: EskoliaButtonVariant.secondary,
                  expand: true,
                  onPressed: _saving ? null : _confirmReset,
                ),
              ],
            ),
          )
        else
          _MissionCard(
            mission: pack.missions[_nextIndex],
            onValidate: _saving ? null : _validateMission,
            busy: _saving,
          ),
      ],
    );
  }
}

class _MissionCard extends StatelessWidget {
  const _MissionCard({
    required this.mission,
    required this.onValidate,
    required this.busy,
  });

  final PracticalMission mission;
  final VoidCallback? onValidate;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GradientBorderCard(
      gradientColors: EskoliaVisual.borderPrimary,
      glowColor: EskoliaVisual.neonViolet,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            mission.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (mission.intro.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              mission.intro,
              style: TextStyle(
                color: _slate.withValues(alpha: 0.95),
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ],
          if (mission.steps.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'À faire sur ta VM',
              style: TextStyle(
                color: EskoliaVisual.neonCyan,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < mission.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${i + 1}. ',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        mission.steps[i],
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 20),
          EskoliaButton(
            label: busy ? 'Enregistrement…' : 'J’ai terminé cette mission sur ma VM',
            variant: EskoliaButtonVariant.primary,
            expand: true,
            icon: Icons.check_circle_outline_rounded,
            onPressed: onValidate,
          ),
        ],
      ),
    );
  }
}
