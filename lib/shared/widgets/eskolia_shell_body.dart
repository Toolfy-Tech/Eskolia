import 'package:flutter/material.dart';

import '../../core/theme/eskolia_layout.dart';

/// Colonne de contenu alignée sur le **Hub** (`HomeScreen`) : même centrage horizontal
/// et même [EskoliaLayout.shellContentMaxWidth].
///
/// À placer **sous** [Stack] après [EskoliaAmbientBackground].
/// Pour les écrans avec [AppBar] + `extendBodyBehindAppBar: true`, utiliser `safeAreaTop: false` :
/// le widget ajoute alors SafeArea (encoche) + kToolbarHeight pour pousser le contenu sous la barre.
class EskoliaShellBody extends StatelessWidget {
  const EskoliaShellBody({
    super.key,
    required this.child,
    this.safeAreaTop = true,
  });

  final Widget child;

  /// `false` lorsque le [Scaffold] a un [AppBar] avec `extendBodyBehindAppBar: true`.
  final bool safeAreaTop;

  @override
  Widget build(BuildContext context) {
    final inner = Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: EskoliaLayout.shellContentMaxWidth),
        child: child,
      ),
    );

    if (!safeAreaTop) {
      // Body extends behind AppBar: SafeArea handles notch, kToolbarHeight handles AppBar.
      return SafeArea(
        top: true,
        child: Padding(
          padding: const EdgeInsets.only(top: kToolbarHeight),
          child: inner,
        ),
      );
    }

    return SafeArea(top: true, child: inner);
  }
}
