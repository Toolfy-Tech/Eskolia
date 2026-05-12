import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/time/xp_week_key.dart';

/// Alias pseudo → email pour la connexion par pseudo (lecture possible sans auth).
/// Règles Firestore suggérées :
/// `match /login_aliases/{name} { allow get: if name is string && name.size() >= 2; allow list: if false; allow create: if request.auth != null; allow update, delete: if request.auth != null && request.auth.uid == resource.data.uid; }`
const String _loginAliasesCollection = 'login_aliases';

const String _prefsRememberMeKey = 'auth_remember_me';

class AuthFailure implements Exception {
  const AuthFailure(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthRepository {
  AuthRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? getCurrentUser() => _auth.currentUser;

  /// Web : applique la persistance (onglet vs machine) selon la préférence enregistrée.
  static Future<void> restoreWebAuthPersistenceIfNeeded() async {
    if (!kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(_prefsRememberMeKey) ?? true;
    await FirebaseAuth.instance.setPersistence(
      remember ? Persistence.LOCAL : Persistence.SESSION,
    );
  }

  /// Web : enregistre le choix « rester connecté » et applique avant le prochain [signIn].
  Future<void> applyRememberMeForWeb(bool rememberMe) async {
    if (!kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsRememberMeKey, rememberMe);
    await _auth.setPersistence(
      rememberMe ? Persistence.LOCAL : Persistence.SESSION,
    );
  }

  static String usernameAliasId(String username) =>
      username.trim().toLowerCase();

  /// Résout un identifiant saisi : email direct, ou email lié au pseudo ([_loginAliasesCollection]).
  Future<String?> resolveEmailForLogin(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.contains('@')) {
      return trimmed.toLowerCase();
    }
    final id = usernameAliasId(trimmed);
    if (id.isEmpty) return null;
    final snap =
        await _firestore.collection(_loginAliasesCollection).doc(id).get();
    if (!snap.exists) return null;
    final data = snap.data();
    final email = data?['email'] as String?;
    if (email == null || email.trim().isEmpty) return null;
    return email.trim().toLowerCase();
  }

  Future<void> assertUsernameAvailable(String username) async {
    final id = usernameAliasId(username);
    if (id.length < 3) {
      throw const AuthFailure('Pseudo trop court');
    }
    final snap =
        await _firestore.collection(_loginAliasesCollection).doc(id).get();
    if (snap.exists) {
      throw const AuthFailure('Ce pseudo est déjà pris');
    }
  }

  Future<UserCredential> signInWithPseudoOrEmail(
    String identifier,
    String password,
  ) async {
    final email = await resolveEmailForLogin(identifier);
    if (email == null || email.isEmpty) {
      throw const AuthFailure('Aucun compte avec ce pseudo');
    }
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _firestore.collection('users').doc(cred.user!.uid).set(
            {'lastLogin': FieldValue.serverTimestamp()},
            SetOptions(merge: true),
          );
      return cred;
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_handleError(e, loginByPseudo: true));
    }
  }

  /// Envoie un lien de réinitialisation sur l’email **Firebase Auth** du compte.
  /// - **Email** : utilisé tel quel (pas besoin du doc Firestore).
  /// - **Pseudo** : résolution via [login_aliases] ; si absent (ex. inscription
  ///   interrompue après Auth), on signale clairement d’utiliser l’email.
  Future<void> sendPasswordResetForIdentifier(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const AuthFailure('Champ vide');
    }

    final String email;
    if (trimmed.contains('@')) {
      email = trimmed.toLowerCase();
    } else {
      final resolved = await resolveEmailForLogin(trimmed);
      if (resolved == null || resolved.isEmpty) {
        throw const AuthFailure(
          'Ce pseudo n’est lié à aucun compte dans la base. Utilise plutôt '
          'l’email exact utilisé à l’inscription pour recevoir le lien — ou supprime '
          'le compte orphelin dans la console Firebase (Auth) puis réinscris-toi.',
        );
      }
      email = resolved;
    }

    ActionCodeSettings? actionCodeSettings;
    if (kIsWeb) {
      final origin = Uri.base.origin;
      if (origin.startsWith('http://') || origin.startsWith('https://')) {
        final base = origin.endsWith('/') ? origin.substring(0, origin.length - 1) : origin;
        actionCodeSettings = ActionCodeSettings(
          url: '$base/login',
          handleCodeInApp: false,
        );
      }
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw const AuthFailure(
          'Aucun compte Firebase avec cette adresse. Vérifie l’orthographe ou '
          'supprime l’ancien compte dans la console Firebase puis réinscris-toi.',
        );
      }
      throw AuthFailure(_handleError(e, loginByPseudo: false));
    }
  }

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String username, {
    List<String> interestSections = const [],
  }) async {
    final emailNorm = email.trim().toLowerCase();
    final aliasId = usernameAliasId(username);
    if (aliasId.contains('/') || aliasId.contains('\\')) {
      throw const AuthFailure('Le pseudo ne peut pas contenir / ou \\');
    }
    try {
      await assertUsernameAvailable(username);
    } on AuthFailure {
      rethrow;
    } catch (e) {
      throw AuthFailure('Vérification du pseudo impossible : $e');
    }

    late UserCredential cred;
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: emailNorm,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_handleError(e, loginByPseudo: false));
    }

    final uid = cred.user!.uid;
    final userRef = _firestore.collection('users').doc(uid);
    final aliasRef =
        _firestore.collection(_loginAliasesCollection).doc(aliasId);

    try {
      final batch = _firestore.batch();
      batch.set(userRef, {
        'uid': uid,
        'username': username.trim(),
        'usernameLower': aliasId,
        'email': emailNorm,
        'interestSections': interestSections,
        'level': 1,
        'xp': 0,
        'xpThisWeek': 0,
        'xpWeekStartKey': xpWeekMondayKey(DateTime.now()),
        'streak': 0,
        'battleWins': 0,
        'currentChapter': 1,
        'currentModule': 1,
        'totalQuizzesPlayed': 0,
        'totalWins': 0,
        'badges': <String>[],
        'role': 'user',
        'lastLogin': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      batch.set(aliasRef, {
        'email': emailNorm,
        'uid': uid,
      });
      await batch.commit();
    } catch (e) {
      try {
        await cred.user?.delete();
      } catch (_) {}
      if (e is FirebaseException) {
        throw AuthFailure(
          'Impossible d’enregistrer le profil. Réessaie ou contacte le support.',
        );
      }
      rethrow;
    }
    return cred;
  }

  Future<void> signOut() => _auth.signOut();

  String _handleError(FirebaseAuthException e, {required bool loginByPseudo}) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mot de passe incorrect';
      case 'user-not-found':
        return loginByPseudo
            ? 'Aucun compte avec ce pseudo'
            : 'Aucun compte avec cet email';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum)';
      case 'invalid-email':
        return 'Adresse email invalide';
      case 'too-many-requests':
        return 'Trop de tentatives, réessaie plus tard';
      case 'network-request-failed':
        return 'Pas de connexion internet';
      default:
        return 'Une erreur est survenue : ${e.message ?? e.code}';
    }
  }
}
