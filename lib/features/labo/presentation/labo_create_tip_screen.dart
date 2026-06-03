import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../economy/data/achievement_rewards.dart';
import '../data/community_tip_repository.dart';
import '../data/labo_tip_kind.dart';
import '../../../core/constants/eskolia_tokens.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _violet = EskoliaTokens.violetSoft;
const Color _slate = EskoliaTokens.textSecondary;
const Color _pink = EskoliaTokens.pink;

class LaboCreateTipScreen extends StatefulWidget {
  const LaboCreateTipScreen({super.key, this.initialModuleId = ''});

  final String initialModuleId;

  @override
  State<LaboCreateTipScreen> createState() => _LaboCreateTipScreenState();
}

class _LaboCreateTipScreenState extends State<LaboCreateTipScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _moduleId;
  final _moduleTitle = TextEditingController();
  final _body = TextEditingController();
  LaboTipKind _kind = LaboTipKind.astuce;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _moduleId = TextEditingController(text: widget.initialModuleId.trim());
  }

  @override
  void dispose() {
    _moduleId.dispose();
    _moduleTitle.dispose();
    _body.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecte-toi pour proposer un tip.')),
      );
      return;
    }
    setState(() => _sending = true);
    try {
      await CommunityTipRepository().submitTip(
        moduleId: _moduleId.text.trim(),
        moduleTitle: _moduleTitle.text.trim(),
        kind: _kind,
        body: _body.text.trim(),
      );
      await AchievementRewards().unlock(uid, 'labo_first_tip');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Merci ! Ton astuce sera visible après validation.'),
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: EskoliaAppBar.standard(context, title: 'Proposer un tip'),
      body: Stack(
        children: [
          const EskoliaAmbientBackground(),
          EskoliaShellBody(
            safeAreaTop: false,
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  EskoliaLayout.screenPaddingH,
                  12,
                  EskoliaLayout.screenPaddingH,
                  EskoliaLayout.screenPaddingBottom,
                ),
                children: [
                  Text(
                    'Lie ton astuce au module de cours concerné (même identifiant '
                    'que dans l’URL du parcours, ex. après /cours/).',
                    style: TextStyle(
                      color: _slate.withValues(alpha: 0.95),
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _moduleId,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec('ID du module *'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _moduleTitle,
                    style: const TextStyle(color: Colors.white),
                    decoration: _dec('Titre du cours (optionnel, pour les modérateurs)'),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Type',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: LaboTipKind.values.map((k) {
                      final sel = _kind == k;
                      return ChoiceChip(
                        label: Text(
                          k.label,
                          style: TextStyle(
                            fontSize: 11,
                            color: sel ? Colors.white : Colors.white70,
                          ),
                        ),
                        selected: sel,
                        onSelected: (_) => setState(() => _kind = k),
                        selectedColor: _pink.withValues(alpha: 0.85),
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        side: BorderSide(
                          color: sel ? _pink : Colors.white24,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _body,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 6,
                    decoration: _dec('Ton astuce *'),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Requis' : null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _sending ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: _violet,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    child: _sending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Envoyer en validation'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: _slate.withValues(alpha: 0.85)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _violet),
      ),
    );
  }
}
