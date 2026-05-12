/// Types de tip — blueprint v3 § Labo (Système de Tips).
enum LaboTipKind {
  astuce('astuce', 'Astuce'),
  mnemo('mnemo', 'Mnémotechnique'),
  piege('piege', 'Piège à éviter'),
  exemple('exemple', 'Exemple'),
  autre('autre', 'Autre');

  const LaboTipKind(this.firestoreValue, this.label);

  final String firestoreValue;
  final String label;

  static LaboTipKind fromFirestore(String? raw) {
    for (final k in LaboTipKind.values) {
      if (k.firestoreValue == raw) return k;
    }
    return LaboTipKind.autre;
  }
}
