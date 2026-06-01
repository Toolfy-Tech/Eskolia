> **Parcours Optimus** — **Module 4** · Chapitre 4 sur 5 · *Plan, RPO/RTO et snapshots*.
>
> Contenu issu du cours Optimus (PDF) ; tableaux extraits du PDF ; illustrations sous `curriculum/optimus/images/`.

## 4. Paramètres du plan de sauvegarde

|**Concept**|**Définition**|
|---|---|
|PCA / PCI|Plan de Continuité de l'Activité/Informatique : redondance pour éviter toute interruption|
|PRA / PRI|Plan de Reprise de l'Activité/Informatique : comment restaurer après un sinistre|
|RPO (Recovery Point Objective)|Quantité de données maximum acceptable à perdre (en temps)|
|RTO (Recovery Time Objective)|Durée maximum acceptable sans production|

Snapshot
Un snapshot est un cliché instantané de l'état d'une machine (différent d'une sauvegarde : il copie l'état,
pas les données). Restauration quasi-immédiate. Trop de snapshots peut ralentir la VM.
🔁 Réflexe : prendre un snapshot avant toute manipulation risquée !
