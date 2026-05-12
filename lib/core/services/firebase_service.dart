import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:eskolia/firebase_options.dart';

abstract final class FirebaseService {
  FirebaseService._();

  static bool get isConfigured {
    final o = DefaultFirebaseOptions.currentPlatform;
    return o.apiKey != 'REPLACE_ME' && o.projectId != 'REPLACE_ME';
  }

  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (!isConfigured) {
      debugPrint(
        'Firebase : clés factices (REPLACE_ME). Lancez « flutterfire configure » '
        'à la racine, ajoutez la plateforme Web dans la console Firebase, '
        'puis autorisez le domaine (localhost / hébergement) dans Auth.',
      );
      throw StateError(
        'Firebase non configuré : exécutez flutterfire configure '
        '(voir commentaire en tête de lib/firebase_options.dart).',
      );
    }
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _configureFirestoreAfterInit();
    } catch (e, stackTrace) {
      debugPrint('Firebase — erreur d’initialisation : $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  /// Web : réduit les plantages du SDK JS (`INTERNAL ASSERTION FAILED`, ex. ID b814)
  /// liés à IndexedDB / WebChannel. À appeler avant tout premier accès Firestore.
  static void _configureFirestoreAfterInit() {
    if (!kIsWeb) return;
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: false,
      webExperimentalAutoDetectLongPolling: true,
      ignoreUndefinedProperties: true,
    );
  }
}
