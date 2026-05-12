/// Emails en **minuscules** : accès **admin / modération** sans champ Firestore `role`.
/// En production, préfère `role: "admin"` ou `"moderator"` sur `users/{uid}`.
const Set<String> kBootstrapStaffEmails = <String>{
  // Ex. 'toi@domaine.com',
};

/// Usernames Firestore `users.username` en **minuscules** : entrée **Admin** dans la barre du bas uniquement.
/// (Les écrans `/admin` restent protégés côté UI par [userHasStaffAccess] si besoin.)
const Set<String> kAdminNavPrivilegedUsernamesLower = <String>{
  'toolf',
  'floot',
};
