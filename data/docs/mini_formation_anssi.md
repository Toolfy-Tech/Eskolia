## Mini-formation — ANSSI & hygiène ops (rappel technicien)

L’**ANSSI** est l’autorité nationale en matière de **cybersécurité** en France : bonnes pratiques, guides, référentiels, sensibilisation et accompagnement des organisations (État, OIV, entreprises, collectivités).

### Ce qui compte au quotidien

1. **Réduction de la surface d’attaque** : inventaire des systèmes exposés, fermer ce qui ne sert pas, durcissement des configurations par défaut.
2. **Segmentation** : limiter les mouvements latéraux (VLAN, pare-feu, comptes de service limités).
3. **Journaux et supervision** : centraliser ce qui est possible, conserver assez longtemps pour investiguer, sans exploser les volumes inutilement.
4. **Mises à jour et correctifs** : processus testés pour ne pas casser la prod, mais ne pas laisser des vulnérabilités critiques traîner.
5. **Sauvegardes** : règle **3-2-1** (3 copies, 2 supports, 1 hors site) et **tests de restauration** réguliers — une sauvegarde non testée est une illusion.
6. **Incidents** : en cas d’intrusion ou de ransomware, **ne pas improviser seul** — préserver les preuves, suivre la **cellule de crise** / la procédure interne, escalader vers le RSSI ou l’ANSSI selon les canaux prévus.

### Culture

Signaler un doute ou une anomalie tôt vaut mieux qu’un incident majeur découvert trop tard.

> Ce texte est un **rappel pédagogique**. Adapte-toi toujours aux politiques et outils de ton organisation.
