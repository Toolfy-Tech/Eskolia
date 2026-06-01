> **Parcours Optimus** — **Module 3** · Chapitre 2 sur 5 · *Adressage et segmentation*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

Partie 2 : Adressage et segmentation

1. Classes d'adresses IP

### 1.1. IPv4

|**Classe**|**Plage publique**|**Plage privée**|**Masque par défaut**|
|---|---|---|---|
|A|1.0.0.0 → 126.255.255.255|10.0.0.0 → 10.255.255.255|/8|
|B|128.0.0.0 → 191.255.255.255|172.16.0.0 → 172.31.255.255|/16|
|C|192.0.0.0 → 223.255.255.255|192.168.0.0 → 192.168.255.255|/24|
|D & E|224.0.0.0 → 255.255.255.255|—|Réservées|

Adresse loopback/localhost : 127.0.0.1 (réservée pour tester la pile réseau locale).
Ces classes sont obsolètes depuis 1993 au profit du CIDR (le fameux /24) voir ci-dessous. Aujourd'hui,
on ne regarde plus la classe (A, B, C) pour définir le masque, on regarde le préfixe.

### 1.2. IPv6 — L'adressage de demain

IPv4 est un nombre d'une valeur de 32 bits représentée par 4 valeurs décimales pointées ;
chacune a un poids de 8 bits (1 octet) prenant des valeurs décimales de 0 à 255 séparées par
des points. Soit environ 4,3 milliards d'adresses. Ce stock est épuisé depuis 2011. IPv6 résout ce
problème définitivement en utilisant 128 bits.

Format IPv6 : 8 groupes de 4 chiffres hexadécimaux séparés par des deux-points.

- Forme longue : 2001:0db8:0000:0000:0000:0000:0000:0001
- Règle de simplification : les groupes de zéros consécutifs peuvent être remplacés par ::

(une seule fois par adresse)
- Forme simplifiée : 2001:db8::1
- Une adresse IPv6 = 128 bits → 340 sextillions d'adresses disponibles

|**Caractéristique**|**IPv4**|**IPv6**|
|---|---|---|
|Taille de l'adresse|32 bits|128 bits|
|Exemple|192.168.1.1|2001:db8::1|
|Adresses disponibles|~4,3 milliards|340 sextillions|
|NAT nécessaire ?|Oui (pénurie)|Non — assez d'adresses publiques pour chaque appareil|
|Config. automatique|DHCP|SLAAC (auto-configuration native, sans serveur)|
|Déploiement|Standard dominant|Remplacement progressif d'IPv4|

💡 Avec IPv6, le NAT devient inutile : chaque appareil peut avoir sa propre adresse publique
mondiale. La coexistence IPv4/IPv6 (mode dual-stack) est aujourd'hui la norme sur les
équipements récents.

## 2. Masque de sous-réseau et calculs

### 2.1. Masque de sous-réseau et calculs

Le masque sert à identifier la partie réseau (Net ID) et la partie hôte (Host ID) d'une adresse IP.
Méthode ET logique : 1 ET 1 = 1 / 0 ET 1 = 0 / 1 ET 0 = 0 / 0 ET 0 = 0
Exemple complet avec 192.168.1.2 /24 :

- **Étape** | **Calcul** | **Résultat**
- Adresse IP en binaire | 192.168.1.2 | 11000000.10101000.00000001.00000010
- Masque en binaire | 255.255.255.0 | 11111111.11111111.11111111.00000000
- Adresse réseau (ET logique) | 11000000.10101000.00000001.00000000 → 192.168.1.0
- Adresse broadcast | Remplacer 0 hôte par des 1 | 11000000.10101000.00000001.11111111 → 192.168.1.255
- 1ère IP utilisable | Adresse réseau + 1 | 192.168.1.1
- Dernière IP utilisable | Broadcast - 1 | 192.168.1.254
- Nombre d'hôtes | 2⁸ - 2 = 254 | 254 IP adressables

Notation CIDR : 192.168.0.133/24 → nombre d'hôtes = 2^(32-24) - 2 = 254

Tuto calcul binaire/broadcast/plage adressable

IP + masque : 192.168.1.2 /24
Convertir en binaire l’adresse IP :
192.168.1.2 → 11000000.10101000.00000001.00000010
Convertir en binaire le masque sous-réseau :
255.255.255.0 → 11111111.11111111.11111111.00000000
 [
 Net-ID Réseau ][ Host-ID Hôte ]
Pour déterminer le nombre d’hôtes possibles, il suffit d’élever 2 à la puissance du nombre de
## 0. de la partie hôte :

ici le nombre de 0 est de 8, cela nous donne donc 2⁸ soit 256 hôtes (bien sûr le nombre d’IP
adressable est égal à ce nombre -2, car on enlève l’adresse du réseau et du broadcast qui sont
réservés soit 256-2=254 IPs adressables)
Déterminer l’adresse réseau :
Faire un ET logique entre l’ip en binaire et le masque de sous-réseau en binaire :
(1 ET 0 =0
0. ET 1=0

0. ET 0=0
1. ET 1=1)
11000000.10101000.00000001.00000010
ET
11111111.11111111.11111111.00000000
-→
11000000.10101000.00000001.00000000 ← adresse du réseau → 192.168.1.0
Déterminer l’adresse Broadcast :
Remplacer tous les 0 (de la partie HOTE de l’adresse réseau) par des 1 nous donne l’adresse
du broadcast :
11000000.10101000.00000001.00000000
11000000.10101000.00000001.11111111 ← adresse du broadcast → 192.168.1.255
L’adresse du réseau (192.168.1.0) et l’adresse du broadcast (192.168.1.255) nous permettent
de déterminer la plage d’IP adressable :

1er IP adressable : 192.168.1.1 (l’adresse du réseau +1)
dernière IP adressable : 192.168.1.254 (l’adresse du broadcast -1)
(Tuto de Matthieu)

### 2.1. Notation CIDR

Le CIDR (Classless Inter-Domain Routing) est une méthode d'adressage IP qui remplace l'ancien système
rigide des classes (A, B, C) par une approche plus flexible. Il utilise une notation simplifiée appelée
"préfixe" (ex: /24), qui indique précisément le nombre de bits réservés à la partie réseau de l'adresse. Cette
technique permet d'optimiser l'utilisation des adresses IP en créant des sous-réseaux de tailles sur mesure,
évitant ainsi le gaspillage inutile d'adresses.
Grâce au CIDR, les routeurs Internet peuvent regrouper plusieurs routes en une seule (agrégation de
routes), ce qui allège considérablement la taille des tables de routage mondiales. C'est aujourd'hui le
standard universel qui permet de calculer dynamiquement le masque de sous-réseau et d'étendre la durée
de vie du protocole IPv4.
Le CIDR (Classless Inter-Domain Routing) remplace l'ancien système rigide des classes par une
approche flexible. Le préfixe (ex: /24) indique le nombre de bits réservés à la partie réseau. Grâce
au CIDR, les routeurs peuvent regrouper plusieurs routes en une seule (agrégation), ce qui allège
les tables de routage mondiales.

### 2.2. Découpage en Sous-Réseaux

![Image 13](../images/image_013.png)

![Image 14](../images/image_014.png)

![Image 15](../images/image_015.png)

![Image 16](../images/image_016.png)

![Image 17](../images/image_017.png)

![Image 18](../images/image_018.png)

(Notes de William)

### 2.3. Route par défaut (Default Route)

✅ La route par défaut 0.0.0.0/0 est le filet de sécurité du routage.

Dans une table de routage, un routeur cherche la route la plus précise correspondant à l'IP
destination. Si aucune route spécifique ne correspond, il utilise la route par défaut.

0.0.0.0/0 = Default Route : cette notation signifie littéralement "toutes les destinations". C'est le
préfixe le moins spécifique possible (longueur de préfixe = 0). Tout paquet qui ne correspond à
aucune route plus précise est envoyé vers cette passerelle.

|**Route**|**Signification**|**Exemple d'usage**|
|---|---|---|
|10.10.20.0/24|Route spécifique : uniquement le réseau 10.10.20.0|Réseau de l'atelier|
|10.10.50.0/24|Route spécifique : uniquement le réseau 10.10.50.0|Réseau des serveurs|
|0.0.0.0/0|Default route : TOUT le reste (catch-all)|Route vers Internet (via le FAI)|

Routeur# show ip route
C 10.10.20.0/24 via Gi0/0 ← réseau local atelier
C 10.10.50.0/24 via Gi0/1 ← réseau serveurs
S* 0.0.0.0/0 via 91.200.1.1 ← default route (vers Internet)

💡 Sur un PC Windows, la "Default Gateway" configurée manuellement ou par DHCP est
l'équivalent de la default route : tout ce qui n'est pas local est envoyé vers cette adresse.
