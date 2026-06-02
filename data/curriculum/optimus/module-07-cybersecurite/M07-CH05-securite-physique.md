> **Parcours Optimus — Module 7 · Chapitre 5 sur 6**

# Sécurité physique des équipements

> 🤖 *Section ajoutée avec l'assistance d'une IA — à relire et vérifier avant usage.*

La cybersécurité protège les données contre les attaques logicielles, mais un équipement peut aussi être **volé ou dérobé physiquement**. La sécurité physique est la première couche, souvent négligée : un PC portable volé, c'est potentiellement toutes ses données exposées.

**Les mesures de verrouillage physique :**

| Mesure | Rôle |
|---|---|
| **Antivol Kensington** (câble + serrure) | Attache physiquement un PC portable ou fixe à un point fixe (bureau) via le **port Kensington** dédié. Dissuade le vol opportuniste. |
| **Verrouillage des baies / armoires** | Les serveurs, switchs et équipements réseau sont enfermés dans une **baie verrouillée**, en local technique à accès restreint. |
| **Verrouillage de session** | `Win + L` à chaque fois qu'on quitte son poste, verrouillage automatique après inactivité (via GPO). |
| **Sécurisation des ports** | Désactivation des ports USB par GPO (cf. baiting, §4), blocage du boot sur support externe dans le BIOS. |
| **Contrôle d'accès physique** | Badges, locaux à accès restreint pour les salles serveurs (lien avec le tailgating, §4). |

**La complémentarité physique + logique** : le verrouillage physique dissuade le vol ; le **chiffrement** (BitLocker, cf. Module 6) garantit que même si le matériel est volé, les données restent illisibles. Les deux se combinent toujours.

> **Réflexe terrain** : sur un parc de portables, la combinaison gagnante = **BitLocker activé** (données illisibles si vol) **+ antivol Kensington** (dissuasion du vol) **+ verrouillage de session automatique** (protection si le poste reste sans surveillance). Aucune des trois ne suffit seule.
