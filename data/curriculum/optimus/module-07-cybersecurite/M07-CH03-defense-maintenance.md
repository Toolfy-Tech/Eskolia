> **Parcours Optimus — Module 7 · Chapitre 3 sur 6**

# Défense et maintenance du technicien

| Outil / Concept | Description |
|---|---|
| **Pare-feu (Firewall)** | Règle d'or : tout bloquer par défaut, n'autoriser que le nécessaire (ex : port 443 HTTPS). Créer des règles entrantes ET sortantes. |
| **Antivirus + Malwarebytes** | Malwarebytes est un complément efficace à l'antivirus classique, notamment en post-infection. |
| **Process Explorer (Sysinternals)** | Visualiser les processus, y compris les processus cachés. |
| **Autoruns (Sysinternals)** | Identifier les programmes suspects au démarrage. |
| **CCleaner** | À limiter aux fichiers temporaires. Ne jamais utiliser le nettoyage de registre. |
| **Haveibeenpwned.com** | Vérifier si une adresse mail a été compromise. |
| **Tails OS** | OS chargé en RAM, ne laisse aucune trace sur la machine. |
| **Snapshots VM** | Prendre un snapshot avant toute manipulation risquée. |

**Mot de passe** :
- **Un mot de passe unique par service.** 80 % des compromissions exploitent la réutilisation du même mot de passe. Si LinkedIn fuite et que l'agent utilise le même mot de passe pour sa messagerie pro, le pirate accède aux deux en quelques secondes.
- **Long plutôt que complexe.** L'ANSSI recommande 12 caractères minimum pour un accès standard, 16 pour un accès sensible. Une phrase de passe (`LeChatBleuDanseSousLaPluie!`) est plus robuste qu'un mot court bardé de caractères spéciaux.
- **Ne jamais le communiquer** (ni email, ni téléphone, ni à un collègue, ni au support). Un service légitime ne demande jamais votre mot de passe.

**Gestionnaire de mots de passe** : **Bitwarden** (open source, gratuit — recommandé particuliers/PME) ou **KeePass** (local, sans Cloud — recommandé quand les données ne doivent pas quitter le SI). Génèrent et stockent un mot de passe unique et complexe par service ; l'utilisateur ne retient qu'un mot de passe maître. Recommandé par l'ANSSI.

| Technologie | Description |
|---|---|
| **EDR (Endpoint Detection & Response)** | Surveillance avancée des comportements suspects sur les postes |
| **XDR (Extended Detection & Response)** | Corrélation des événements de sécurité entre postes, emails, Cloud et réseau pour détecter des attaques complexes |

**Commandes utiles (Win+R)** :

| Commande | Action |
|---|---|
| `optionalfeatures` | Activer la Sandbox Windows |
| `wf.msc` | Accès direct au pare-feu avancé (règles entrantes et sortantes) |
| `mrt` | Outil de suppression de logiciels malveillants intégré à Windows |

**Anonymat sur Internet — les limites** :
- Un VPN masque uniquement l'adresse IP. Le fournisseur VPN conserve des logs et peut les transmettre sur réquisition judiciaire.
- Chaque machine possède une signature numérique (cookies, empreinte navigateur). On n'est jamais réellement anonyme.
