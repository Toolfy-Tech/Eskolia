> **Parcours Optimus — Module 6 · Chapitre 1 sur 14**

# Microsoft 365 et Entra ID (Le Cloud)

La majorité des entreprises utilise des services hébergés dans le Cloud (messagerie, fichiers partagés, outils collaboratifs). Le serveur local (On-Premise) a souvent été remplacé ou complété par le Cloud.

**Entra ID (anciennement Azure AD)** : l'équivalent de l'Active Directory local, mais hébergé sur les serveurs de Microsoft. Service d'identité qui gère les connexions à Microsoft 365 (Outlook, Teams, SharePoint, OneDrive).

| Caractéristique | Active Directory Local (On-Premise) | Microsoft Entra ID (Cloud) |
|---|---|---|
| Emplacement | Serveur physique dans l'entreprise (DC) | Serveurs Microsoft (Cloud) |
| Gestion des PC | Jonction de domaine + GPO | Jonction Entra ID + Microsoft Intune (MDM) |
| Authentification | Kerberos / NTLM | Protocoles web (SAML, OAuth 2.0) |
| Usage typique | PME traditionnelles, usines, réseaux fermés | Télétravail, startups, entreprises modernes |

**L'environnement Hybride** : souvent l'entreprise possède les deux (vieux serveur local ET licences Microsoft 365). On installe **Entra Connect (Azure AD Connect)** sur le serveur local : il synchronise les utilisateurs de l'AD local vers le Cloud toutes les 30 minutes.

> Réflexe terrain : en hybride, l'AD local est « le maître ». Si un utilisateur oublie son mot de passe, le réinitialiser sur le serveur local (`dsa.msc`). La modification montera dans le Cloud quelques minutes plus tard.

## 1.1 Réinitialiser un mot de passe AD en PowerShell

```powershell
# Réinitialiser le mot de passe
Set-ADAccountPassword -Identity "m.dupont" `
  -NewPassword (ConvertTo-SecureString "NouveauMdp2024!" -AsPlainText -Force) `
  -Reset
# Obliger l'utilisateur à changer son mot de passe
Set-ADUser "m.dupont" -ChangePasswordAtLogon $true
# Forcer une synchronisation immédiate vers Microsoft 365
Start-ADSyncSyncCycle -PolicyType Delta
```

> `Start-ADSyncSyncCycle` doit être exécutée sur le serveur où Entra Connect est installé.

## 1.2 Joindre un PC à Microsoft Entra ID

Paramètres > Comptes > Accès professionnel ou scolaire > Se connecter > Joindre cet appareil à Microsoft Entra ID. (Ne pas simplement ajouter l'adresse mail, sinon le PC reste local.)

## 1.3 Microsoft Intune

Administre les postes joints à Entra ID : déploiement de logiciels, stratégies de sécurité, chiffrement BitLocker, inventaire matériel, conformité des appareils, effacement à distance. Intune remplace progressivement les GPO dans les environnements Cloud modernes.

## 1.3 (bis) MDM mobile — gérer smartphones et tablettes

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le **MDM (Mobile Device Management)** étend la gestion centralisée aux **smartphones et tablettes** professionnels (cf. OS mobiles, Module 3 §7). Microsoft Intune est la solution MDM de l'écosystème Microsoft, mais le principe vaut pour toutes (VMware Workspace ONE, Jamf pour Apple...).

**Ce que permet un MDM sur mobile :**
- **Enrôler** un appareil (l'inscrire pour qu'il soit géré par l'entreprise).
- **Déployer des applications** métier et des configurations (Wi-Fi, VPN, messagerie) à distance.
- **Appliquer des règles de sécurité** : code de verrouillage obligatoire, chiffrement, blocage de fonctions à risque.
- **Effacer à distance** un appareil perdu ou volé — totalement, ou seulement les données professionnelles (**wipe sélectif**).
- **Contrôler la conformité** : un appareil non conforme (jailbreaké, OS obsolète) peut se voir refuser l'accès aux ressources (lien avec l'accès conditionnel).

**Deux approches de parc mobile :**

| Modèle | Principe | Usage |
|---|---|---|
| **COPE / appareil d'entreprise** | Mobile fourni et entièrement géré par l'entreprise | Postes nomades, terrain |
| **BYOD** (*Bring Your Own Device*) | Appareil personnel de l'employé, seules les données pro sont gérées | Souplesse, mais frontière vie privée/pro à respecter |

> **Réflexe terrain** : pour un mobile pro **perdu ou volé**, la priorité absolue est l'**effacement à distance** via le MDM, pour protéger les données de l'entreprise. En BYOD, on privilégie le **wipe sélectif** (effacer le compartiment professionnel sans toucher aux photos/contacts personnels de l'employé).

## 1.4 Le MFA (Authentification multifacteur)

Ajoute une seconde vérification : application Microsoft Authenticator, SMS, appel téléphonique, clé de sécurité. Même si un mot de passe est volé, le pirate ne peut pas se connecter sans le second facteur.

## 1.5 Ticket classique : « J'ai changé de téléphone »

- Portail Entra ID → rechercher l'utilisateur → Méthodes d'authentification → **Exiger le réenregistrement MFA**.
- **Cas critique (téléphone perdu/cassé)** : Portail Entra ID → Utilisateurs → Méthodes d'authentification → Supprimer les anciennes méthodes MFA → Exiger le réenregistrement.

> Toujours vérifier l'identité de l'utilisateur avant cette opération (scénario classique de social engineering).

## 1.6 Les licences Microsoft 365

Outlook, Teams, OneDrive, Office, Exchange Online ne fonctionnent pas sans licence. Chemin : Portail admin M365 > Utilisateurs > Utilisateurs actifs > Licences et applications.

| Licence | Contenu principal |
|---|---|
| Microsoft 365 Business Basic | Outlook web, Teams, OneDrive, SharePoint |
| Microsoft 365 Business Standard | + applications Office desktop |
| Microsoft 365 Business Premium | + Intune, Defender, gestion sécurité avancée |

> Ticket « Je n'ai pas Teams » : souvent une licence absente, mauvaise, ou un service décoché. Toujours vérifier les licences avant un diagnostic technique complexe.

## 1.7 Les portails d'administration

| Portail | Usage |
|---|---|
| Admin Microsoft 365 | Gestion utilisateurs, licences, mots de passe |
| Entra Admin Center | MFA, accès conditionnel, appareils |
| Intune Admin Center | Gestion des postes |
| Exchange Admin Center | Boîtes mail, redirections, groupes |
| SharePoint Admin Center | Sites SharePoint et OneDrive |

**Conditional Access (Accès conditionnel)** : bloque ou autorise les connexions selon des critères (pays, appareil conforme, MFA, niveau de risque, type d'application). Si un utilisateur est bloqué « sans raison », vérifier les politiques d'accès conditionnel dans Entra ID.

## 1.8 Réflexes support à retenir

Toujours vérifier : 1) la licence M365, 2) le statut MFA, 3) la synchronisation Entra Connect, 4) l'accès conditionnel, 5) l'état du compte dans l'AD local, 6) la conformité du poste dans Intune.
