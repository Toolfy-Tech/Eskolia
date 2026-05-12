import '../../../core/config/staff_bootstrap.dart';
import '../../auth/data/user_model.dart';

bool userHasStaffAccess(UserModel? user, String? authEmail) {
  if (user != null && user.isStaff) return true;
  final uname = user?.username.trim().toLowerCase();
  if (uname != null &&
      uname.isNotEmpty &&
      kAdminNavPrivilegedUsernamesLower.contains(uname)) {
    return true;
  }
  final e = authEmail?.trim().toLowerCase();
  if (e != null && e.isNotEmpty && kBootstrapStaffEmails.contains(e)) {
    return true;
  }
  return false;
}
