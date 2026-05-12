#!/usr/bin/env python3
"""Audit/normalisation des doublons TIP `chapter-XX.json` vs `chapitre-(C)XX.json`.

Par défaut: affiche les doublons potentiels sans modifier les fichiers.
Option `--delete-legacy`: supprime les fichiers `chapitre-*` uniquement quand le
fichier `chapter-XX.json` correspondant existe dans la même section.
"""
from __future__ import annotations

import argparse
import re
from pathlib import Path

CHAPTER_RE = re.compile(r"^chapter-(\d+)\.json$")
CHAPITRE_RE = re.compile(r"^chapitre-(?:C)?(\d+)\.json$")


def audit(root: Path) -> list[tuple[Path, str, Path, Path]]:
    duplicates: list[tuple[Path, str, Path, Path]] = []
    for section in sorted([p for p in root.iterdir() if p.is_dir()]):
        by_num: dict[str, dict[str, Path]] = {}
        for f in sorted(section.glob("*.json")):
            m = CHAPTER_RE.match(f.name)
            if m:
                by_num.setdefault(m.group(1), {})["chapter"] = f
                continue
            m = CHAPITRE_RE.match(f.name)
            if m:
                by_num.setdefault(m.group(1), {})["chapitre"] = f
        for num, pair in sorted(by_num.items(), key=lambda x: int(x[0])):
            if "chapter" in pair and "chapitre" in pair:
                duplicates.append((section, num, pair["chapter"], pair["chapitre"]))
    return duplicates


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--root",
        default="data/questions/tip",
        help="Racine TIP contenant section-XX",
    )
    parser.add_argument(
        "--delete-legacy",
        action="store_true",
        help="Supprime les fichiers legacy `chapitre-*` quand `chapter-*` existe",
    )
    args = parser.parse_args()

    root = Path(args.root)
    if not root.exists():
        print(f"Dossier introuvable: {root}")
        return 1

    duplicates = audit(root)
    if not duplicates:
        print("Aucun doublon chapter/chapitre detecte.")
        return 0

    print(f"Doublons detectes: {len(duplicates)}")
    grouped: dict[str, int] = {}
    for section, num, chapter, chapitre in duplicates:
        grouped[section.name] = grouped.get(section.name, 0) + 1
        print(f"- {section.name} C{num}: keep={chapter.name} legacy={chapitre.name}")

    print("\nResume:")
    for sec, n in sorted(grouped.items()):
        print(f"  {sec}: {n}")

    if args.delete_legacy:
        for _, _, _, chapitre in duplicates:
            chapitre.unlink()
            print(f"deleted {chapitre}")
        print(f"Suppression terminee: {len(duplicates)} fichiers legacy supprimes.")
    else:
        print("\nMode audit seulement. Utiliser --delete-legacy pour supprimer.")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
