> **Parcours Optimus — Module 4 · Chapitre 4 sur 5**

# Organisation avancée — VLANs

**Mise en situation — Cas AéroSud** : Nadia (admin réseau, 120 employés, 4 étages) découvre qu'un stagiaire marketing a accédé aux fiches de paie de toute l'entreprise — réseau non segmenté depuis 3 ans. `show vlan brief` révèle 48 ports tous dans le VLAN 1 (réseau « plat », un seul domaine de broadcast). Second incident : les caisses du showroom tombent car un technicien R&D transfère 40 Go qui saturent tout le réseau.

## 1. Définition et intérêt des VLANs

Un VLAN (Virtual Local Area Network) est un réseau local logique créé par configuration logicielle sur un ou plusieurs switchs physiques. Sans acheter de matériel, on crée des « murs virtuels » qui isolent les flux entre services.

## 2. Les 3 piliers des VLANs

| Pilier | Bénéfice | Exemple AéroSud |
|---|---|---|
| Sécurité | Isolation par défaut entre VLANs | Le stagiaire marketing ne peut plus accéder au serveur comptabilité |
| Réduction des broadcasts | Chaque VLAN = son propre domaine de broadcast | Le transfert R&D de 40 Go ne noie plus les caisses |
| Flexibilité | Regroupement logique indépendant de la position physique | Pas besoin de tirer de nouveaux câbles |

## 3. Sans VLAN vs Avec VLAN

| Caractéristique | Sans VLAN | Avec VLAN |
|---|---|---|
| Sécurité | Faible — tout le monde voit tout | Élevée — isolation par défaut |
| Broadcast | Un seul gros domaine | Plusieurs petits domaines indépendants |
| Gestion | Physique — dépend des câbles | Logique — logicielle et flexible |
| Maintenance | Difficile — tout est lié | Facilitée — on touche un VLAN sans impacter les autres |

## 4. Ports Access et Ports Trunk

- **Port Access** : appartient à un seul VLAN, connecté à un équipement final (PC, imprimante, serveur). Trafic non taggué.

```
SW1(config)# interface range FastEthernet 0/1-12
SW1(config-if-range)# switchport mode access
SW1(config-if-range)# switchport access vlan 10
```

- **Port Trunk** : transporte le trafic de PLUSIEURS VLANs (liens inter-switch). Standard **802.1Q** : chaque trame reçoit un tag de 4 octets indiquant son VLAN.

```
SW1(config)# interface GigabitEthernet 0/1
SW1(config-if)# switchport trunk encapsulation dot1q
SW1(config-if)# switchport mode trunk
```

> Analogie du centre de tri postal : chaque colis (trame) porte une étiquette (tag VLAN) ; le convoyeur (trunk) l'achemine dans le bon bac.

## 5. Plan de VLAN — Application pratique

Numérotation par intervalles de 10 (convention pro permettant d'insérer de nouveaux VLANs).

| VLAN | Nom | Service | Ports (Switch 1) |
|---|---|---|---|
| VLAN 10 | COMPTA | Comptabilité / Finance — 1er étage | Fa0/1 → Fa0/12 |
| VLAN 20 | RD | Recherche & Développement — 2e étage | Fa0/13 → Fa0/24 |
| VLAN 30 | MARKETING | Marketing — 3e étage | Fa0/25 → Fa0/36 |
| VLAN 40 | DIRECTION | Direction — 4e étage | Fa0/37 → Fa0/42 |
| VLAN 50 | SHOWROOM | Caisses & bornes — RDC | Fa0/43 → Fa0/48 |

## 6. Séquence complète de configuration

**Étape 1 — Créer les VLANs :**

```
SW1# configure terminal
SW1(config)# vlan 10
SW1(config-vlan)# name COMPTA
SW1(config-vlan)# exit
... (idem 20/RD, 30/MARKETING, 40/DIRECTION, 50/SHOWROOM)
```

> Toujours nommer ses VLANs : sans nom, `show vlan brief` affiche `VLAN0010` au lieu de `COMPTA`.

**Étape 2 — Assigner les ports (mode Access)** : voir Port Access ci-dessus.

**Étape 3 — Configurer les trunks inter-switch** : à répéter sur CHAQUE côté du lien (4 switchs = 3 liens trunk = 6 interfaces).

**Étape 4 — Sauvegarder (INDISPENSABLE)** :

```
SW1# copy running-config startup-config
```

> Sur Cisco : la running-config est en RAM (perdue au reboot), la startup-config est en NVRAM (persistante).

**Vérification :**

| Commande | Ce qu'elle vérifie |
|---|---|
| `show vlan brief` | VLANs créés, noms, ports assignés |
| `show interfaces trunk` | Ports trunk, encapsulation 802.1Q, VLANs actifs |
| `show mac address-table` | Quelle MAC est sur quel port |
| `ping <IP_destination>` | Tester l'isolation : un ping en timeout entre deux VLANs = succès de la segmentation |

## 7. Communication inter-VLAN

Par défaut, deux VLANs ne peuvent pas communiquer. Pour autoriser des échanges contrôlés, il faut un équipement de **couche 3** :
- Un routeur (méthode « Router-on-a-stick »)
- Un switch de niveau 3 (switch L3) avec interfaces virtuelles (SVI)

> Métaphore : « Les VLANs, c'est poser les murs. Le routage inter-VLAN, c'est installer les portes à badge. »

## 8. Active Directory et les VLANs

AD gère les utilisateurs et leurs droits, les VLANs gèrent la segmentation réseau — deux couches complémentaires. Un utilisateur s'authentifie via AD, et selon son groupe AD, il peut être automatiquement placé dans le bon VLAN (ex. groupe « Comptabilité » → VLAN 10) grâce au protocole **802.1X** couplé à un serveur **RADIUS**. Sans 802.1X, l'assignation est statique (le VLAN dépend du port physique).

## 9. Sécurité des ports (Port-Security)

Restreint l'accès à un port du switch en fonction de l'adresse MAC. Première barrière contre l'intrusion physique.

**Les 3 modes de réaction (Violation) :**
- **Protect** : les paquets de l'intrus sont jetés, le port reste actif pour les autres.
- **Restrict** : idem + alerte (log/SNMP) et incrémente un compteur.
- **Shutdown (défaut)** : le port se désactive (err-disable). Réactivation manuelle nécessaire (`shutdown` puis `no shutdown`).

```
SW1(config)# interface fastEthernet 0/5
SW1(config-if)# switchport mode access
SW1(config-if)# switchport port-security
SW1(config-if)# switchport port-security maximum 1
SW1(config-if)# switchport port-security mac-address sticky
SW1(config-if)# switchport port-security violation shutdown
```

> L'option **sticky** : le switch apprend automatiquement la MAC autorisée et l'enregistre dans la configuration. Vérification : `show port-security interface fastEthernet 0/5`.

## Résumé VLANs

- Un VLAN = un réseau logique isolé sur un équipement physique.
- VLAN 1 = VLAN d'usine sur Cisco → ne jamais laisser des postes en production dessus.
- Port Access = un seul VLAN, trafic non taggué. Port Trunk = plusieurs VLANs, trafic taggué 802.1Q.
- Toujours nommer ses VLANs et sauvegarder.
- Pour faire communiquer deux VLANs → routeur ou switch L3 obligatoire.
- Les VLANs ne coûtent rien en matériel : c'est de la configuration pure.
