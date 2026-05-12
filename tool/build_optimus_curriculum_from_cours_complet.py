# Génère data/curriculum/optimus depuis cours_complet_tables.md (prioritaire)
# ou cours_complet.md. Découpage par ancres (MODULE / Partie / titres de chapitre).
#
# Prérequis tableaux + images PDF :
#   python tool/enrich_cours_from_pdf_tables.py
# Puis :
#   python tool/build_optimus_curriculum_from_cours_complet.py

from __future__ import annotations

import json
import re
import shutil
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SRC_TABLES = ROOT / "cours_complet_tables.md"
SRC_LEGACY = ROOT / "cours_complet.md"
SRC_IMG = ROOT / "images"
OUT = ROOT / "data" / "curriculum" / "optimus"

# (slug, titre affiché, regex de début de chapitre dans l’ordre)
SECTION_SPECS: list[dict] = [
    {
        "id": "O01",
        "titre": "HARDWARE & ARCHITECTURE",
        "slug": "section-01-hardware-architecture",
        "chapter_patterns": [
            r"^COURS TIP\s*$",
            r"^1\.\s+La carte mere",
            r"^2\.\s+Le processeur",
            r"^3\.\s+La memoire vive",
            # Titre « 4. » parfois absorbé par l’extraction PDF :
            r"^Le stockage conserve les données",
            r"^5\.\s+La carte graphique",
            r"^6\.\s+L'alimentation",
            # « 7. » souvent fusionné avec le tableau USB — ancrage sur l’en-tête du tableau ports :
            r"^\|\*\*Standard\*\*\|\*\*Debit max\*\*\|\|\*\*Couleur\*\*",
            r"^8\.\s+Les bus et slots",
            r"^9\.1\.\s+Pourquoi refroidir",
            r"^10\.\s+Le BIOS",
            r"^11\.1 Ordre de montage",
        ],
        "chapters_meta": [
            ("chapter-01-intro-peripheriques-boitiers", "Introduction, périphériques et boîtiers"),
            ("chapter-02-carte-mere", "Carte mère (Motherboard)"),
            ("chapter-03-processeur-cpu", "Processeur (CPU)"),
            ("chapter-04-memoire-vive-ram", "Mémoire vive (RAM)"),
            ("chapter-05-stockage-hdd-ssd-nvme", "Stockage (HDD / SSD / NVMe)"),
            ("chapter-06-gpu-npu", "Carte graphique (GPU) et NPU"),
            ("chapter-07-alimentation-psu", "Alimentation (PSU)"),
            ("chapter-08-connecteurs-ports", "Connecteurs et ports externes"),
            ("chapter-09-bus-extensions", "Bus et slots d'extension"),
            ("chapter-10-refroidissement", "Refroidissement"),
            ("chapter-11-bios-uefi", "BIOS / UEFI"),
            ("chapter-12-assemblage-depannage", "Assemblage et dépannage hardware"),
        ],
    },
    {
        "id": "O02",
        "titre": "SYSTÈME D'EXPLOITATION",
        "slug": "section-02-systeme-exploitation",
        "chapter_patterns": [
            r"^MODULE 2\s*:",
            r"^2\.\s+Installer Windows",
            r"^3\.\s+La virtualisation",
        ],
        "chapters_meta": [
            ("chapter-01-systemes-exploitation", "Systèmes d'exploitation"),
            ("chapter-02-installer-windows", "Installer Windows"),
            ("chapter-03-virtualisation", "Virtualisation"),
        ],
    },
    {
        "id": "O03",
        "titre": "RÉSEAUX & INFRASTRUCTURE",
        "slug": "section-03-reseaux-infrastructure",
        "chapter_patterns": [
            r"^MODULE 3\s*:",
            r"^Partie 2\s*:",
            r"^Partie 3\s*:",
            r"^Partie 4\s*:",
            r"^Partie 5\s*:",
        ],
        "chapters_meta": [
            ("chapter-01-composants-reseau-binaire", "Composants du réseau et binaire"),
            ("chapter-02-adressage-segmentation", "Adressage et segmentation"),
            ("chapter-03-osi-encapsulation-tcp-ip", "OSI, encapsulation et TCP/IP"),
            ("chapter-04-vlans-organisation", "VLANs et organisation avancée"),
            ("chapter-05-services-protocoles-critiques", "Services et protocoles critiques"),
        ],
    },
    {
        "id": "O04",
        "titre": "MAINTENANCE ET SAUVEGARDE",
        "slug": "section-04-maintenance-sauvegarde",
        "chapter_patterns": [
            r"^MODULE 4\s*:",
            r"^2\.\s+Supports de sauvegarde",
            r"^3\.\s+Typologie des sauvegardes",
            r"^4\.\s+Paramètres du plan de sauvegarde",
            r"^5\.\s+Solutions de sauvegarde",
        ],
        "chapters_meta": [
            ("chapter-01-sauvegarde-definition", "Sauvegarde : définition et règle 3-2-1-1-0"),
            ("chapter-02-supports-sauvegarde", "Supports de sauvegarde"),
            ("chapter-03-typologie-sauvegardes", "Typologie des sauvegardes"),
            ("chapter-04-plan-rpo-rto-snapshots", "Plan, RPO/RTO et snapshots"),
            ("chapter-05-solutions-sauvegarde", "Solutions de sauvegarde"),
        ],
    },
    {
        "id": "O05",
        "titre": "CYBERSÉCURITÉ",
        "slug": "section-05-cybersecurite",
        "chapter_patterns": [
            r"^MODULE 5\s*:",
            r"^2\.\s+Détection et analyse",
            r"^3\.\s+Défense et maintenance du technicien",
        ],
        "chapters_meta": [
            ("chapter-01-malwares", "Malwares et menaces"),
            ("chapter-02-detection-analyse", "Détection et analyse"),
            ("chapter-03-defense-outils", "Défense et maintenance du technicien"),
        ],
    },
    {
        "id": "O06",
        "titre": "UTILISER L'IA",
        "slug": "section-06-utiliser-ia",
        "chapter_patterns": [
            r"^MODULE 6\s*:",
            r"^2\.\s+Comment l'utiliser en informatique",
            r"^3\.\s+Pièges à éviter",
        ],
        "chapters_meta": [
            ("chapter-01-roct-contexte", "Méthode R.O.C.T. et contexte"),
            ("chapter-02-cas-usage-informatique", "Cas d'usage en informatique"),
            ("chapter-03-pieges-securite-ia", "Pièges et sécurité"),
        ],
    },
]


def _module_starts(lines: list[str]) -> list[int]:
    idx = []
    for i, L in enumerate(lines):
        if re.match(r"^MODULE\s+\d+\s*:", L.strip()):
            idx.append(i)
    return idx


def _chapter_ranges(
    lines: list[str],
    m_start: int,
    m_end: int,
    patterns: list[str],
) -> list[tuple[int, int]]:
    starts: list[int] = []
    for pat in patterns:
        rx = re.compile(pat)
        found: int | None = None
        for li in range(m_start, m_end):
            if rx.search(lines[li]):
                found = li
                break
        if found is None:
            raise SystemExit(
                f"Ancre introuvable dans MODULE (lignes {m_start + 1}–{m_end + 1}) : {pat!r}",
            )
        starts.append(found)
    ranges: list[tuple[int, int]] = []
    for i, a in enumerate(starts):
        b = (starts[i + 1] - 1) if i + 1 < len(starts) else (m_end - 1)
        ranges.append((a, b))
    return ranges


def _strip_page_comments(text: str) -> str:
    return re.sub(r"<!--\s*page\s+\d+\s*-->\s*", "", text)


def main() -> None:
    src = SRC_TABLES if SRC_TABLES.is_file() else SRC_LEGACY
    if not src.is_file():
        raise SystemExit(
            f"Aucune source : ni {SRC_TABLES.name} ni {SRC_LEGACY.name}",
        )
    lines = src.read_text(encoding="utf-8").splitlines()
    mods = _module_starts(lines)
    if len(mods) < 6:
        raise SystemExit(f"Attendu 6 MODULE, trouvé {len(mods)}")
    mod_ranges = []
    for i in range(6):
        a = mods[i]
        b = mods[i + 1] if i + 1 < len(mods) else len(lines)
        mod_ranges.append((a, b))

    if OUT.exists():
        shutil.rmtree(OUT)
    img_out = OUT / "images"
    img_out.mkdir(parents=True)
    if SRC_IMG.is_dir():
        for p in sorted(SRC_IMG.iterdir()):
            if p.is_file():
                shutil.copy2(p, img_out / p.name)

    sections_json: list[dict] = []
    chapitres_json: list[dict] = []
    module_num = 0

    for sec_i, sec in enumerate(SECTION_SPECS):
        module_num += 1
        m_start, m_end = mod_ranges[sec_i]
        # Le bloc « COURS TIP » est avant la ligne « MODULE 1 » : inclure depuis le début du fichier.
        if sec_i == 0:
            m_start = 0
        sec_dir = OUT / sec["slug"]
        sec_dir.mkdir(parents=True)
        patterns = sec["chapter_patterns"]
        meta = sec["chapters_meta"]
        if len(patterns) != len(meta):
            raise SystemExit(f"{sec['slug']}: patterns vs meta count mismatch")
        ranges = _chapter_ranges(lines, m_start, m_end, patterns)
        total_ch = len(meta)

        sections_json.append(
            {
                "id": sec["id"],
                "titre": sec["titre"],
                "slug": sec["slug"],
            }
        )

        for ch_i, ((a, b), (slug, title)) in enumerate(zip(ranges, meta), start=1):
            chunk = lines[a : b + 1]
            body = _strip_page_comments("\n".join(chunk))
            body = body.replace("./images/", "../images/")
            kicker = (
                f"> **Parcours Optimus** — **Module {module_num}** · "
                f"Chapitre {ch_i} sur {total_ch} · *{title}*.\n>\n> "
                f"Contenu issu du cours TIP (PDF) ; tableaux extraits du PDF ; illustrations sous "
                f"`curriculum/optimus/images/`.\n\n"
            )
            md_path = sec_dir / f"{slug}.md"
            md_path.write_text(kicker + body + "\n", encoding="utf-8")
            chapitres_json.append(
                {
                    "id": f"C{ch_i:02d}",
                    "section": sec["id"],
                    "titre": title,
                    "slug": slug,
                    "path": f"curriculum/optimus/{sec['slug']}/{slug}.md",
                }
            )

    index = {
        "version": "1.0",
        "updated_at": "2026-04-21",
        "track": "optimus",
        "title": "Parcours Optimus",
        "sections": sections_json,
        "chapitres": chapitres_json,
    }
    (OUT / "index.json").write_text(
        json.dumps(index, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    print(f"OK -- {len(chapitres_json)} chapitres depuis {src.name}")


if __name__ == "__main__":
    main()
