> **Parcours Optimus** — **Module 3** · Chapitre 4 sur 5 · *VLANs et organisation avancée*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.
Partie 4 : organisation avancee (VLANs)
1. Définition et intérêt des VLANs
Un VLAN (Virtual Local Area Network) est un réseau local logique créé par configuration logicielle sur un
ou plusieurs switchs physiques.
Sans acheter un seul câble ni un seul switch supplémentaire, on crée des murs virtuels qui isolent les flux
entre services.
## 2. Les 3 piliers des VLANs

|**Pilier**|**Bénéfice**|**Exemple AéroSud**|
|---|---|---|
|**Sécurité**|Isolation par défaut entre VLANs|Le stagiaire marketing ne peut plus accéder au serveur comptabilité|
|**Réduction des broadcasts**|Chaque VLAN = son propre domaine de broadcast, donc moins de congestion|Le transfert R&D de 40 Go ne noie plus les caisses du showroom|
|**Flexibilité**|Regroupement logique indépendant de la position physique|Pas besoin de tirer de nouveaux câbles : on reconfigure les ports|
3. Sans VLAN vs Avec VLAN
|**Caractéristique**|❌ **Sans VLAN**|✅ **Avec VLAN**|
|---|---|---|
|**Sécurité**|Faible — tout le monde voit tout|Élevée — isolation par défaut|
|**Broadcast**|Un seul gros domaine (tous les postes)|Plusieurs petits domaines indépendants|
|**Gestion**|Physique — dépend des câbles|Logique — logicielle et flexible|
|**Maintenance**|Difficile — tout est lié|Facilitée — on touche un VLAN sans impacter les autres|
4. Ports Access et Ports Trunk
- Port Access
Un port en mode access appartient à un seul VLAN. Il est connecté à un équipement final (PC, imprimante,
serveur). Le trafic qui en sort est non taggué.
SW1(config)# interface range FastEthernet 0/1-12
SW1(config-if-range)# switchport mode access
SW1(config-if-range)# switchport access vlan 10
SW1(config-if-range)# exit
→ Les ports 1 à 12 sont assignés au VLAN 10 (Comptabilité)
🔷 Interface range
La commande 'interface range' permet de configurer plusieurs ports simultanément. Configurer 12 ports un par un
serait inutilement long.
- Port Trunk
Un port en mode trunk transporte le trafic de PLUSIEURS VLANs simultanément. Il est utilisé sur les liens
entre switchs (liens inter-switch).
Le standard utilisé est le protocole 802.1Q (IEEE) : chaque trame Ethernet reçoit un tag de 4 octets
indiquant le numéro de VLAN auquel elle appartient. Le switch destinataire lit le tag et place la trame dans
le bon VLAN.
SW1(config)# interface GigabitEthernet 0/1
SW1(config-if)# switchport trunk encapsulation dot1q
SW1(config-if)# switchport mode trunk
SW1(config-if)# exit
→ Le lien inter-switch transporte les VLANs 10, 20, 30, 40 et 50 taggués
📌 Analogie du centre de tri postal
Chaque colis (trame) porte une étiquette (tag VLAN). Le convoyeur (trunk) l'achemine dans le bon bac (VLAN de
destination). Sans étiquette, impossible de trier.
## 5. Plan de VLAN — Application pratique

Nadia définit 5 VLANs pour AéroSud. La numérotation commence à 10 et progresse par intervalles de 10
— convention professionnelle permettant d'insérer de nouveaux VLANs ultérieurement sans casser la
numérotation.
|**VLAN**|**Nom**|**Service**|**Ports (Switch 1)**|
|---|---|---|---|
|**VLAN 10**|`COMPTA`|Comptabilité / Finance — 1er étage|`Fa0/1 → Fa0/12`|
|**VLAN 20**|`RD`|Recherche & Développement — 2e étage|`Fa0/13 → Fa0/24`|
|**VLAN 30**|`MARKETING`|Marketing — 3e étage|`Fa0/25 → Fa0/36`|
|**VLAN 40**|`DIRECTION`|Direction — 4e étage|`Fa0/37 → Fa0/42`|
|**VLAN 50**|`SHOWROOM`|Caisses & bornes — RDC|`Fa0/43 → Fa0/48`|
6. Séquence complète de configuration
Voici la séquence que Nadia exécute sur chaque switch, dans l'ordre :
Étape 1 — Créer les VLANs
SW1# configure terminal
SW1(config)# vlan 10
SW1(config-vlan)# name COMPTA
SW1(config-vlan)# exit
SW1(config)# vlan 20
SW1(config-vlan)# name RD
SW1(config-vlan)# exit
SW1(config)# vlan 30
SW1(config-vlan)# name MARKETING
SW1(config-vlan)# exit
SW1(config)# vlan 40
SW1(config-vlan)# name DIRECTION
SW1(config-vlan)# exit
SW1(config)# vlan 50
SW1(config-vlan)# name SHOWROOM
SW1(config-vlan)# exit
🔷 Toujours nommer ses VLANs
Sans nom, un 'show vlan brief' affiche 'VLAN0010' au lieu de 'COMPTA'. En production, un VLAN sans nom est une
source d'erreur lors des maintenances.
Étape 2 — Assigner les ports (mode Access)
SW1(config)# interface range FastEthernet 0/1-12
SW1(config-if-range)# switchport mode access
SW1(config-if-range)# switchport access vlan 10
SW1(config-if-range)# exit
SW1(config)# interface range FastEthernet 0/13-24
SW1(config-if-range)# switchport mode access
SW1(config-if-range)# switchport access vlan 20
SW1(config-if-range)# exit
! ... idem pour les autres services
Étape 3 — Configurer les trunks inter-switch
SW1(config)# interface GigabitEthernet 0/1
SW1(config-if)# switchport trunk encapsulation dot1q
SW1(config-if)# switchport mode trunk
SW1(config-if)# exit
! À répéter sur CHAQUE côté du lien (les 2 switchs concernés)
! 4 switchs = 3 liens trunk = 6 interfaces à configurer
Étape 4 — Sauvegarder (INDISPENSABLE)
SW1# copy running-config startup-config
! Sur Cisco : la running-config est en RAM → perdue au reboot
! La startup-config est en NVRAM → persistante
! Ne jamais oublier cette étape sous peine de tout refaire
### 5.8. Vérification — Les commandes essentielles

- **Commande** | **Ce qu'elle vérifie**
- `show vlan brief` | Liste des VLANs créés, leurs noms, et les ports assignés
- `show interfaces trunk` | Ports en mode trunk, encapsulation 802.1Q, VLANs actifs
- `show interfaces trunk` | sur le trunk
- `show mac address-table` | Table d'adresses MAC : quelle adresse est sur quel port →
- `show mac address-table` | identifier qui est branché où
- `ping <IP_destination>` | Tester l'isolation : un ping en timeout entre deux VLANs
- `ping <IP_destination>` | différents = succès de la segmentation
🔷 Un ping en timeout = bonne nouvelle
Nadia sourit quand le ping du poste marketing vers le serveur compta retourne 4 timeouts. C'est exactement le
résultat attendu : l'isolation fonctionne.
### 5.9. Communication inter-VLAN

Par défaut, deux VLANs différents ne peuvent pas communiquer. Pour autoriser des échanges contrôlés
(ex. la direction accède aux données comptables), il faut obligatoirement un équipement de couche 3 :
- Un routeur (méthode « Router-on-a-stick »)
- Un switch de niveau 3 (switch L3) avec des interfaces virtuelles (SVI)
📌 Métaphore de Nadia
"Les VLANs, c'est poser les murs. Le routage inter-VLAN, c'est installer les portes à badge. On pose les murs en
premier, les portes après." — Nadia, réunion de crise AéroSud
Le routage inter-VLAN fera l'objet d'un cours dédié.
### 5.10. Résumé — Ce qu'il faut retenir

- Un VLAN = un réseau logique isolé sur un équipement physique
- VLAN 1 = VLAN d'usine sur Cisco → ne jamais laisser des postes en production dessus
- Port Access = un seul VLAN, trafic non taggué → équipements finaux
- Port Trunk = plusieurs VLANs, trafic taggué 802.1Q → liens inter-switch
- Toujours nommer ses VLANs et sauvegarder (copy running-config startup-config)
- Pour faire communiquer deux VLANs → équipement routeur ou switch L3 obligatoire
- Les VLANs ne coûtent rien en matériel : c'est de la configuration pure
📌 La leçon d'AéroSud
"Un réseau sans VLAN, ça marche. Mais ça marche ne veut pas dire c'est bien fait. Un immeuble sans murs, ça tient
debout aussi… jusqu'au jour où quelqu'un entre dans ton appartement."
Active Directory et les VLANs
Active Directory (AD) gère les utilisateurs et leurs droits, les VLANs gèrent la segmentation réseau — ce sont
deux couches complémentaires. Un utilisateur s'authentifie via AD, et selon son groupe AD, il peut être
automatiquement placé dans le bon VLAN (ex. groupe "Comptabilité" → VLAN 10) grâce au protocole 802.1X couplé
à un serveur RADIUS. Le switch interroge le serveur RADIUS au moment de la connexion du poste, qui consulte l'AD
et retourne le numéro de VLAN à assigner dynamiquement au port. Sans 802.1X, l'assignation est statique (le VLAN
dépend du port physique, pas de l'utilisateur) — c'est ce qu'a configuré Nadia chez AéroSud. L'imbrication AD + VLAN
dynamique est la solution entreprise complète : AD contrôle qui accède, le VLAN contrôle à quoi le trafic accède.
### 5.11. Sécurité des ports (Port-Security)

La Port-Security permet de restreindre l'accès à un port du switch en fonction de l'adresse MAC de
l'équipement qui s'y connecte. C'est la première barrière contre l'intrusion physique dans un réseau
d'entreprise.
Pourquoi l'utiliser ?
- Empêcher un visiteur de débrancher une imprimante pour connecter son propre ordinateur.
- Limiter le nombre de machines pouvant se connecter à une seule prise murale.
- Bloquer automatiquement un port si une anomalie est détectée.
Les 3 modes de réaction (Violation)
Si une adresse MAC non autorisée se branche, le switch peut réagir de trois façons :
- Protect : Les paquets de l'intrus sont jetés, mais le port reste actif pour les autres.
- Restrict : Idem, mais le switch envoie une alerte (log/SNMP) et incrémente un compteur de
violations.
- Shutdown (Par défaut) : Le port se désactive immédiatement (err-disable). Il faut l'intervention
d'un technicien (shutdown puis no shutdown) pour le réactiver.
Exemple de configuration (Cisco)
Nadia veut sécuriser le port du bureau d'accueil pour qu'uniquement le PC de la réception puisse s'y
connecter :
SW1(config)# interface fastEthernet 0/5
SW1(config-if)# switchport mode access
SW1(config-if)# switchport port-security ! Active la sécurité
SW1(config-if)# switchport port-security maximum 1 ! 1 seule MAC autorisée
SW1(config-if)# switchport port-security mac-address sticky ! "Apprend" la MAC
actuelle
SW1(config-if)# switchport port-security violation shutdown ! Coupe le port en cas
d'intrusion
 L'option Sticky : L’option sticky permet au switch d’apprendre automatiquement l’adresse MAC
autorisée sur le port et de l’enregistrer dans la configuration.
Commande de vérification
show port-security interface fastEthernet 0/5 Permet de voir si le port est en "Secure-up" ou s'il
a été coupé suite à une violation.
