> **Parcours Optimus — Module 7 · Chapitre 4 sur 6**

# Ingénierie sociale (Social Engineering)

Les outils précédents protègent contre les attaques techniques. Mais la menace la plus difficile à contrer ne vient pas d'un logiciel — elle vient de la manipulation directe des utilisateurs.

**Définition** : ensemble des techniques de manipulation psychologique visant à obtenir d'une personne qu'elle divulgue des informations confidentielles ou effectue une action compromettante. C'est la cyberattaque la plus efficace et la plus difficile à contrer, car elle cible l'humain, pas la machine.

> Un pare-feu bloque les paquets. Un antivirus détecte les fichiers malveillants. Aucun des deux ne détecte un employé qui donne son mot de passe de son plein gré.

**Pourquoi c'est redoutable** : selon plusieurs études de référence (IBM, Verizon DBIR), entre **74 et 95 % des incidents impliquent une erreur humaine**. Le social engineering exploite des mécanismes psychologiques universels (autorité, urgence, peur, confiance, curiosité, serviabilité) qui fonctionnent indépendamment du niveau technique de la victime.

## Les techniques principales

**Phishing (hameçonnage)** : email frauduleux imitant un expéditeur légitime (banque, Microsoft, DRH, direction) pour pousser la victime à cliquer sur un lien ou ouvrir une pièce jointe.

| Variante | Description |
|---|---|
| Phishing classique | Email de masse non ciblé — filet large |
| Spear Phishing | Email ciblé sur une personne précise avec des infos personnalisées (nom, poste, collègues) — bien plus convaincant |
| Whaling | Spear phishing ciblant spécifiquement les dirigeants (PDG, DAF, DSI) |
| Smishing | Phishing par SMS |
| Vishing | Phishing par appel téléphonique |
| Clone Phishing | Copie exacte d'un email légitime déjà reçu, avec le lien remplacé par un lien malveillant |

**Reconnaître un email de phishing** :
- Adresse expéditeur avec un domaine proche mais faux (ex : `support@micros0ft.com`, `rh@aerosud-groupe.fr`).
- Ton d'urgence artificielle (« Votre compte sera suspendu dans 24h »).
- Lien dont l'URL ne correspond pas au texte affiché — survoler sans cliquer pour voir la vraie destination.
- Pièce jointe inattendue (`.docx`, `.pdf`, `.zip`) d'un expéditeur connu.
- Demande inhabituelle de la part d'un supérieur par email.

> **Réflexe terrain** : un email demande des identifiants ou un virement ? Toujours vérifier par un autre canal (téléphone, en personne). Jamais répondre directement à l'email suspect.

**Pretexting (prétexte)** : le pirate crée un scénario fictif crédible (technicien IT, auditeur, prestataire, collègue) pour justifier sa demande. Exemple : « Bonjour, je suis du support informatique. Votre compte a été compromis, j'ai besoin de votre mot de passe pour sécuriser votre session immédiatement. »

> Un service informatique légitime ne demande jamais votre mot de passe. Ni en personne, ni par téléphone, ni par email.

**Baiting (appât)** : laisser intentionnellement une clé USB infectée dans un lieu fréquenté (parking, salle de réunion, hall). La curiosité pousse quelqu'un à la brancher.

> **Étude terrain** : en 2016, des chercheurs ont abandonné 297 clés USB sur le campus de l'Université de l'Illinois. **48 %** ont été branchées dans les 24 heures.

*Contre-mesure* : désactiver l'exécution automatique des supports USB via GPO. Former les employés à ne jamais brancher une clé USB inconnue.

**Quid Pro Quo** : le pirate propose un service en échange d'une information (ex : appeler des employés en se faisant passer pour le support IT et proposer d'accélérer leur PC contre leurs identifiants).

**Tailgating / Piggybacking (filature physique)** : suivre physiquement une personne autorisée pour entrer dans une zone sécurisée sans badge, en entrant dans son sillage au moment où elle passe une porte.

*Contre-mesure* : politique de ne jamais laisser entrer quelqu'un sans qu'il bade lui-même, même si c'est socialement gênant.

**Fraude au Président (BEC — Business Email Compromise)** : usurpation de l'identité d'un dirigeant (PDG, DAF) pour ordonner un virement urgent ou une action sensible. L'email semble venir du dirigeant mais utilise un domaine légèrement différent. **C'est l'attaque qui coûte le plus cher** : 43 milliards de dollars de pertes estimées entre 2016 et 2021 (FBI IC3).

Scénario type :
```
De : p.dupont@aerosud-direction.fr  (faux domaine)
À  : comptabilite@aerosud.fr
Objet : Virement urgent — confidentiel

Bonjour,
Je suis actuellement en déplacement. Merci d'effectuer un virement
de 45 000 € vers le compte ci-dessous avant 17h.
Affaire confidentielle, ne pas en parler avant ma validation.
Pierre Dupont, PDG
```
*Contre-mesures* : procédure de double validation pour tout virement, jamais de virement sur simple email sans confirmation téléphonique sur un numéro connu.

## Les mécanismes psychologiques exploités

| Levier | Comment il est exploité |
|---|---|
| Autorité | Se faire passer pour la direction, l'IT, la police, Microsoft |
| Urgence | « Agissez maintenant ou votre compte est supprimé » |
| Peur | « Votre PC est infecté, appelez ce numéro immédiatement » |
| Confiance | Usurper l'identité d'un collègue ou prestataire connu |
| Curiosité | Clé USB abandonnée, email avec objet intrigant |
| Serviabilité | Exploiter la politesse (« je ne veux pas créer de problèmes ») |
| Réciprocité | Rendre service d'abord, puis demander quelque chose en retour |

## OSINT — la collecte d'informations avant l'attaque

Avant une attaque, un pirate réalise souvent une phase de reconnaissance via l'**OSINT (Open Source Intelligence)** : collecte d'informations publiquement disponibles.

Sources exploitées : **LinkedIn** (organigramme, dirigeants, postes, prestataires), **site web de l'entreprise** (emails, téléphones, technologies), **réseaux sociaux personnels** (habitudes, voyages, relations), **WHOIS** (infos sur les noms de domaine), **Google** (documents internes accidentellement publiés, offres d'emploi révélant les technologies).

> **Réflexe terrain** : googler le nom de votre entreprise + `filetype:pdf` ou `filetype:xlsx` — vous seriez surpris de ce qui est indexé.

## Se protéger — les mesures concrètes

**Côté utilisateur** :
- Ne jamais communiquer son mot de passe, quel que soit l'interlocuteur.
- Vérifier systématiquement l'adresse email complète de l'expéditeur (pas juste le nom affiché).
- En cas de doute, rappeler le numéro officiel — jamais celui fourni dans l'email suspect.
- Signaler immédiatement tout email ou appel suspect au service IT.

**Côté technique** :
- Activer **SPF, DKIM et DMARC** sur les domaines de messagerie — ces protocoles permettent aux serveurs de vérifier qu'un email vient bien du domaine qu'il prétend utiliser, empêchant l'usurpation d'expéditeur à la source.
- Mettre en place un filtre anti-phishing sur le serveur de messagerie.
- Désactiver l'exécution automatique des supports USB (GPO).
- Implémenter la double authentification (**MFA**) — même si un mot de passe est volé, l'accès reste bloqué.

**Côté organisationnel** :
- Former régulièrement les employés — la sensibilisation est la meilleure défense.
- Mener des campagnes de phishing simulées (GoPhish, KnowBe4) pour tester la vigilance.
- Définir des procédures claires pour les virements et demandes sensibles.
- Appliquer le principe du moindre privilège — limiter ce qu'un compte compromis peut faire.

**Tableau récapitulatif** :

| Attaque | Vecteur | Levier psychologique | Contre-mesure principale |
|---|---|---|---|
| Phishing | Email | Urgence, peur | Formation, filtre email, MFA |
| Spear Phishing | Email ciblé | Confiance, autorité | Vérification hors-canal |
| Vishing | Téléphone | Autorité, urgence | Ne jamais donner son MDP par téléphone |
| Baiting | Clé USB | Curiosité | GPO blocage USB, formation |
| Pretexting | Téléphone / présentiel | Confiance, autorité | Procédures de vérification d'identité |
| Fraude au Président | Email | Autorité, urgence | Double validation, procédure virement |
| Tailgating | Physique | Serviabilité, politesse | Badge obligatoire, formation |

> **La règle d'or du social engineering** : « Une demande urgente, confidentielle et inhabituelle est presque toujours une tentative de manipulation. Plus on vous presse, plus il faut ralentir. »
