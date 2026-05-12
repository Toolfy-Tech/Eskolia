import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import '../data/auth_repository.dart';

const Color _bg = EskoliaVisual.bgDeep;
const Color _blue = Color(0xFF3B82F6);
const Color _violet = Color(0xFF7C3AED);
const Color _slate = Color(0xFF64748B);
const Color _fieldBg = Color(0xFF1E293B);
const Color _fieldBorder = Color(0xFF334155);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _pseudoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AuthRepository get _authRepo =>
      widget.authRepository ?? AuthRepository();

  bool _isLoading = false;
  bool _obscureText = true;
  String? _errorMessage;
  bool _rememberMe = true;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((p) {
      if (!mounted) return;
      setState(() => _rememberMe = p.getBool('auth_remember_me') ?? true);
    });
  }

  @override
  void dispose() {
    _pseudoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _authRepo.applyRememberMeForWeb(_rememberMe);
      await _authRepo.signInWithPseudoOrEmail(
        _pseudoController.text,
        _passwordController.text,
      );
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'Erreur : $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final neon = Theme.of(context).extension<NeonTheme>();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  AppAssets.loginBackground,
                  fit: BoxFit.cover,
                ),
              ),
            ),
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
                      const SizedBox(height: 80),
                      _LogoBlock(neon: neon),
                      const SizedBox(height: 48),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: GradientBorderCard(
                            gradientColors: EskoliaVisual.borderPrimary,
                            glowColor: _violet,
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Connexion',
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
                                    controller: _pseudoController,
                                    textInputAction: TextInputAction.next,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _fieldDecoration(
                                      context,
                                      label: 'Pseudo',
                                      hint: 'Tu peux aussi saisir ton email',
                                      prefixIcon: Icons.person_outline,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Champ requis';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscureText,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: _fieldDecoration(
                                      context,
                                      label: 'Mot de passe',
                                      prefixIcon: Icons.lock_outline,
                                    ).copyWith(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureText
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _slate,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscureText = !_obscureText,
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
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      onPressed: () =>
                                          context.push('/login/forgot'),
                                      child: const Text('Mot de passe oublié ?'),
                                    ),
                                  ),
                                  if (kIsWeb) ...[
                                    const SizedBox(height: 8),
                                    CheckboxListTile(
                                      value: _rememberMe,
                                      onChanged: (v) => setState(
                                        () => _rememberMe = v ?? true,
                                      ),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      title: Text(
                                        'Rester connecté sur cet appareil',
                                        style: TextStyle(
                                          color: Colors.white.withValues(
                                              alpha: 0.9),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Décoche pour être déconnecté à la fermeture de l’onglet.',
                                        style: TextStyle(
                                          color: _slate.withValues(alpha: 0.9),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
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
                                          label:
                                              _isLoading ? ' ' : 'Se connecter',
                                          variant: EskoliaButtonVariant.primary,
                                          expand: true,
                                          onPressed:
                                              _isLoading ? null : _handleLogin,
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
                                      onTap: () => context.go('/register'),
                                      child: Text.rich(
                                        TextSpan(
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: _slate,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: 'Pas encore de compte ? ',
                                            ),
                                            const TextSpan(
                                              text: 'S’inscrire',
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
        borderSide: const BorderSide(color: Color(0xFFEF4444)),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
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
        color: const Color(0xFF7F1D1D).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFEF4444)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: const Color(0xFFFCA5A5).withValues(alpha: 0.9),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFFFCA5A5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
