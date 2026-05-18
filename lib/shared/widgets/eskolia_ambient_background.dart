import 'package:flutter/material.dart';

/// Fond global de l'application — image placée en dessous du contenu de chaque page.
class EskoliaAmbientBackground extends StatelessWidget {
  const EskoliaAmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/backgrounds/eskolia_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SizedBox.expand(),
      ),
    );
  }
}
