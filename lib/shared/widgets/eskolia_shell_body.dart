import 'package:flutter/material.dart';

import '../../core/theme/eskolia_layout.dart';
import 'eskolia_app_bar.dart';

/// Colonne de contenu alignée sur le **Hub** (`HomeScreen`) : même centrage horizontal
/// et même [EskoliaLayout.shellContentMaxWidth].
///
/// À placer **sous** [Stack] après [EskoliaAmbientBackground].
/// Pour les écrans avec [AppBar] + `extendBodyBehindAppBar: true`, utiliser `safeAreaTop: false` :
/// le widget ajoute alors SafeArea (encoche) + kEskoliaAppBarHeight pour pousser le contenu sous la barre.
class EskoliaShellBody extends StatelessWidget {
  const EskoliaShellBody({
    super.key,
    required this.child,
    this.safeAreaTop = true,
    this.showBack = true,
  });

  final Widget child;

  /// `false` lorsque le [Scaffold] a un [AppBar] avec `extendBodyBehindAppBar: true`.
  final bool safeAreaTop;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.sizeOf(context).width > 800;

    // Detect if we can navigate back, respecting showBack configuration
    final canPop = showBack && Navigator.of(context).canPop();

    Widget inner = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isLargeScreen ? double.infinity : EskoliaLayout.shellContentMaxWidth,
        ),
        child: child,
      ),
    );

    if (canPop) {
      inner = Stack(
        children: [
          inner,
          Positioned(
            left: 12,
            top: 12,
            child: Material(
              color: Colors.black.withValues(alpha: 0.45),
              shape: const CircleBorder(),
              elevation: 2,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                onPressed: () => Navigator.of(context).pop(),
                tooltip: 'Retour',
              ),
            ),
          ),
        ],
      );
    }

    if (!safeAreaTop) {
      // Body extends behind AppBar: SafeArea handles notch, kEskoliaAppBarHeight handles AppBar.
      return SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.only(top: kEskoliaAppBarHeight),
          child: inner,
        ),
      );
    }

    return SafeArea(top: true, child: inner);
  }
}
