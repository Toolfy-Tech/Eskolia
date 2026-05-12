import 'package:flutter/material.dart';

import '../../core/theme/eskolia_layout.dart';

/// Colonne de contenu alignée sur le **Hub** (`HomeScreen`) : même centrage horizontal
/// et même [EskoliaLayout.shellContentMaxWidth] que
/// `SafeArea` → `Align(topCenter)` → `ConstrainedBox(maxWidth: shellContentMaxWidth)`.
///
/// À placer **sous** [Stack] après [EskoliaAmbientBackground]. Pour les écrans avec
/// [AppBar], utiliser `safeAreaTop: false`.
class EskoliaShellBody extends StatelessWidget {
  const EskoliaShellBody({
    super.key,
    required this.child,
    this.safeAreaTop = true,
  });

  final Widget child;

  /// `false` lorsque le [Scaffold] a un [AppBar] (déjà sous encoche).
  final bool safeAreaTop;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: safeAreaTop,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: EskoliaLayout.shellContentMaxWidth,
          ),
          child: child,
        ),
      ),
    );
  }
}
