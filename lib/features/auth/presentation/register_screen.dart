import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/eskolia_card.dart';
import '../data/auth_repository.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _blue = EskoliaTokens.info;
const Color _violet = EskoliaTokens.violet;
const Color _slate = EskoliaTokens.textSecondary;
const Color _fieldBg = EskoliaTokens.surface2;
const Color _fieldBorder = EskoliaTokens.textDisabled;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _authRepo = AuthRepository();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _authRepo.signUpWithEmail(
        _emailController.text,
        _passwordController.text,
        _usernameController.text,
        interestSections: const [],
      );
      if (!mounted) return;
      context.go('/formation-choix');
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) setState(() => _errorMessage = 'Erreur : $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final neon = Theme.of(context).extension<NeonTheme>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      // opaque capte trop de gestes et peut bloquer le swipe du carrousel.
      behavior: HitTestBehavior.deferToChild,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            const EskoliaAmbientBackground(),
            EskoliaShellBody(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: EskoliaLayout.screenPaddingH,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.sizeOf(context).height -
                        MediaQuery.paddingOf(context).vertical,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 56),
                      _LogoBlock(neon: neon),
                      const SizedBox(height: 40),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: EskoliaCardContent(
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Créer un compte',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 24,
                                        ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _fieldDecoration(
                                      context,
                                      label: 'Email',
                                      prefixIcon: Icons.mail_outline,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Champ requis';
                                      }
                                      if (!v.contains('@')) {
                                        return 'Email invalide';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _usernameController,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _fieldDecoration(
                                      context,
                                      label: 'Pseudo',
                                      hint: 'ex: TechPro_42',
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Champ requis';
                                      }
                                      final t = v.trim();
                                      if (t.contains('/') || t.contains('\\')) {
                                        return 'Le pseudo ne peut pas contenir / ou \\';
                                      }
                                      if (t.length < 3) {
                                        return 'Au moins 3 caractères';
                                      }
                                      if (t.length > 20) {
                                        return '20 caractères maximum';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _fieldDecoration(
                                      context,
                                      label: 'Mot de passe',
                                      prefixIcon: Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _slate,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscurePassword =
                                              !_obscurePassword,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Champ requis';
                                      }
                                      if (v.length < 6) {
                                        return 'Au moins 6 caractères';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _confirmController,
                                    obscureText: _obscureConfirm,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _fieldDecoration(
                                      context,
                                      label: 'Confirmer mot de passe',
                                      prefixIcon: Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirm
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _slate,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureConfirm =
                                              !_obscureConfirm,
                                        ),
                                      ),
                                    ),
                                    validator: (v) {
                                      if (v == null || v.isEmpty) {
                                        return 'Champ requis';
                                      }
                                      if (v != _passwordController.text) {
                                        return 'Les mots de passe ne correspondent pas';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  if (_errorMessage != null) ...[
                                    const SizedBox(height: 12),
                                    _ErrorBanner(message: _errorMessage!),
                                  ],
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        EskoliaButton(
                                          label: _isLoading
                                              ? ' '
                                              : 'Créer mon compte',
                                          variant: EskoliaButtonVariant.primary,
                                          expand: true,
                                          onPressed: _isLoading
                                              ? null
                                              : _handleRegister,
                                        ),
                                        if (_isLoading)
                                          const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Center(
                                    child: GestureDetector(
                                      onTap: () => context.go('/login'),
                                      child: Text.rich(
                                        TextSpan(
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: _slate,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'Déjà un compte ? ',
                                            ),
                                            const TextSpan(
                                              text: 'Se connecter',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: _blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    BuildContext context, {
    required String label,
    required IconData prefixIcon,
    String? hint,
  }) {
    final glass = Theme.of(context).extension<GlassmorphismTheme>();
    final focusColor = glass?.borderColor ?? _blue;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _fieldBorder),
    );
    return InputDecoration(
      filled: true,
      fillColor: _fieldBg,
      labelText: label,
      hintText: hint,
      hintStyle: TextStyle(color: _slate.withValues(alpha: 0.65)),
      labelStyle: const TextStyle(color: _slate),
      prefixIcon: Icon(prefixIcon, color: _slate),
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: focusColor, width: 1.5),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: EskoliaTokens.error),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: EskoliaTokens.error, width: 1.5),
      ),
    );
  }
}

class _LogoBlock extends StatelessWidget {
  const _LogoBlock({this.neon});

  final NeonTheme? neon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: neon != null
              ? BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: neon!.neonColor.withValues(
                        alpha: 0.2 * neon!.intensity.clamp(0.0, 1.5),
                      ),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                  ],
                )
              : null,
          child: ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => const LinearGradient(
              colors: [_blue, _violet],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: const Text(
              'ESKOLIA',
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Deviens expert en réseaux',
          style: TextStyle(
            fontSize: 16,
            color: _slate.withValues(alpha: 0.95),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EskoliaTokens.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EskoliaTokens.error),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: EskoliaTokens.error.withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: EskoliaTokens.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
