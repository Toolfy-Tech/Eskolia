> **Parcours Optimus** — **Module 3** · Chapitre 5 sur 5 · *Services et protocoles critiques*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

Partie 5 : Services et Protocoles Critiques

## 1. Serveur DHCP

Dynamic Host Configuration Protocol : distribue automatiquement les adresses IP et paramètres réseau (masque, passerelle, DNS). Processus DORA :

|**Étape**|**Description**|
|---|---|
|D - Discover|Le client diffuse une requête pour trouver un serveur DHCP (paquet UDP)|
|O - Offer|Le serveur propose une adresse IP avec durée de bail|
|R - Request|Le client accepte l'offre et demande à louer l'IP|
|A - Acknowledge|Le serveur confirme l'attribution de l'adresse IP|

Ports DHCP : 67 (serveur) et 68 (client)

L'adresse APIPA (Automatic Private IP Addressing) est une fonctionnalité des systèmes d'exploitation (principalement Windows) qui permet à un appareil de s'attribuer automatiquement une adresse IP lorsqu'il ne parvient pas à contacter un serveur DHCP. Les adresses APIPA appartiennent à la plage 169.254.0.0/16, souvent résumée en 169.254.x.x.

Pourquoi cela arrive ? Si vous voyez une adresse commençant par 169.254, c'est généralement le signe d'un problème réseau :
- le serveur DHCP (souvent votre box internet) est inaccessible ;
- le câble Ethernet est mal branché ou le Wi-Fi est déconnecté ;
- le service DHCP est en panne.

À quoi ça sert ? Communication locale : elle permet à deux ordinateurs reliés par un simple câble de communiquer entre eux sans configuration manuelle. Diagnostic : elle sert d'indicateur visuel pour savoir que l'ordinateur cherche une IP mais n'en reçoit aucune.

Limite : pas d'Internet (pas de passerelle par défaut). Les communications restent locales.

En résumé : si votre PC affiche une adresse en 169.254.x.x, c'est qu'il est "en mode secours" car il n'a pas réussi à obtenir de configuration réseau valide.

## 2. Serveur DNS

Convertit les noms de domaine en adresses IP. Hiérarchie :

|**Niveau**|**Exemple**|
|---|---|
|Domaine racine|.|
|Domaine de premier niveau (TLD)|.fr .com .org|
|Domaine de second niveau|wikipedia|
|Sous-domaine|fr (→ fr.wikipedia.org)|

Fonctionnement : fr.wikipedia.org → DNS récursif → DNS racine → DNS .org → DNS wikipedia.org → adresse IP
Port DNS : 53

## 3. Pare-feu (Firewall)

Un pare-feu est un équipement (matériel ou logiciel) qui contrôle et filtre le trafic réseau entrant et sortant selon un ensemble de règles définies par l'administrateur.

Principe de base : le pare-feu analyse chaque paquet et décide de l'autoriser (PERMIT) ou de le bloquer (DENY) selon :
- l'adresse IP source et/ou destination ;
- le numéro de port ;
- le protocole (TCP, UDP, ICMP...) ;
- la direction du trafic (entrant/sortant).

Exemple vu dans le cours Aérotec : TCP/8080 autorisé mais TCP/9090 bloqué. Résultat : ERP inaccessible depuis les postes de l'atelier, même si le routage était fonctionnel.

Stateless vs Stateful :

|**Type**|**Fonctionnement**|**Avantage**|**Inconvénient**|**Exemple**|
|---|---|---|---|---|
|Stateless (sans état)|Analyse chaque paquet sans mémoire de connexion|Très rapide, peu gourmand|Ne voit pas le contexte|ACL Cisco classique (access-list)|
|Stateful (avec état)|Suit l'état des connexions TCP|Plus intelligent, meilleure sécurité|Plus gourmand en ressources|Cisco ASA, pfSense, pare-feu Windows|

💡 Analogie : Stateless = vigile qui vérifie chaque carte d'entrée sans mémoire. Stateful = vigile qui tient un registre.

Règle d'or : principe du moindre privilège (whitelist).

Cisco — exemple de règles ACL stateless :
`access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 9090`
`access-list 101 deny ip any any` (bloque tout le reste)

## 4. Configuration d'un routeur

Accéder à l'interface d'un routeur inconnu :

- Brancher le routeur à l'ordinateur via un câble RJ45 (port LAN)
- Le routeur attribue automatiquement une IP via son DHCP (vérifier avec `ipconfig`)
- Si pas de DHCP : configurer une IP fixe dans le même sous-réseau (ex : 192.168.1.50 si routeur en 192.168.1.1)

Commandes utiles (Windows) :
- `ipconfig /release` -> libère l'adresse IP actuelle
- `ipconfig /renew` -> demande une nouvelle IP via DHCP
- `ipconfig` -> affiche IP, masque, passerelle

Trouver l'adresse de l'interface web :
- Regarder la passerelle par défaut dans `ipconfig`
- Adresses courantes : 192.168.0.1 / 192.168.1.1
- Identifiants par défaut : admin/admin (à changer immédiatement)

Paramètres essentiels à configurer :
- SSID et mot de passe Wi-Fi (WPA2 minimum, WPA3 si disponible)
- Mode Wi-Fi (routeur / point d'accès / répéteur)
- DHCP (plage d'adresses, durée de bail)
- NAT/PAT (règles de redirection)
- DNS et paramètres WAN
- Désactiver WPS

5. NAT / PAT — Redirection de ports (Port Forwarding)

- NAT : traduit IP privée <-> IP publique.
- PAT : version NAT avec ports, permettant la redirection vers une machine interne.

Exemple GLPI :
Port externe WAN `4444` -> machine interne `192.168.1.10:443`.

Trouver son IP publique : `monip.org` ou `whatismyip.com`.

## 6. DMZ — Zone démilitarisée

La DMZ est une zone réseau isolée entre Internet et le réseau interne.

| | DMZ | NAT/PAT |
|---|---|---|
|Exposition|Totale (tous ports)|Ciblée (ports choisis)|
|Sécurité|Faible|Meilleure|
|Usage|Serveur web public, reverse proxy|Accès ciblé (GLPI, RDP...)|

Préférer NAT/PAT ciblé sauf cas très spécifique.

## 7. SSH — Accès à distance sécurisé

SSH (Secure Shell) permet d'administrer un équipement à distance en ligne de commande, avec chiffrement (contrairement à Telnet).

Port : 22 (TCP)

Deux modes d'authentification :

|Mode|Fonctionnement|Sécurité|
|---|---|---|
|Par mot de passe|Login + mot de passe|Correct mais vulnérable au brute-force|
|Par clé (recommandé)|Paire clé publique/privée|Élevée|

Commandes essentielles :
- `ssh admin@192.168.1.1`
- `ssh -p 2222 admin@192.168.1.1`
- `exit`

Configuration Cisco :
`Router(config)# hostname RTR-Principal`
`Router(config)# ip domain-name aerosud.local`
`Router(config)# crypto key generate rsa modulus 2048`
`Router(config)# ip ssh version 2`
`Router(config)# line vty 0 4`
`Router(config-line)# transport input ssh`
`Router(config-line)# login local`

Telnet vs SSH : Telnet (port 23) envoie les mots de passe en clair, SSH est le remplacement recommandé.

## 8. Commandes réseau essentielles

|**Commande**|**Description**|
|---|---|
|ipconfig|Afficher la configuration réseau (IP, masque, passerelle, DNS)|
|ipconfig /all|Version détaillée avec adresse MAC, serveur DHCP, etc.|
|ipconfig /release|Abandonne l'adresse IP actuelle|
|ipconfig /renew|Demande une nouvelle adresse IP|
|ping [IP/site]|Tester la connectivité et la latence|
|tracert [IP/site]|Tracer le chemin d'un paquet|
|Pathping [IP/site]|Combine Ping et Tracert|
|netstat -an|Lister les ports ouverts et connexions actives|
|arp -a|Afficher le cache ARP|
|nslookup [nom]|Tester la résolution DNS|
|test-netconnexion|Tester la connectivité réseau|
|systeminfo|Lister la configuration machine/réseau|
|netstat|Connexions actives et ports utilisés|

Diagnostic terrain (ordre) :
1) `ping 127.0.0.1` -> pile IP locale
2) ping passerelle -> LAN
3) `ping 8.8.8.8` -> Internet
4) ping nom de domaine -> DNS

## FICHE RECAPITULATIVE — ERREURS COURANTES RESEAU

IP · DHCP · DNS · VLAN · OSI · Wi-Fi · Depannage

### Erreurs critiques

1. Wi-Fi ≠ Ethernet
2. IP 169.254.x.x (APIPA)

3. Ping ≠ Appli OK
4. Passerelle oubliée

5. VLAN sans routage

### Erreurs fréquentes

6. Switch vs Routeur
7. SSID masqué ≠ sécurité

8. Filtrage MAC ≠ sécurité
9. WPA2 "cassé" ? (faux)

### Erreurs de méthode réseau (OSI)

10. Ordre OSI non respecté
11. Chercher trop haut trop vite

12. Ports et protocoles oubliés

## QUIZZ Réseau

1. Une adresse commençant par 169.254.X.X indique : A/B/C
2. Équipement couche 2 utilisant MAC : A/B/C

3. Utilité principale d'un VLAN : A/B/C
4. Ping OK mais google.fr KO : A/B/C

5. Port HTTPS : A/B/C
6. `ipconfig /release` sert à : A/B/C

7. CIDR pour 255.255.255.0 : A/B/C
8. Couche OSI du routage IP : A/B/C

9. "Couche 8" : A/B/C
10. Commande Cisco pour VLANs : A/B/C

Correction : 1-B | 2-B | 3-B | 4-B | 5-C | 6-B | 7-C | 8-B | 9-B | 10-B
