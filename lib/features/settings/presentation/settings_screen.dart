import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../admin/data/staff_capability.dart';
import '../../auth/data/user_model.dart';
import '../data/settings_repository.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _cyan = Color(0xFF00BCD4);
const Color _violet = Color(0xFF6C63FF);
const Color _slate = Color(0xFF64748B);
const Color _slateLight = Color(0xFF94A3B8);
const Color _danger = Color(0xFFE53935);
const Color _dangerDark = Color(0xFFB71C1C);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsRepository _repo = SettingsRepository();
  AppSettings? _settings;
  bool _loading = true;
  String? _loadError;
  Future<UserModel?>? _staffProfileFuture;
  String? _username;

  @override
  void initState() {
    super.initState();
    _load();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    _staffProfileFuture = uid.isEmpty
        ? Future<UserModel?>.value(null)
        : UserRepository().getUserById(uid);
    _staffProfileFuture?.then((u) {
      if (mounted) setState(() => _username = u?.username);
    });
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final s = await _repo.loadSettings();
      if (!mounted) return;
      setState(() {
        _settings = s;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _save(AppSettings s) async {
    setState(() => _settings = s);
    await _repo.saveSettings(s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: EskoliaAppBar.standard(
        context,
        title: 'Paramètres',
        showBack: false,
      ),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _loadError != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '\u{26A0}\u{FE0F}',
                                  style: TextStyle(fontSize: 40),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _loadError!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: _slateLight),
                                ),
                                const SizedBox(height: 20),
                                FilledButton(
                                  onPressed: _load,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _violet,
                                  ),
                                  child: const Text('Réessayer'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _loading || _settings == null
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: _violet,
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                              children: [
                                _sectionCard(
                                  title: 'Notifications',
                                  children: [
                                    SwitchListTile(
                                      title: const Text(
                                        'Notifications push',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      value: _settings!.notificationsEnabled,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: _violet,
                                      onChanged: (v) => _save(_settings!
                                          .copyWith(notificationsEnabled: v)),
                                    ),
                                    SwitchListTile(
                                      title: const Text(
                                        'Sons',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      value: _settings!.soundEnabled,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: _violet,
                                      onChanged: (v) => _save(
                                          _settings!.copyWith(soundEnabled: v)),
                                    ),
                                    SwitchListTile(
                                      title: const Text(
                                        'Vibrations',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      value: _settings!.vibrationEnabled,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: _violet,
                                      onChanged: (v) => _save(_settings!
                                          .copyWith(vibrationEnabled: v)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _sectionCard(
                                  title: 'Profil & Confidentialité',
                                  children: [
                                    SwitchListTile(
                                      title: const Text(
                                        'Profil public',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      value: _settings!.publicProfile,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: _violet,
                                      onChanged: (v) => _save(_settings!
                                          .copyWith(publicProfile: v)),
                                    ),
                                    SwitchListTile(
                                      title: const Text(
                                        'Afficher ma série',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      value: _settings!.showStreak,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: _violet,
                                      onChanged: (v) => _save(
                                          _settings!.copyWith(showStreak: v)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _sectionCard(
                                  title: 'Apprentissage',
                                  children: [
                                    ListTile(
                                      title: const Text(
                                        'Objectif quotidien',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        '${_settings!.dailyGoalMinutes} min/jour',
                                        style: TextStyle(color: _slateLight),
                                      ),
                                      onTap: () => _showGoalDialog(),
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Langue',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        _settings!.language == 'en'
                                            ? '\u{1F1EC}\u{1F1E7} English'
                                            : '\u{1F1EB}\u{1F1F7} Français',
                                        style: TextStyle(color: _slateLight),
                                      ),
                                      onTap: () => _showLangDialog(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _sectionCard(
                                  title: 'Compte',
                                  children: [
                                    FutureBuilder<UserModel?>(
                                      future: _staffProfileFuture,
                                      builder: (context, snap) {
                                        final staff = userHasStaffAccess(
                                          snap.data,
                                          FirebaseAuth.instance.currentUser?.email,
                                        );
                                        if (!staff) {
                                          return const SizedBox.shrink();
                                        }
                                        return ListTile(
                                          leading: const Text(
                                            '\u{1F6E1}\u{FE0F}',
                                            style: TextStyle(fontSize: 22),
                                          ),
                                          title: const Text(
                                            'Espace modération',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                          subtitle: Text(
                                            'Signalements & brouillons',
                                            style: TextStyle(color: _slateLight),
                                          ),
                                          trailing: const Icon(Icons.chevron_right,
                                              color: _slate),
                                          onTap: () => context.push('/admin'),
                                        );
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Modifier le profil',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      trailing: const Icon(Icons.chevron_right,
                                          color: _slate),
                                      onTap: () => context.push('/profil'),
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Exporter mes données',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        showEskoliaSnackBar(
                                          context,
                                          'Fonctionnalité à venir',
                                        );
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Se déconnecter',
                                        style: TextStyle(color: _danger),
                                      ),
                                      onTap: () async {
                                        await FirebaseAuth.instance.signOut();
                                        if (context.mounted) {
                                          context.go('/login');
                                        }
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Supprimer le compte',
                                        style: TextStyle(color: _dangerDark),
                                      ),
                                      onTap: () async {
                                        final ok = await _showDeleteConfirmDialog();
                                        if (ok == true && context.mounted) {
                                          showEskoliaSnackBar(
                                            context,
                                            'Fonctionnalité à venir',
                                          );
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _sectionCard(
                                  title: 'À propos',
                                  children: [
                                    ListTile(
                                      title: const Text(
                                        'Version',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      subtitle: Text(
                                        '1.0.0 (build 1)',
                                        style: TextStyle(color: _slateLight),
                                      ),
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Conditions d\'utilisation',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        showEskoliaSnackBar(context, 'À venir');
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Politique de confidentialité',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        showEskoliaSnackBar(context, 'À venir');
                                      },
                                    ),
                                    ListTile(
                                      title: const Text(
                                        'Nous contacter',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onTap: () {
                                        showEskoliaSnackBar(
                                          context,
                                          'contact@eskolia.fr',
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Future<bool?> _showDeleteConfirmDialog() async {
    final ctrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          backgroundColor: const Color(0xFF151B2E),
          title: const Text(
            'Supprimer le compte ?',
            style: TextStyle(color: Colors.white),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cette action est irréversible. Saisis ton pseudo pour confirmer.',
                style: TextStyle(color: _slateLight, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _username ?? 'Ton pseudo',
                  hintStyle: TextStyle(color: _slate),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.07),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _dangerDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _danger),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                  ),
                ),
                onChanged: (_) => setD(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: _username != null && ctrl.text == _username
                  ? () => Navigator.pop(ctx, true)
                  : null,
              style: FilledButton.styleFrom(backgroundColor: _dangerDark),
              child: const Text('Supprimer'),
            ),
          ],
        ),
      ),
    );
    ctrl.dispose();
    return result;
  }

  Future<void> _showGoalDialog() async {
    var g = _settings!.dailyGoalMinutes;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setD) {
            return AlertDialog(
              backgroundColor: const Color(0xFF151B2E),
              title: const Text(
                'Objectif quotidien',
                style: TextStyle(color: Colors.white),
              ),
              content: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [15, 30, 45, 60].map((m) {
                  return ChoiceChip(
                    label: Text('$m min'),
                    selected: g == m,
                    onSelected: (_) => setD(() => g = m),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    _save(_settings!.copyWith(dailyGoalMinutes: g));
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(backgroundColor: _violet),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showLangDialog() async {
    var lang = _settings!.language;
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setD) {
            return AlertDialog(
              backgroundColor: const Color(0xFF151B2E),
              title: const Text(
                'Langue',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text(
                      '\u{1F1EB}\u{1F1F7} Français',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: lang == 'fr'
                        ? const Icon(Icons.check, color: _cyan)
                        : null,
                    onTap: () => setD(() => lang = 'fr'),
                  ),
                  ListTile(
                    title: const Text(
                      '\u{1F1EC}\u{1F1E7} English',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: lang == 'en'
                        ? const Icon(Icons.check, color: _cyan)
                        : null,
                    onTap: () => setD(() => lang = 'en'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () {
                    _save(_settings!.copyWith(language: lang));
                    Navigator.pop(ctx);
                  },
                  style: FilledButton.styleFrom(backgroundColor: _violet),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
