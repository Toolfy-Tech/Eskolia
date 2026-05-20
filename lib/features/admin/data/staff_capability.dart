import '../../auth/data/user_model.dart';

/// Acces staff base uniquement sur le champ `role` Firestore (admin ou moderator).
bool userHasStaffAccess(UserModel? user, String? authEmail) {
  return user != null && user.isStaff;
}
