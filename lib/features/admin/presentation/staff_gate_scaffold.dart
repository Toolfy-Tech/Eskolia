import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/eskolia_visual.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../shared/widgets/eskolia_app_bar.dart';
import '../../auth/data/user_model.dart';
import '../data/staff_capability.dart';

/// Affiche [child] seulement si l’utilisateur est staff (Firestore `role` ou bootstrap email).
class StaffGateScaffold extends StatelessWidget {
  const StaffGateScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final auth = FirebaseAuth.instance;
    final uid = auth.currentUser?.uid ?? '';
    final email = auth.currentUser?.email;

    return FutureBuilder<UserModel?>(
      future: uid.isEmpty ? Future<UserModel?>.value(null) : UserRepository().getUserById(uid),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: EskoliaVisual.bgDeep,
            appBar: EskoliaAppBar.standard(context, title: title),
            body: const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            ),
          );
        }
        final allowed = userHasStaffAccess(snap.data, email);
        if (!allowed) {
          return Scaffold(
            backgroundColor: EskoliaVisual.bgDeep,
            appBar: EskoliaAppBar.standard(context, title: 'Accès restreint'),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Cette zone est reservee aux moderateurs.\n\n'
                  'Demande le role admin ou moderator sur ton document '
                  'Firestore users/{uid}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.45,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
