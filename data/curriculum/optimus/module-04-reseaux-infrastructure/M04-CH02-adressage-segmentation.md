> **Parcours Optimus — Module 4 · Chapitre 2 sur 5**

# Adressage et segmentation réseau

## 1. Classes d'adresses IP

### 1.1 IPv4

| Classe | Plage publique | Plage privée | Masque par défaut |
|---|---|---|---|
| A | 1.0.0.0 → 126.255.255.255 | 10.0.0.0 → 10.255.255.255 | /8 |
| B | 128.0.0.0 → 191.255.255.255 | 172.16.0.0 → 172.31.255.255 | /16 |
| C | 192.0.0.0 → 223.255.255.255 | 192.168.0.0 → 192.168.255.255 | /24 |
| D & E | 224.0.0.0 → 255.255.255.255 | — | Réservées |

Adresse **loopback/localhost** : 127.0.0.1 (réservée pour tester la pile réseau locale). Ces classes sont obsolètes depuis 1993 au profit du **CIDR** (le fameux /24). Aujourd'hui, on regarde le préfixe, pas la classe.

### 1.2 IPv6 — L'adressage de demain

IPv4 = 32 bits (4 valeurs décimales pointées de 0 à 255), soit ~4,3 milliards d'adresses (stock épuisé depuis 2011). IPv6 utilise 128 bits.

Format IPv6 : 8 groupes de 4 chiffres hexadécimaux séparés par des deux-points.
- Forme longue : `2001:0db8:0000:0000:0000:0000:0000:0001`
- Simplification : les groupes de zéros consécutifs remplacés par `::` (une seule fois par adresse)
- Forme simplifiée : `2001:db8::1`
- 128 bits → 340 sextillions d'adresses

| Caractéristique | IPv4 | IPv6 |
|---|---|---|
| Taille | 32 bits | 128 bits |
| Exemple | 192.168.1.1 | 2001:db8::1 |
| Adresses disponibles | ~4,3 milliards | 340 sextillions |
| NAT nécessaire ? | Oui (pénurie) | Non |
| Config. automatique | DHCP | SLAAC (auto-config native, sans serveur) |
| Déploiement | Standard dominant | Remplacement progressif |

> Avec IPv6, le NAT devient inutile. La coexistence IPv4/IPv6 (mode dual-stack) est la norme sur les équipements récents.

## 2. Masque de sous-réseau et calculs

Le masque sert à identifier la partie réseau (Net ID) et la partie hôte (Host ID).

**Méthode ET logique** : 1 ET 1 = 1 / 0 ET 1 = 0 / 1 ET 0 = 0 / 0 ET 0 = 0

**Exemple complet avec 192.168.1.2 /24 :**

| Étape | Calcul | Résultat |
|---|---|---|
| Adresse IP en binaire | 192.168.1.2 | 11000000.10101000.00000001.00000010 |
| Masque en binaire | 255.255.255.0 | 11111111.11111111.11111111.00000000 |
| Adresse réseau (ET logique) | | 11000000.10101000.00000001.00000000 → 192.168.1.0 |
| Adresse broadcast | Remplacer 0 hôte par des 1 | 11000000.10101000.00000001.11111111 → 192.168.1.255 |
| 1ère IP utilisable | Adresse réseau + 1 | 192.168.1.1 |
| Dernière IP utilisable | Broadcast - 1 | 192.168.1.254 |
| Nombre d'hôtes | 2⁸ - 2 = 254 | 254 IP adressables |

Notation CIDR : `192.168.0.133/24` → nombre d'hôtes = 2^(32-24) - 2 = 254.

## 2.2 Notation CIDR

Le **CIDR (Classless Inter-Domain Routing)** remplace l'ancien système rigide des classes (A, B, C) par une approche flexible. Le **préfixe** (ex : /24) indique le nombre de bits réservés à la partie réseau. Grâce au CIDR, les routeurs peuvent regrouper plusieurs routes en une seule (**agrégation de routes**), allégeant les tables de routage mondiales. Standard universel qui permet de calculer dynamiquement le masque et d'étendre la durée de vie d'IPv4.

## 2.3 Découpage en sous-réseaux (exemple 44.224.191.17 /15)

Objectif : créer **32 sous-réseaux**.

**Étape 1 — Bits à emprunter** : chercher n tel que 2ⁿ ≥ 32. 2⁵ = 32 → **n = 5 bits**. Règle : prendre toujours la puissance de 2 supérieure ou égale au nombre de sous-réseaux voulus.
Masque actuel /15 + 5 bits empruntés = **nouveau masque /20**.

**Étape 2 — Nouveau masque /20** : 20 premiers bits à 1, 12 suivants à 0 → `11111111.11111111.11110000.00000000` = **255.255.240.0**. (3e octet : 4 bits à 1 + 4 bits à 0 = 11110000 = 240.)

**Étape 3 — Adresse réseau (ET logique)** : appliquer le masque sur l'IP → adresse réseau de départ confirmée : **44.224.0.0/20**.

**Étape 4 — Calcul du pas (incrément)** : le pas = poids du dernier bit à 1 dans le masque /20 (3e octet = 240). Dernier bit à 1 en position 4 → **poids = 16**. Vérification : 256 - 240 = 16. **PAS = 16**. Hôtes/sous-réseau = 2¹² - 2 = **4094 hôtes**.

**Étape 5 — Tableau des sous-réseaux** : le pas de 16 fait « sauter » de 16 dans le 3e octet (0, 16, 32, 48 … jusqu'à 240). Quand l'octet dépasse 255, on incrémente le 2e octet (224 → 225).

| # | Adresse réseau | 1ère adresse utile | Dernière adresse utile | Broadcast |
|---|---|---|---|---|
| SR 1 | 44.224.0.0/20 | 44.224.0.1 | 44.224.15.254 | 44.224.15.255 |
| SR 2 | 44.224.16.0/20 | 44.224.16.1 | 44.224.31.254 | 44.224.31.255 |
| SR 3 | 44.224.32.0/20 | 44.224.32.1 | 44.224.47.254 | 44.224.47.255 |
| ... | ... | ... | ... | ... |
| SR 31 | 44.225.224.0/20 | 44.225.224.1 | 44.225.239.254 | 44.225.239.255 |
| SR 32 | 44.225.240.0/20 | 44.225.240.1 | 44.225.255.254 | 44.225.255.255 |

> Pourquoi 224 → 225 au SR17 ? Après SR16, le 3e octet atteindrait 240 + 16 = 256 (dépasse 255). On le remet à 0 et on incrémente le 2e octet : 224 → 225.

## 2.4 Route par défaut (Default Route)

Dans une table de routage, un routeur cherche la route la plus précise correspondant à l'IP destination. Si aucune ne correspond, il utilise la route par défaut. `0.0.0.0/0` = **Default Route** : « toutes les destinations », préfixe le moins spécifique possible.

| Route | Signification | Exemple d'usage |
|---|---|---|
| 10.10.20.0/24 | Route spécifique | Réseau de l'atelier |
| 10.10.50.0/24 | Route spécifique | Réseau des serveurs |
| 0.0.0.0/0 | Default route (catch-all) | Route vers Internet (via le FAI) |

```
Routeur# show ip route
C  10.10.20.0/24 via Gi0/0   ← réseau local atelier
C  10.10.50.0/24 via Gi0/1   ← réseau serveurs
S* 0.0.0.0/0     via 91.200.1.1  ← default route (vers Internet)
```

> Sur un PC Windows, la « Default Gateway » (manuelle ou DHCP) est l'équivalent de la default route.
