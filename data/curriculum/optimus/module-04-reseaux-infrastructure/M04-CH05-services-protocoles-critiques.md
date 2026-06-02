> **Parcours Optimus — Module 4 · Chapitre 5 sur 5**

# Services et protocoles critiques

## 1. Serveur DHCP

Distribue automatiquement les adresses IP et paramètres réseau. Processus **DORA** :

| Étape | Description |
|---|---|
| **D** - Discover | Le client diffuse une requête pour trouver un serveur DHCP (paquet UDP) |
| **O** - Offer | Le serveur propose une adresse IP avec durée de bail |
| **R** - Request | Le client accepte l'offre et demande à louer l'IP |
| **A** - Acknowledge | Le serveur confirme l'attribution |

Ports DHCP : **67 (serveur) et 68 (client)**.

**APIPA (Automatic Private IP Addressing)** : si un appareil ne parvient pas à contacter un serveur DHCP, il s'attribue automatiquement une adresse de la plage **169.254.0.0/16** (169.254.x.x). C'est le signe d'un problème réseau (DHCP inaccessible, câble débranché, Wi-Fi déconnecté, service DHCP en panne). Permet la communication locale uniquement, pas d'Internet (pas de passerelle). « Mode secours » du PC.

## 2. Serveur DNS

Convertit les noms de domaine en adresses IP. Hiérarchie :

| Niveau | Exemple |
|---|---|
| Domaine racine | . |
| TLD (premier niveau) | .fr .com .org |
| Second niveau | wikipedia |
| Sous-domaine | fr (→ fr.wikipedia.org) |

Fonctionnement : `fr.wikipedia.org` → DNS récursif → DNS racine → DNS .org → DNS wikipedia.org → adresse IP. Port DNS : **53**.

## 3. Pare-feu (Firewall)

Équipement (matériel ou logiciel) qui contrôle et filtre le trafic entrant/sortant selon des règles. Analyse chaque paquet et l'autorise (PERMIT) ou le bloque (DENY) selon : IP source/destination, numéro de port, protocole (TCP/UDP/ICMP), direction.

**Stateless vs Stateful :**

| Type | Fonctionnement | Avantage | Inconvénient | Exemple |
|---|---|---|---|---|
| Stateless (sans état) | Analyse chaque paquet indépendamment, sans mémoire | Très rapide, peu gourmand | Ne voit pas le contexte | ACL Cisco classique (access-list) |
| Stateful (avec état) | Suit l'état de chaque connexion TCP. Autorise automatiquement les réponses aux connexions initiées de l'intérieur | Plus intelligent, meilleure sécurité | Plus gourmand (table de connexions) | Cisco ASA, pfSense, pare-feu Windows |

> Analogie : Stateless = vigile qui vérifie chaque carte sans mémoire. Stateful = vigile qui tient un registre.

**Règle d'or** : principe du moindre privilège. On autorise uniquement le nécessaire (whitelist), on bloque tout le reste par défaut.

```
access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 9090
access-list 101 deny ip any any   ← bloque tout le reste
```

## 4. Configuration d'un routeur

**Accéder à l'interface d'un routeur inconnu :**
- Brancher le routeur via un câble RJ45 (port LAN). Le routeur attribue une IP via son DHCP → vérifier avec `ipconfig`.
- Si pas de DHCP : configurer une IP fixe dans le même sous-réseau (ex : 192.168.1.50 si le routeur est en 192.168.1.1).
- Trouver l'interface web : regarder la Passerelle par défaut dans `ipconfig` → taper cette adresse dans le navigateur. Adresses courantes : 192.168.0.1 / 192.168.1.1. Identifiants par défaut : admin / admin (à changer immédiatement).

```
ipconfig /release   → Libère l'adresse IP actuelle
ipconfig /renew     → Demande une nouvelle IP via DHCP
ipconfig            → Affiche IP, masque, passerelle
```

**Paramètres essentiels** : SSID + mot de passe Wi-Fi (WPA2 min, WPA3 si dispo) ; mode Wi-Fi (routeur / AP / répéteur) ; DHCP ; NAT/PAT (redirection de ports) ; DNS et WAN ; désactiver le WPS.

## 5. NAT / PAT — Redirection de ports (Port Forwarding)

- **NAT** : traduit une IP privée en IP publique. Permet à tout un réseau local de sortir avec une seule IP publique.
- **PAT** : version du NAT incluant les numéros de port. Permet de rediriger un port public précis vers une machine interne.

**Exemple** : rendre un serveur GLPI accessible depuis Internet. Règle PAT : Port externe (WAN) 4444 → machine interne 192.168.1.10:443. En tapant `IP_publique:4444` on arrive sur le serveur GLPI.

Trouver son IP publique : monip.org ou whatismyip.com.

## 6. DMZ — Zone démilitarisée

Zone réseau isolée entre Internet et le réseau interne. Expose un serveur à Internet sans mettre en danger le reste.

| | DMZ | NAT/PAT |
|---|---|---|
| Exposition | Totale (tous ports ouverts) | Ciblée (un ou plusieurs ports) |
| Sécurité | Faible | Meilleure |
| Usage | Serveur web public, reverse proxy | Accès distant ciblé (GLPI, RDP…) |

> Placer un serveur en DMZ l'expose à TOUT Internet sur TOUS les ports. Préférer le NAT/PAT ciblé sauf cas spécifique.

## 7. SSH — Accès à distance sécurisé

SSH (Secure Shell) administre à distance un équipement (routeur, switch, serveur Linux) en ligne de commande. Chiffre intégralement la communication (contrairement à Telnet, en clair). Port : **22 (TCP)**.

| Mode | Fonctionnement | Sécurité |
|---|---|---|
| Par mot de passe | Login + mot de passe à chaque connexion | Correct mais vulnérable au brute-force |
| Par clé (recommandé) | Paire clé publique / clé privée (la privée ne quitte jamais le client) | Élevée |

```
ssh admin@192.168.1.1            → Connexion SSH
ssh -p 2222 admin@192.168.1.1    → SSH sur un port non standard
exit                             → Fermer la session
```

Configuration SSH sur Cisco :

```
Router(config)# hostname RTR-Principal
Router(config)# ip domain-name aerosud.local
Router(config)# crypto key generate rsa modulus 2048
Router(config)# ip ssh version 2
Router(config)# line vty 0 4
Router(config-line)# transport input ssh
Router(config-line)# login local
```

> Telnet (port 23) envoie les mots de passe en clair. SSH est son remplacement obligatoire. En production, utiliser Telnet est une faute professionnelle. Couplé à un **jump server (bastion SSH)**, SSH sécurise tous les accès d'administration depuis un point unique.

## 7 (bis). VPN — configuration de l'accès distant (côté client)

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Le **VPN (Virtual Private Network)** crée un **tunnel chiffré** entre l'appareil de l'utilisateur et le réseau de l'entreprise, à travers Internet. Une fois connecté, le poste se comporte comme s'il était physiquement dans les locaux : il accède aux serveurs, partages et applications internes, et son trafic est protégé contre l'interception. C'est la solution standard du **télétravail** et des interventions à distance. Configurer le client VPN sur le poste de l'utilisateur est une tâche courante du technicien.

**Les deux usages à distinguer :**

| Type | Principe | Usage |
|---|---|---|
| **VPN nomade** (client-à-site) | Un poste isolé se connecte au réseau de l'entreprise | Télétravail, déplacement |
| **VPN site-à-site** | Tunnel permanent entre deux réseaux (deux sites) | Relier deux agences en continu |

Le technicien de proximité configure surtout le **VPN nomade** côté poste utilisateur.

**Protocoles courants :** **IPsec**, **OpenVPN**, **WireGuard** (moderne, rapide), et **L2TP/IPsec**. Le choix et les paramètres sont fournis par l'administrateur réseau.

**Configurer un client VPN — démarche type :**

1. Récupérer auprès de l'administrateur : le **type/protocole**, l'**adresse du serveur VPN** (IP ou nom de domaine public de l'entreprise), et les **identifiants** (login/mot de passe, certificat, ou fichier de configuration `.ovpn`).
2. Installer le **client** adapté (client VPN natif Windows, ou logiciel éditeur : OpenVPN Connect, FortiClient, Cisco AnyConnect...).
3. Saisir les paramètres (ou importer le fichier de configuration fourni).
4. Activer le **MFA** si l'entreprise l'impose (cf. Module 6).
5. Se connecter, puis **tester l'accès** à une ressource interne (partage, intranet) pour valider.

*Sous Windows, un VPN simple s'ajoute via :* Paramètres → Réseau et Internet → VPN → Ajouter un VPN (nom de connexion, serveur, type, identifiants).

> **Réflexe terrain** : « le VPN ne connecte pas » → vérifier dans l'ordre : connexion Internet du poste OK ? adresse du serveur VPN correcte ? identifiants/certificat valides (non expirés) ? MFA validé ? Et côté entreprise, le **pare-feu** autorise-t-il le port du VPN ? Une fois connecté mais « pas d'accès aux serveurs » : souvent un problème de **route** ou de **DNS** poussé par le VPN (cf. passerelle/DNS, Partie 2).

> **À retenir — VPN client**
> - Tunnel chiffré → le poste distant accède au réseau interne comme s'il était sur place.
> - Nomade (un poste → l'entreprise) vs site-à-site (deux réseaux reliés en permanence).
> - Toujours **tester l'accès à une ressource interne** après connexion.
> - Le VPN protège aussi les accès sensibles : **ne jamais exposer RDP directement sur Internet**, le faire passer par le VPN (cf. Module 6).

## 8. Commandes réseau essentielles

| Commande | Description |
|---|---|
| `ipconfig` | Configuration réseau (IP, masque, passerelle, DNS) |
| `ipconfig /all` | Version détaillée (MAC, serveur DHCP, etc.) |
| `ipconfig /release` | Abandonne l'adresse IP actuelle |
| `ipconfig /renew` | Demande une nouvelle IP via DHCP |
| `ping [IP/site]` | Teste la connectivité et la latence (ms) |
| `tracert [IP/site]` | Trace le chemin saut par saut |
| `pathping [IP/site]` | Combine Ping et Tracert |
| `netstat -an` | Liste les ports ouverts et connexions actives |
| `arp -a` | Affiche le cache ARP (table IP ↔ MAC) |
| `nslookup [nom]` | Teste la résolution DNS |
| `Test-NetConnection` | Teste la connectivité réseau (PowerShell) |
| `systeminfo` | Configurations machine et réseau |

> Diagnostic terrain, dans l'ordre : 1) `ping 127.0.0.1` (pile IP locale ?) → 2) `ping passerelle` (LAN ?) → 3) `ping 8.8.8.8` (Internet ?) → 4) `ping google.fr` (DNS ?).

## 8 (bis). Documenter le réseau

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

Déployer un réseau ne suffit pas : il faut **maintenir sa documentation à jour**. Un réseau non documenté devient ingérable dès qu'une panne survient ou qu'un autre technicien doit intervenir.

Ce qu'on documente : le **plan d'adressage IP** (plages, VLANs, IP fixes des équipements), le **schéma réseau** (topologie, équipements, liaisons), l'**inventaire des équipements** (switchs, routeurs, AP — modèle, emplacement, configuration), le **plan de câblage** et l'**étiquetage** des prises/baies de brassage, ainsi que les **identifiants et configurations** (de façon sécurisée).

> **Réflexe terrain** : une baie de brassage et des prises murales **étiquetées** font gagner un temps considérable en intervention. Mettre à jour la documentation **après chaque modification** (et non « plus tard ») : une doc fausse est pire qu'une doc absente, car elle induit en erreur.

## Fiche récapitulative — Erreurs courantes réseau

**Erreurs critiques :**
1. **Wi-Fi ≠ Ethernet** : Wi-Fi = débit partagé/interférences ; Ethernet = débit dédié/stable. Tout ce qui ne bouge pas → câble.
2. **IP 169.254.x.x** : APIPA → DHCP inaccessible (pas « Internet lent »).
3. **Ping ≠ Appli OK** : Ping = ICMP (L3) ; Application = TCP/UDP (L4+). Tester aussi les ports.
4. **Passerelle oubliée** : IP + masque + DNS OK mais pas de gateway = pas d'Internet. Vérifier `ipconfig /all`.
5. **VLAN sans routage** : VLAN = isolement logique, pas de communication auto. Inter-VLAN = routeur ou switch L3.

**Erreurs fréquentes :**
6. **Switch (couche 2/MAC) vs Routeur (couche 3/IP)** : identifier le matériel d'abord.
7. **SSID masqué ≠ sécurité** : un scanner détecte quand même. Utiliser WPA2/WPA3 + mot de passe fort.
8. **Filtrage MAC ≠ sécurité** : une MAC se spoofe. Couche complémentaire seulement.
9. **WPA2 « cassé » ?** : faux, WPA2 reste sûr avec mot de passe fort, mais peu adapté à l'entreprise (secret partagé). WPA3 = meilleur, pas obligatoire partout.

**Méthode OSI :**
10. **Ordre OSI non respecté** : méthode jury attendue (1→Câble/LED/alim ; 2→MAC/switch ; 3→IP/gateway/ping ; 4→Ports ; 5+→Application).
11. **Chercher trop haut trop vite** : 50 % des pannes = Couche 1. Vérifier le physique d'abord.
12. **Ports/protocoles oubliés** : HTTPS (443) ≠ HTTP (80) ; DNS (53) ≠ DHCP (67/68) ; TCP (fiable) ≠ UDP (rapide).
