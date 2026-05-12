#!/usr/bin/env python3
"""Passe bulk : corrections françaises récurrentes dans les JSON QCM TIP (chaînes uniquement).
Ne remplace pas les clés JSON. À relire : énoncés tronqués, cohérence pédagogique."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

# Ordre : phrases longues d'abord quand pertinent
REPLACEMENTS: list[tuple[str, str]] = [
    ("Mettre a jour", "Mettre à jour"),
    ("mettre a jour", "mettre à jour"),
    ("mise a jour", "mise à jour"),
    ("Mise a jour", "Mise à jour"),
    ("Desactiver", "Désactiver"),
    ("desactive", "désactive"),
    ("desactives", "désactives"),
    ("procedure ", "procédure "),
    ("procedure.", "procédure."),
    ("procedure,", "procédure,"),
    ("procedure?", "procédure?"),
    ("La procedure", "La procédure"),
    ("Une procedure", "Une procédure"),
    ("carte mere", "carte mère"),
    ("boitier", "boîtier"),
    ("energie", "énergie"),
    ("role ", "rôle "),
    ("role?", "rôle?"),
    ("role,", "rôle,"),
    ("frequence", "fréquence"),
    ("Frequence", "Fréquence"),
    ("capacite", "capacité"),
    ("Capacite", "Capacité"),
    ("compatibilite", "compatibilité"),
    ("Compatibilite", "Compatibilité"),
    ("incompatibilite", "incompatibilité"),
    ("represente", "représente"),
    ("Represente", "Représente"),
    ("exprimee", "exprimée"),
    ("Exprimee", "Exprimée"),
    ("defectueux", "défectueux"),
    ("defectueuse", "défectueuse"),
    ("instabilite", "instabilité"),
    ("utilisee", "utilisée"),
    ("utilisees", "utilisées"),
    ("realisees", "réalisées"),
    ("realise ", "réalise "),
    ("conserve ", "conserve "),
    ("maniere ", "manière "),
    ("peripheriques", "périphériques"),
    ("applications metier", "applications métier"),
    (" en priorite", " en priorité"),
    ("priorite ", "priorité "),
    ("priorite?", "priorité?"),
    ("immediate ", "immédiate "),
    ("immediate?", "immédiate?"),
    ("immediatement", "immédiatement"),
    ("echoue", "échoue"),
    ("Echoue", "Échoue"),
    ("echec", "échec"),
    ("ecran ", "écran "),
    ("ecrans ", "écrans "),
    (" aleatoires", " aléatoires"),
    ("redemarre", "redémarre"),
    ("demarre ", "démarre "),
    ("demarre?", "démarre?"),
    ("demarre.", "démarre."),
    (" caracteristique", " caractéristique"),
    ("Caracteristique", "Caractéristique"),
    ("mecanique", "mécanique"),
    ("Mecanique", "Mécanique"),
    ("magnetiques", "magnétiques"),
    ("magnetique", "magnétique"),
    ("Presence ", "Présence "),
    ("presence ", "présence "),
    ("amelioration", "amélioration"),
    ("Amelioration", "Amélioration"),
    ("resolution d'ecran", "résolution d'écran"),
    ("luminosite", "luminosité"),
    ("etranglement", "étranglement"),
    ("eleve ", "élevé "),
    ("reduite", "réduite"),
    ("Debit ", "Débit "),
    ("debit ", "débit "),
    ("designe", "désigne"),
    ("Designe", "Désigne"),
    ("enonce", "énoncé"),
    ("Enonce", "Énoncé"),
    ("pate thermique", "pâte thermique"),
    ("Controler", "Contrôler"),
    ("controler ", "contrôler "),
    ("etat ", "état "),
    ("Etat ", "État "),
    ("defaillance", "défaillance"),
    ("secteurs defectueux", "secteurs défectueux"),
    ("repetitives", "répétitives"),
    ("Selectionner", "Sélectionner"),
    ("declencher", "déclencher"),
    ("depend ", "dépend "),
    ("intervient ", "intervient "),
    ("considere ", "considéré "),
    ("evolution", "évolution"),
    ("materielle", "matérielle"),
    ("materiel ", "matériel "),
    ("sequence", "séquence"),
    ("enchaine", "enchaîne"),
    ("eteint", "éteint"),
    ("Executer", "Exécuter"),
    ("executer ", "exécuter "),
    ("arret ", "arrêt "),
    ("a l'", "à l'"),
    (" a la ", " à la "),
    (" a le ", " au "),
    ("conclut trop vite a ", "conclut trop vite à "),
    (" mener a ", " mener à "),
    ("conduit a ", "conduit à "),
    ("associé a ", "associé à "),
    ("lie a ", "lié à "),
    ("liee a ", "liée à "),
    ("donne ", "donné "),
    ("donne.", "donné."),
    ("symptome", "symptôme"),
    ("hypothese", "hypothèse"),
    ("Hypothese", "Hypothèse"),
    ("apres ", "après "),
    ("apres.", "après."),
    ("apres?", "après?"),
    ("Apres ", "Après "),
    ("demarrage", "démarrage"),
    ("Demarrage", "Démarrage"),
    ("systeme", "système"),
    ("Systeme", "Système"),
    ("benefice", "bénéfice"),
    ("benefice", "bénéfice"),
    ("generations", "générations"),
    ("generation ", "génération "),
    ("Melange", "Mélange"),
    ("melange", "mélange"),
    ("reactiver", "réactiver"),
    ("reduit ", "réduit "),
    ("empeche", "empêche"),
    ("emettre", "émettre"),
    ("emet ", "émet "),
    ("affiche ecran", "affiche écran"),
    ("verifie", "vérifie"),
    ("Verification", "Vérification"),
    ("verification ", "vérification "),
    ("verrouille", "verrouillé"),
    ("signes", "signés"),
    ("cable ", "câble "),
    ("priorite", "priorité"),
    ("detectee", "détectée"),
    ("detecte", "détecté"),
    ("detecter", "détecter"),
    ("echappe", "échappe"),
    ("partitionnement", "partitionnement"),
    ("Privilegie", "Privilégié"),
    ("privilegie", "privilégié"),
    ("reactiver", "réactiver"),
    ("forcement ", "forcément "),
    ("forcement?", "forcément?"),
    ("forcement.", "forcément."),
    ("debranche", "débranché"),
    ("Debranche", "Débranché"),
    ("critere ", "critère "),
    ("critere.", "critère."),
    ("critere,", "critère,"),
    ("critere)", "critère)"),
    (" un cle", " une clé"),
    (" cle ", " clé "),
    (" cle.", " clé."),
    (" cle,", " clé,"),
]

SUSPICIOUS = re.compile(
    r"\bdans \?| la procédure \?|[^é]forcement |debranche|saturér|critere[^u]"
)


def fix_string(s: str) -> str:
    for old, new in REPLACEMENTS:
        s = s.replace(old, new)
    return s


# Clés dont les chaînes ne doivent pas être « francisées » (identifiants, chemins).
_SKIP_VALUE_KEYS = frozenset(
    {
        "tags",
        "chapter_slug",
        "notion_id",
        "id",
        "asset",
        "exercisesAsset",
        "quizTheoryAsset",
        "quizPratiqueAsset",
        "missionsAsset",
        "tipModuleId",
        "section_id",
    }
)


def walk(obj, parent_key: str | None = None):
    if isinstance(obj, dict):
        out = {}
        for k, v in obj.items():
            if k == "tags":
                out[k] = v
            else:
                out[k] = walk(v, k)
        return out
    if isinstance(obj, list):
        return [walk(v, parent_key) for v in obj]
    if isinstance(obj, str):
        if parent_key in _SKIP_VALUE_KEYS:
            return obj
        if parent_key and parent_key.endswith("Asset"):
            return obj
        return fix_string(obj)
    return obj


def main() -> int:
    root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("data/questions/tip/section-01")
    if not root.exists():
        print("Missing:", root, file=sys.stderr)
        return 1
    files = sorted(root.rglob("*.json"))
    for path in files:
        raw = path.read_text(encoding="utf-8")
        try:
            data = json.loads(raw)
        except json.JSONDecodeError as e:
            print("JSON error", path, e, file=sys.stderr)
            return 1
        out = walk(data)
        text = json.dumps(out, ensure_ascii=False, indent=2) + "\n"
        if text != raw:
            path.write_text(text, encoding="utf-8")
            print("updated", path.relative_to(root.parent.parent.parent))
        # warnings
        for line in text.splitlines():
            if SUSPICIOUS.search(line):
                print("check:", path.name, ":", line.strip()[:120])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
