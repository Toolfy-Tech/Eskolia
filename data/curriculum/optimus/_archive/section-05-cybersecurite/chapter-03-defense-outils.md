> **Parcours Optimus** — **Module 5** · Chapitre 3 sur 3 · *Défense et maintenance du technicien*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

## 3. Défense et maintenance du technicien

|**Outil / Concept**|**Description**|
|---|---|
|Pare-feu (Firewall)|Règle d'or : tout bloquer par défaut, n'autoriser que le nécessaire (ex : port 443 HTTPS). Créer des règles entrantes ET sortantes.|
|Antivirus + Malwarebytes|Malwarebytes est un complément efficace à l'antivirus classique, notamment en post-infection.|
|Process Explorer (Sysinternals)|Visualiser les processus, y compris les processus cachés.|
|Autoruns (Sysinternals)|Identifier les programmes suspects au démarrage.|

|CCleaner|Nettoyer les clés de registre obsolètes après désinfection “Éviter les nettoyeurs de registre sauf cas très particulier et maîtrisé.”Si tu gardes CCleaner, limite-le à : fichiers temporaires, entretien léger, jamais comme solution miracle.|
|---|---|
|Haveibeenpwned.com|Vérifier si une adresse mail a été compromise.|
|Tails OS|OS chargé en RAM, ne laisse aucune trace sur la machine.|
|Snapshots VM|Prendre un snapshot avant toute manipulation risquée.|

Commandes utiles (Win+R)

|**Commande**|**Action**|
|---|---|
|optionalfeatures|Activer la Sandbox Windows|
|wf.msc|Accès direct au pare-feu avancé (règles entrantes et sortantes)|
|mrt|Outil de suppression de logiciels malveillants intégré à Windows|

Anonymat sur internet : les limites

- Un VPN masque uniquement l'adresse IP. Le fournisseur VPN conserve des logs et peut les
transmettre sur réquisition judiciaire.
- Chaque machine possède une signature numérique (cookies, empreinte navigateur). Nous ne
sommes jamais réellement anonymes.
