import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/services/eskolia_folder_service.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../core/theme/sidebar_button_colors_provider.dart';
import '../../../core/theme/theme_palette_provider.dart';
import '../../../core/theme/text_scale_provider.dart';
import '../../../core/utils/eskolia_snackbar.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../admin/data/staff_capability.dart';
import '../../auth/data/user_model.dart';
import '../data/settings_repository.dart';


class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
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
      extendBodyBehindAppBar: false,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            showBack: false,
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
                                  style: const TextStyle(color: EskoliaTokens.textSecondary),
                                ),
                                const SizedBox(height: 20),
                                FilledButton(
                                  onPressed: _load,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: EskoliaTokens.violetSoft,
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
                                color: EskoliaTokens.violetSoft,
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 24, top: 8),
                                    child: Text(
                                      'Paramètres',
                                      style: GoogleFonts.outfit(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),                                 FutureBuilder<UserModel?>(
                                  future: _staffProfileFuture,
                                  builder: (context, snap) {
                                    final user = snap.data;
                                    final name = _username ?? user?.username ?? 'Utilisateur';
                                    final level = user?.level ?? 1;
                                    final xp = user?.xp ?? 0;
                                    
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 20),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              EskoliaTokens.violetSoft.withValues(alpha: 0.15),
                                              EskoliaTokens.cyan.withValues(alpha: 0.05),
                                            ],
                                          ),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.08),
                                            width: 1.0,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 28,
                                              backgroundColor: EskoliaTokens.cyan.withValues(alpha: 0.2),
                                              child: Text(
                                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                                style: GoogleFonts.outfit(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 22,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    name,
                                                    style: GoogleFonts.outfit(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Niveau $level · $xp XP',
                                                    style: GoogleFonts.plusJakartaSans(
                                                      color: EskoliaTokens.textSecondary,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.edit_rounded, color: Colors.white70),
                                              onPressed: () => context.push('/profil'),
                                              tooltip: 'Modifier le profil',
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                _sectionCard(
                                  title: 'Notifications',
                                  children: [
                                    SwitchListTile(
                                      title: Text(
                                        'Notifications push',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      value: _settings!.notificationsEnabled,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: EskoliaTokens.cyan,
                                      onChanged: (v) => _save(_settings!
                                          .copyWith(notificationsEnabled: v)),
                                    ),
                                    SwitchListTile(
                                      title: Text(
                                        'Sons',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      value: _settings!.soundEnabled,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: EskoliaTokens.cyan,
                                      onChanged: (v) => _save(
                                          _settings!.copyWith(soundEnabled: v)),
                                    ),
                                    SwitchListTile(
                                      title: Text(
                                        'Vibrations',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      value: _settings!.vibrationEnabled,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: EskoliaTokens.cyan,
                                      onChanged: (v) => _save(_settings!
                                          .copyWith(vibrationEnabled: v)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _sectionCard(
                                  title: 'Affichage & Thème',
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(Icons.palette_outlined, size: 18, color: ref.watch(themePaletteProvider).primaryAccent),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Ambiance & Thème visuel',
                                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                              ),
                                              const Spacer(),
                                              Text(
                                                ref.watch(themePaletteProvider).label,
                                                style: TextStyle(
                                                  color: ref.watch(themePaletteProvider).primaryAccent,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: EskoliaThemeId.values.map((theme) {
                                              final isSelected = ref.watch(themePaletteProvider).themeId == theme;
                                              return Tooltip(
                                                message: theme.label,
                                                child: InkWell(
                                                  onTap: () => ref.read(themePaletteProvider.notifier).setTheme(theme),
                                                  borderRadius: BorderRadius.circular(20),
                                                  child: AnimatedContainer(
                                                    duration: const Duration(milliseconds: 200),
                                                    width: 32,
                                                    height: 32,
                                                    decoration: BoxDecoration(
                                                      color: theme.accentColor,
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: isSelected ? Colors.white : Colors.transparent,
                                                        width: 2.5,
                                                      ),
                                                      boxShadow: isSelected
                                                          ? [
                                                              BoxShadow(
                                                                color: theme.accentColor.withValues(alpha: 0.6),
                                                                blurRadius: 10,
                                                                spreadRadius: 1,
                                                              ),
                                                            ]
                                                          : [],
                                                    ),
                                                    child: isSelected
                                                        ? const Center(
                                                            child: Icon(Icons.check, size: 16, color: Colors.black),
                                                          )
                                                        : null,
                                                  ),
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(color: Colors.white10, height: 1),
                                    ListTile(
                                      leading: const Icon(Icons.color_lens_rounded, color: EskoliaTokens.violetSoft),
                                      title: Text(
                                        'Couleurs des boutons de la barre latérale',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      subtitle: Text(
                                        'Personnaliser les couleurs du menu et de la barre latérale',
                                        style: GoogleFonts.plusJakartaSans(color: EskoliaTokens.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white60),
                                      onTap: () => showSidebarButtonColorsDialog(context, ref),
                                    ),
                                    const Divider(color: Colors.white10, height: 1),
                                    ListTile(
                                      leading: const Icon(Icons.zoom_in_rounded, color: EskoliaTokens.cyan),
                                      title: Text(
                                        'Taille du texte et Zoom',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      subtitle: Text(
                                        'Échelle actuelle : ${(ref.watch(textScaleProvider) * 100).round()}%',
                                        style: GoogleFonts.plusJakartaSans(color: EskoliaTokens.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                      trailing: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: EskoliaTokens.cyan.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${(ref.watch(textScaleProvider) * 100).round()}%',
                                          style: const TextStyle(color: EskoliaTokens.cyan, fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ),
                                      onTap: () => showTextScaleDialog(context, ref),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _sectionCard(
                                  title: 'Profil & Confidentialité',
                                  children: [
                                    SwitchListTile(
                                      title: Text(
                                        'Profil public',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      value: _settings!.publicProfile,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: EskoliaTokens.cyan,
                                      onChanged: (v) => _save(_settings!
                                          .copyWith(publicProfile: v)),
                                    ),
                                    SwitchListTile(
                                      title: Text(
                                        'Afficher ma série',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      value: _settings!.showStreak,
                                      activeThumbColor: Colors.white,
                                      activeTrackColor: EskoliaTokens.cyan,
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
                                      title: Text(
                                        'Objectif quotidien',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      subtitle: Text(
                                        '${_settings!.dailyGoalMinutes} min/jour',
                                        style: GoogleFonts.plusJakartaSans(color: EskoliaTokens.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                      onTap: () => _showGoalDialog(),
                                    ),
                                    ListTile(
                                      title: Text(
                                        'Langue',
                                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      subtitle: Text(
                                        _settings!.language == 'en'
                                            ? '\u{1F1EC}\u{1F1E7} English'
                                            : '\u{1F1EB}\u{1F1F7} Français',
                                        style: GoogleFonts.plusJakartaSans(color: EskoliaTokens.textSecondary, fontSize: 11, fontWeight: FontWeight.w500),
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
                                            style: TextStyle(color: EskoliaTokens.textSecondary),
                                          ),
                                          trailing: const Icon(Icons.chevron_right,
                                              color: EskoliaTokens.textSecondary),
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
                                          color: EskoliaTokens.textSecondary),
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
                                        style: TextStyle(color: EskoliaTokens.error),
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
                                        style: TextStyle(color: EskoliaTokens.error),
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
                                const _EskoliaFolderCard(),
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
                                        style: TextStyle(color: EskoliaTokens.textSecondary),
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
          backgroundColor: EskoliaTokens.surface1,
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
                style: TextStyle(color: EskoliaTokens.textSecondary, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: _username ?? 'Ton pseudo',
                  hintStyle: TextStyle(color: EskoliaTokens.textSecondary),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.07),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: EskoliaTokens.error),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: EskoliaTokens.error),
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
              style: FilledButton.styleFrom(backgroundColor: EskoliaTokens.error),
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
              backgroundColor: EskoliaTokens.surface1,
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
                  style: FilledButton.styleFrom(backgroundColor: EskoliaTokens.violetSoft),
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
              backgroundColor: EskoliaTokens.surface1,
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
                        ? const Icon(Icons.check, color: EskoliaTokens.cyan)
                        : null,
                    onTap: () => setD(() => lang = 'fr'),
                  ),
                  ListTile(
                    title: const Text(
                      '\u{1F1EC}\u{1F1E7} English',
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: lang == 'en'
                        ? const Icon(Icons.check, color: EskoliaTokens.cyan)
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
                  style: FilledButton.styleFrom(backgroundColor: EskoliaTokens.violetSoft),
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

// ── Dossier Eskolia ────────────────────────────────────────────────────────────

class _EskoliaFolderCard extends StatefulWidget {
  const _EskoliaFolderCard();

  @override
  State<_EskoliaFolderCard> createState() => _EskoliaFolderCardState();
}

class _EskoliaFolderCardState extends State<_EskoliaFolderCard> {
  final _fs = EskoliaFolderService.instance;

  bool _loading = true;
  String? _folderName;

  static const _teal = EskoliaTokens.cyan;
  static const _amber = EskoliaTokens.amber;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final name = await _fs.getFolderName();
    if (mounted) setState(() { _folderName = name; _loading = false; });
  }

  Future<void> _pick() async {
    setState(() => _loading = true);
    final ok = await _fs.pickFolder();
    if (!mounted) return;
    if (ok) {
      await _loadState();
      showEskoliaSnackBar(context, 'Dossier Eskolia configure.');
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _forget() async {
    await _fs.forgetFolder();
    if (mounted) setState(() => _folderName = null);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Mes fichiers',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          if (!_fs.isSupported)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _amber.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _amber.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: _amber, size: 16),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Ton navigateur ne supporte pas la sélection de dossier local. Les fichiers seront sauvegardés dans l\'application ou dans ton dossier Téléchargements. Utilise Chrome ou Edge pour une expérience optimale.',
                        style: GoogleFonts.plusJakartaSans(
                          color: _amber.withValues(alpha: 0.9),
                          fontSize: 11,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (_loading)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: _teal)),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: Text(
                'Configure un dossier local Eskolia sur ton ordinateur pour y synchroniser tes cours, quiz et flashcards physiques.',
                style: GoogleFonts.plusJakartaSans(
                  color: EskoliaTokens.textSecondary.withValues(alpha: 0.8),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            if (_folderName != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _teal.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _teal.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.folder_open_rounded, color: _teal, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _folderName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              'Dossier actif configuré',
                              style: GoogleFonts.plusJakartaSans(color: EskoliaTokens.textSecondary, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: _forget,
                        style: TextButton.styleFrom(
                          foregroundColor: EskoliaTokens.error,
                          textStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Oublier'),
                      ),
                    ],
                  ),
                ),
              ),
            ListTile(
              leading: Icon(
                _folderName != null
                    ? Icons.drive_folder_upload_rounded
                    : Icons.create_new_folder_rounded,
                color: _teal,
              ),
              title: Text(
                _folderName != null ? 'Modifier le dossier' : 'Choisir mon dossier Eskolia',
                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: EskoliaTokens.textSecondary, size: 14),
              onTap: _pick,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: EskoliaFolder.values.map((f) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _teal.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _teal.withValues(alpha: 0.15)),
                  ),
                  child: Text(
                    f.folderName,
                    style: GoogleFonts.plusJakartaSans(color: _teal, fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                )).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
