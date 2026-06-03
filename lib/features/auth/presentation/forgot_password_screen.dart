import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/eskolia_tokens.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/theme/eskolia_layout.dart';
import '../../../core/theme/eskolia_visual.dart';
import '../../../shared/widgets/eskolia_ambient_background.dart';
import '../../../shared/widgets/eskolia_shell_body.dart';
import '../../../shared/widgets/eskolia_button.dart';
import '../../../shared/widgets/gradient_border_card.dart';
import '../data/auth_repository.dart';


class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.authRepository});

  final AuthRepository? authRepository;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _idController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  AuthRepository get _authRepo =>
      widget.authRepository ?? AuthRepository();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _authRepo.sendPasswordResetForIdentifier(_idController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Si l’email est correct, un lien vient d’être envoyé par Firebase '
            '(vérifie les courriers indésirables, délais de quelques minutes).',
          ),
        ),
      );
      context.go('/login');
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white70),
                          onPressed: () => context.go('/login'),
                        ),
                      ),
                      const SizedBox(height: 32),
                      _LogoBlock(neon: neon),
                      const SizedBox(height: 40),
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: GradientBorderCard(
                            gradientColors: EskoliaVisual.borderPrimary,
                            glowColor: EskoliaTokens.violet,
                            padding: const EdgeInsets.all(32),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'Mot de passe oublié',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 24,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Indique ton pseudo ou ton email : '
                                    'nous enverrons un lien sur l’adresse du compte.',
                                    style: TextStyle(
                                      color: EskoliaTokens.textSecondary.withValues(alpha: 0.95),
                                      fontSize: 14,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  TextFormField(
                                    controller: _idController,
                                    style: const TextStyle(color: Colors.white),
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration: _fieldDecoration(
                                      context,
                                      label: 'Pseudo ou email',
                                      prefixIcon: Icons.alternate_email_rounded,
                                    ),
                                    validator: (v) {
                                      if (v == null || v.trim().isEmpty) {
                                        return 'Champ requis';
                                      }
                                      return null;
                                    },
                                  ),
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
                                              : 'Envoyer le lien',
                                          variant: EskoliaButtonVariant.primary,
                                          expand: true,
                                          onPressed:
                                              _isLoading ? null : _submit,
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
  }) {
    final glass = Theme.of(context).extension<GlassmorphismTheme>();
    final focusColor = glass?.borderColor ?? EskoliaTokens.info;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: EskoliaTokens.textDisabled),
    );
    return InputDecoration(
      filled: true,
      fillColor: EskoliaTokens.surface2,
      labelText: label,
      labelStyle: const TextStyle(color: EskoliaTokens.textSecondary),
      prefixIcon: Icon(prefixIcon, color: EskoliaTokens.textSecondary),
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
              colors: [EskoliaTokens.info, EskoliaTokens.violet],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds),
            child: const Text(
              'ESKOLIA',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
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
