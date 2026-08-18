# Mini-formation — ANSSI & Cybersécurité Opérationnelle

## 1. Rôle et Missions de l'ANSSI
L'**Agence Nationale de la Sécurité des Systèmes d'Information (ANSSI)** est l'autorité nationale française en matière de cyberdéfense et de sécurité numérique, rattachée au Secrétariat Général de la Défense et de la Sécurité Nationale (SGDSN).

### Ses missions prioritaires :
- **Défense et Réaction** : Détecter et réagir aux attaques ciblant les réseaux sensibles de l'État, des Opérateurs d'Importance Vitale (OIV) et des Opérateurs de Services Essentiels (OSE / NIS 2).
- **Prévention et Conseil** : Éditer des guides de durcissement, des méthodologies d'analyse de risques (EBIOS RM) et des référentiels de sécurité (SecNumCloud, PDIS, PRIS).
- **Veille et Alertes** : Le **CERT-FR** (Centre gouvernemental de veille, d'alerte et de réponse aux attaques informatiques) diffuse les avis de sécurité et bulletins d'alerte sur les vulnérabilités critiques (CVE).

---

## 2. Le Guide d'Hygiène Informatique (Règles Fondamentales)
L'ANSSI propose 40 règles essentielles pour sécuriser un système d'information. Voici les piliers incontournables pour un technicien :

### A. Gestion des Accès et Authentification
- **Authentification Multifacteur (MFA / 2FA)** : Obligatoire pour tout accès distant (VPN, portail web) et pour tous les comptes à privilèges d'administration.
- **Mots de passe robustes** : Au moins 12 à 16 caractères comprenant minuscules, majuscules, chiffres et caractères spéciaux, sans mot du dictionnaire.
- **Séparation stricte des privilèges (PoLP)** : Un technicien doit posséder un compte utilisateur standard pour la bureautique/web et un compte d'administration distinct uniquement utilisé pour les tâches d'administration.
- **Modèle de Tiering Active Directory** :
  - *Tier 0* : Contrôleurs de domaine, PKI, serveurs d'identité.
  - *Tier 1* : Serveurs applicatifs, bases de données, stockage.
  - *Tier 2* : Postes clients, imprimantes, périphériques utilisateurs.
  - *Règle d'or* : Un compte de Tier inférieur ne doit jamais administrer un élément de Tier supérieur.

### B. Architecture et Cloisonnement Réseau
- **Segmentation réseau étanche** : Séparer physiquement ou logiquement (VLANs filtrés par pare-feu) la bureautique, la production, la DMZ publique et les flux d'administration (réseau d'admin hors-bande).
- **Fermeture des flux superflus** : Bloquer par défaut tous les ports et protocoles entrants et sortants non justifiés.
- **Désactivation des protocoles obsolètes** : Supprimer SMBv1, NTLMv1, SSLv3, TLS 1.0 et 1.1, Telnet, SNMPv1/v2c.

### C. Postes de Travail, Serveurs et Patch Management
- **Maintien en Condition de Sécurité (MCS)** : Appliquer les correctifs de sécurité critiques dans les plus brefs délais après validation sur environnement de recette.
- **Durcissement des configurations** : Désactiver les services inutiles, restreindre l'exécution de macros Office et de scripts PowerShell non signés, activer AppLocker / WDAC.
- **Chiffrement des supports nomades** : Chiffrer intégralement les disques durs des ordinateurs portables (BitLocker / LUKS) et clés USB.

### D. Sauvegardes et Résilience Ransomware
- **Règle 3-2-1** : 3 copies des données, sur 2 supports différents, dont 1 copie hors-site / hors-ligne (Air-Gapped ou WORM / immuable).
- **Tests de restauration périodiques** : Une sauvegarde non testée régulièrement en conditions réelles ne garantit aucune reprise d'activité.

### E. Traçabilité, Journalisation et Détection
- **Centralisation des journaux (Syslog / SIEM)** : Collecter les logs d'authentification, de pare-feu et d'antivirus sur un serveur sécurisé dédié.
- **Synchronisation du temps (NTP)** : Tous les équipements doivent être synchronisés sur une même source de temps fiable pour corréler les logs lors d'une analyse forensic.

---

## 3. Conduite à tenir en cas d'Incident / Ransomware
1. **Isoler immédiatement la machine compromise** : Débrancher le câble réseau RJ45 et désactiver la carte Wi-Fi / Bluetooth.
2. **Ne PAS éteindre ni redémarrer la machine** : Préserver le contenu de la mémoire vive (RAM) essentiel pour l'analyse judiciaire et l'extraction des clés de déchiffrement.
3. **Alerter immédiatement** : Contacter le RSSI, le responsable d'infrastructure et le CERT-FR / ANSSI selon la criticité.
4. **Documenter et préserver les preuves** : Noter l'heure exacte, les messages affichés, les anomalies constatées, sans modifier les fichiers touchés.

---
*Site officiel & guides : [ssi.gouv.fr](https://www.ssi.gouv.fr) — Alertes : [cert.ssi.gouv.fr](https://www.cert.ssi.gouv.fr)*
