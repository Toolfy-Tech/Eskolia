<!-- page 1 -->

COURS TIP

METTRE EN SERVICE DES EQUIPEMENTS NUMERIQUES ET ASSURER LE 
SUPPORT UTILISATEUR

MODULE 1 : HARDWARE & ARCHITECTURE DES 
SYSTEMES INFORMATIQUES 
Dans le système informatique on distingue :

• 
Le matériel ou hardware 
• 
Le logiciel ou software 
On distingue également les périphériques d’entrée : clavier, souris, manette, caméra, microphone. Les 
périphériques de sortie : écran, imprimante, haut-parleurs, casque audio. Certains périphériques sont 
mixtes (entrée/sortie) : par exemple un casque-micro. 
 
0. Les boîtiers  
Le choix d'un boîtier repose sur trois critères majeurs :

• 
L'ergonomie et le design : Encombrement sur le bureau et esthétique. 
• 
La compatibilité matérielle : Il doit pouvoir accueillir la taille de la carte mère, la longueur de la 
carte graphique et la hauteur du refroidisseur CPU. 
• 
Le flux d'air (Airflow) : Le flux d’air (airflow) correspond à la capacité du boîtier à évacuer 
efficacement la chaleur. Il dépend notamment du nombre, de l’emplacement et du sens des 
ventilateurs (aspiration / extraction), ainsi que de la circulation de l’air à l’intérieur du boîtier. Le 
push-pull est surtout utilisé sur certains radiateurs pour améliorer le refroidissement. 
 
On distingue principalement quatre formats physiques : Desktop (horizontal), Tour (le plus commun), 
Mini-PC et Serveur (rackable). La taille est dictée par la norme ATX (créée par Intel), qui définit les 
dimensions standards des cartes mères : Mini-ITX < Micro-ATX < ATX < E-ATX.  
Cable Management : un bon boîtier possède des espaces derrière la carte mère pour cacher les câbles, 
ce qui n'est pas seulement esthétique, mais améliore grandement la circulation de l'air. 
1. La carte mere (Motherboard)

La carte mere est le composant central du PC, c’est le coeur. Tous les autres composants y sont 
connectes directement ou indirectement. Elle détermine la compatibilite entre les pieces. 
 1.1 Roles de la carte mere

• 
Interconnecter tous les composants (CPU, RAM, stockage, GPU...) 
• 
Gerer les communications via les bus de donnees 
• 
Heberger le BIOS/UEFI qui demarre la machine 
• 
Fournir les ports externes (USB, audio, reseau, video)

1.2 Facteurs de forme (Form Factor) 
Le facteur de forme definit la taille physique de la carte mere et sa compatibilite avec le boitier.


||**Format**|||**Dimensions**|||**Utilisation typique**|||**Nb slots RAM**||
||Mini-ITX|||170 x 170 mm|||PC tres compact / HTPC|||2 slots||
||Micro-ATX|||244 x 244 mm|||PC compact bureautique|||2-4 slots||
||ATX|||305 x 244 mm|||PC de bureau standard / gaming|||4 slots||


1


<!-- page 2 -->

||E-ATX|||305 x 330 mm|||Workstation / serveur|||8 slots||


1.3 Les principaux composants sur la carte mere


||**Composant**|||**Description**||
|**Socket**|<br> <br> <br> <br><br>|C'est le**connecteur spécifique situé sur la carte mère permettant d'accueillir et**||
|**Socket**|<br> <br> <br> <br><br>|**de fixer le processeur (CPU). Il assure la liaison électrique et la**|
|**Socket**|<br> <br> <br> <br><br>|<br>**communication entre le processeur et les autres composants**(RAM, stockage,|
|**Socket**|<br> <br> <br> <br><br>|<br>GPU). Chaque socket est conçu pour une famille précise de processeurs. Il est**non-**|
|**Socket**|<br> <br> <br> <br><br>|<br>**interchangeable** : un processeur Intel ne rentrera jamais dans un socket AMD (et|
|**Socket**|<br> <br> <br> <br><br>|<br>vice-versa). (Apparence : plaque carré recouverte de points).|
|Slots RAM (DIMM)|<br>|Emplacements pour les barrettes de RAM. La couleur indique les paires (dual||
|Slots RAM (DIMM)|<br>|<br>channel).|
|**Chipset (jeu de puces)**|<br> <br> <br> <br>|Ensemble de composants électroniques intégrés à la carte mère qui coordonne les||
|**Chipset (jeu de puces)**|<br> <br> <br> <br>|<br>flux de données entre le processeur et les différents périphériques (stockage, USB,|
|**Chipset (jeu de puces)**|<br> <br> <br> <br>|<br>réseau). Il détermine les capacités de la carte mère (nombre de ports USB, vitesse|
|**Chipset (jeu de puces)**|<br> <br> <br> <br>|<br>du disque dur, possibilité d'overclocking). En résumé :**puce qui gere les**|
|**Chipset (jeu de puces)**|<br> <br> <br> <br>|<br>**communications entre CPU, RAM, stockage et peripheriques.**|
||Slots PCIe|||Emplacements pour GPU, cartes reseau, cartes son, SSD NVMe...||
||Connecteurs SATA|||Branchement des disques durs et SSD SATA (cable en L).||
||Slot M.2|||Emplacement pour SSD NVMe ou SATA en format compact (pas de cable).||
||Connecteur 24 broches|||Alimentation principale de la carte mere depuis le PSU.||
|<br>|Connecteur CPU (4/8||Alimentation specifique du processeur.|
|<br>|<br>broches)|
||CMOS / Pile bouton|||Maintient la date/heure et les parametres BIOS quand le PC est eteint.||
||Headers facade|||Connecteurs pour bouton power, reset, LEDs, USB facade, audio facade.||
|||**A retenir - Carte mere**||
|<br> <br> <br> <br>|Le socket doit etre compatible avec le CPU : socket Intel LGA (broches sur la carte) vs AMD AM4 (broches|||
|<br> <br> <br> <br>|sur le CPU) mais AM5 s’est aligné sur Intel avec LGA|
|<br> <br> <br> <br>|Le chipset determine les fonctionnalites : overclocking, nombre de ports USB/SATA, PCIe...|
|<br> <br> <br> <br>|ATX = standard le plus courant. Mini-ITX = le plus petit. Ne jamais forcer un format incompatible dans un|
|<br> <br> <br> <br>|boitier.|


2

![Image 1](./images/image_001.jpeg)


<!-- page 3 -->

2. Le processeur (CPU)

Le CPU (Central Processing Unit) est le cerveau de l'ordinateur. Il interprète et exécute les instructions 
des programmes selon un cycle perpétuel en 4 étapes :

1. Fetch (Recherche) : Récupération de l'instruction en mémoire. 
2. Decode (Interprétation) : Décodage du code opération et des opérandes par l'unité de contrôle. 
3. Execute (Exécution) : Réalisation de l'opération par l'UAL. 
4. Writeback (Écriture) : Enregistrement du résultat en registre ou en RAM. 
Architecture interne :

• 
Unité de contrôle : Dirige le flux de données et coordonne les autres unités. 
• 
UAL (Unité Arithmétique et Logique) : Effectue les calculs (+, -, x) et les comparaisons logiques. 
• 
Registres (32/64 bits) : Zones de stockage ultra-rapides (ex: Compteur Ordinal, Registre d'état). 
• 
Horloge : Génère des impulsions pour synchroniser et cadencer les traitements (mesurée en GHz). 
• 
Bus : Canaux de communication (Données, Adresses et Contrôle). 
Technologies modernes : Les processeurs actuels intègrent également de la mémoire cache (SRAM) 
pour réduire les temps d'accès, ainsi que le pipelining et l'unité de prédiction de branchement pour 
optimiser l'exécution des instructions en anticipant les besoins du programme.

2.1 Caracteristiques cles


||**Caracteristique**|||**Definition**|||**Exemple**|
|Nombre de<br>coeurs (cores)|<br> <br> <br> <br>|Le processeur avec un coeur traite une seule consigne à la fois. S’il||4 coeurs, 8 coeurs,<br>16 coeurs...|
|Nombre de<br>coeurs (cores)|<br> <br> <br> <br>|<br>reçoit plusieurs instructions il va les traiter en série. Un CPU multi-coeurs|
|Nombre de<br>coeurs (cores)|<br> <br> <br> <br>|possède plusieurs coeurs physiques independants qui peuvent donc|
|Nombre de<br>coeurs (cores)|<br> <br> <br> <br>|<br>exécuter des tâches en simultanée. Plus de coeurs = meilleur|
|Nombre de<br>coeurs (cores)|<br> <br> <br> <br>|multitache.|
|<br>|Nombre de||<br>|Coeurs logiques. Avec HyperThreading = 2x coeurs physiques. (chez||8 coeurs = 16 threads|
|<br>|threads|<br>**AMD** on appelle cela le**SMT** (_Simultaneous Multi-Threading_))|
|Frequence<br>(GHz)|Nombre de cycles par seconde. Plus = calculs plus rapides.|<br> <br> <br> <br>|3.6 GHz (3.6 milliards<br>de cycles par<br>seconde / 1 cycle ≠ 1<br>instruction (IPC<br>variable)), 5.0 GHz...|
|Cache L1 / L2 /<br>L3|<br> <br>|Memoire ultra-rapide integree au CPU. L1 < L2 < L3 (taille) = technologie||L3 = 12 Mo, 32 Mo...|
|Cache L1 / L2 /<br>L3|<br> <br>|<br>SRAM (voir ci-après)§|
|Cache L1 / L2 /<br>L3|<br> <br>|<br>µ|
|TDP (Watts)|<br>|Chaleur dissipee = consommation indicative. Important pour le choix du||65W, 95W, 125W...|
|TDP (Watts)|<br>|ventirad.|
|Architecture<br>(nm)|<br><br>|La finesse de gravure (les nanomètres) impacte surtout la**chauffe** et la||7nm, 5nm, 4nm...|
|Architecture<br>(nm)|<br><br>|<br>**consommation**. Plus c'est fin, plus on peut mettre de transistors dans le|
|Architecture<br>(nm)|<br><br>|même espace sans que le CPU ne fonde.|


2.2 Principaux fabricants et sockets


||**Fabricant**|||**Gamme**|||**Socket**|||**Particularite**|
|Intel|Core i3 / i5 / i7 / i9|<br> <br> <br> <br> <br>|LGA 1700||Broches sur la carte mere (LGA)|
|Intel|Core i3 / i5 / i7 / i9|<br> <br> <br> <br> <br>|(12e/13e/14e gen) LGA|
|Intel|Core i3 / i5 / i7 / i9|<br> <br> <br> <br> <br>|<br>1851 est destiné à la|
|Intel|Core i3 / i5 / i7 / i9|<br> <br> <br> <br> <br>|nouvelle architecture|
|Intel|Core i3 / i5 / i7 / i9|<br> <br> <br> <br> <br>|(Core Ultra / Arrow|
|Intel|Core i3 / i5 / i7 / i9|<br> <br> <br> <br> <br>|<br>Lake)|
|AMD|Ryzen 3 / 5 / 7 / 9|AM4, AM5|<br>|Broches sur le CPU (PGA pour AM4,|
|AMD|Ryzen 3 / 5 / 7 / 9|AM4, AM5|<br>|<br>LGA pour AM5)|


3


<!-- page 4 -->

||Intel||Xeon|||LGA 3647 / 4677|||Serveurs et workstations||
||AMD||EPYC / Threadripper|||TR4 / SP3 / SP5|||Serveurs et workstations||


2.3 Refroidissement CPU

• 
Ventirad (air cooler) : radiateur + ventilateur. Suffisant pour la majorite des usages. 
• 
Watercooling AIO : radiateur + pompe + ventilateurs. Plus efficace pour CPU chauds. 
• 
Pate thermique : indispensable entre le CPU et le ventirad pour conduire la chaleur.


|<br> <br> <br>|**Attention - Erreur frequente a l'examen**||
|<br> <br> <br>|LGA et PGA ne sont pas les memes : LGA = broches sur le socket de la carte mere, PGA = broches sur le CPU.|
|<br> <br> <br>|Un CPU Intel ne s'installe pas sur un socket AMD et vice versa.|
|<br> <br> <br>|Ne jamais oublier la pate thermique lors du montage : sans elle, le CPU surchauffe en quelques secondes.|


Attention - Erreur frequente a l'examen 
LGA et PGA ne sont pas les memes : LGA = broches sur le socket de la carte mere, PGA = broches sur le CPU. 
Un CPU Intel ne s'installe pas sur un socket AMD et vice versa. 
Ne jamais oublier la pate thermique lors du montage : sans elle, le CPU surchauffe en quelques secondes. 
3. La memoire vive (RAM) 
La RAM (Random Access Memory) est la memoire de travail du PC. Elle stocke temporairement les 
donnees des applications en cours d'utilisation. Elle est volatile : son contenu est efface a chaque 
extinction. 
3.1 Structure interne de RAM 
Une barrette est composée de plusieurs puces mémoire (chips), La RAM est constituée de barrettes 
contenant plusieurs puces mémoire, contenant chacune des millions de cellules. Chaque cellule mémoire 
(1 transistor + 1 condensateur) correspond à 1 bit. 
3.2 Types de RAM

• 
La SDRAM (DDR3, DDR4, DDR5) constitue les barrettes de mémoire amovibles de l'ordinateur, 
servant à stocker temporairement les données des logiciels et du système en cours d'utilisation. 
Toutes les RAM que tu rencontres aujourd'hui en intervention (DDR3, DDR4, DDR5) sont des 
SDRAM. La DRAM asynchrone est obsolète — la SDRAM en est l'évolution synchronisée (Pour 
l’explication : La DRAM (Dynamic RAM asynchrone) fonctionne indépendamment de l'horloge du 
processeur. Elle envoie et reçoit des données quand elle est prête, sans se synchroniser avec le 
CPU. La SDRAM (Synchronous DRAM) elle se synchronise sur l'horloge du processeur. Elle 
attend le signal d'horloge pour envoyer ou recevoir des données, ce qui permet au CPU de prévoir 
exactement quand la donnée sera disponible) 
• 
La SRAM (Static RAM), intégrée directement au processeur sous forme de mémoire cache (L1, L2, 
L3), est beaucoup plus rapide et coûteuse, permettant au CPU d'accéder instantanément à ses 
instructions prioritaires. La SRAM ne nécessite pas de rafraîchissement (contrairement à la DRAM), 
ce qui explique le terme "statique" et sa vitesse supérieure. 
• 
La VRAM Vidéo RAM (dont la technologie principale est la GDDR) est une mémoire spécialisée 
soudée sur la carte graphique, optimisée pour le transport massif de données d'image et de 
textures. Versions actuelles : GDDR5, GDDR6, GDDR6X, GDDR7 — et HBM sur certains GPU 
haut de gamme.


||**Type de RAM**||**Generation**|||**Vitesse typique**|||**Tension**|||**Usage**|
|DDR3||3e||800 - 2133 MHz|1.5V|Anciens PC (2007-2014)|
|DDR3||generation|
|DDR4||4e||2133 - 3600 MHz|1.2V|PC courants (2014-2022)|
|DDR4||generation|
|DDR5||5e||4800 - 6400 MHz+|1.1V|PC récents (2021+)|
|DDR5||generation|
||LPDDR4/5||Mobile|||Variable|||1.1V|||Laptops, ultraportables|
|<br> <br> <br>|ECC RAM<br>(Error-Correcting Code)<br>Intègre un mécanisme<br>de détection et|Serveur|Variable|Utilisée dans les**serveurs et**<br>**stations de travail** critiques.|


4


<!-- page 5 -->

|<br>|correction d'erreurs||||||
|<br>|mémoire.|



||**Caracteristique**|||**Description**|||**Exemple**|
|Capacite (Go)|<br>|Quantite de donnees stockables. 8 Go||8 Go, 16 Go, 32 Go, 64 Go|
|Capacite (Go)|<br>|minimum, 16 Go recommande.|
|Frequence (MHz)|<br>|Vitesse de transfert des donnees. Plus =||3200 MHz, 3600 MHz|
|Frequence (MHz)|<br>|meilleur.|
|Latence (CL)|<br>|Nombre de cycles avant reponse. Moins =||CL16, CL18, CL36|
|Latence (CL)|<br>|<br>meilleur.|
|Dual Channel|<br> <br>|2 barrettes identiques = bande passante||2x 8 Go > 1x 16 Go|
|Dual Channel|<br> <br>|théorique doublée (gain réel variable selon|
|Dual Channel|<br> <br>|<br>les usages) Slots de meme couleur.|
|Format|<br>|DIMM = desktop. SO-DIMM = laptop.||DIMM, SO-DIMM|
|Format|<br>|Physiquement incompatibles.|
|XMP / EXPO|<br>|Profil d'overclock RAM a activer dans le||XMP (Intel), EXPO (AMD)|
|XMP / EXPO|<br>|BIOS pour la vraie frequence.|
|||**A retenir - RAM**||
|<br> <br> <br> <br> <br> <br>|DDR3, DDR4 et DDR5 sont physiquement incompatibles (encoches differentes) : toujours verifier la|||
|<br> <br> <br> <br> <br> <br>|compatibilite avec la carte mere.|
|<br> <br> <br> <br> <br> <br>|Le**dual channel** peut**augmenter fortement la bande passante (jusqu’à ~2x)** selon les usages : toujours|
|<br> <br> <br> <br> <br> <br>|installer les barrettes par paires dans les bons slots.|
|<br> <br> <br> <br> <br> <br>|La capacite minimale pour Windows 11 : 4 Go (Microsoft), mais 8 Go recommande en pratique pour un|
|<br> <br> <br> <br> <br> <br>|usage bureautique.|
|<br> <br> <br> <br> <br> <br>|XMP/EXPO doit etre active dans le BIOS pour que la RAM tourne a sa vraie frequence annoncee.|


Le stockage conserve les données de façon permanente (OS, fichiers, logiciels). Contrairement à la RAM, 
les données ne sont pas effacées à l'extinction : on parle de mémoire non volatile. On distingue deux 
types de disques durs :

• 
HDD (Hard Disk Drive) : stockage magnétique composé de plateaux rotatifs et d'une tête de 
lecture/écriture mécanique. Plus lent en raison des pièces mobiles, mais offre une grande capacité 
à faible coût. Sensible aux chocs. Vitesses typiques : 5400 à 7200 tr/min.

• 
SSD (Solid State Drive) : stockage à mémoire flash, sans pièce mécanique. Beaucoup plus rapide 
que le HDD, plus résistant aux chocs, silencieux et à faible consommation. On distingue deux 
interfaces principales : SATA : connectique classique, débits jusqu'à ~550 Mo/s et NVMe : utilise le 
bus PCIe (via le CPU ou le chipset selon la carte mère), débits jusqu'à 7000 Mo/s sur les modèles 
récents

5


<!-- page 6 -->

Le SAS (Serial Attached SCSI) :

o Le HDD SAS est un disque dur mécanique haute performance conçu pour les serveurs.

Contrairement au SATA, il utilise le protocole SCSI et tourne à des vitesses très élevées (10 000 
ou 15 000 tr/min). Il est privilégié pour sa robustesse, sa capacité à fonctionner 24 h/24 sans 
interruption et son temps d’accès généralement plus faible qu’un HDD SATA classique, avec 
de meilleures performances en environnement serveur. En résumé : HDD SAS = Fiabilité 
mécanique + Rapidité de rotation (usage intensif).

• 
Le SSD SAS est un support de stockage à mémoire flash utilisant l'interface professionnelle SAS 
au lieu du SATA ou du NVMe. Bien qu'il soit physiquement similaire à un SSD classique, il se 
distingue par son "Dual Port" (deux chemins de données redondants) et une endurance extrême. 
C'est le support de choix pour les infrastructures de stockage critiques où la panne d'un contrôleur 
ne doit jamais stopper l'accès aux données. En résumé : SSD SAS = Performance flash + Sécurité 
maximale (redondance).

• 
NVMe (Non-Volatile Memory Express) : protocole de transfert de données ultra-rapide spécialement 
conçu pour les supports de stockage à mémoire flash (SSD). Là où le SATA ou le SAS utilisent des 
protocoles hérités de l'époque des disques durs mécaniques, le NVME lui utilise l'interface PCI 
Express pour offrir des débits largement supérieurs au SATA. En permettant une communication 
directe et massivement parallèle avec le processeur, il réduit la latence au minimum et constitue 
aujourd'hui le standard de performance pour les ordinateurs modernes. Attention à ne pas 
confondre le protocole et le format : NVMe est le langage (le protocole) et M.2 est la forme de la 
carte (le connecteur). Note : Il existe des SSD M.2 qui utilisent encore le vieux langage SATA, mais 
ils sont de plus en plus rares. 
 
 
 
 
4.1 Comparatif des technologies


||**Type**|||**Interface**|||**Vitesse lecture**|||**Forme**|||**Prix/Go**|||**Usage ideal**||
|HDD|SATA|80-160 Mo/s|<br>|3.5" (desktop)||Faible|<br>|Stockage de masse, NAS,||
|HDD|SATA|80-160 Mo/s|<br>|<br>/ 2.5" (laptop)|<br>archivage|
|HDD SAS|SAS|200-300 Mo/s|<br>|3.5" ou 2.5"||Moyen|<br>|Serveurs, bases de données,||
|HDD SAS|SAS|200-300 Mo/s|<br>|(SFF*)|haute disponibilité (24h/7j)|
|SSD SATA|SATA|500-560 Mo/s|2.5" ou M.2|Moyen|<br>|Disque systeme,||
|SSD SATA|SATA|500-560 Mo/s|2.5" ou M.2|Moyen|<br>|<br>remplacement HDD|


6

![Image 2](./images/image_002.jpeg)

![Image 3](./images/image_003.jpeg)


<!-- page 7 -->

|<br>|SSD NVMe||M.2 NVMe|3000-3500 Mo/s|M.2|Moyen-eleve|Disque systeme rapide|
|<br>|(PCIe 3.0)|
|<br>|SSD NVMe||M.2 NVMe|5000-7000 Mo/s|M.2|Eleve|<br>|Workstation, gaming haute|
|<br>|(PCIe 4.0)|<br>perf.|
|<br>|SSD NVMe||M.2 NVMe|10 000+ Mo/s|M.2|Tres eleve|Pro / serveurs|
|<br>|(PCIe 5.0)|
|SSD SAS|SAS|1000-4000Mo/s|2.5” (SFF)|Très élevé|<br> <br>|Infrastructures critiques,|
|SSD SAS|SAS|1000-4000Mo/s|2.5” (SFF)|Très élevé|<br> <br>|centres de données, stockage|
|SSD SAS|SAS|1000-4000Mo/s|2.5” (SFF)|Très élevé|<br> <br>|<br>SAN|


Infrastructures critiques, 
centres de données, stockage 
SAN 
 * En entreprise, le format 2.5" s’appelle le SFF (Small Form Factor) et le 3.5" le LFF (Large Form Factor) 
 
4.2 Le format M.2 en detail 
Le slot M.2 est un connecteur physique présent sur la carte mère qui peut accueillir deux types de SSD aux 
performances très différentes. C'est une source fréquente d'erreur en intervention.


||**M.2 SATA vs M.2 NVMe**||
|•<br>M.2 SATA Utilise le protocole SATA, le même que les anciens disques 2,5 pouces. La vitesse<br>est limitée à ~560 Mo/s. Se reconnaît à son encoche de type clé B ou B+M.<br>•<br>M.2 NVMe Utilise le protocole NVMe via le bus PCIe, communiquant directement avec le CPU.<br>De 3 à 20 fois plus rapide que le SATA. Se reconnaît à son encoche de type clé M.<br>  Point critique en intervention Un slot M.2 NVMe n'accepte pas forcément un SSD M.2 SATA, et<br>inversement. Un SSD peut rentrer physiquement dans le slot sans être compatible avec le protocole<br>supporté par la carte mère. Toujours consulter la documentation de la carte mère avant tout<br>remplacement ou upgrade.<br>**Tailles physiques disponibles** Le format M.2 existe en plusieurs longueurs. La désignation indique la<br>largeur puis la longueur en mm :<br>**Format**<br>**Longueur**<br>**Usage**<br>2240<br>42mm<br>Petits PC, tablettes<br>2260<br>60 mm<br>Rare<br>2280<br>80 mm<br>Le plus courant<br>22110<br>110 mm<br>Serveurs|



|• M.2 SATA Utilise le protocole SATA, le même que les anciens disques 2,5 pouces. La vitesse|Col2|Col3|
|---|---|---|
|est limitée à ~560 Mo/s. Se reconnaît à son encoche de type clé B ou B+M.|
|<br>•<br>M.2 NVMe Utilise le protocole NVMe via le bus PCIe, communiquant directement avec le CPU.|
|De 3 à 20 fois plus rapide que le SATA. Se reconnaît à son encoche de type clé M.|
|<br>  Point critique en intervention Un slot M.2 NVMe n'accepte pas forcément un SSD M.2 SATA, et|
|inversement. Un SSD peut rentrer physiquement dans le slot sans être compatible avec le protocole|
|<br>supporté par la carte mère. Toujours consulter la documentation de la carte mère avant tout|
|<br>remplacement ou upgrade.|
|<br>**Tailles physiques disponibles** Le format M.2 existe en plusieurs longueurs. La désignation indique la|
|largeur puis la longueur en mm :|
|**Format**|**Longueur**|**Usage**|
|2240|42mm|Petits PC, tablettes|
|2260|60 mm|Rare|
|2280|80 mm|Le plus courant|
|22110|110 mm|Serveurs|


7

![Image 4](./images/image_004.jpeg)


<!-- page 8 -->

4.3 Interfaces SATA


||**Composant**|||**Description**||
||SATA III|||Interface actuelle, debit max 600 Mo/s, cable SATA en L 7 broches||
||SATA II|||Ancienne gen, 300 Mo/s max, retrocompatible avec SATA III||
||eSATA|||SATA externe, remplace par l'USB 3.x dans la plupart des cas||
|Cable SATA|<br>|Cable de donnees 7 broches. Cable d'alimentation SATA 15 broches (du||
|Cable SATA|<br>|<br>PSU).|


4.4 Systemes de fichiers 
C'est l'élément logiciel indispensable qui fait le pont entre les composants physiques (HDD, SSD) et les 
données (fichiers, dossiers). Sans lui, le disque n'est qu'une suite de "0" et de "1" illisible. Le système de 
fichiers est la méthode utilisée par un système d'exploitation (Windows, macOS, Linux) pour organiser, 
stocker et récupérer les données sur un support de stockage. On peut le comparer à un bibliothécaire 
qui décide où ranger chaque livre et tient un index précis pour les retrouver instantanément. Rôles 
principaux :

• 
Gestion de l'espace : Il divise le disque en blocs (clusters) et attribue ces blocs aux fichiers. 
• 
Indexation : Il conserve le nom, la taille et l'emplacement exact de chaque fichier (Metadata). 
• 
Sécurité et Permissions : Il définit qui a le droit de lire, modifier ou supprimer un fichier. 
• 
Journalisation : Il enregistre les modifications en cours pour éviter la perte de données en cas de 
coupure de courant brutale.


||**Systeme**|||**OS compatible**|||**Caracteristiques**||||
|NTFS|Windows (natif)|<br>|Journalisation, permissions, chiffrement. Standard||||
|NTFS|Windows (natif)|<br>|Windows.|
|FAT32|Windows/Linux/macOS|Compatible universel mais limite**a 4 Go par fichier**|
||exFAT|||Windows/Linux/macOS|||Cles USB/cartes SD. Pas de limite pratique.||||
||ext4|||Linux (natif)|||Journalisation, permissions Linux. Standard Linux.||||
||APFS|||macOS (natif)|||SSD optimise, chiffrement natif. Exclusif Apple.||||
||**Attention - Erreur frequente a l'examen**||
||Un fichier de plus de 4 Go (ex : ISO, film 4K) ne peut PAS etre copie sur une cle USB formatee en FAT32.|
||<br>NVMe et SATA M.2 ont le meme connecteur physique M.2 mais des protocoles differents : ils ne sont pas toujours|
||<br>interchangeables.|


5. La carte graphique (GPU)... et NPU

8

![Image 5](./images/image_005.jpeg)


<!-- page 9 -->

Le GPU (Graphics Processing Unit) gere l'affichage. Il existe deux types : les GPU dedies (carte graphique 
independante) et les GPU intégrés (iGPU) : intégré au processeur (Intel UHD / Iris Xe, AMD Radeon). Les 
GPU intégrés aux chipsets de carte mère sont obsolètes depuis ~2010.

5.1 GPU integre vs GPU dedie


||**Critere**|||**GPU integre (iGPU)**|||**GPU dedie (dGPU)**|
|Localisation|<br>|Dans le CPU (GPU sur carte mère||Carte PCIe independante|
|Localisation|<br>|= ancien (chipsets d’avant ~2010)|
||Memoire|||Utilise la RAM systeme|||VRAM dediee (4 Go, 8 Go, 16 Go...)|
||Performances|||Suffisant pour bureau/video/2D||I|ndispensable pour gaming/3D/IA|
||Consommation|||Tres faible (integre au CPU)|||Elevee (100W a 400W+)|
||Exemples|||Intel UHD, AMD Radeon Vega|||NVIDIA GeForce, AMD Radeon RX|


5.2 Connexion et alimentation

• 
Interface : slot PCIe x16 sur la carte mere (le plus grand slot) 
• 
Alimentation : connecteur PCIe 6 ou 8 broches (ou 12 broches pour les puissantes) 
• 
Sorties video : HDMI, DisplayPort, DVI, VGA (obsolete) 
5.3 Sorties video - Comparatif


||**Connecteur**|||**Resolution max**|||**Audio**||**Remarques**|
||HDMI 2.1|||10K / 8K@120Hz|||Oui||Standard TV et moniteurs recents|
|DisplayPort 2.1|16K|Oui|<br>|Standard PC gaming, ecrans haut de<br>gamme|
|DVI-D|2560x1600|Non|<br>|Ancien standard, encore present sur<br>certains ecrans|
|VGA (D-Sub)|Analogique|Non|<br>|Obsolete. A eviter. Ne supporte pas<br>la HD sans degradation.|
||USB-C / Thunderbolt|||8K|||Oui||Laptops et moniteurs modernes|



||**A retenir - GPU**|
|<br> <br>|Sans GPU dedie, les jeux 3D et logiciels de conception graphique sont possibles mais avec performances||
|<br> <br>|limitées. La VRAM (memoire video) est separee de la RAM systeme sur les GPU dedies.|
|<br> <br>|VGA est un signal analogique : qualite d'image inferieure. Toujours privilegier HDMI ou DisplayPort.|


5.4. Les NPU (Neural Processing Units) : l’accélérateur d’IA 
Le NPU (Neural Processing Unit) est une unité matérielle spécialisée dans certains calculs liés à 
l’intelligence artificielle, notamment les calculs matriciels. Il permet d’exécuter localement certaines tâches 
d’IA de manière plus efficace énergétiquement que le CPU ou le GPU dans certains usages. Son but est 
de décharger le CPU et le GPU pour préserver l'autonomie et la réactivité du système.  
Les principaux acteurs sont Intel (Core Ultra), AMD (Ryzen AI), Apple (Neural Engine) et Qualcomm 
(Snapdragon X Elite). Intégré directement au processeur central (SoC), son prix ne se détaille pas 
séparément. (à partir d'environ 250 € pour le processeur complet) Les NPU deviennent fréquents sur les 
PC récents, surtout les portables de milieu et haut de gamme. .

• 
Performance : Mesurée en TOPS (Trillions d'Opérations Par Seconde). certaines certifications 
constructeurs ou marketing imposent des seuils minimaux de TOPS.

9


<!-- page 10 -->

• 
Usage concret : Reconnaissance vocale, amélioration d'image en temps réel, réduction de bruit 
intelligente et sécurité des données (traitement local sans passer par le cloud). 
• 
Maintenance : le technicien doit surveiller les pilotes spécifiques et, sur certaines machines 
compatibles, l’activité du NPU peut être visible dans le Gestionnaire des tâches de Windows 11, 
onglet Performance.

Les trois composants partagent le même bus mémoire RAM, ce qui illustre bien pourquoi le NPU ne

remplace pas le CPU ou le GPU — ils coopèrent au sein du même SoC.

✅ L'intégration des NPU nécessite un minimum de 16 Go de RAM (norme Copilot+) pour gérer les 
modèles d'IA localement, créant une tension massive sur la production mondiale. Cette demande, couplée 
à la priorité donnée par les fabricants aux serveurs d'IA, a fait bondir le prix des puces DDR5 de plus de 50 
% depuis 2025. 
6. L'alimentation (PSU - Power Supply Unit) 
Le PSU convertit le courant secteur (220V en courant alternatif) en courant continu de faible tension 
utilisable par les composants (12V, 5V, 3.3V). Il distribue l’énergie aux différents composants en étant 
équipé de protection contre les surtensions, court-circuit, etc. Un PSU sous-dimensionne provoque 
instabilite et pannes.

6.1 Caracteristiques principales


||**Caracteristique**|||**Description**||
|Puissance (Watts)|<br>|Règle des 20-30% de la capacite totale :**Choisir 20-30% de marge au-dessus de**||
|Puissance (Watts)|<br>|<br>**la consommation reelle.**|
|Certification 80 Plus|<br>|Rendement énergétique :**White < Bronze < Silver < Gold < Platinum < Titanium**.||
|Certification 80 Plus|<br>|<br>Garantit qu'au moins 80% du courant est converti (le reste est perdu en chaleur).|
|Modulaire||**Full** (tous les câbles détachables),**Semi** (câbles vitaux fixes) ou**Non-modulaire**.||
|Modulaire||<br>Facilite le_cable management_ et le flux d'air.|
|Format||**ATX** (standard),**SFX** (compact),**TFX** (slim). Doit impérativement correspondre au||
|Format||<br>format supporté par le boîtier.|


10

![Image 6](./images/image_006.png)


<!-- page 11 -->

|PFC actif|<br>|_Power Factor Correction_. Optimise la consommation électrique. Présent sur tous les<br>modèles de qualité moderne.|


*Câble IEC : câble secteur qui entre dans le PSU  
6.2 Connecteurs du PSU


||**Connecteur**|||**Broches**|||**Tensions**|||**Destination**|||**Remarques**|
|ATX 24<br>broches|24 pins|<br> <br>|+3.3V, +5V,||Alimentation principale de la<br>carte mere|Connecteur indispensable, toujours<br>présent|
|ATX 24<br>broches|24 pins|<br> <br>|+12V, -12V,|
|ATX 24<br>broches|24 pins|<br> <br>|+5Vsb|
|EPS / CPU|<br>|4+4 ou 8||+12V|<br>|Alimentation du processeur||<br>|Le format 4+4 permet l'adaptation|
|EPS / CPU|<br>|broches|(pres du socket CPU)|selon le socket|
|PCIe|<br> <br>|6 ou 8||+12V|Alimentation de la carte<br>graphique|<br> <br>|Nouveau connecteur 16 broches|
|PCIe|<br> <br>|broches|(12VHPWR) sur GPU haut de gamme|
|PCIe|<br> <br>|(6+2)|<br>RTX 4000/5000+|
|SATA|<br> <br>|15||+3.3V, +5V,<br>+12V|Alimentation des HDD / SSD<br>SATA / lecteurs optiques|Distinct du connecteur SATA données<br>(7 broches, relié à la carte mère)|
|SATA|<br> <br>|broches|
|SATA|<br> <br>|en L|
|Molex|<br>|4||+5V, +12V|<br>|Anciens peripheriques,||<br>|Progressivement remplacé par SATA|
|Molex|<br>|broches|ventilateurs, eclairage|<br>alimentation|
|Floppy|<br> <br>|4||+5V|<br> <br>|Obsolete. Parfois utilise pour||5V uniquement|
|Floppy|<br> <br>|broches|certains boitiers ou|
|Floppy|<br> <br>|petit|controleurs|


6.3 Calcul de la puissance necessaire


||**Methode de calcul PSU**|
||1. Relevez la consommation GPU (ex : 200W sous charge) et le TDP du CPU (ex : 65W).**Thermal Design**||
||**Power,**Enveloppe Thermique Nominale : mesure la quantité maximale de chaleur qu'un système de|
||refroidissement (ventilateur, watercooling) doit être capable de dissiper pour que le processeur fonctionne|
||correctement à sa fréquence de base.|
||2. Ajoutez les autres composants : RAM (~5W), SSD (~5W), HDD (~8W), carte mere (~50W).|
||3. Total estimatif : 65 + 200 + 5 + 5 + 8 + 50 = 333W|
||4. Ajoutez 20-30% de marge : 333 x 1.25 = ~416W|
||5. Choisissez un PSU de 500W minimum dans cet exemple.|
||Outil utile : PCPartPicker.com ou OuterVision PSU Calculator.|
||**Attention - Erreur frequente a l'examen**<br>Un PSU pas assez puissant = redemarrages aleatoires, coupures sous charge, corruption de donnees.<br>Un PSU de mauvaise qualite sans certification 80 Plus peut endommager les autres composants en cas de<br>surtension. Ne jamais ouvrir un PSU : les condensateurs gardent une charge electrique dangereuse meme PC<br>eteint et debranche.|



|**Standard**|**Debit max**||**Couleur**||**Forme**|**Remarques**|
|**Standard**|**Debit max**||**connecteur**|


11

![Image 7](./images/image_007.jpeg)


<!-- page 12 -->

|USB 2.0|<br>|480 Mb/s (60||Noir / blanc|Type-A|<br>|Standard ancien, toujours tres|
|USB 2.0|<br>|<br>Mo/s)|<br>repandu|
|<br>|USB 3.0 / 3.1||5 Gb/s (625 Mo/s)|Bleu|Type-A ou C|Appele aussi USB 3.2 Gen1|
|<br>|Gen1|
|USB 3.1 Gen2|<br>|10 Gb/s (1.25||Rouge / bleu|Type-A ou C|Appele aussi USB 3.2 Gen2|
|USB 3.1 Gen2|<br>|<br>Go/s)|
||USB 3.2 Gen2x2|||20 Gb/s|||Generalement C|||Type-C|||Rare, specifique|
|<br>|USB4 /||40 Gb/s|Type-C|<br>|Compatible video, daisy chain,|
|<br>|Thunderbolt 4|<br>alimentation|


7.2 Formes des connecteurs USB


||**Forme**|||**Usage**|
||Type-A (rectangle plat)|||PC, chargeurs, hubs. Le plus courant cote 'host'.|
||Type-B (carre avec coins coupes)|||Imprimantes, scanners, anciens peripheriques.|
||Mini-USB (trapeze petit)|||Anciens appareils photo, GPS, disques externes. Obsolete.|
||Micro-USB (trapeze tres plat)|||Smartphones anciens, manettes. En voie d'obsolescence.|
||Type-C (ovale symetrique)|||Standard actuel : smartphones, laptops, moniteurs, accessoires.|


7.3 Ports reseau et audio


||**Port**|||**Description**|
||RJ-45 (Ethernet)|||Reseau filaire. 8 broches. 100 Mb/s (Fast), 1 Gb/s (Gigabit), 2.5/10 Gb/s (haute perf).|
||Jack 3.5mm|||Audio analogique. Vert = sortie audio. Rose = entree micro. Bleu = entree ligne.|
|<br>|Optique||Audio numerique optique. Qualite superieure au Jack.|
|<br>|TOSLINK|
||HDMI (type A)|||19 broches. Video + audio numerique. Standard TV/moniteur.|
||DisplayPort|||20 broches. Video + audio. Standard PC gaming.|


12

![Image 8](./images/image_008.jpeg)


<!-- page 13 -->

7.4 Ports d'affichage legacy*


||**Port**|||**Broches**|||**Signal**|||**Statut**||
|VGA (D-Sub 15)|15 broches|Analogique|<br>|Obsolete. Encore present sur anciens||
|VGA (D-Sub 15)|15 broches|Analogique|<br>|ecrans.|
|DVI-I|29 broches|<br>|Analogique +||Ancien standard|
|DVI-I|29 broches|<br>|<br>Numerique|
||DVI-D Single Link|||19 broches|||Numerique|||Max 1920x1200||
||DVI-D Dual Link|||25 broches|||Numerique|||Max 2560x1600||
|||**A retenir - Connecteurs USB**||
|<br> <br>|La couleur BLEUE d'un port USB-A = USB 3.0 minimum. Port NOIR ou BLANC = USB 2.0.|||
|<br> <br>|USB Type-C ne signifie pas forcement USB 4 ou Thunderbolt : la forme est la meme mais les debits varient.|
|<br> <br>|VGA = signal analogique degradable. Toujours lui preferer HDMI ou DisplayPort.|


* Legacy désigne une technologie ancienne, conservée pour compatibilité, mais : technologiquement 
dépassée, plus développée activement, remplacée par des standards plus récents.

Legacy ≠ inutilisable, mais non recommandée pour du matériel moderne.

8. Les bus et slots d'extension

8.1 Le bus PCIe (PCI Express) 
PCIe est le bus d'extension principal des PC modernes. Il sert a connecter GPU, SSD NVMe, cartes 
reseau, etc.


||**Version PCIe**|||**Debit par lane**|||**Slot x16 total**|||**Usage**||
||PCIe 3.0|||~1 Go/s / lane|||~16 Go/s|||Standard encore tres repandu||
||PCIe 4.0|||~2 Go/s / lane|||~32 Go/s|||GPU recents, SSD NVMe Gen4||
|PCIe 5.0|~4 Go/s / lane|~64 Go/s|<br>|Plateformes 2023+ (Intel 13e gen, AMD Ryzen||
|PCIe 5.0|~4 Go/s / lane|~64 Go/s|<br>|<br>7000)|
||PCIe 6.0|||~8 Go/s / lane|||~128 Go/s|||En cours de deploiement (serveurs)||


8.2 Tailles de slots PCIe

13

![Image 9](./images/image_009.jpeg)


<!-- page 14 -->

||**Slots PCIe - Tailles et compatibilite**||
|<br> <br> <br> <br> <br> <br> <br>|x1  : petit slot. Cartes reseau, cartes son, cartes d'acquisition. 1 lane.|||
|<br> <br> <br> <br> <br> <br> <br>|x4  : slot moyen. SSD NVMe en adaptateur, cartes HBA.|
|<br> <br> <br> <br> <br> <br> <br>|x8  : slot grand. Cartes RAID, certains GPU secondaires.|
|<br> <br> <br> <br> <br> <br> <br>|x16 : le plus grand slot. Reserve au GPU principal.|
|<br> <br> <br> <br> <br> <br> <br>|COMPATIBILITE : une carte PCIe peut s'inserer dans un slot plus grand (x1 dans x16) mais tournera a la|
|<br> <br> <br> <br> <br> <br> <br>|bande passante du slot de la carte.|
|<br> <br> <br> <br> <br> <br> <br>|PCIe est rétrocompatible : une carte PCIe 4.0 peut fonctionner sur un port PCIe 3.0 (avec performances|
|<br> <br> <br> <br> <br> <br> <br>|réduites)|


8.3 Anciens bus (a connaitre pour les pannes)


||**Bus**|||**Periode**|||**Description**|
||PCI|||1992-2010|||Avant PCIe. Slots blancs sur anciennes cartes. Debit faible (133 Mo/s).|
||AGP|||1997-2004|||Slot dedie aux cartes graphiques. Remplace par PCIe.|
||ISA|||1981-2000|||Tres ancien bus 8/16 bits. Uniquement sur machines d'avant 2000.|


9.1. Pourquoi refroidir ?

Les composants électroniques (CPU, GPU, VRM, RAM) produisent de la chaleur par effet Joule. Sans 
évacuation thermique :

• 
les performances baissent (throttling = réduction automatique de fréquence) 
• 
la durée de vie des composants diminue 
• 
dans les cas extrêmes, arrêt d'urgence ou dommages permanents

9.2. Les types de refroidissement

• 
Refroidissement par air (le plus courant). Il est composé de deux éléments indissociables : Le 
dissipateur thermique (heatsink) Bloc de métal (aluminium ou cuivre) qui absorbe la chaleur du 
composant et augmente la surface de dissipation via ses ailettes. Et Le ventilateur (fan) Fait 
circuler l'air à travers les ailettes pour évacuer la chaleur. Contrôlé par la carte mère via le signal 
PWM (régulation de vitesse selon la température). Pâte thermique : Matériau conducteur appliqué 
entre le CPU/GPU et le dissipateur. Elle comble les micro-irrégularités de surface qui 
emprisonneraient de l'air (mauvais conducteur thermique).  En intervention : ne jamais remonter 
un ventirad sans renouveler la pâte thermique si elle est sèche ou craquelée.

• 
Watercooling (refroidissement liquide) L'eau conduit mieux la chaleur que l'air. Deux variantes : AIO 
(All-In-One) Circuit fermé prêt à l'emploi. Pompe + radiateur + ventilateurs intégrés. Facile à 
installer, entretien minimal. Standard sur les PC gaming et workstations. / Custom loop Circuit 
ouvert configurable (reservoir, pompe séparée, waterblocks GPU/RAM). Très performant, très 
coûteux, maintenance régulière. Niche (overclocking extrême).

• 
Refroidissement passif : Aucun ventilateur. Le dissipateur seul évacue la chaleur par convection 
naturelle. Silencieux, zéro panne mécanique. Limité aux composants basse consommation (mini-
PC, NAS, composants embarqués).

9.3. La circulation d'air dans le boîtier

Un bon refroidissement ne dépend pas que des composants — la circulation d'air dans le boîtier est 
critique. Règle de base : les ventilateurs d'entrée (intake) en façade/bas, les ventilateurs de sortie

14


<!-- page 15 -->

(exhaust) en arrière/haut. La chaleur monte naturellement. Pression positive (plus d'entrée que de sortie) 
→ moins de poussière, recommandé avec filtres. Pression négative (plus de sortie que d'entrée) → aspire 
la poussière, déconseillé.

9.4. Températures de référence (au repos / en charge)

Composant 
Normal repos 
Normal charge 
Seuil d'alerte 
CPU (modern) 
30–45 °C 
70–85 °C 
> 95 °C 
GPU 
35–50 °C 
75–85 °C 
> 95 °C 
SSD NVMe 
35–50 °C 
60–70 °C 
> 80 °C 
HDD 
30–40 °C 
40–50 °C 
> 55 °C 
*certains CPU modernes atteignent 95°C en fonctionnement normal 
9.5. Outils de diagnostic en intervention

Outil 
Usage

HWMonitor 
Températures, vitesses ventilateurs, 
tensions 
MSI Afterburner 
Monitoring GPU en temps réel 
CrystalDiskInfo 
Température SSD/HDD via SMART 
BIOS/UEFI 
Températures CPU, vitesses fans sans OS 
 
À retenir pour le support IT :

• 
Un PC qui s'éteint seul sous charge → vérifier les températures en premier 
• 
Un CPU à 100 % sans raison → peut être du throttling thermique, pas un problème logiciel 
• 
Nettoyage des filtres et radiateurs = maintenance préventive essentielle (poussière = isolation 
thermique) 
• 
Renouveler la pâte thermique tous les 3–5 ans sur un laptop, moins souvent sur desktop

10. Le BIOS / UEFI

Le BIOS (Basic Input/Output System) ou UEFI (Unified Extensible Firmware Interface) est le firmware de la 
carte mere. Il s'execute avant tout OS et gere l'initialisation du materiel. 
 10.1 BIOS vs UEFI


||**Critere**|||**BIOS (legacy)**|||**UEFI (moderne)**|
|Interface|<br>|Texte uniquement, navigation||Graphique, souris supportee|
|Interface|<br>|<br>clavier|
||Adressage disque|||MBR uniquement (max 2 To)|||GPT et MBR (disques > 2 To supportes)|
|Temps de demarrage|Lent|<br>|Beaucoup plus rapide (Secure Boot,|
|Temps de demarrage|Lent|<br>|<br>Fast Boot)|
||Secure Boot|||Non|||Oui (empeche boot de code non signe)|
||Table de partitions|||MBR (4 partitions max)|||GPT (128 partitions, disques >2 To)|
||Presence sur machines|||Avant 2012 environ|||2012 a aujourd'hui|


10.2 Parametres BIOS/UEFI importants


||**Parametre**|||**Description**|
||Boot Order / Boot Priority|||Ordre de demarrage : HDD, USB, Reseau (PXE)...|
|Secure Boot|<br>|Valide la signature numerique du bootloader. Desactiver<br>pour Linux si necessaire.|


15


<!-- page 16 -->

|Fast Boot|<br>|Reduit le temps de POST en sautant certains tests. Peut<br>empecher d'acceder au BIOS.|
||XMP / EXPO|||Active le profil de frequence haute de la RAM.|
||Virtualisation (VT-x/AMD-V)|||Necesaire pour faire tourner des VM (VMware, VirtualBox).|
|AHCI / NVMe|<br>|Mode du controleur SATA. AHCI = standard. IDE = ancien<br>mode a ne pas utiliser.|
||TPM 2.0|||Puce de securite. Obligatoire pour Windows 11.|


10.3 La pile CMOS

• 
Pile bouton CR2032 sur la carte mere. 
• 
Maintient la date/heure et les parametres BIOS quand le PC est debranche. 
• 
Duree de vie : 5-10 ans. Symptomes de pile morte : date/heure reinitialisee a chaque demarrage, 
perte des reglages BIOS. 
• 
Remplacement : retirer la pile quelques secondes = reset BIOS (CMOS clear).


||**A retenir - BIOS/UEFI**|
||UEFI + GPT = obligatoire pour installer Windows 11 et supporter des disques de plus de 2 To.||
||BIOS + MBR = systemes anciens, 4 partitions primaires max, disques 2 To max.|
||Secure Boot doit etre desactive pour booter sur certaines distributions Linux (ou activer avec cle tierce).|
||Pile CMOS morte = heure et date incorrectes au demarrage = symptome caracteristique.|


11.1 Ordre de montage d'un PC

• 
1. Installer le CPU sur la carte mere (sans forcer, aligner le triangle) 
• 
2. Appliquer la pate thermique (grain de riz au centre) 
• 
3. Fixer le ventirad/watercooling 
• 
4. Installer la/les barrettes RAM dans les bons slots (dual channel) 
• 
5. Monter les entretoises dans le boitier (standoffs) 
• 
6. Installer la plaque I/O de la carte mere dans le boitier 
• 
7. Visser la carte mere sur les entretoises 
• 
8. Installer le PSU dans le boitier 
• 
9. Installer les SSD/HDD (M.2 directement, SATA avec cable) 
• 
10. Installer la carte graphique dans le slot PCIe x16 
• 
11. Brancher tous les cables (24 broches, CPU, PCIe, SATA, headers facade) 
• 
12. Premier demarrage : entrer dans le BIOS et verifier que tout est detecte 
11.2 Precautions ESD (Decharges electrostatiques)


|<br> <br> <br> <br> <br>|**Attention - Erreur frequente a l'examen**<br>L'electricite statique peut detruire les composants instantanement et silencieusement.<br>Toujours porter un bracelet anti-statique ou toucher une partie metallique mise a la terre avant de manipuler des<br>composants.<br>Travailler sur une surface antistatique ou sur la boite carton du composant. Ne jamais sur moquette.<br>Tenir les cartes par les bords, jamais par les composants ou les contacts dores.|


11.3 Diagnostic des pannes hardware courantes


||**Symptome**|||**Causes possibles**|||**Verifications a faire**|
|<br>|PC ne demarre pas (aucun||<br>|Cable 24 broches ou CPU debranche,||<br>|Reverifier tous les cables, remettre la|
|<br>|<br>bip, aucun affichage)|RAM mal inseree, court-circuit|RAM, tester avec 1 seule barrette|


16


<!-- page 17 -->

|PC demarre mais aucun<br>affichage|Mauvaise sortie video, GPU mal insere,<br>ecran eteint|<br> <br> <br>|Tester la sortie vidéo de la carte mère si|
|PC demarre mais aucun<br>affichage|Mauvaise sortie video, GPU mal insere,<br>ecran eteint|<br> <br> <br>|le processeur dispose d’un iGPU,|
|PC demarre mais aucun<br>affichage|Mauvaise sortie video, GPU mal insere,<br>ecran eteint|<br> <br> <br>|reinserrer le GPU, tester un autre cable|
|PC demarre mais aucun<br>affichage|Mauvaise sortie video, GPU mal insere,<br>ecran eteint|<br> <br> <br>|video|
|<br>|PC s'eteint aleatoirement sous||<br>|PSU sous-dimensionne, surchauffe||<br>|Verifier temperatures (HWiNFO64),|
|<br>|charge|CPU/GPU, RAM instable|<br>tester PSU, verifier XMP/EXPO|
|PC tres lent|<br>|Disque presque plein, RAM saturee,||<br>|Analyser avec gestionnaire des taches,|
|PC tres lent|<br>|pilotes obsoletes, virus|<br>liberer espace, mettre a jour pilotes|
|Ecran bleu (BSOD)|<br>|RAM defectueuse, pilote corrompu, SSD||<br>|Memtest86 pour RAM, CrystalDiskInfo|
|Ecran bleu (BSOD)|<br>|defaillant, surchauffe|<br>pour SSD, DDU pour pilotes GPU|
|Bruits de clic HDD|HDD en fin de vie (head crash)|<br>|Sauvegarder immediatement.|
|Bruits de clic HDD|HDD en fin de vie (head crash)|<br>|<br>Remplacer le disque. Ne pas attendre.|
|PC ne detecte pas un<br>SSD/HDD|<br><br> <br>|Cable SATA defaillant, slot M.2||Changer cable SATA, verifier mode<br>AHCI dans BIOS, verifier slot M.2|
|PC ne detecte pas un<br>SSD/HDD|<br><br> <br>|incompatible, vérifier le mode du|
|PC ne detecte pas un<br>SSD/HDD|<br><br> <br>|contrôleur SATA (AHCI/RAID) dans|
|PC ne detecte pas un<br>SSD/HDD|<br><br> <br>|<br>l’UEFI/BIOS|
|<br>|Date/heure incorrecte a||Pile CMOS morte|Remplacer pile CR2032|
|<br>|chaque demarrage|


11.4 Outils de diagnostic


||**Outil**|||**Type**|||**Utilisation**|
||HWiNFO64|||Logiciel|||Monitoring temperatures, tensions, vitesses ventilateurs|
|~~CPU-Z~~ne pas utiliser|Logiciel|<br> <br>|Infos detaillees CPU, RAM, carte mere L'outil officiel<br>(cpuid.com) est légitime mais de fausses versions ont été<br>diffusées via Google Ads en 2023.|
||GPU-Z|||Logiciel|||Infos detaillees GPU, VRAM, temperatures|
||CrystalDiskInfo|||Logiciel|||Sante des disques SMART, temperatures SSD/HDD|
||Memtest86|||Bootable|||Test RAM hors OS. A faire tourner 2+ passes.|
||CrystalDiskMark|||Logiciel|||Benchmark vitesses SSD/HDD en lecture/ecriture|
||Prime95|||Logiciel|||Test de stabilite CPU / stress test sous charge maximale|
||FurMark|||Logiciel|||Stress test GPU. Verifie stabilite et refroidissement.|



||**Questions frequentes sur la carte mere**|
|<br> <br> <br> <br> <br>|Q : Quelle est la difference entre ATX et Micro-ATX ?||
|<br> <br> <br> <br> <br>|R : Taille et nombre de slots d'extension. ATX = plus grand, plus de slots. Micro-ATX = plus compact.|
|<br> <br> <br> <br> <br>|||
|<br> <br> <br> <br> <br>|Q : A quoi sert le chipset ?|
|<br> <br> <br> <br> <br>|R : A gerer les communications entre le CPU, la RAM, le stockage et les peripheriques.|
|<br> <br> <br> <br> <br>|||
|<br> <br> <br> <br> <br>|Q : Que se passe-t-il si la pile CMOS est morte ?|
|<br> <br> <br> <br> <br>|R : La date/heure se remet a zero a chaque demarrage et les parametres BIOS sont perdus.|


17


<!-- page 18 -->

||**Questions frequentes sur le CPU et la RAM**||
|<br> <br> <br> <br> <br> <br> <br>|Q : Quelle est la difference entre coeurs et threads ?|||
|<br> <br> <br> <br> <br> <br> <br>|R : Coeurs = unites physiques de calcul. Threads = coeurs logiques (HyperThreading = 2 threads/coeur).|
|<br> <br> <br> <br> <br> <br> <br>||||
|<br> <br> <br> <br> <br> <br> <br>|Q : DDR4 et DDR5 sont-ils compatibles ?|
|<br> <br> <br> <br> <br> <br> <br>|R : Non. Ils ont des encoches differentes et ne sont pas physiquement interchangeables.|
|<br> <br> <br> <br> <br> <br> <br>||||
|<br> <br> <br> <br> <br> <br> <br>|Q : Qu'est-ce que le dual channel ?|
|<br> <br> <br> <br> <br> <br> <br>|R : Installer 2 barrettes identiques dans les bons slots pour doubler la bande passante memoire.|
|<br> <br> <br> <br> <br> <br> <br>||||
|<br> <br> <br> <br> <br> <br> <br>|Q : Pourquoi la RAM ne tourne pas a sa frequence annoncee ?|
|<br> <br> <br> <br> <br> <br> <br>|R : Il faut activer le profil XMP (Intel) ou EXPO (AMD) dans le BIOS.|



||**Questions frequentes sur le stockage**||
|<br> <br> <br> <br> <br> <br>|Q : Quelle est la difference entre SSD SATA et SSD NVMe ?|||
|<br> <br> <br> <br> <br> <br>|R : SATA max ~560 Mo/s. NVMe via PCIe : 3000 a 7000 Mo/s selon generation. NVMe beaucoup plus|
|<br> <br> <br> <br> <br> <br>|rapide.|
|<br> <br> <br> <br> <br> <br>||||
|<br> <br> <br> <br> <br> <br>|Q : Pourquoi ne peut-on pas copier un fichier de 10 Go sur une cle USB ?|
|<br> <br> <br> <br> <br> <br>|R : La cle est probablement formatee en FAT32, limite a 4 Go par fichier. Reformater en exFAT.|
|<br> <br> <br> <br> <br> <br>||||
|<br> <br> <br> <br> <br> <br>|Q : Quelle table de partitions utiliser pour un disque de 3 To sous Windows ?|
|<br> <br> <br> <br> <br> <br>|R : GPT. MBR est limite a 2 To.|



||**Questions frequentes sur les connecteurs**||
|<br> <br> <br> <br> <br> <br> <br>|Q : Comment identifier un port USB 3.0 ?|||
|<br> <br> <br> <br> <br> <br> <br>|R : La languette interieure du port est bleue. Debit : 5 Gb/s minimum.|
|<br> <br> <br> <br> <br> <br> <br>||||
|<br> <br> <br> <br> <br> <br> <br>|Q : Quelle est la difference entre HDMI et DisplayPort ?|
|<br> <br> <br> <br> <br> <br> <br>|R : HDMI : standard TV/consoles/moniteurs grand public. DisplayPort : standard PC gaming, supporte des|
|<br> <br> <br> <br> <br> <br> <br>|resolutions et taux de rafraichissement plus eleves.|
|<br> <br> <br> <br> <br> <br> <br>||||
|<br> <br> <br> <br> <br> <br> <br>|Q : VGA est-il encore utilise ?|
|<br> <br> <br> <br> <br> <br> <br>|R : Oui, sur de vieux ecrans et PC. Mais c'est un signal analogique degrade. A remplacer par HDMI/DP si|
|<br> <br> <br> <br> <br> <br> <br>|possible.|



||**Questions frequentes sur le PSU et le BIOS**||
|<br> <br> <br> <br> <br> <br> <br> <br>|Q : Que signifie la certification 80 Plus Gold ?|||
|<br> <br> <br> <br> <br> <br> <br> <br>|R : Le PSU a un rendement energetique d'au moins 87% en charge. Moins de chaleur et d'electricite|
|<br> <br> <br> <br> <br> <br> <br> <br>|gaspillee.|
|<br> <br> <br> <br> <br> <br> <br> <br>||||
|<br> <br> <br> <br> <br> <br> <br> <br>|Q : Quelle est la difference entre BIOS et UEFI ?|
|<br> <br> <br> <br> <br> <br> <br> <br>|R : BIOS = ancien firmware texte, MBR, max 2 To. UEFI = moderne, graphique, GPT, Secure Boot, plus|
|<br> <br> <br> <br> <br> <br> <br> <br>|rapide.|
|<br> <br> <br> <br> <br> <br> <br> <br>||||
|<br> <br> <br> <br> <br> <br> <br> <br>|Q : Pourquoi activer la virtualisation dans le BIOS ?|
|<br> <br> <br> <br> <br> <br> <br> <br>|R : Pour pouvoir faire tourner des machines virtuelles avec VMware, VirtualBox ou Hyper-V.|
|<br> <br> <br> <br> <br> <br> <br> <br>||||
|<br> <br> <br> <br> <br> <br> <br> <br>|Q : Qu'est-ce que le Secure Boot ?|


18


<!-- page 19 -->

|<br>|R : Fonction UEFI qui verifie la signature numerique du bootloader pour empecher le demarrage de code||
|<br>|malveillant.|



||**Composant**|||**Valeur cle**|||**A retenir**|
||ATX|||305 x 244 mm|||Format standard desktop|
||Mini-ITX|||170 x 170 mm|||Format mini|
||USB 2.0|||480 Mb/s|||Languette noire/blanche|
||USB 3.0|||5 Gb/s|||Languette bleue|
||SATA III|||600 Mo/s max|||7 broches donnees + 15 alimentation|
||SSD NVMe Gen3|||3500 Mo/s|||6x plus rapide que SATA|
||SSD NVMe Gen4|||7000 Mo/s|||12x plus rapide que SATA|
||FAT32 limite|||4 Go / fichier|||Attention cles USB|
||DDR4 tension|||1.2V|||DDR3 = 1.5V, DDR5 = 1.1V|
||Pile CMOS|||CR2032|||Pile bouton 3V|
||MBR limite disque|||2 To|||Au-dela = GPT obligatoire|
||PCIe x16|||Slot GPU|||Le plus long slot de la carte mere|
||Pate thermique|||Grain de riz|||Quantite et emplacement centre CPU|
||TPM 2.0|||Windows 11 requis|||Puce securite|


19


<!-- page 20 -->

MODULE 2 : SYSTEME D’EXPLOITATION

1. Les différents systèmes d’exploitation

OS : Ensemble des programmes qui dirigent l'utilisation des ressources d'un ordinateur par des logiciels 
applicatifs. Il constitue l'interface entre le matériel (hardware) et les logiciels utilisateurs.

1.1 Familles d'OS

OS de bureau :

• 
Windows (Microsoft) — dominant en entreprise  
et grand public 
• 
macOS (Apple) — exclusif au matériel Apple 
• 
Linux (open source) — distributions : Ubuntu,  
Debian, Fedora, etc. 
 
OS exploitation mobile :

• 
Android (Google) — basé sur Linux, domine le  
marché smartphone (~72 % de parts de marché) 
• 
iOS (Apple) — exclusif iPhone/iPad, fermé et  
propriétaire 
• 
HarmonyOS (Huawei) — en développement, marché principalement asiatique 
 
OS pour serveur :

• 
Linux (Ubuntu Server, Debian, RHEL, CentOS) — majoritaire sur les serveurs web 
• 
Windows Server (Microsoft) — dominant en environnement Active Directory / entreprise 
 
OS embarqué. Conçu pour des systèmes dédiés avec ressources limitées. Exemples : firmware des 
routeurs, systèmes industriels, caisses enregistreuses, voitures connectées. Basés souvent sur Linux 
allégé ou RTOS (Real Time OS). 
 
1.2 Fonctionnalités de l’OS

• 
Gestion des processus : L'OS crée, ordonnance et termine les processus. Il alloue du temps CPU 
à chaque processus via un scheduler (ordonnanceur). Gère le multitâche en donnant l'illusion que 
plusieurs programmes tournent simultanément. Concepts clés : processus, thread, état (actif / en 
attente / suspendu). 
• 
Gestion de la mémoire : l’OS alloue et libère la RAM pour chaque processus. Il empêche un 
processus d’accéder à la mémoire d’un autre (isolation mémoire). Il gère également la mémoire 
virtuelle : une partie du disque (swap / pagefile) peut être utilisée comme extension de la RAM 
lorsque celle-ci est saturée. 
• 
Gestion des fichiers l’OS organise les données sur les supports de stockage via un système de 
fichiers (NTFS sous Windows, ext4 sous Linux, APFS sous macOS). Il gère l’arborescence, les 
droits d’accès, la lecture/écriture et les métadonnées des fichiers. 
• 
Gestion des périphériques : l’OS communique avec le matériel via des pilotes (drivers). 
• 
Il fait l’interface entre le matériel et les applications, afin que celles-ci n’aient pas à gérer 
directement le hardware. Le Gestionnaire de périphériques permet d’identifier et de surveiller les 
composants connectés.

• 
Sécurité et gestion des utilisateurs L'OS gère les comptes utilisateurs, les droits d'accès et les 
permissions sur les fichiers et ressources. Il distingue les niveaux de privilèges :

20

![Image 10](./images/image_010.jpeg)


<!-- page 21 -->

Niveau 
Windows 
Linux/macOS 
Administrateur complet 
Administrateur 
root 
Utilisateur standard 
Utilisateur 
user 
Élévation temporaire 
UAC 
sudo

L’OS assure aussi le chiffrement, le pare-feu natif et les journaux d'événements (logs).

1.3 Structure du système de fichiers Windows

Essentiel pour le support de proximité — connaître l'arborescence pour localiser les fichiers lors d'une 
intervention :


||**Dossier**|||**Rôle**||
||C:\Windows\System32|||Fichiers système critiques||
||C:\Users|||Profils utilisateurs||
||C:\Program Files|||Applications 64 bits||
||C:\Program Files (x86)|||Applications 32 bits||
||C:\ProgramData|||Données applications (dossier caché)||
||AppData\Roaming|||Profil itinérant utilisateur||
||AppData\Local|||Données locales utilisateur||


1.4 Le registre Windows

Base de données hiérarchique qui stocke la configuration de Windows et des applications. Accès : Win+R 
→ regedit


||**Ruche**|||**Contenu**||
||HKEY_LOCAL_MACHINE (HKLM)|||Configuration matérielle et système||
||HKEY_CURRENT_USER (HKCU)|||Paramètres de l'utilisateur connecté||
||HKEY_CLASSES_ROOT (HKCR)|||Associations de fichiers||


21

![Image 11](./images/image_011.png)


<!-- page 22 -->

||HKEY_USERS|||Profils de tous les utilisateurs||
||⚠** À retenir :**Toujours exporter une sauvegarde avant modification du registre (Fichier → Exporter).|||


1.5 Comptes et groupes locaux

Accès : Win+R → lusrmgr.msc

• 
Groupes locaux importants : Administrateurs, Utilisateurs, Invités 
• 
Désactiver le compte Invité par défaut en environnement entreprise 
• 
Renommer le compte Administrateur intégré (bonne pratique sécurité)

1.6 Services Windows

Un service est un programme qui tourne en arrière-plan sans interface utilisateur. Accès : Win+R → 
services.msc


||**État / Type**|||**Description**||
||Démarré|||Service actif en mémoire||
||Arrêté|||Service inactif||
||Désactivé|||Ne peut pas démarrer||
||Démarrage automatique|||Lance au démarrage de Windows||
||Démarrage manuel|||Lance à la demande||


En intervention : un service arrêté explique souvent un dysfonctionnement. Exemples critiques :

• 
Print Spooler — impression 
• 
DHCP Client — attribution d'adresse IP réseau 
• 
Windows Update — mises à jour

1.7 Gestion des disques

Accès : Win+R → diskmgmt.msc

• 
Créer, supprimer, formater des partitions 
• 
Distinction MBR (ancien) vs GPT (actuel, lié à UEFI) 
• 
Attribuer des lettres de lecteurs 
• 
diskpart en ligne de commande pour les cas avancés


|||||**MBR**|||**GPT**||
||Partitions max|||4 primaires|||128||
||Taille disque max|||2 To|||18 Eo||
||Compatibilité|||BIOS legacy|||UEFI||
||Statut|||Ancien|||Actuel (standard)||


1.8 Journaux et observateur d'événements

Accès : Win+R → eventvwr.msc — Première consultation lors d'un crash ou dysfonctionnement inexpliqué.


||**Journal**|||**Contenu**||
||Application|||Événements générés par les logiciels||
||Système|||Événements du noyau Windows et des pilotes||


22


<!-- page 23 -->

||Sécurité|||Connexions, échecs d'authentification, modifications de droits||
||**Niveau**|||**Signification**||
||Information|||Événement normal||
||Avertissement|||Problème potentiel non bloquant||
||Erreur|||Problème ayant causé un dysfonctionnement||
||Critique|||Défaillance grave — action requise||


1.9 Sauvegarde et restauration


||**Outil**|||**Accès**|||**Usage**||
|Points de restauration|rstrui.exe|<br>|Restaure la configuration système sans affecter les||
|Points de restauration|rstrui.exe|<br>|<br>données utilisateur|
||Historique des fichiers|||Paramètres → Mise à jour|||Sauvegarde automatique des données utilisateur||
||Image système|||Panneau de configuration|||Sauvegarde complète du disque||
||Snapshot VM|||VirtualBox / VMware|||Cliché d'état — PAS une sauvegarde long terme||
||⚠** À retenir :**Snapshot VM ≠ sauvegarde. Un snapshot occupe de l'espace disque et ne||||
||protège pas contre une défaillance matérielle.|


1.10 À retenir — Support IT

• 
L'OS est la couche logicielle sans laquelle aucun logiciel applicatif ne peut fonctionner 
• 
Un problème matériel se diagnostique souvent depuis l'OS (gestionnaire de périphériques, logs 
système) 
• 
La gestion des droits utilisateurs est centrale en entreprise : “Un utilisateur standard ne peut 
généralement pas installer de logiciels système ni modifier les paramètres sensibles sans 
élévation de privilèges.” 
• 
Le swap/pagefile excessif est un indicateur de RAM insuffisante — signe d'un besoin d'upgrade 
mémoire 
2. Installer Windows 
2.1 Installer Windows depuis une clé bootable

Étape 1 — Créer la clé bootable avec Ventoy : Télécharger Ventoy sur https://www.ventoy.net et 
l'installer sur la clé USB. La clé sera formatée — sauvegarder les données présentes. Copier ensuite les 
images (.iso) des OS sur la clé.

Étape 2 — Démarrer sur la clé : Brancher la clé USB et démarrer l'ordinateur en appuyant sur F9 ou 
Échap. Si nécessaire, modifier l'ordre de démarrage dans le BIOS/UEFI pour booter depuis la clé USB.

Étape 3 — Installation : Sélectionner l'ISO Windows dans Ventoy, Débrancher le câble Ethernet - “On 
peut débrancher le réseau pendant l’installation pour éviter certaines contraintes en environnement 
de test pas de production (compte Microsoft, mises à jour immédiates, isolement de test).” / Choisir 
la langue d'installation / Cliquer sur « Je n'ai pas de clé de produit » pour sélectionner la version / 
Sélectionner une partition d'au moins 64 Go (200 Go préférable si installation de logiciels) / Sélectionner « 
Configurer pour une utilisation personnelle » / Renseigner le nom du PC et un mot de passe / Questions de 
sécurité : mettre 1 en environnement de test uniquement / Répondre Non à tous les paramètres de 
personnalisation

Contourner l'obligation de compte Microsoft

Ouvrir l'invite de commande avec Maj+F10 (Fn+Maj+F10 sur laptop) et taper :

23


<!-- page 24 -->

OOBE\BYPASSNRO

(Le système va ensuite redémarrer) Si cela ne fonctionne pas : 
start ms-cxh:localonly

2.2 Paramétrage et optimisation

Paramètres système de base

Informations système : Clic droit sur Démarrer → Système (ou Win+Pause) 
Vérifier : nom du PC / version Windows / mémoire RAM / type de système


|||||**32 bits**|||**64 bits**||
||Traitement|||32 bits à la fois|||64 bits à la fois||
||RAM max|||Limité à ~4 Go|||Beaucoup plus de RAM||
||Performances|||Moins performant|||Plus performant||


Mises à jour et pilotes

Mises à jour système : Paramètres → Système → Windows Update 
Pour les pilotes, il faut privilégier en priorité le site du constructeur du PC, puis si nécessaire le site du 
fabricant du composant (ex. carte graphique, chipset, Wi-Fi).Windows Update peut proposer certains 
pilotes, mais ils ne sont pas toujours les plus récents ni les plus complets. 
Les sites tiers doivent rester un recours complémentaire, avec prudence. 
Site utile pour les pilotes : touslesdrivers.com 
Extensions de fichiers pilotes : .inf ou .sys 
Un point d'exclamation dans devmgmt.msc signale un pilote manquant

Mise à jour via PowerShell (mode admin) : 
winget upgrade  →  puis :  winget upgrade –all

* Cette commande permet de mettre à jour de nombreux logiciels référencés dans 
Winget, mais elle ne remplace pas Windows Update et ne met pas à jour tous les 
pilotes.

Configuration réseau


||**Commande / Accès**|||**Action**||
||Win+R → PowerShell → ipconfig|||Affiche les infos réseau (IP, masque, passerelle)||
||ping 172.16.3.X / ping 9.9.9.9|||Test de connectivité réseau||
||Win+R → ncpa.cpl|||Ouvre les connexions réseau||
||IPv4 → Propriétés|||Fixer l'IP, passerelle (.1 par convention), DNS (ex : 9.9.9.9)||
||⚠** À retenir :** activer la découverte réseau**uniquement lorsque c’est nécessaire et sur un**||||
||**réseau de confiance**. Désactiver et réactiver la connexion si problème de connectivité.|


Personnalisation 
Affichage : Système → Affichage → résolution, mise à l'échelle, mode clair/sombre 
GodMode : créer un dossier nommé exactement GodMode.{ED7BA470-8E54-465E-825C-99712043E01C} 
Explorateur Windows : Accueil → ... → Options → Affichage → afficher fichiers cachés + extensions

2.3 Raccourcis et commandes essentiels

24


<!-- page 25 -->

||**Raccourci / Commande**|||**Action**||
||Win + X|||Menu de liens rapides (Mode admin)||
||Win + Tab / Alt + Tab|||Vue des tâches||
||Tab|||Pour se déplacer entre les onglets||
||Alt + F4|||Fermer une fenêtre||
||Win + R|||Boîte de dialogue Exécuter||
||Win + I|||Ouvrir les Paramètres||
||Win + Pause|||Informations système||
||Ctrl + Shift + Esc / Ctrl + Alt + suppr|||Gestionnaire des tâches||
||powershell|||Console PowerShell (via Win+R)||
||services.msc|||Gestion des services Windows||
||eventvwr.msc|||Observateur d'événements||
||secpol.msc|||Stratégie de sécurité locale||
||wf.msc|||Pare-feu Windows avancé||
||ncpa.cpl|||Connexions réseau||
||msconfig|||Configuration du système / démarrage||
||optionalfeatures|||Fonctionnalités Windows||
||Devmgmt.msc|||Gestionnaire de périphériques||
||diskmgmt.msc|||Gestion des disques||
||lusrmgr.msc|||Comptes et groupes locaux||
||regedit|||Éditeur du registre||
||diskpart|||Gestion avancée des disques (CLI)||
||gpupdate /force|||Forcer l'application des stratégies de groupe||
||netstat -an|||Voir les connexions réseau actives et ports ouverts||
||sfc /scannow|||Réparation des fichiers système||
||chkdsk|||Vérification du disque||


chkdsk 
Vérification du disque 
3. La virtualisation 
La virtualisation peut être définie comme une technologie qui créé des représentations virtuelles de 
machines physiques (serveurs, stockage et réseaux), d’applications, de bureaux, de stockage ou de 
données. En raison de la variété des éléments informatiques qui peuvent être virtualisés, la virtualisation 
offre des avantages dans plusieurs domaines : infrastructure informatique, développement de logiciels et 
déploiement d’applications.

3.1 Les avantages de la virtualisation pour l'infrastructure informatique

25


<!-- page 26 -->

• 
Réduction des coûts : La virtualisation permet aux services informatiques d'utiliser efficacement 
les ressources matérielles coûteuses en allouant dynamiquement l'unité centrale, la mémoire et le 
stockage aux machines virtuelles (VM) en fonction des besoins, afin d'optimiser l'utilisation des 
ressources. La virtualisation permet également aux services informatiques de consolider plusieurs 
charges de travail sur un nombre réduit de serveurs physiques afin de réduire la consommation 
d'énergie. 
• 
Flexibilité : Les VM fonctionnant séparément du matériel sous-jacent, le service informatique peut 
déplacer les VM d'un serveur physique à un autre sans apporter de modifications à la VM. Cette 
capacité permet au service informatique d'exécuter des opérations d'équilibrage de charge, de 
maintenance du matériel et de reprise après sinistre avec peu ou pas de temps d'arrêt. 
 En outre, les VM peuvent être facilement créées, clonées ou supprimées. Cette flexibilité simplifie 
la mise à l'échelle des applications en fonction des besoins, ce qui accroît l'agilité des opérations 
informatiques. 
• 
Complexité réduite : Étant donné que plusieurs charges de travail peuvent être consolidées sur un 
nombre réduit de serveurs physiques, le service informatique a moins de serveurs physiques à 
gérer. En outre, comme il peut prendre des instantanés de l'état d'une VM à un moment précis. Les 
snapshots facilitent certains retours arrière rapides après une erreur ou une manipulation risquée. 
En revanche, un snapshot ne remplace pas une vraie sauvegarde et ne constitue pas, à lui seul, 
une stratégie complète de reprise après sinistre. Enfin, les outils de gestion de la virtualisation 
offrent un contrôle centralisé, ce qui facilite l'approvisionnement, la surveillance et la gestion des 
machines virtuelles. 
• 
Sécurité : Les VM étant isolées les unes des autres, les problèmes d'une VM (c'est-à-dire les 
pannes ou les failles de sécurité) n'affectent pas les autres dans le centre de données, ce qui 
renforce la sécurité et la stabilité de l'infrastructure. Cet isolement facilite également la mise en 
œuvre de mesures de sécurité telles que les pare-feu, les systèmes de détection d'intrusion et la 
segmentation du réseau. 
• 
Indépendance matérielle : Étant donné que le service informatique peut faire fonctionner des 
machines virtuelles avec des applications et des systèmes d'exploitation (OS) plus anciens sur du 
matériel moderne, une organisation peut continuer à faire fonctionner des systèmes patrimoniaux 
essentiels à l'activité. 
• 
Efficacité : Les services informatiques peuvent s'assurer que l'utilisation des ressources d'une VM 
n'a pas d'impact négatif sur les autres VM du même serveur en fixant des limites de ressources, ce 
qui permet une gestion efficace des ressources et prévient les goulets d'étranglement en matière de 
performances. En outre, la virtualisation peut fournir aux services informatiques des fonctions de 
clustering de basculement et de migration en direct, qui améliorent la disponibilité du système en 
cas de défaillance en déplaçant automatiquement les charges de travail vers des hôtes sains et en 
automatisant les tâches de gestion répétitives.


||**Avantages Virtualisation**||
||**Usage**|||**Description**||
||Multi-OS|||Faire cohabiter plusieurs OS sans redémarrer ni partitionner||
||Isolation / Sandboxing|||Tester un script risqué ou logiciel suspect sans affecter la machine physique||
||Snapshots|||Prendre un cliché avant une manipulation risquée pour revenir à l'état précédent||
|Cloud / Économie|<br>|Diviser un serveur physique en plusieurs VM, réduisant coûts et consommation||
|Cloud / Économie|<br>|<br>énergétique|


Cloud / Économie 
Diviser un serveur physique en plusieurs VM, réduisant coûts et consommation 
énergétique 
3.2 Machine Virtuelle (VM) 
Une Machine Virtuelle (VM) est une version logicielle d'un ordinateur physique. Elle possède son propre 
OS, processeur virtuel, RAM et stockage, alors qu'elle n'est qu'un ensemble de fichiers tournant sur une 
machine physique appelée l'hôte.

Le cœur du système est l'Hyperviseur : le logiciel qui fait le pont entre le matériel physique et les machines 
virtuelles.

26


<!-- page 27 -->

||**Type**|||**Description**|||**Exemples**||
|Type 1 (Bare Metal)|<br>|S'installe directement sur le matériel. Utilisé en||<br>|VMware ESXi, Proxmox,||
|Type 1 (Bare Metal)|<br>|serveurs et Cloud.|Hyper-V|
|Type 2 (Hosted)|<br>|S'installe comme un logiciel sur l'OS hôte. Utilisé en||<br>|VirtualBox, VMware||
|Type 2 (Hosted)|<br>|<br>TP.|Workstation|


• 
Développement et tests : Les développeurs peuvent tester leurs applications sur différents 
systèmes d'exploitation sans avoir besoin de plusieurs machines physiques. 
• 
Formation et éducation : Les étudiants et formateurs peuvent expérimenter différents 
environnements informatiques en toute sécurité. 
• 
Compatibilité logicielle : Il permet d'exécuter des applications anciennes ou incompatibles avec le 
système d'exploitation principal. 
• 
Sécurité : Les professionnels de la cybersécurité peuvent analyser des logiciels malveillants dans 
un environnement isolé. 
• 
Migration de systèmes : Facilite la transition entre différents systèmes d'exploitation en permettant 
de les exécuter côte à côte. 
• 
Démonstrations de logiciels : Les commerciaux peuvent présenter des produits sur différentes 
plateformes à partir d'un seul ordinateur. 
3.3 Installer Windows 11 en VM

Configuration minimale : 4 Go de RAM, 2 cœurs, 60 Go de stockage.

Cocher « Skip unattended installation » et activer UEFI. Débrancher le câble Ethernet avant installation. 
 Bypass des prérequis Windows 11 (TPM, RAM, etc.)

Lors de l'installation, ouvrir l'éditeur de registre (regedit) et naviguer jusqu'à : 
HKEY_LOCAL_MACHINE\SYSTEM\Setup

Clic droit sur « Setup » → Nouveau → Clé → nommer « LabConfig » (respecter la casse).

Dans LabConfig, créer les valeurs DWORD 32 bits suivantes (valeur = 1) :

- 
BypassTPMCheck  - BypassSecureBootCheck – BypassRAMCheck -BypassStorageCheck 
- 
BypassCPUCheck

Pour passer l'étape de connexion internet : Maj+F10 → OOBE\BYPASSNRO (alternatives possibles) 
Après installation : installer les VirtualBox Guest Additions pour activer le copier-coller hôte/invité.


||⚠** À retenir :**Ne jamais installer deux hyperviseurs sur un même PC !||


3.4 Récapitulatif


||**Terme**|||**Définition**||
||Hôte (Host)|||La machine physique réelle||
||Invité (Guest)|||La machine virtuelle||
||Hyperviseur|||Distribue les ressources CPU/RAM entre les VM||
||Snapshot|||Cliché d'état — n'est PAS une sauvegarde long terme||
||Guest Additions|||Pilotes VirtualBox pour copier-coller et résolution d'écran||


27


<!-- page 28 -->

INTERVENIR SUR LES ELEMENTS DE L’INFRASTRUCTURE

MODULE 3 : RÉSEAUX & INFRASTRUCTURE

Partie 1 : Les composants du réseau (switch, routeur, wifi, MAC) et binaire

1. Réseau 
Un réseau est un ensemble de machines et d'équipements (switch, routeurs, points d'accès, câbles RJ45, 
cartes réseau/NIC) qui peuvent communiquer et s'échanger des données.

Définitions

• 
Adresse MAC : propre à chaque carte réseau, codée en hexadécimal sur 48 bits. Les 24 premiers 
bits identifient le fabricant, les 24 suivants identifient la carte de façon unique.

• 
Hub : équipement de couche 1 (couche Physique du modèle OSI). Il répète le signal électrique reçu 
vers TOUS ses ports simultanément, sans aucune intelligence : c'est du broadcast physique 
permanent. Résultat : toutes les machines branchées « entendent » tout le traficla bande passante 
est partagée entre tous les appareils. Le Hub est aujourd'hui obsolète et remplacé par le switch.

• 
Switch (commutateur) : équipement de 
couche 2 (couche Liaison). Il analyse les 
adresses MAC contenues dans chaque trame 
et les envoie uniquement au port destinataire 
grâce à sa table SAT (port physique ↔ adresse 
MAC). Contrairement au Hub, la bande 
passante est dédiée à chaque paire de 
communicants.

• 
Modem : MOdulateur-DEModulateur. Convertit les signaux numériques en signaux analogiques 
(modulation) et inversement (démodulation). Aujourd'hui notre box contient toujours un modem. Il 
n'est pas remplacé, il est intégré dans un appareil tout-en-un (Modem + Routeur + Switch + Point 
d'accès).

• 
Routeur : fait communiquer plusieurs réseaux entre eux, route les paquets vers leur destination en 
s'appuyant sur les adresses IP.

• 
Passerelle (Gateway) : adresse IP du routeur côté réseau local. Elle constitue le point de sortie 
obligatoire pour tout trafic à destination d'un autre réseau. Finit souvent par .1 par convention (non 
obligatoire). La "Default Gateway" (Passerelle) : si la passerelle est mal configurée sur un PC, celui-
ci pourra communiquer avec ses voisins (VLAN local), mais ne pourra jamais sortir sur Internet, 
même si l'IP et le DNS sont bons.

• 
NAT (Network Address Translation) : technique utilisée par les routeurs. Permet à plusieurs 
appareils d'un réseau local de partager une seule IP publique. Indispensable pour Internet à la 
maison. Pour être précis, ce qu'on utilise à la maison est le PAT (Port Address Translation). Le NAT 
classique fait correspondre une IP privée à une IP publique. Le PAT permet à plusieurs IP privées 
d'utiliser une seule IP publique grâce aux numéros de ports.

• 
Point d'accès Wi-Fi : crée une cellule sans fil (BSS) identifiée par un SSID. La box à la maison est 
un appareil 3-en-1 : Routeur + Switch + Point d'accès.

• 
Adresse IP : identifiant logique unique de chaque appareil sur un réseau. Elle peut être fixe (static) 
ou dynamique (DHCP) IP privées (réseau local, non routables) vs IP publiques (routables sur 
Internet).

28

![Image 12](./images/image_012.jpeg)


<!-- page 29 -->

• 
Masque de sous-réseau : valeur sur 32 bits associée à une adresse IP. Permet de distinguer la 
partie réseau de la partie hôte d'une adresse. Exemple : 255.255.255.0 (/24). Utilisé pour 
déterminer si deux appareils sont sur le même réseau.

• 
Adresse de réseau : première adresse d'une plage IP. Identifie le réseau lui-même, non assignable 
à un appareil. Exemple : 192.168.1.0.

• 
Adresse de broadcast : dernière adresse d'une plage IP. Utilisée pour envoyer un message à tous 
les appareils du réseau simultanément. Exemple : 192.168.1.255.

• 
DNS (Domain Name System) : convertit les noms de domaine en adresses IP (et inversement via 
le DNS inversé). Permet de naviguer avec des noms lisibles plutôt que des adresses numériques.

• 
DDNS (Dynamic DNS) : service qui met à jour automatiquement un enregistrement DNS lorsque 
l'IP publique d'un hôte change. Utile pour accéder à distance à un équipement dont l'IP publique est 
dynamique (la plupart des abonnements particuliers).

• 
DHCP (Dynamic Host Configuration Protocol) : protocole qui attribue automatiquement une 
configuration réseau aux appareils (adresse IP, masque, passerelle, DNS). Évite la configuration 
manuelle de chaque poste.

• 
VPN (Virtual Private Network) : crée un tunnel sécurisé et chiffré entre un appareil et un réseau 
distant. Masque l'adresse IP réelle. VPN nomade (connexion depuis n'importe où vers un réseau) 
vs VPN site-à-site (tunnel fixe et permanent entre deux sites).

• 
VLAN (Virtual Local Area Network) : réseau local virtuel créé par segmentation logique d'un 
switch. Permet d'isoler des groupes d'appareils sur la même infrastructure physique, pour des 
raisons de sécurité ou d'organisation.

• 
Protocole réseau : ensemble de règles définissant comment les données sont échangées entre 
appareils. Exemples principaux : TCP (transmission fiable avec vérification) et UDP (transmission 
rapide sans vérification, utilisé pour la vidéo/jeux).

• 
Ping / ICMP : outil de diagnostic réseau. Envoie un paquet ICMP à une adresse cible et mesure le 
temps de réponse (en ms). Permet de vérifier qu'un appareil est joignable et d'estimer la latence.

2. Supports de transmission : Filaire (Ethernet) vs Sans-fil (Wi-Fi)

2.1. Ethernet — L'accès filaire (IEEE 802.3)

Si le Wi-Fi est la liberté, l'Ethernet est la stabilité. Ethernet est une norme réseau dédiée principalement 
aux réseaux LAN, mais également utilisée dans les réseaux MAN et WAN. Elle s'est imposée comme le 
standard universel des réseaux locaux. 
  
Ethernet est utilisé dans le modèle OSI aux niveaux de la couche Physique (couche 1) et de la couche 
Liaison de données (couche 2). Il a servi de base à la norme IEEE 802.3, qui a unifié le développement 
des réseaux et des composants matériels. Ethernet est une norme en constante évolution. Sa première 
version (1980) n'offrait que 10 Mb/s. Aujourd'hui, les versions les plus récentes atteignent 400 Gb/s à 1,6 
Tb/s sur fibre optique.

⚠️ Même si on associe Ethernet aux réseaux câblés, cette norme ne se limite pas au cuivre : elle 
s'applique aussi aux liaisons fibre optique (10GBASE-SR, 100GBASE-LR…).

2.1.1. Normes Ethernet — De 10 Mb/s à 1,6 Tb/s


|**Norme**|**Débit**|**Support (câble)**|<br>|**Distance**||**Connecteur**|** Remarques**|
|**Norme**|**Débit**|**Support (câble)**|<br>|**max**|


29


<!-- page 30 -->

|10BASE-T|10<br>Mb/s|Cat 3 / Cat 5|100 m|RJ45|Obsolète|
|---|---|---|---|---|---|
|100BASE-TX<br>(Fast Eth.)|100<br>Mb/s|Cat 5 / 5e|100 m|RJ45|Encore sur vieux<br>équipements|
|1000BASE-T<br>(Gigabit)|1 Gb/s|Cat 5e / 6|100 m|RJ45|Standard actuel<br>minimum|
|10GBASE-T<br>(10 Gigabit)|10<br>Gb/s|Cat 6 (55 m) / Cat 6a|55–100 m|RJ45|Existe en cuivre,<br>pas seulement fibre|
|10GBASE-SR<br>/ LR|10<br>Gb/s|Fibre optique<br>multimodo/monomodo|Jusqu'à<br>plusieurs<br>km|LC/SC|Interconnexion switchs|
|40G / 100G<br>Ethernet|40–100<br>Gb/s|Fibre optique|Variable|QSFP / MPO|Data centers,<br>backbone|
|200G / 400G /<br>800G / 1.6T|Très<br>haut<br>débit|Fibre optique|Variable|QSFP-DD|Réseaux opérateurs /<br>hyperscale|


2.1.2. Câbles et catégories — Ce qui change vraiment

Le connecteur RJ45 reste identique pour toutes les catégories de câble cuivre. Ce qui change, c'est la 
qualité du cuivre, l'isolation interne et la protection contre les interférences.


||**Catégorie**|||**Débit max**|||**Fréquence**|||**Blindage**|||**Usage typique**||
|Cat 5e|1 Gb/s|100 MHz|UTP (non blindé)|LAN bureautique — standard minimum|
|Cat 6|1 Gb/s (10<br>Gb/s sur<br>55 m)|250 MHz|UTP ou FTP|LAN entreprise, interconnexion courte|
|Cat 6a|10 Gb/s|500 MHz|FTP / SFTP (blindé)|Infrastructure entreprise actuelle<br>recommandée|
|Cat 7|10 Gb/s|600 MHz|SFTP (blindage par<br>paire)|Environnements industriels à fortes<br>perturbations|
|Cat 8|40 Gb/s|2000 MHz|SFTP|Data centers, liaisons très courtes (30 m<br>max)|


Le blindage (Shielding) :

 UTP (Unshielded Twisted Pair) : pas de blindage — suffit en bureautique standard 
 FTP (Foiled Twisted Pair) : feuille d'aluminium autour de toutes les paires — bon rapport qualité/prix 
 STP (Shielded Twisted Pair) : blindage autour de chaque paire individuelle 
 SFTP / S/FTP : feuille par paire + blindage global — niveau maximum, utilisé en milieu industriel/

📌 Application terrain (Sonia) : dans une usine avec de gros moteurs électriques (CNC, variateurs de 
vitesse), on choisit du Cat 6a SFTP pour éviter que les parasites électromagnétiques fassent tomber le 
réseau. Le surcout du câble blindé est négligeable comparé au coût d'une panne de production.

La rétrocompatibilité : un câble Cat 6a fonctionnera parfaitement sur une vieille carte réseau Fast 
Ethernet (100 Mbps), mais il sera bridé. L'inverse n'est pas vrai : un câble Cat 5e ne permettra jamais 
d'atteindre du 10 Gb/s stable sur 100 mètres.

2.1.3. PoE — Power over Ethernet

30


<!-- page 31 -->

Le PoE (Power over Ethernet) permet d’alimenter électriquement un équipement réseau directement via 
le câble Ethernet, sans prise secteur séparée. Les données et l’alimentation peuvent transiter sur le 
même câble réseau.


|**Standard**||**Puissance**||**Usage typique**|
|**Standard**||**max**|
|PoE (802.3af)|15,4 W|Téléphones IP, petites caméras IP, points d'accès Wi-Fi<br>basiques|
|PoE+ (802.3at)|30 W|Points d'accès Wi-Fi 6, caméras PTZ, écrans d'affichage|
|PoE++ (802.3bt)|60–90 W|PC légers, écrans, bornes de recharge, équipements vidéo<br>haute qualité|


✅ Avantage terrain majeur : une caméra de surveillance ou un point d'accès Wi-Fi placé en hauteur 
ou en extérieur n'a besoin que d'un seul câble RJ45. Pas d'électricien, pas de gaine supplémentaire. 
Un switch PoE peut alimenter 24 équipements avec un seul câble chacun.

💡 Pour qu'un équipement soit alimenté en PoE, deux conditions : le switch doit être un switch PoE 
(pas un switch standard), et l'équipement doit être compatible PoE. Un équipement non-PoE branché 
sur un port PoE ne sera pas endommagé — le switch détecte la compatibilité avant d'envoyer le 
courant.

2.1.4. Ethernet vs Wi-Fi — Tableau comparatif


||**Caractéristique**|||**Ethernet (Câble)**|||**Wi-Fi (Ondes)**||
|Débit|Constant et dédié (Full-Duplex)|Partagé entre tous les appareils<br>connectés|
|Latence|Très faible — idéal pour VoIP, jeux,<br>RDP|Variable — sujet aux interférences<br>et à la charge|
|Sécurité|Physique — il faut se brancher<br>physiquement|Ondes dans l'air — plus exposé aux<br>interceptions|
|Mobilité|Nulle — fil obligatoire|Totale — liberté de déplacement|
|Fiabilité|Très élevée — pas de perturbations|Dépend de l'environnement (murs,<br>appareils voisins)|
|Installation|Tirage de câbles nécessaire|Rapide — juste un point d'accès|
|Usage recommandé|Postes fixes, serveurs, imprimantes|Téléphones, laptops, IoT, espaces<br>ouverts|


📌 Règle terrain : pour tout équipement fixe (PC de bureau, imprimante réseau, serveur, caméra 
fixe, téléphone IP), préférer toujours le câble. Le Wi-Fi est réservé aux équipements mobiles ou 
aux zones impossibles à câbler.connecté.Limite des 100 mètres  : c'est la question piège sur le 
terrain : "Qu'est-ce qu'on fait si l'imprimante est à 120 mètres ?" (Réponse : switch intermédiaire 
ou fibre).

2.2. Wi-Fi — Fonctionnement et normes 
Le Wi-Fi (Wireless Fidelity) est né en 1997 avec la norme initiale IEEE 802.11 (2 Mb/s). En 1999, 
le Wi-Fi décolle avec le 802.11b (11 Mb/s, 2,4 GHz) et le 802.11a (54 Mb/s, 5 GHz). Le 802.11g 
unifie les débits à 54 Mb/s en 2003, puis le 802.11n (Wi-Fi 4, 2009) introduit le MIMO (antennes 
multiples) pour atteindre 600 Mb/s. En 2013, le 802.11ac (Wi-Fi 5) franchit le gigabit grâce au 5

31


<!-- page 32 -->

GHz uniquement. Depuis 2019, le Wi-Fi 6 (802.11ax) optimise la gestion des environnements 
denses (nombreux appareils), tandis que le Wi-Fi 7 (802.11be, 2024) dépasse les 46 Gb/s 
théoriques.  
Le Wi-Fi fonctionne via les ondes hertziennes sur les bandes de fréquences 2,4 GHz, 5 GHz et 6 
GHz.

2.2.1. Évolution des normes Wi-Fi


|**Génération**|**Norme**<br>**IEEE**||**Année**|**Fréquences**||**Débit max**||**Nouveauté clé**|
|**Génération**|**Norme**<br>**IEEE**||**Année**|**Fréquences**||**théorique**|
|Wi-Fi 1|802.11b|1999|2,4 GHz|11 Mb/s|Première démocratisation|
|Wi-Fi 2|802.11a|1999|5 GHz|54 Mb/s|5 GHz (moins de congestion)|
|Wi-Fi 3|802.11g|2003|2,4 GHz|54 Mb/s|Unification 2,4 GHz|
|Wi-Fi 4|802.11n|2009|2,4 + 5 GHz|600 Mb/s|MIMO (antennes multiples)|
|Wi-Fi 5|802.11ac|2013|5 GHz|3,5 Gb/s|MU-MIMO, beamforming|
|Wi-Fi 6|802.11ax|2019|2,4 + 5 GHz|9,6 Gb/s|OFDMA — gestion dense<br>(IoT, open space)|
|Wi-Fi 6E|802.11ax|2021|2,4 + 5 + 6<br>GHz|9,6 Gb/s|Bande 6 GHz non<br>congestionnée|
|Wi-Fi 7|802.11be|2024|2,4 + 5 + 6<br>GHz|46 Gb/s max<br>plutot des 5 à 10<br>Gb/s utiles dans la<br>réalité|Multi-Link Operation<br>(plusieurs bandes<br>simultanées)|


2.2.2. Fréquences et canaux


|**Fréquence**|**Portée**|<br>|**Débit max**||**Interférences**|<br>|**Usage**||
|**Fréquence**|**Portée**|<br>|**(pratique)**|<br>**recommandé**|
|2,4 GHz|Longue — traverse<br>mieux les murs et<br>les obstacles|~300 Mb/s|Nombreuses (micro-ondes,<br>Bluetooth, voisins, tous sur 3<br>canaux)|IoT, appareils<br>éloignés du point<br>d'accès|
|5 GHz|Courte — s'atténue<br>rapidement avec les<br>murs|~1,3 Gb/s|Peu denses — plus de<br>canaux disponibles (25<br>canaux non-chevauchants)|PC,<br>smartphones, TV<br>proches du point<br>d'accès|
|6 GHz (Wi-<br>Fi 6E/7)|Très courte|> 2 Gb/s|Quasi inexistantes — bande<br>récente peu utilisée|Équipements<br>récents, très haut<br>débit|


Canaux et interférences (2,4 GHz) : en 2,4 GHz, seuls 3 canaux sont non-chevauchants : 1, 6 et 
11. Lorsque deux points d'accès voisins utilisent le même canal, les signaux se perturbent 
mutuellement — c'est la principale cause de Wi-Fi lent en immeuble.

💡 Conseil terrain : si le Wi-Fi est lent ou instable, inspecter les canaux voisins avec Wi-Fi 
Analyzer (Android) ou inSSIDer (PC). Changer de canal peut résoudre le problème sans 
aucune intervention matérielle. En environnement dense, passer sur du 5 GHz réduit 
drastiquement les interférences.

32


<!-- page 33 -->

2.3. Wi-Fi — Sécurisation 
La sécurité Wi-Fi garantit deux choses : que seul l'utilisateur autorisé peut se connecter 
(Authentification) et que personne ne peut lire les données qui circulent dans l'air (Chiffrement).

2.3.1. Protocoles de sécurité


||**Protocole**|||**Chiffrement**|||**Statut**|||**Niveau de sécurité**||
|WEP|RC4 (cassé)|Obsolète,<br>à bannir|Nul — se pirate en quelques<br>minutes avec un simple PC|
|WPA|TKIP|Obsolète|Faible — première réponse<br>urgente aux failles WEP|
|WPA2|Chiffrement : AES-CCMP (Advanced<br>Encryption Standard)- (Counter Mode<br>with Cipher Block Chaining Message<br>Authentication Code Protocol) +<br>Méthode de connexion : PSK<br>(PreShared Key) : "Handshake" (la<br>poignée de main) entre le PC et la<br>borne contient des informations qui<br>permettent de deviner le mot de passe.|Standard<br>actuel|Protocole de chiffrement<br>robuste du WPA2 qui garantit<br>que vos données Wi-Fi sont à<br>la fois illisibles pour les pirates<br>et protégées contre toute<br>modification. Bon — norme la<br>plus répandue en entreprise<br>aujourd'hui|
|WPA3|Chiffrement : AES-GCM + Méthode de<br>connexion : SAE (_Simultaneous_<br>_Authentication of Equals : c_'est ce qui<br>remplace le "Handshake" du WPA2 et<br>empêche le pirate du parking de faire<br>une attaque par dictionnaire offline)|<br>Recommandé|Excellent — résiste aux<br>attaques par dictionnaire et<br>brute-force offline|


⚠️ WEP est cassé depuis 2001. S'il est encore présent sur un équipement en production, c'est 
une faille de sécurité ouverte. Aucune excuse pour le maintenir.

2.3.2. Modes d'authentification : Personal vs Enterprise


||**Mode**|||**Fonctionnement**|||**Avantage**|||**Inconvénient**|||**Usage**||
|WPA2/WPA3<br>Personal<br>(PSK)|Un seul mot de<br>passe partagé entre<br>tous les utilisateurs|Simple à<br>configurer|Si un<br>employé part,<br>il faut<br>changer le<br>mot de passe<br>sur TOUS les<br>appareils|Maison, PME sans AD (Le<br>WPA2**reste sûr en pratique**<br>quand le mot de passe est fort<br> MAIS**vulnérable aux**<br>**attaques offline** (KRACK<br>exclu))|
|WPA2/WPA3<br>Enterprise<br>(802.1X)|Chaque utilisateur<br>se connecte avec<br>son identifiant/mot<br>de passe Active<br>Directory (via<br>serveur RADIUS*)|Révocation<br>individuelle :<br>on coupe<br>l'accès d'une<br>personne sans<br>toucher aux<br>autres|Nécessite un<br>serveur<br>RADIUS +<br>infrastructure<br>AD|Entreprises avec AD —<br>solution recommandée|


*Serveur RADIUS : RADIUS est un protocole AAA qui centralise l'authentification des accès réseau en 
s'appuyant sur Active Directory comme base d'utilisateurs par exemple. Lorsqu'un utilisateur tente de se

33


<!-- page 34 -->

connecter, le NAS envoie les credentials au serveur RADIUS (ex: NPS sur Windows Server), qui les vérifie 
auprès de l'AD et répond Accept ou Reject.

2.3.3. Bonnes pratiques de sécurisation


||**Pratique**||**Description**|||**Priorité**||
|Utiliser WPA2 ou<br>WPA3|Ne jamais utiliser WEP ou WPA1|Critique|
|Désactiver le<br>WPS|Le bouton WPS est une faille connue (brute-force en quelques<br>heures). À désactiver immédiatement|Critique|
|VLANs Wi-Fi<br>dédiés|Réseau Invité sur VLAN isolé, réseau Production sur VLAN<br>séparé. Un invité ne doit jamais atteindre les serveurs|Critique|
|Masquer le SSID|Fausse bonne idée : un scanner (Wireshark, Aircrack) détecte le<br>réseau même masqué. Complique la vie des utilisateurs sans<br>apporter de vraie sécurité|Inutile|
|Filtrage MAC|On autorise uniquement les adresses MAC connues. Limite : une<br>adresse MAC se spoofie facilement. Couche supplémentaire, pas<br>une protection réelle|<br>Complémentaire|
|Isolation des<br>clients|Empêche les appareils Wi-Fi de communiquer entre eux.<br>Obligatoire pour un Wi-Fi Visiteurs|<br>Recommandé|
|Changer le mot<br>de passe par<br>défaut du point<br>d'accès|Les identifiants admin par défaut sont publics en ligne|Critique|


2.3.4. Cas pratique — AéroSud (Nadia)

🔷 Situation : Un pirate stationne sur le parking d'AéroSud avec un ordinateur portable et un 
adaptateur Wi-Fi en mode monitor.


||**Scénario**||**Ce que le pirate peut faire**|||**Solution de Nadia**||
|Wi-Fi ouvert<br>(aucun<br>chiffrement)|Capture et lit en clair TOUS les emails,<br>mots de passe et données qui circulent<br>(attaque passive avec Wireshark) Un**Wi-**<br>**Fi ouvert** permet à un attaquant<br>d’intercepter le trafic**non chiffré** et<br>d’exploiter des services mal sécurisés.<br>Même si de nombreux sites utilisent<br>aujourd’hui**HTTPS/TLS**, ce type de<br>réseau reste**inadapté à un usage**<br>**professionnel**.|Inadmissible en entreprise|
|WPA2 Personal<br>avec mot de passe<br>simple (ex:<br>Aerosud2024)|<br>Attaque par dictionnaire offline : il capture<br>le handshake et teste des millions de<br>combinaisons avec Hashcat|Mot de passe long et complexe —<br>mais révocation impossible si<br>l'employé part|
|WPA2/WPA3<br>Enterprise (802.1X<br>+ RADIUS + AD)|<br>Bloqué : chaque utilisateur a ses propres<br>identifiants AD. Sans compte valide,<br>impossible de s'authentifier|Solution retenue par Nadia —<br>révocation individuelle, logs de<br>connexion, intégration AD|


34


<!-- page 35 -->

✅ La solution Enterprise de Nadia est la seule qui coupe l'accès en 30 secondes si un 
employé est licencié, sans toucher aux autres utilisateurs. C'est la norme dans toute 
infrastructure professionnelle sérieuse.

2.4. Récapitulatif — Ce qu'il faut retenir

Ethernet

 Norme IEEE 802.3 — fonctionne sur cuivre (RJ45) et fibre optique 
 Cat 6a = standard recommandé en entreprise (10 Gb/s, résistant aux perturbations) 
 PoE : alimentation électrique via le câble RJ45 — idéal pour caméras, téléphones IP, AP Wi-Fi 
 Pour tout équipement fixe : câble > Wi-Fi (débit garanti, latence constante, sécurité physique)

Wi-Fi

 Wi-Fi 6 (802.11ax) = standard actuel recommandé pour les déploiements neufs 
 2,4 GHz = portée longue, interférences nombreuses / 5 GHz = portée courte, moins encombré 
 3 canaux non-chevauchants en 2,4 GHz : 1, 6, 11 
 WPA3 > WPA2 > WPA > WEP (à bannir absolument) 
 Enterprise (802.1X) = seule vraie solution en environnement professionnel avec AD 
 Désactiver le WPS — c'est une faille ouverte 
 Réseau Invité = VLAN isolé obligatoire

📌 La règle d'or du terrain (Sonia) : "On câble tout ce qui ne bouge pas, on met en Wi-Fi tout ce qui se 
déplace. Et on n'autorise jamais un VoIP ou une caméra de sécurité sur le Wi-Fi si on peut l'éviter."

3.Typologie des réseaux


||**Type**|||**Portée**|||**Usage**|||**Technologie**||
|PAN|1-10 m|Montre connectée,<br>écouteurs|Bluetooth, USB|
|LAN|100 m - 1 km|Réseau d'entreprise,<br>maison|Wi-Fi, Ethernet|
|MAN|10-50 km|Plusieurs sites d'une ville|Fibre optique|
|WAN|Illimité|Internet|Satellites, câbles sous-marins|


Topologies réseau


||**Topologie**|||**Avantage**|||**Inconvénient**|||**Usage**||
|Étoile|Panne isolée à un<br>seul poste|Si nœud central<br>tombe, tout tombe|Bureaux, foyers (la plus utilisée)|
|Maillée|Ultra-robuste,<br>chemins alternatifs|Très coûteux|Internet, systèmes militaires|
|Hybride|Flexible, adaptable|Complexe|Grandes entreprises, campus|
|Bus|Simple et peu<br>coûteux|Câble central = point<br>unique de<br>défaillance|Obsolète|
|Anneau|Pas de collision|Une panne = tout le<br>réseau tombe|Réseaux industriels anciens|


4. Binaire et hexadécimal

35


<!-- page 36 -->

Comprendre le binaire et l'hexadécimal est indispensable pour configurer les masques de sous-réseau, 
interpréter les adresses IPv6 ou diagnostiquer des erreurs matérielles, car ces systèmes numériques 
représentent la réalité brute des données circulant sur un réseau.


||**2⁷**|||**2⁶**|||**2⁵**|||**2⁴**|||**2³**|||**2²**|||**2¹**|||**2⁰**||
|128|64|32|16|8|4|2|1|


Le binaire est un langage base 2. Exemple : 222 en binaire 
Méthode de la division successives par 2, on lit les restes de bas en haut : 
222/2=111(0) → 111/2=55(1) → 55/2=27(1) → 27/2=13(1) → 13/2=6(1) → 6/2=3(0) → 3/2=1(1) 
→ 1/2=0(1) 
  222 = 1101 1110 (vérification : 128+64+16+8+4+2 = 222) 
 
Méthode décimal → binaire : soustraire successivement les puissances de 2 en partant de 128. 
Si le décimal est pair → se termine par 0 ; si impair → se termine par 1. 
 
Hexadécimal : 
L'hexadécimal utilise la base 16 (symboles 0-9 et A-F). Un octet (8 bits) se représente en 2 caractères 
hexadécimaux. C'est beaucoup plus compact pour lire la mémoire ou les adresses MAC. 
Exemple : 255 (décimal) = FF (hexadécimal) car F=15 → 15×16⁰ + 15×16¹ = 15 + 240 = 255

Partie 2 : Adressage et segmentation

1. Classes d'adresses IP

1.1 IPv4


||**Classe**|||**Plage publique**|||**Plage privée**|||**Masque par défaut**||
|A|1.0.0.0 → 126.255.255.255|10.0.0.0 → 10.255.255.255|/8|
|B|128.0.0.0 →<br>191.255.255.255|172.16.0.0 →<br>172.31.255.255|/16|
|C|192.0.0.0 →<br>223.255.255.255|192.168.0.0 →<br>192.168.255.255|/24|
|D & E|224.0.0.0 →<br>255.255.255.255|—|Réservées|


Adresse loopback/localhost : 127.0.0.1 (réservée pour tester la pile réseau locale). 
Ces classes sont obsolètes depuis 1993 au profit du CIDR (le fameux /24) voir ci-dessous. Aujourd'hui, 
on ne regarde plus la classe (A, B, C) pour définir le masque, on regarde le préfixe.

1.2 IPv6 — L'adressage de demain

IPv4 est un nombre d'une valeur de 32 bits représentée par 4 valeurs décimales pointées ; 
chacune a un poids de 8 bits (1 octet) prenant des valeurs décimales de 0 à 255 séparées par 
des points. Soit environ 4,3 milliards d'adresses. Ce stock est épuisé depuis 2011. IPv6 résout ce 
problème définitivement en utilisant 128 bits.

Format IPv6 : 8 groupes de 4 chiffres hexadécimaux séparés par des deux-points.

 Forme longue  : 2001:0db8:0000:0000:0000:0000:0000:0001 
 Règle de simplification : les groupes de zéros consécutifs peuvent être remplacés par ::

(une seule fois par adresse) 
 Forme simplifiée : 2001:db8::1 
 Une adresse IPv6 = 128 bits → 340 sextillions d'adresses disponibles

36


<!-- page 37 -->

||**Caractéristique**|||**IPv4**|||**IPv6**||
|Taille de l'adresse|32 bits|128 bits|
|Exemple|192.168.1.1|2001:db8::1|
|Adresses disponibles|~4,3 milliards|340 sextillions|
|NAT nécessaire ?|Oui (pénurie)|Non — assez d'adresses publiques pour<br>chaque appareil|
|Config. automatique|DHCP|SLAAC (auto-configuration native, sans<br>serveur)|
|Déploiement|Standard dominant|Remplacement progressif d'IPv4|


💡 Avec IPv6, le NAT devient inutile : chaque appareil peut avoir sa propre adresse publique 
mondiale. La coexistence IPv4/IPv6 (mode dual-stack) est aujourd'hui la norme sur les 
équipements récents.

2. Masque de sous-réseau et calculs

2.1 Masque de sous-réseau et calculs

Le masque sert à identifier la partie réseau (Net ID) et la partie hôte (Host ID) d'une adresse IP. 
Méthode ET logique : 1 ET 1 = 1 / 0 ET 1 = 0 / 1 ET 0 = 0 / 0 ET 0 = 0 
Exemple complet avec 192.168.1.2 /24 :


||**Étape**|||**Calcul**|||**Résultat**||
|Adresse IP en binaire|192.168.1.2|11000000.10101000.00000001.00000010|
|Masque en binaire|255.255.255.0|11111111.11111111.11111111.00000000|
|Adresse réseau (ET<br>logique)||||11000000.10101000.00000001.00000000<br>→ 192.168.1.0|
|Adresse broadcast|Remplacer 0 hôte par des<br>1|11000000.10101000.00000001.11111111<br>→ 192.168.1.255|
|1ère IP utilisable|Adresse réseau + 1|192.168.1.1|
|Dernière IP utilisable|Broadcast - 1|192.168.1.254|
|Nombre d'hôtes|2⁸ - 2 = 254|254 IP adressables|


Notation CIDR : 192.168.0.133/24 → nombre d'hôtes = 2^(32-24) - 2 = 254

Tuto calcul binaire/broadcast/plage adressable

IP + masque : 192.168.1.2 /24 
Convertir en binaire l’adresse IP :  
192.168.1.2 → 11000000.10101000.00000001.00000010 
Convertir en binaire le masque sous-réseau : 
255.255.255.0 → 11111111.11111111.11111111.00000000 
     [ 
      Net-ID Réseau         ][  Host-ID Hôte    ] 
Pour déterminer le nombre d’hôtes possibles, il suffit d’élever 2 à la puissance du nombre de 
0 de la partie hôte :

37


<!-- page 38 -->

ici le nombre de 0 est de 8, cela nous donne donc 2⁸ soit 256 hôtes (bien sûr le nombre d’IP 
adressable est égal à ce nombre -2, car on enlève l’adresse du réseau et du broadcast qui sont 
réservés soit 256-2=254 IPs adressables) 
Déterminer l’adresse réseau : 
Faire un ET logique entre l’ip en binaire et le masque de sous-réseau en binaire : 
(1 ET 0 =0 
0 ET 1=0  
0 ET 0=0 
1 ET 1=1) 
11000000.10101000.00000001.00000010 
ET 
11111111.11111111.11111111.00000000 
-→ 
11000000.10101000.00000001.00000000   ← adresse du réseau → 192.168.1.0 
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

2.1 Notation CIDR

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

2.2 Découpage en Sous-Réseaux

38

![Image 13](./images/image_013.png)


<!-- page 39 -->

39

![Image 14](./images/image_014.png)

![Image 15](./images/image_015.png)


<!-- page 40 -->

40

![Image 16](./images/image_016.png)


<!-- page 41 -->

41

![Image 17](./images/image_017.png)

![Image 18](./images/image_018.png)


<!-- page 42 -->

(Notes de William)

2.3 Route par défaut (Default Route)

✅ La route par défaut 0.0.0.0/0 est le filet de sécurité du routage.

Dans une table de routage, un routeur cherche la route la plus précise correspondant à l'IP 
destination. Si aucune route spécifique ne correspond, il utilise la route par défaut.

0.0.0.0/0 = Default Route : cette notation signifie littéralement "toutes les destinations". C'est le 
préfixe le moins spécifique possible (longueur de préfixe = 0). Tout paquet qui ne correspond à 
aucune route plus précise est envoyé vers cette passerelle.


||**Route**|||**Signification**|||**Exemple d'usage**||
|10.10.20.0/24|Route spécifique : uniquement le<br>réseau 10.10.20.0|Réseau de l'atelier|
|10.10.50.0/24|Route spécifique : uniquement le<br>réseau 10.10.50.0|Réseau des serveurs|
|0.0.0.0/0|Default route : TOUT le reste<br>(catch-all)|Route vers Internet (via le FAI)|


Routeur# show ip route 
C   10.10.20.0/24  via Gi0/0  ← réseau local atelier 
C   10.10.50.0/24  via Gi0/1  ← réseau serveurs 
S*  0.0.0.0/0      via 91.200.1.1  ← default route (vers Internet)

💡 Sur un PC Windows, la "Default Gateway" configurée manuellement ou par DHCP est 
l'équivalent de la default route : tout ce qui n'est pas local est envoyé vers cette adresse.

Partie 3 : Comment tout communique (OSI, encapsulation, TCP/IP)

1. Modèle OSI — 7 couches


||**Couche**|||**Nom**|||**Rôle**|||**Équipements/Protocoles**||
|7|Application|Données à transmettre|HTTP, FTP, DNS, SMTP|
|6|Présentation|Mise en forme,<br>chiffrement/déchiffrement|SSL/TLS|


42

![Image 19](./images/image_019.png)


<!-- page 43 -->

|5|Session|Synchroniser la<br>connexion entre deux<br>machines|La couche session est rarement isolée. Exemple<br>historique : NetBIOS (peu utilisé aujourd’hui)|
|---|---|---|---|
|4|Transport|Communication de bout<br>en bout|TCP (fiable) / UDP (rapide) (voir plus ci-après)<br>**DNS :** Utilise principalement l'**UDP 53** (rapide pour<br>les requêtes). Cependant, il utilise le**TCP 53** pour<br>les transferts de zone ou quand la réponse est<br>trop volumineuse.|
|3|Réseau|Adressage et routage|IP, Routeur / Le mécanisme ARP (voir ci dessous)<br>(Liaison Couche 2 / Couche 3) C'est le "pont"<br>entre l'IP et la MAC. Sans ARP, une machine ne<br>peut pas envoyer de paquet sur le réseau local.<br>**Principe :** "Je connais l'IP 192.168.1.50, mais<br>quelle est son adresse MAC ?"**Commande :** `arp`<br>`-a` (Windows) ou`show ip arp` (Cisco).|
|2|Liaison des<br>données|Adressage physique|Adresse MAC, Switch|
|1|Physique|Transmission des<br>signaux|Câbles (**Cat 5e :** Jusqu'à 1 Gbps.**Cat 6 / 6a :**<br>Jusqu'à 10 Gbps (le standard actuel en<br>entreprise).**Fibre Optique :** Pour les liaisons<br>longue distance ou entre switchs, Wi-Fi|


Moyen mnémotechnique (de 1 à 7) : « Pour le réseau tout se passe automatiquement » 
Conseil : 50% des pannes se résolvent en vérifiant la Couche 1 (le câble ou l'alimentation) !

• ARP — Mécanisme détaillé (Liaison Couche 2 / Couche 3) : ARP (Address 
Resolution Protocol) est le pont entre l'adresse IP (couche 3) et l'adresse MAC (couche 2). Sans 
ARP, une machine ne peut pas envoyer de paquet sur le réseau local, même si elle connaît l'IP de 
destination. 
 Principe : "Je connais l'IP 192.168.1.50, mais quelle est son adresse MAC ?" 
 Déroulement complet :


|**Étape**|<br>|**Type de**||**Destination**|**Contenu**|
|**Étape**|<br>|<br>**trame**|
|1 — ARP<br>Request|Broadcast|ff:ff:ff:ff:ff:ff (toute la<br>machine du réseau reçoit)|"Qui a l'IP 192.168.1.50 ? Réponds à<br>aa:bb:cc:dd:ee:ff"|
|2 — ARP<br>Reply|Unicast|Directement vers<br>l'expéditeur (MAC connue<br>maintenant)|"C'est moi ! Mon adresse MAC est<br>11:22:33:44:55:66"|
|3 — Mise en<br>cache|— (local)|Table ARP locale de<br>l'expéditeur|IP 192.168.1.50 ↔ MAC<br>11:22:33:44:55:66 (durée limitée)|


Cache ARP : après résolution, l'association IP ↔ MAC est stockée temporairement en mémoire pour 
éviter de répéter la requête broadcast à chaque paquet. Ce cache a un délai d'expiration (timeout) :

• 
Windows : ~2 minutes par défaut 
• 
Linux/Cisco : ~5 minutes par défaut 
• 
Après expiration, une nouvelle ARP Request est émise si la communication reprend 
Commande de consultation :

arp -a                          (Windows) 
ip neigh show                   (Linux)

43


<!-- page 44 -->

show ip arp                     (Cisco IOS)

💡 Si deux machines ont la même IP sur un réseau, leurs ARP Reply se concurrencent → conflit ARP 
→ interruptions aléatoires. C'est un piège classique lors de la mise en production d'un nouveau 
serveur.

• 
TLS / SSL — Le chiffrement des communications : Définition TLS (Transport Layer Security) 
est le protocole qui chiffre les données échangées entre un client et un serveur. C'est lui qui affiche 
le cadenas dans le navigateur. SSL est son prédécesseur — il est abandonné depuis 2015 et ne 
doit plus être utilisé. Quand on dit encore "SSL" dans le langage courant, on parle en réalité de 
TLS. Versions : TLS 1.2 → encore très répandu, acceptable / TLS 1.3 → version actuelle / 
recommandée, plus rapide et plus sécurisée / SSL / TLS 1.0 / TLS 1.1 → obsolètes, à désactiver 
Le handshake TLS — Comment ça fonctionne Avant d'échanger la moindre donnée, le client et le 
serveur négocient en 4 étapes :

• 
Le client dit : "Bonjour, voici les algorithmes de chiffrement que je supporte" 
• 
Le serveur répond et envoie son certificat (preuve de son identité) 
• 
Le client vérifie le certificat auprès d'une autorité de certification (CA) 
• 
Une clé de session chiffrée est générée → la communication peut commencer

Si le certificat est expiré ou non reconnu → le navigateur bloque l'accès avec une erreur "Votre 
connexion n'est pas privée". C'est la couche 6 qui signale le problème.

Lien avec les ports : Port 80 → HTTP (non chiffré) Port 443 → HTTPS (chiffré via TLS)

Sur le terrain Un certificat TLS expiré = les utilisateurs ne peuvent plus accéder à l'application → ticket de 
support. Première chose à vérifier : date d'expiration du certificat (dans le navigateur : cliquer sur le 
cadenas → Certificat → Date de validité).

• 
DNS et UDP/TCP : DNS utilise principalement l'UDP 53 (rapide pour les requêtes). Il utilise TCP 53 
pour les transferts de zone ou quand la réponse est trop volumineuse.

2. L'encapsulation 
Les données sont encapsulées de la couche 7 vers la couche 1 : on ajoute un en-tête à chaque couche 
(comme une lettre dans une enveloppe).


||**Couche**|||**Analogie postale**||
|Application|Tu écris ton message (la donnée)|
|Transport|Tu mets la lettre dans une enveloppe (TCP = recommandé, UDP = simple)|
|Réseau|Tu écris les adresses IP expéditeur/destinataire|
|Accès Réseau|La lettre est mise dans le camion (câble ou Wi-Fi)|


Utilisation pour le dépannage : Je n'ai plus internet → je commence par vérifier le câble (couche 1), puis les 
paramètres réseau (couche 3), puis l'application (couche 7).

3. Le modèle TCP/IP — 4 couches 
Le Modèle TCP/IP est un modèle réseau en 4 couches qui décrit comment les données sont transmises 
sur Internet à l’aide de protocoles comme TCP et IP.


||**Couche**|||**Rôle**|||**Protocoles**||
|4 - Application|Interface avec l'utilisateur,<br>prépare les données|HTTP, FTP, SMTP, DNS|
|3 - Transport|Communication bout en bout,<br>vérification des données|TCP (fiable) / UDP (rapide)|


44


<!-- page 45 -->

|2 - Réseau (Internet)|Adresse et route les paquets<br>entre réseaux|IP (IPv4/IPv6), ICMP (Ping)|
|---|---|---|
|1 - Liaison (Accès<br>réseau)|Transforme les données en<br>signaux physiques|Ethernet, Wi-Fi (802.11), Fibre|


4. Notion de port — Identification des applications  
L'adresse IP identifie une machine sur le réseau. Mais une machine fait tourner plusieurs services 
en même temps (serveur web, messagerie, DNS…). Le numéro de port permet de distinguer quel 
service est concerné par un paquet.

Combinaison clé : IP + Port = Socket. C'est le couple qui identifie de façon unique une 
communication réseau.

Exemple : 192.168.1.10:443 = machine 192.168.1.10, service HTTPS (port 443)

 Ports 0-1023 : ports bien connus (réservés aux services standards comme HTTP=80,

HTTPS=443, SSH=22) 
 Ports 1024-49151 : ports enregistrés (applications spécifiques comme RDP=3389, ERP

custom...) 
 Ports 49152-65535 : ports dynamiques/éphémères (utilisés par le client pour établir une

connexion)


||**Protocole**|||**Port(s)**|||**Description**|||**TCP ou UDP ?**||
|HTTP|80|Navigation web non sécurisée|TCP|
|HTTPS|443|Navigation web sécurisée (TLS)|TCP|
|DNS|53|Résolution de noms|UDP (requêtes) / TCP (transferts)|
|DHCP|67/68|Attribution automatique des IP|UDP|
|SSH|22|Connexion à distance sécurisée|TCP|
|FTP|20-21|Transfert de fichiers|TCP|
|SFTP|22|FTP sécurisé (via SSH)|TCP|
|RDP|3389|Bureau à distance Windows|TCP|
|SMTP|25|Envoi d'emails|TCP|
|POP3|110|Réception d'emails (téléchargement)|TCP|
|IMAP|143|Réception d'emails (synchronisation)|TCP|
|SNMP|161|Supervision et monitoring réseau|UDP|


TCP vs UDP — Comparatif


||**Caractéristique**|||**TCP**|||**UDP**||
|Fiabilité|Très élevée (accusés de réception)|Faible (pas de vérification)|
|Vitesse|Plus lent|Très rapide|
|Ordre des paquets|Garanti (1, 2, 3...)|Non garanti (ordre non assuré)|


45


<!-- page 46 -->

|Analogie|Lettre recommandée|Mégaphone dans la rue|
|---|---|---|
|Exemple d'usage|Téléchargement, navigation web,<br>RDP|Streaming, jeux en ligne, VoIP|


4. Le Modèle OSI — Application terrain

4.1. Mise en situation — L'ERP inaccessible chez Aérotec

🔷 Contexte (vidéo Formip) 
Sonia, admin réseau chez Aérotec Industrie (200 postes, usine aéronautique), reçoit une alerte : l'ERP 
est inaccessible depuis tous les postes de l'atelier. Les opérateurs ne peuvent plus scanner les pièces. 
La chaîne de production est à l'arrêt. Sa méthode : le modèle OSI couche par couche, de bas en haut. 
💡 La règle d'or de Sonia 
« On ne saute jamais une marche. Tu commences en bas, tu vérifies, tu élimines, tu montes. »

4.2. La méthode Bottom-Up — OSI comme plan d'enquête

Le modèle OSI n'est pas qu'un schéma à apprendre par cœur : c'est un plan d'enquête structuré. Chaque 
couche est un étage à inspecter. On commence toujours par le bas (le câble) et on remonte vers 
l'application.


|**Couche**|**Nom**|<br>|**Commande clé**||**Ce qu'on vérifie**|
|**Couche**|**Nom**|<br>|**(Cisco)**|
|**1**|**Physique**|<br> <br>|`show interfaces`||Ports connectés, vitesse, compteurs<br>CRC/erreurs|
|**1**|**Physique**|<br> <br>|`status`|
|**1**|**Physique**|<br> <br>|`show interface Gi0/3`|
|**2**|**Liaison**|<br> <br>|`show mac address-`||Adresses MAC apprises, topologie<br>voisins, erreurs L2|
|**2**|**Liaison**|<br> <br>|`table`|
|**2**|**Liaison**|<br> <br>|`show cdp neighbors`|
|**3**|**Réseau**|<br> <br> <br> <br>|`show ip interface`||Interfaces UP/DOWN, joignabilité IP,<br>routes, résolution ARP|
|**3**|**Réseau**|<br> <br> <br> <br>|`brief`|
|**3**|**Réseau**|<br> <br> <br> <br>|`ping <IP>`|
|**3**|**Réseau**|<br> <br> <br> <br>|`show ip route`|
|**3**|**Réseau**|<br> <br> <br> <br>|`show ip arp`|
|**4**|**Transport**|`telnet <IP> <PORT>`<br>`netstat -an`|<br>|Port TCP ouvert ou fermé, service en||
|**4**|**Transport**|`telnet <IP> <PORT>`<br>`netstat -an`|<br>|<br>écoute|
|**5-6-7**|<br>|**Session /**||`Test applicatif`<br>`direct`|<br>|Vérification groupée : l'application||
|**5-6-7**|<br>|**Présent. / App.**|<br>répond-elle ?|


4.3. Déroulé du diagnostic — Couche par couche

Couche 1 — Physique

Première vérification : les ports sont-ils physiquement connectés ? Y a-t-il des erreurs de signal ? 
 
SW-Atelier# show interfaces status 
Port     Status      Speed   Duplex  VLAN 
Gi0/1    connected   1000    full    20 
... 
 
SW-Atelier# show interface GigabitEthernet 0/3 
→ 0 CRC errors, 0 runts, 0 giants   ← Signal propre 
 
Résultat : tous les ports sont connectés, zéro erreur CRC. Couche 1 ✅ éliminée.

46


<!-- page 47 -->

🔷 Note sur les erreurs CRC 
47 erreurs CRC détectées sur le lien montant (uplink) depuis le dernier reset des compteurs. 
Non critique sur plusieurs semaines, mais signe d'un câble vieillissant. À surveiller.

Couche 2 — Liaison des données

Vérification que le switch reconnaît bien les machines et que la topologie est conforme. 
SW-Atelier# show mac address-table 
→ Adresses MAC des postes atelier présentes, bon port, bon VLAN 
 
SW-Atelier# show cdp neighbors 
→ Switch de distribution visible sur Gi0/48 
→ Switch bureau d'études visible sur Gi0/47 
   Topologie conforme au schéma réseau. 
Résultat : trames circulantes, MACs apprises, voisins visibles. Couche 2 ✅ éliminée.

Couche 3 — Réseau

L'atelier (10.10.20.0/24) et le serveur ERP (10.10.50.0/24) sont sur des réseaux différents : les paquets 
passent obligatoirement par le routeur. 
 
Routeur# show ip interface brief 
GigabitEthernet0/0   10.10.20.1   UP/UP   ← vers atelier 
GigabitEthernet0/1   10.10.50.1   UP/UP   ← vers serveurs 
 
Routeur# ping 10.10.50.10 
!!!!!   →   5/5 reçus. Routeur atteint le serveur ERP. 
 
Routeur# show ip route 
C  10.10.20.0/24 via Gi0/0   ← réseau atelier 
C  10.10.50.0/24 via Gi0/1   ← réseau serveurs 
 
Routeur# show ip arp 
10.10.50.10   →   aa:bb:cc:dd:ee:ff   ← résolution ARP OK 
 
Résultat : routage fonctionnel, ARP résolu, ping depuis les postes atelier = 4/4. Couche 3 ✅ éliminée. 
💡 Et pourtant… 
Câble OK. Trames OK. Paquets OK. Mais l'ERP reste inaccessible. Le problème est plus haut.

Couche 4 — Transport (TCP/UDP)

Un ping fonctionne → Couche 3 OK. Mais le ping utilise ICMP, pas TCP. L'ERP communique en TCP sur 
un port précis. C'est ce port qu'il faut tester. 
 
Poste-Atelier> telnet 10.10.50.10 8080 
→ Connection refused   ← Le port 8080 ne répond pas 
 
# Sur le serveur ERP (Windows Server) : 
C:\> netstat -an | findstr 8080 
→ (aucun résultat)   ← 8080 n'est PAS en écoute 
 
C:\> netstat -an | findstr LISTENING 
→ 0.0.0.0:9090   LISTENING   ← L'ERP écoute sur 9090 ! 
 
🔷 Cause identifiée 
Une mise à jour de l'ERP déployée le samedi soir a changé le port par défaut : 8080 → 9090. 
La note de version le mentionnait en page 14. Personne n'avait lu. Personne n'avait prévenu l'équipe réseau. 
Résultat : le pare-feu autorisait toujours le TCP/8080, mais bloquait le TCP/9090 (jamais ajouté en liste blanche).

4.4. Résolution — Pare-feu Cisco

47


<!-- page 48 -->

Deux actions : ouvrir le nouveau port 9090, fermer l'ancien port 8080 devenu inutile (une porte ouverte 
inutilement = un risque de sécurité). 
Routeur# configure terminal 
 
! Autoriser TCP depuis l'atelier vers l'ERP sur le nouveau port 
Routeur(config)# access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 9090 
 
! Supprimer l'ancienne règle devenue obsolète 
Routeur(config)# no access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 8080 
 
! Vérifier 
Routeur# show access-list 101 
→ permit tcp ... eq 9090   ✓ 
→ (eq 8080 disparaît)      ✓ 
 
Poste-Atelier> telnet 10.10.50.10 9090 
→ Connexion établie. Handshake TCP OK. ERP accessible. 
⏱ Durée totale du diagnostic : 25 minutes. Couche 1 → Couche 4. Sans paniquer, sans tirer dans le 
tas.

4.5. Pourquoi les couches 5, 6 et 7 n'ont pas été diagnostiquées séparément

Dans la théorie, les 7 couches OSI sont distinctes. Sur le terrain, les couches 5, 6 et 7 sont quasiment 
toujours fusionnées dans les protocoles modernes (ex. HTTPS gère session + chiffrement TLS + HTTP 
ensemble).


||**Couche**|||**Nom**|||**Réalité terrain**||
|**5**|**Session**|<br> <br>|Gère l'ouverture/fermeture des sessions. Pas de||
|**5**|**Session**|<br> <br>|commande isolée — on le détecte en testant|
|**5**|**Session**|<br> <br>|l'application.|
|**6**|**Présentation**|<br>|Chiffrement SSL/TLS, encodage. Vérifié globalement||
|**6**|**Présentation**|<br>|<br>(ex. certificat expiré → erreur à l'ouverture de l'appli).|
|**7**|**Application**|<br> <br>|L'interface utilisateur. Si TCP (C4) passe → on teste||
|**7**|**Application**|<br> <br>|<br>directement l'appli. Les 3 couches se valident d'un|
|**7**|**Application**|<br> <br>|coup.|


💡 Règle pratique 
Les couches 1 à 4 se diagnostiquent une par une avec des commandes précises. Les couches 5, 6 et 7 se vérifient 
ensemble en testant l'application. Ce n'est pas un raccourci — c'est ainsi que fonctionnent les réseaux modernes.

4.6. La Couche 8 — L'interface chaise-clavier (ICC)

Même jour, second ticket : M. Duran (comptabilité) n'a plus de réseau du tout. Plus de ping, plus rien. Marc 
a déjà vérifié à distance — sans succès. 
Sonia se déplace. Constat en 8 secondes : le câble RJ45 est débranché. M. Duran avait déplacé des 
bureaux vendredi soir pour un pot de départ et le câble avait sauté. Il n'avait pas vérifié.


||**Couche 8**|||**Définition**||
|**Interface Chaise-**<br>**Clavier (ICC)**|<br> <br>|Erreur humaine entre l'utilisateur et la machine. Aucun protocole ne peut la||
|**Interface Chaise-**<br>**Clavier (ICC)**|<br> <br>|corriger, aucun pare-feu ne peut la filtrer, aucune mise à jour ne peut la|
|**Interface Chaise-**<br>**Clavier (ICC)**|<br> <br>|<br>patcher.|


Temps de diagnostic : 8 secondes.  Temps de résolution : 1 seconde. 
🔷 Statistique terrain 
Statistiquement, la couche 8 génère le plus grand nombre de tickets en entreprise. 
La bonne pratique : avant de lancer un diagnostic OSI complet, vérifier l'évidence physique (câble branché ?). 
→ C'est d'ailleurs pourquoi le conseil du cours reste valide : 50% des pannes = couche 1.

4.7. Récapitulatif — Ce qu'il faut retenir

48


<!-- page 49 -->

 Le modèle OSI est un outil de diagnostic, pas juste un schéma théorique 
 Méthode bottom-up : couche 1 → couche 7, sans sauter d'étape 
 Quand une couche basse est en panne, toutes les couches au-dessus sont impactées (effet

domino) 
 Un ping qui fonctionne prouve la couche 3, PAS la couche 4 (ping = ICMP, pas TCP) 
 Tester un port TCP : telnet <IP> <PORT> ou netstat -an sur le serveur 
 Les couches 5, 6, 7 se valident ensemble en testant directement l'application 
 La couche 8 (erreur humaine) est souvent la première cause à éliminer physiquement 
💡 Morale de l'histoire (Sonia) 
« Un réseau qui tombe, c'est rarement un drame, c'est un puzzle. Et le modèle OSI, c'est la boîte qui contient toutes 
les pièces rangées par catégorie. Tu n'y cherches pas au hasard — tu ouvres le bon tiroir. »

5. Les VLANs : segmentation logique des réseaux

5.1 Mise en situation — Le cas AéroSud

Contexte (vidéo Formip) : Nadia, admin réseau chez AéroSud (fabricant aéronautique, 120 employés, 4 
étages), arrive un lundi matin et reçoit un appel urgent du DAF : un stagiaire du marketing vient de tomber 
sur les fiches de paie de toute l'entreprise. Le coupable ? Un réseau non segmenté depuis 3 ans.  
Le diagnostic de Nadia est immédiat. Elle se connecte en SSH sur le switch principal et tape : 
 
AeroSud-SW1# show vlan brief 
 
VLAN  Name       Status   Ports 
----  ---------  ------   ------ 
1     default    active   Fa0/1, Fa0/2 ... Fa0/48 
 
→ 48 ports. Tous dans le VLAN 1 (VLAN d'usine). Aucune segmentation. 
 
Ce résultat révèle un réseau "plat" : un seul domaine de broadcast, aucun cloisonnement entre la 
comptabilité, la R&D, le marketing, la direction et le showroom. 
 
Deuxième appel dans la matinée : les caisses du showroom tombent. Un technicien R&D est en train de 
transférer 40 Go entre deux serveurs — son trafic sature tout le réseau, caisses incluses. 
 
  Problème fondamental 
Un réseau plat = tout le monde voit tout le monde, tout le monde subit le trafic de tout le monde. Ça « 
marche » jusqu'au jour où ça explose.

Partie 4 : organisation avancées (VLANs)

1. Définition et intérêt des VLANs

Un VLAN (Virtual Local Area Network) est un réseau local logique créé par configuration logicielle sur un 
ou plusieurs switchs physiques. 
Sans acheter un seul câble ni un seul switch supplémentaire, on crée des murs virtuels qui isolent les flux 
entre services.

2. Les 3 piliers des VLANs


||**Pilier**|||**Bénéfice**|||**Exemple AéroSud**||
||||Isolation par défaut entre<br>VLANs|Le stagiaire marketing ne peut plus accéder<br>au serveur comptabilité|
|** Sécurité**|


49


<!-- page 50 -->

|Col1|Chaque VLAN = son propre<br>domaine de broadcast →<br>moins de congestion|Le transfert R&D de 40 Go ne noie plus les<br>caisses du showroom|
|---|---|---|
|** Réduction des**<br>**broadcasts**|
||Regroupement logique<br>indépendant de la position<br>physique|Pas besoin de tirer de nouveaux câbles : on<br>reconfigure les ports|
|** Flexibilité**|


3. Sans VLAN vs Avec VLAN


||**Caractéristique**|||❌** Sans VLAN**|||✅** Avec VLAN**||
||||Faible — tout le monde voit tout|Élevée — isolation par défaut|
||**Sécurité**||||||||
||||Un seul gros domaine (tous les<br>postes)|Plusieurs petits domaines<br>indépendants|
|**Broadcast**|
||||Physique — dépend des câbles|Logique — logicielle et flexible|
||**Gestion**||||||||
||||Difficile — tout est lié|Facilitée — on touche un VLAN<br>sans impacter les autres|
|**Maintenance**|


4. Ports Access et Ports Trunk

• Port Access 
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

• Port Trunk

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

5. Plan de VLAN — Application pratique

50


<!-- page 51 -->

Nadia définit 5 VLANs pour AéroSud. La numérotation commence à 10 et progresse par intervalles de 10 
— convention professionnelle permettant d'insérer de nouveaux VLANs ultérieurement sans casser la 
numérotation.


||**VLAN**|||**Nom**|||**Service**|||**Ports (Switch 1)**||
||**VLAN 10**|||`COMPTA`|||Comptabilité / Finance — 1er étage|||`Fa0/1 → Fa0/12`||
|**VLAN 20**|`RD`|<br>|Recherche & Développement — 2e||`Fa0/13 → Fa0/24`|
|**VLAN 20**|`RD`|<br>|<br>étage|
||**VLAN 30**|||`MARKETING`|||Marketing — 3e étage|||`Fa0/25 → Fa0/36`||
||**VLAN 40**|||`DIRECTION`|||Direction — 4e étage|||`Fa0/37 → Fa0/42`||
||**VLAN 50**|||`SHOWROOM`|||Caisses & bornes — RDC|||`Fa0/43 → Fa0/48`||


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

51


<!-- page 52 -->

Étape 4 — Sauvegarder (INDISPENSABLE) 
SW1# copy running-config startup-config 
 
! Sur Cisco : la running-config est en RAM → perdue au reboot 
! La startup-config est en NVRAM → persistante 
! Ne jamais oublier cette étape sous peine de tout refaire

5.8 Vérification — Les commandes essentielles


||**Commande**|||**Ce qu'elle vérifie**||
||`show vlan brief`|||Liste des VLANs créés, leurs noms, et les ports assignés||
|`show interfaces trunk`|<br>|Ports en mode trunk, encapsulation 802.1Q, VLANs actifs||
|`show interfaces trunk`|<br>|<br>sur le trunk|
|`show mac address-table`|<br>|Table d'adresses MAC : quelle adresse est sur quel port →||
|`show mac address-table`|<br>|<br>identifier qui est branché où|
|`ping <IP_destination>`|<br>|Tester l'isolation : un ping en timeout entre deux VLANs||
|`ping <IP_destination>`|<br>|<br>différents = succès de la segmentation|


🔷 Un ping en timeout = bonne nouvelle 
Nadia sourit quand le ping du poste marketing vers le serveur compta retourne 4 timeouts. C'est exactement le 
résultat attendu : l'isolation fonctionne.

5.9. Communication inter-VLAN

Par défaut, deux VLANs différents ne peuvent pas communiquer. Pour autoriser des échanges contrôlés 
(ex. la direction accède aux données comptables), il faut obligatoirement un équipement de couche 3 :

 Un routeur (méthode « Router-on-a-stick ») 
 Un switch de niveau 3 (switch L3) avec des interfaces virtuelles (SVI) 
 
📌 Métaphore de Nadia 
"Les VLANs, c'est poser les murs. Le routage inter-VLAN, c'est installer les portes à badge. On pose les murs en 
premier, les portes après." — Nadia, réunion de crise AéroSud 
Le routage inter-VLAN fera l'objet d'un cours dédié.

5.10. Résumé — Ce qu'il faut retenir

 Un VLAN = un réseau logique isolé sur un équipement physique 
 VLAN 1 = VLAN d'usine sur Cisco → ne jamais laisser des postes en production dessus 
 Port Access = un seul VLAN, trafic non taggué → équipements finaux 
 Port Trunk = plusieurs VLANs, trafic taggué 802.1Q → liens inter-switch 
 Toujours nommer ses VLANs et sauvegarder (copy running-config startup-config) 
 Pour faire communiquer deux VLANs → équipement routeur ou switch L3 obligatoire 
 Les VLANs ne coûtent rien en matériel : c'est de la configuration pure 
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

52


<!-- page 53 -->

5.11. Sécurité des ports (Port-Security)

La Port-Security permet de restreindre l'accès à un port du switch en fonction de l'adresse MAC de 
l'équipement qui s'y connecte. C'est la première barrière contre l'intrusion physique dans un réseau 
d'entreprise. 
Pourquoi l'utiliser ?

• 
Empêcher un visiteur de débrancher une imprimante pour connecter son propre ordinateur. 
• 
Limiter le nombre de machines pouvant se connecter à une seule prise murale. 
• 
Bloquer automatiquement un port si une anomalie est détectée. 
Les 3 modes de réaction (Violation) 
Si une adresse MAC non autorisée se branche, le switch peut réagir de trois façons :

• 
Protect : Les paquets de l'intrus sont jetés, mais le port reste actif pour les autres. 
• 
Restrict : Idem, mais le switch envoie une alerte (log/SNMP) et incrémente un compteur de 
violations. 
• 
Shutdown (Par défaut) : Le port se désactive immédiatement (err-disable). Il faut l'intervention 
d'un technicien (shutdown puis no shutdown) pour le réactiver. 
Exemple de configuration (Cisco) 
Nadia veut sécuriser le port du bureau d'accueil pour qu'uniquement le PC de la réception puisse s'y 
connecter : 
Bash 
SW1(config)# interface fastEthernet 0/5 
SW1(config-if)# switchport mode access 
SW1(config-if)# switchport port-security          ! Active la sécurité 
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

Partie 5 : Services et Protocoles Critiques

1. Serveur DHCP 
Dynamic Host Configuration Protocol : distribue automatiquement les adresses IP et paramètres réseau 
(masque, passerelle, DNS). Processus DORA :


||**Étape**|||**Description**||
|D - Discover|Le client diffuse une requête pour trouver un serveur DHCP (paquet UDP)|
|O - Offer|Le serveur propose une adresse IP avec durée de bail|
|R - Request|Le client accepte l'offre et demande à louer l'IP|
|A - Acknowledge|Le serveur confirme l'attribution de l'adresse IP|


Ports DHCP : 67 (serveur) et 68 (client)

L'adresse APIPA (Automatic Private IP Addressing) est une fonctionnalité des systèmes d'exploitation 
(principalement Windows) qui permet à un appareil de s'attribuer automatiquement une adresse IP lorsqu'il 
ne parvient pas à contacter un serveur DHCP. Les adresses APIPA appartiennent à la plage 
169.254.0.0/16, souvent résumée en 169.254.x.x. Pourquoi cela arrive ? Si vous voyez une adresse 
commençant par 169.254, c'est généralement le signe d'un problème réseau : Le serveur DHCP (souvent

53


<!-- page 54 -->

votre box internet) est inaccessible / Le câble Ethernet est mal branché ou le Wi-Fi est déconnecté / Le 
service DHCP est en panne.

À quoi ça sert ? Communication locale : Elle permet à deux ordinateurs reliés par un simple câble de 
communiquer entre eux sans configuration manuelle. Diagnostic : Elle sert d'indicateur visuel pour savoir 
que l'ordinateur cherche une IP mais n'en reçoit aucune.

Limite : Pas d'Internet : Une adresse APIPA ne permet pas de naviguer sur le Web (pas de passerelle par 
défaut). / Local uniquement : Les communications sont limitées au segment de réseau local.

En résumé : Si votre PC affiche une adresse en 169.254.x.x, c'est qu'il est "en mode secours" car il n'a 
pas réussi à obtenir de configuration réseau valide.

2. Serveur DNS 
Convertit les noms de domaine en adresses IP. Hiérarchie :


||**Niveau**|||**Exemple**||
|Domaine racine|.|
|Domaine de premier niveau (TLD)|.fr .com .org|
|Domaine de second niveau|wikipedia|
|Sous-domaine|fr (→ fr.wikipedia.org)|


Fonctionnement : fr.wikipedia.org → DNS récursif → DNS racine → DNS .org → DNS wikipedia.org → 
adresse IP 
Port DNS : 53

3. Pare-feu (Firewall)

Un pare-feu est un équipement (matériel ou logiciel) qui contrôle et filtre le trafic réseau entrant et sortant 
selon un ensemble de règles définies par l'administrateur.

Principe de base : le pare-feu analyse chaque paquet et décide de l'autoriser (PERMIT) ou de le bloquer 
(DENY) en fonction de règles portant sur :

 L'adresse IP source et/ou destination 
 Le numéro de port (service concerné) 
 Le protocole (TCP, UDP, ICMP...) 
 La direction du trafic (entrant / sortant)  
Exemple vu dans le cours Aérotec : le pare feu autorisait TCP/8080 mais bloquait TCP/9090.  
Résultat : l'ERP inaccessible depuis les postes de l'atelier, même si le routage était fonctionnel.

Stateless vs Stateful — Les deux modes de filtrage


||**Type**|||**Fonctionnement**|||**Avantage**|||**Inconvénient**|||**Exemple**||
|Stateless<br>(sans état)|Analyse chaque paquet<br>indépendamment, sans<br>mémoire des connexions<br>précédentes|Très rapide,<br>peu<br>gourmand<br>en<br>ressources|Ne voit pas le contexte : ne<br>sait pas si une réponse<br>correspond à une requête<br>légitime|ACL Cisco<br>classique<br>(access-list)|
|Stateful<br>(avec état)|Suit l'état de chaque<br>connexion TCP. Autorise<br>automatiquement les<br>réponses aux<br>connexions initiées de<br>l'intérieur|Plus<br>intelligent,<br>meilleure<br>sécurité|Plus gourmand en<br>ressources (table de<br>connexions)|Cisco ASA,<br>pfSense, pare-<br>feu Windows|


54


<!-- page 55 -->

💡 Analogie : Stateless = vigile qui vérifie chaque carte d'entrée sans se souvenir des personnes déjà 
passées. Stateful = vigile qui tient un registre et sait que M. Duran est entré il y a 10 minutes, donc sa 
réponse de sortie est légitime. 
 Règle d'or du pare-feu : principe du moindre privilège. On autorise uniquement ce qui est nécessaire 
(whitelist), on bloque tout le reste par défaut. Une porte ouverte inutilement = un risque de sécurité.

! Cisco — exemple de règles ACL stateless 
access-list 101 permit tcp 10.10.20.0 0.0.0.255 host 10.10.50.10 eq 9090 
access-list 101 deny   ip any any  ← bloque tout le reste

4. Configuration d'un routeur

Accéder à l'interface d'un routeur inconnu

• 
Brancher le routeur à l'ordinateur via un câble RJ45 (port LAN) 
• 
Le routeur attribue automatiquement une IP via son DHCP → vérifier avec ipconfig 
• 
Si pas de DHCP : configurer une IP fixe dans le même sous-réseau que le routeur (ex : 
192.168.1.50 si le routeur est en 192.168.1.1)

Commandes utiles (Windows)

ipconfig /release    →  Libère l'adresse IP actuelle 
ipconfig /renew      →  Demande une nouvelle IP via DHCP 
ipconfig             →  Affiche IP, masque, passerelle

Trouver l'adresse de l'interface web

• 
Regarder la Passerelle par défaut dans ipconfig → taper cette adresse dans le navigateur 
• 
Adresses courantes : 192.168.0.1 / 192.168.1.1 
• 
Identifiants par défaut : admin / admin (à changer immédiatement)

Les identifiants par défaut sont publics sur Internet. Un routeur avec admin/admin sur un réseau 
d'entreprise est une faille de sécurité ouverte.

Paramètres essentiels à configurer

• 
SSID et mot de passe Wi-Fi (WPA2 minimum, WPA3 si disponible) 
• 
Mode Wi-Fi : routeur / point d'accès (AP) / répéteur 
• 
DHCP : activer/désactiver, plage d'adresses, durée du bail 
• 
NAT/PAT : règles de redirection de ports 
• 
DNS et paramètres WAN (connexion Internet) 
• 
Désactiver le WPS

5. NAT / PAT — Redirection de ports (Port Forwarding)

• 
NAT (Network Address Translation) : traduit une adresse IP privée en IP publique (et inversement). 
Permet à tout un réseau local de sortir sur Internet avec une seule IP publique. 
• 
PAT (Port Address Translation) : version du NAT qui inclut les numéros de port. Permet de rediriger 
un port public précis vers une machine interne spécifique. C'est ce qu'on utilise concrètement à la 
maison et en entreprise.

Exemple concret Objectif : rendre un serveur GLPI accessible depuis Internet.

Règle PAT configurée sur la box :

Port externe (WAN) : 4444 
→  Machine interne hébergeant GLPI : 192.168.1.10 : port 443

55


<!-- page 56 -->

Résultat : en tapant IP_publique:4444 dans un navigateur depuis n'importe où, on arrive directement sur le 
serveur GLPI.

Trouver son IP publique

• 
Se rendre sur monip.org ou whatismyip.com 
• 
L'adresse affichée est celle de la box côté Internet

6. DMZ — Zone démilitarisée

La DMZ est une zone réseau isolée placée entre Internet et le réseau interne. Elle permet d'exposer un 
serveur à Internet sans mettre en danger le reste du réseau local.

DMZ 
NAT/PAT 
Exposition 
Totale (tous ports ouverts) 
Ciblée (un ou plusieurs ports) 
Sécurité 
Faible 
Meilleure 
Usage 
Serveur web public, reverse proxy 
Accès à distance ciblé (GLPI, RDP…)

Placer un serveur en DMZ l'expose à TOUT Internet sur TOUS les ports. Préférer systématiquement le 
NAT/PAT ciblé sauf cas très spécifique.

7. SSH — Accès à distance sécurisé

Définition SSH (Secure Shell) est le protocole utilisé pour administrer à distance un équipement réseau 
(routeur, switch, serveur Linux) en ligne de commande. Il chiffre intégralement la communication — 
contrairement à Telnet qui envoie tout en clair.

Port : 22 (TCP)

Deux modes d'authentification

Mode 
Fonctionnement 
Sécurité 
Par mot de 
passe 
Login + mot de passe saisis à chaque connexion 
Correct mais vulnérable au 
brute-force

Par clé 
(recommandé)

Paire clé publique / clé privée — la clé privée ne quitte 
jamais le poste client

Élevée — même sans mot 
de passe

Commandes essentielles

ssh admin@192.168.1.1          →  Connexion SSH à un équipement 
ssh -p 2222 admin@192.168.1.1  →  SSH sur un port non standard 
exit                           →  Fermer la session SSH

Sur un équipement Cisco (configuration SSH)

Router(config)# hostname RTR-Principal 
Router(config)# ip domain-name aerosud.local 
Router(config)# crypto key generate rsa modulus 2048 
Router(config)# ip ssh version 2 
Router(config)# line vty 0 4 
Router(config-line)# transport input ssh 
Router(config-line)# login local

Telnet vs SSH : Telnet (port 23) envoie les mots de passe en clair sur le réseau — n'importe qui avec 
Wireshark peut les capturer. SSH est son remplacement obligatoire. En 2024, utiliser Telnet en production 
est une faute professionnelle.

56


<!-- page 57 -->

Sur le terrain SSH est l'outil quotidien du technicien réseau pour administrer les switchs et routeurs à 
distance, sans avoir à se déplacer physiquement dans la salle serveur. Couplé à un jump server (bastion 
SSH), il permet de sécuriser tous les accès d'administration du réseau depuis un point unique.

8. Commandes réseau essentielles


||**Commande**|||**Description**||
|ipconfig|Afficher la configuration réseau (IP, masque, passerelle, DNS)|
|ipconfig /all|Version détaillée avec adresse MAC, serveur DHCP, etc.|
|ipconfig /release|Ordinateur a**bandonne son adresse IP actuelle** en informant le serveur<br>DHCP qu'il ne l'utilise plus, ce qui coupe momentanément toute<br>connexion réseau.|
|ipconfig /renew|Demande au serveur DHCP de**vous attribuer une nouvelle adresse**<br>**IP** (ou de prolonger l'actuelle)|
|ping [IP/site]|Tester la connectivité et mesurer la latence (ms)|
|tracert [IP/site]|Tracer le chemin d'un paquet saut par saut (voir où il se bloque)|
|Pathping [IP/site]|Combine les fonctionnalités de Ping et Tracert|
|netstat -an|Lister les ports ouverts et les connexions actives|
|arp -a|Afficher le cache ARP (table IP ↔ MAC locale)|
|nslookup [nom]|Tester la résolution DNS d'un nom de domaine|
|test-netconnexion|teste la connectivité réseau|
|systeminfo|Liste les configurations de la machine et du réseau|
|netstat|Connexions réseaux actives et ports utilisés|


📌 Pour le diagnostic terrain, toujours dans cet ordre : 1) ping 127.0.0.1 (pile IP locale OK ?) → 2) ping 
passerelle (LAN OK ?) → 3) ping 8.8.8.8 (Internet OK ?) → 4) ping google.fr (DNS OK ?) 
 
 
 
 
 
 
🟥 FICHE RECAPITULATIVE — ERREURS COURANTES RÉSEAU 
IP · DHCP · DNS · VLAN · OSI · Wi-Fi · Dépannage


|🔴 ERREURS CRITIQUES|Col2|Col3|Col4|Col5|
|---|---|---|---|---|
|❌** 1. Wi-Fi ≠ Ethernet**<br>❌ "Wi-Fi aussi fiable que câble"<br>Wi-Fi = débit partagé,<br>interférences<br>Ethernet = débit dédié, stable|❌** 2. IP 169.254.x.x**<br>❌ "Internet est lent"<br>169.254 = APIPA<br>→ DHCP inaccessible<br>→ IP attribuée localement|<br> <br> <br>|❌** 3. Ping ≠ Appli OK**||
|❌** 1. Wi-Fi ≠ Ethernet**<br>❌ "Wi-Fi aussi fiable que câble"<br>Wi-Fi = débit partagé,<br>interférences<br>Ethernet = débit dédié, stable|❌** 2. IP 169.254.x.x**<br>❌ "Internet est lent"<br>169.254 = APIPA<br>→ DHCP inaccessible<br>→ IP attribuée localement|<br> <br> <br>|❌ "Le ping marche → tout|
|❌** 1. Wi-Fi ≠ Ethernet**<br>❌ "Wi-Fi aussi fiable que câble"<br>Wi-Fi = débit partagé,<br>interférences<br>Ethernet = débit dédié, stable|❌** 2. IP 169.254.x.x**<br>❌ "Internet est lent"<br>169.254 = APIPA<br>→ DHCP inaccessible<br>→ IP attribuée localement|<br> <br> <br>|marche"|
|❌** 1. Wi-Fi ≠ Ethernet**<br>❌ "Wi-Fi aussi fiable que câble"<br>Wi-Fi = débit partagé,<br>interférences<br>Ethernet = débit dédié, stable|❌** 2. IP 169.254.x.x**<br>❌ "Internet est lent"<br>169.254 = APIPA<br>→ DHCP inaccessible<br>→ IP attribuée localement|<br> <br> <br>|Ping = ICMP (couche 3 / L3)|
|❌** 1. Wi-Fi ≠ Ethernet**<br>❌ "Wi-Fi aussi fiable que câble"<br>Wi-Fi = débit partagé,<br>interférences<br>Ethernet = débit dédié, stable|❌** 2. IP 169.254.x.x**<br>❌ "Internet est lent"<br>169.254 = APIPA<br>→ DHCP inaccessible<br>→ IP attribuée localement|<br> <br> <br>|Application = TCP/UDP (L4+)|
|❌** 1. Wi-Fi ≠ Ethernet**<br>❌ "Wi-Fi aussi fiable que câble"<br>Wi-Fi = débit partagé,<br>interférences<br>Ethernet = débit dédié, stable|❌** 2. IP 169.254.x.x**<br>❌ "Internet est lent"<br>169.254 = APIPA<br>→ DHCP inaccessible<br>→ IP attribuée localement|<br> <br> <br>|→ Tester les ports aussi !|


57


<!-- page 58 -->

||📌 Tout ce qui ne bouge pas →||||||
||câble|
|<br> <br><br> <br>|❌** 4. Passerelle oubliée**||<br><br> <br> <br>|❌** 5. VLAN sans routage**|||
|<br> <br><br> <br>|IP + masque OK|VLAN = isolement logique|
|<br> <br><br> <br>|DNS OK|❌ Pas de communication auto|
|<br> <br><br> <br>|❌ Pas de gateway = pas|Inter-VLAN = routeur ou switch|
|<br> <br><br> <br>|d'Internet|L3|
|<br> <br><br> <br>|→ Vérifier ipconfig /all|→ Configurer le routage !|



|🟠** ERREURS FRÉQUENTES**|
|⚠** 6. Switch vs Routeur**<br>Switch → Couche 2 / MAC<br>Routeur → Couche 3 / IP<br>❌ Confondre = mauvais<br>diagnostic<br>→ Identifier le matériel d'abord|<br> <br> <br> <br>|⚠** 7. SSID masqué ≠ sécurité**||<br> <br> <br> <br>|⚠** 8. Filtrage MAC ≠ sécurité**||
|⚠** 6. Switch vs Routeur**<br>Switch → Couche 2 / MAC<br>Routeur → Couche 3 / IP<br>❌ Confondre = mauvais<br>diagnostic<br>→ Identifier le matériel d'abord|<br> <br> <br> <br>|❌ "Cacher SSID = Wi-Fi|❌ Faux seul|
|⚠** 6. Switch vs Routeur**<br>Switch → Couche 2 / MAC<br>Routeur → Couche 3 / IP<br>❌ Confondre = mauvais<br>diagnostic<br>→ Identifier le matériel d'abord|<br> <br> <br> <br>|sécurisé"|Une adresse MAC se spoofe|
|⚠** 6. Switch vs Routeur**<br>Switch → Couche 2 / MAC<br>Routeur → Couche 3 / IP<br>❌ Confondre = mauvais<br>diagnostic<br>→ Identifier le matériel d'abord|<br> <br> <br> <br>|Scanner Wi-Fi détecte quand|<br>facilement|
|⚠** 6. Switch vs Routeur**<br>Switch → Couche 2 / MAC<br>Routeur → Couche 3 / IP<br>❌ Confondre = mauvais<br>diagnostic<br>→ Identifier le matériel d'abord|<br> <br> <br> <br>|même|→ Couche complémentaire|
|⚠** 6. Switch vs Routeur**<br>Switch → Couche 2 / MAC<br>Routeur → Couche 3 / IP<br>❌ Confondre = mauvais<br>diagnostic<br>→ Identifier le matériel d'abord|<br> <br> <br> <br>|→ Utiliser WPA2/WPA3 + mot|seulement|
|⚠** 6. Switch vs Routeur**<br>Switch → Couche 2 / MAC<br>Routeur → Couche 3 / IP<br>❌ Confondre = mauvais<br>diagnostic<br>→ Identifier le matériel d'abord|<br> <br> <br> <br>|de passe fort|→ Combiner avec WPA2/3|
|<br> <br> <br>|⚠** 9. WPA2 "cassé" ?**|||||
|<br> <br> <br>|❌ Faux|
|<br> <br> <br>|WPA2 reste sûr avec mdp fort mais **peu adapté à l’entreprise** car il|
|<br> <br> <br>|repose sur un**secret partagé** entre plusieurs utilisateurs.|
|<br> <br> <br>|WPA3 = meilleur, pas obligatoire partout|
|<br> <br> <br>|<br>→ Prioriser un mot de passe fort|



|🟡 ERREURS DE MÉTHODES RÉSEAU (OSI)|Col2|Col3|Col4|Col5|Col6|Col7|Col8|Col9|
|---|---|---|---|---|---|---|---|---|
|<br> <br> <br> <br>|❌** 10. Ordre OSI non respecté**||<br> <br> <br>|❌** 11. Chercher trop haut trop**|<br> <br>|<br> <br> <br> <br>|❌** 12. Ports et protocoles**||
|<br> <br> <br> <br>|✅ Méthode jury attendue :|**vite**|**oubliés**|
|<br> <br> <br> <br>|✅ Méthode jury attendue :|📌 50% des pannes = Couche 1|HTTPS (443) ≠ HTTP (80)|
|<br> <br> <br> <br>|1 → Câble, LED, alimentation|
|<br> <br> <br> <br>|2 → MAC, switch|→ Toujours vérifier le physique|DNS (53) ≠ DHCP (67/68)|
|<br> <br> <br> <br>|<br>3 → IP, gateway, ping|d'abord|TCP (fiable) ≠ UDP (rapide)|
|<br> <br> <br> <br>|<br>4 → Ports (telnet, netstat)|→ Câble branché ? LED active ?|→ netstat -an pour vérifier les|
|<br> <br> <br> <br>|<br>5+ → Application|→ Alimentation OK ?|ports|


QUIZZ Réseau


||**1. Une adresse commençant par 169.254.X.X indique :**||
||•<br>A) Que la connexion Internet est excellente.<br>•<br>B) Que le PC n'a pas pu contacter de serveur DHCP (APIPA).<br>•<br>C) Que le pare-feu bloque tout le trafic.||
||**2. Quel équipement travaille principalement en Couche 2 (Liaison) et utilise les adresses MAC ?**||
||•<br>A) Le routeur.<br>•<br>B) Le switch.<br>•<br>C) Le hub.||


58


<!-- page 59 -->

||**3. Quelle est l'utilité principale d'un VLAN ?**||
||•<br>A) Augmenter la vitesse de la connexion fibre.|||
||<br>•<br>B) Segmenter le réseau logiquement pour améliorer la sécurité et réduire le broadcast.|
||<br>•<br>C) Remplacer le serveur DNS.|
|<br>|**4. Si je peux "pinger" une adresse IP mais que je ne peux pas accéder à "google.fr", quel service**||
|<br>|<br>**est probablement en panne ?**|
||•<br>A) Le DHCP.|||
||<br>•<br>B) Le DNS.|
||<br>•<br>C) La passerelle par défaut.|
||**5. Quel port est utilisé par le protocole HTTPS (navigation sécurisée) ?**||
||•<br>A) 80|||
||<br>•<br>B) 22|
||<br>•<br>C) 443|
||**6. La commande****`ipconfig /release` sert à :**||
||•<br>A) Demander une nouvelle adresse IP.|||
||<br>•<br>B) Abandonner l'adresse IP actuelle.|
||<br>•<br>C) Redémarrer la box internet.|
||**7. Quelle notation CIDR correspond au masque de sous-réseau 255.255.255.0 ?**||
||•<br>A) /8|||
||<br>•<br>B) /16|
||<br>•<br>C) /24|
||**8. Dans le modèle OSI, à quelle couche se situe le routage des paquets IP ?**||
||•<br>A) Couche 1 (Physique).|||
||<br>•<br>B) Couche 3 (Réseau).|
||<br>•<br>C) Couche 7 (Application).|
||**9. Qu'est-ce que la "Couche 8" dans le jargon informatique ?**||
||•<br>A) Une nouvelle norme Wi-Fi ultra rapide.|||
||<br>•<br>B) L'utilisateur (erreur humaine).|
||<br>•<br>C) Le câble de secours.|
|<br>|**10. Sur un switch Cisco, quelle commande permet de voir quels ports sont assignés à quels**||
|<br>|<br>**VLANs ?**|
||•<br>A)`show ip route`|||
||•<br>B)`show vlan brief`|
||•<br>C)`ipconfig /all`|


Correction  
1-B | 2-B | 3-B | 4-B | 5-C | 6-B | 7-C | 8-B | 9-B | 10-B

59


<!-- page 60 -->

MODULE 4 : MAINTENANCE ET SAUVEGARDE DU 
SYSTÈME

1. Backup / Sauvegarde : définition 
Un backup est la copie et l'archivage de données informatiques en vue de leur restauration en cas de 
perte, corruption ou destruction. En entreprise, on établit un plan de sauvegarde avec une fréquence 
définie.

Règle 3-2-1-1-0


||**Principe**|||**Détail**||
|3 copies|Au moins 3 exemplaires des données|
|2 supports différents|Ex : disque dur + cloud|
|1 hors site|Contre les sinistres physiques (incendie). Ex : coffre ignifugé ou site distant|
|1 hors ligne|Contre les ransomwares : une copie non connectée au réseau|
|0 échec|Les sauvegardes doivent être testées régulièrement|


2. Supports de sauvegarde

• 
Support physique : HDD, SSD 
• 
Cloud : Azure, etc. 
• 
Serveur de fichiers : NAS 
• 
Bande magnétique LTO

3. Typologie des sauvegardes


||**Type**|||**Description**|||**Restauration**|||**Espace disque**||
|Totale (Full)|Copie complète du disque<br>à chaque fois|Simple (1 seule source)|Très élevé|
|Différentielle|Full puis sauvegarde ce<br>qui a changé depuis le<br>Full|Moyen (2 sources : Full +<br>dernière différentielle)|Moyen|
|Incrémentale|Full puis chaque<br>sauvegarde ne capture<br>que les changements<br>depuis la précédente|Long (toutes les<br>sauvegardes)|Faible|


Conserver au minimum 1 an les sauvegardes totales (un malware peut rester dormant plusieurs mois).

4. Paramètres du plan de sauvegarde


||**Concept**|||**Définition**||
|PCA / PCI|Plan de Continuité de l'Activité/Informatique : redondance pour éviter<br>toute interruption|
|PRA / PRI|Plan de Reprise de l'Activité/Informatique : comment restaurer après<br>un sinistre|
|RPO (Recovery Point Objective)|Quantité de données maximum acceptable à perdre (en temps)|
|RTO (Recovery Time Objective)|Durée maximum acceptable sans production|


60


<!-- page 61 -->

Snapshot 
Un snapshot est un cliché instantané de l'état d'une machine (différent d'une sauvegarde : il copie l'état, 
pas les données). Restauration quasi-immédiate.   Trop de snapshots peut ralentir la VM. 
🔁 Réflexe : prendre un snapshot avant toute manipulation risquée !

5. Solutions de sauvegarde


||**Catégorie**|||**Outils**||
|Windows natif|Sauvegarde de fichiers Windows|
|Logiciels spécialisés|VEEAM Backup & Replication, Proxmox Backup Server|
|Cloud|Azure|
|Serveur|Windows Server Backup|


Note : Windows Server permet de centraliser les mises à jour (WSUS) : un seul serveur récupère les mises 
à jour et les distribue à tous les postes, avec validation et planification (mise à jour le 2e mardi du mois — 
Patch Tuesday).

61


<!-- page 62 -->

MODULE 5 : CYBERSÉCURITÉ

1. Malwares (logiciels malveillants)


||**Malware**|||**Description**||
|Ransomware<br>(Rançongiciel)|Chiffre les données pour exiger une rançon. Seule défense efficace :<br>sauvegarde hors-ligne.|
|Spyware|Vole des données ou espionne l'activité de l'utilisateur|
|RAT (Remote Access Tool)|Permet de prendre le contrôle à distance de la machine|
|Trojan (Cheval de Troie)|Ouvre un port pour laisser entrer la charge malveillante|
|Keylogger|Enregistre toutes les frappes au clavier|
|Virus|Se greffe à une application et se multiplie à l'exécution|
|Ver (Worm)|Malware autonome qui se propage de poste en poste via le réseau|
|Rootkit|Un rootkit est un logiciel malveillant qui se cache dans le système pour<br>conserver un accès, et dans certains cas (bootkit) il s’installe dans le MBR<br>pour se lancer avant l’OS et résister à un formatage simple.|
|Bootkit|S'inscrit dans la partition GPT de l'UEFI|
|Rogue|Fausse application (souvent faux antivirus) pour tromper l'utilisateur|
|DDoS|Surcharge d'un serveur par des milliers de requêtes (souvent via PC<br>zombies / botnets)|


2. Détection et analyse 
VirusTotal (virustotal.com) : soumettre un fichier pour l'analyser avec plusieurs antivirus simultanément.

Fonctionnement de l'antivirus

• 
Base de signatures : compare les fichiers à une base d'empreintes connues. 
• 
Analyse comportementale (heuristique) : surveille les actions suspectes. Attention aux faux positifs. 
• 
Actions : mise en quarantaine ou suppression. 
• 
Redémarrage souvent nécessaire si le malware est chargé en RAM.

3. Défense et maintenance du technicien


||**Outil / Concept**|||**Description**||
|Pare-feu (Firewall)|Règle d'or : tout bloquer par défaut, n'autoriser que le nécessaire (ex : port<br>443 HTTPS). Créer des règles entrantes ET sortantes.|
|Antivirus + Malwarebytes|Malwarebytes est un complément efficace à l'antivirus classique,<br>notamment en post-infection.|
|Process Explorer<br>(Sysinternals)|Visualiser les processus, y compris les processus cachés.|
|Autoruns (Sysinternals)|Identifier les programmes suspects au démarrage.|


62


<!-- page 63 -->

|CCleaner|Nettoyer les clés de registre obsolètes après désinfection “Éviter les<br>nettoyeurs de registre sauf cas très particulier et maîtrisé.”Si tu<br>gardes CCleaner, limite-le à : fichiers temporaires, entretien léger, jamais<br>comme solution miracle.|
|---|---|
|Haveibeenpwned.com|Vérifier si une adresse mail a été compromise.|
|Tails OS|OS chargé en RAM, ne laisse aucune trace sur la machine.|
|Snapshots VM|Prendre un snapshot avant toute manipulation risquée.|


Commandes utiles (Win+R)


||**Commande**|||**Action**||
|optionalfeatures|Activer la Sandbox Windows|
|wf.msc|Accès direct au pare-feu avancé (règles entrantes et sortantes)|
|mrt|Outil de suppression de logiciels malveillants intégré à Windows|


Anonymat sur internet : les limites

• 
Un VPN masque uniquement l'adresse IP. Le fournisseur VPN conserve des logs et peut les 
transmettre sur réquisition judiciaire. 
• 
Chaque machine possède une signature numérique (cookies, empreinte navigateur). Nous ne 
sommes jamais réellement anonymes.

63


<!-- page 64 -->

MODULE 6 : UTILISER L'IA

1. La règle d'or : Le contexte (R.O.C.T.) 
Pour obtenir une bonne réponse, un bon prompt est indispensable. Utiliser la méthode R.O.C.T. :


||**Lettre**|||**Élément**|||**Exemple**||
|R|Rôle|« Agis comme un expert en Python »|
|O|Objectif|« Explique-moi les boucles while »|
|C|Contexte|« Je suis en 1ère année de BTS SIO et je ne comprends pas la différence<br>avec la boucle for »|
|T|Format|« Donne-moi une définition, un exemple de code et un petit exercice »|


2. Comment l'utiliser en informatique ?


||**Cas d'usage**|||**Exemple de prompt**||
|Explication de concepts<br>abstraits|« Explique la POO avec une analogie simple (voiture, recette...) »|
|Rubber Duck Debugging|« Voici mon code [...]. Il renvoie une erreur IndexError. Explique pourquoi<br>sans me donner la solution directe. »|
|Génération de données de<br>test|« Génère un JSON de 10 faux utilisateurs avec nom, email et âge. »|
|Documentation /<br>commentaires|« Ajoute des commentaires pédagogiques à ce script pour que je puisse le<br>réviser plus tard. »|


3. Pièges à éviter

• 
L'hallucination : l'IA peut affirmer des choses fausses avec assurance, surtout sur des bibliothèques 
récentes. Toujours vérifier dans la documentation officielle. 
• 
Le copier-coller aveugle : utiliser l'IA pour comprendre le pourquoi du code, pas pour le générer en 
entier sans comprendre. 
• 
La sécurité : ne jamais donner de mots de passe réels, clés d'API ou données sensibles.

64

