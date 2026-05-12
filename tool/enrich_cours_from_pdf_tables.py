# Reconstruit un Markdown à partir du PDF : blocs de texte + tableaux (PyMuPDF),
# puis réinjecte les lignes ![Image …](…) de cours_complet.md dans l’ordre.
#
# Usage (racine repo) :
#   python tool/enrich_cours_from_pdf_tables.py
#
# Entrées : Cours TIP Optimus.pdf, cours_complet.md
# Sortie   : cours_complet_tables.md

from __future__ import annotations

import re
from collections import defaultdict
from pathlib import Path

import fitz

ROOT = Path(__file__).resolve().parents[1]
PDF_PATH = ROOT / "Cours TIP Optimus.pdf"
LEGACY_MD = ROOT / "cours_complet.md"
OUT_MD = ROOT / "cours_complet_tables.md"


def _rect_overlap_ratio(block: fitz.Rect, table: fitz.Rect) -> float:
    inter = block & table
    if inter.is_empty or block.get_area() <= 0:
        return 0.0
    return inter.get_area() / block.get_area()


def _compress_duplicate_adjacent_cells(line: str) -> str:
    """Réduit les répétitions (cellules fusionnées PDF → mêmes libellés en série)."""
    s = line.strip()
    if not s.startswith("|"):
        return line
    inner = s[1:-1] if s.endswith("|") else s[1:]
    cells = [c.strip() for c in inner.split("|")]
    merged: list[str] = []
    for c in cells:
        if c and merged and c == merged[-1]:
            continue
        merged.append(c)
    return "|" + "|".join(merged) + "|"


def _clean_table_markdown(md: str) -> str:
    """Allège les grilles Col1…Col12 et lignes vides produites par MuPDF."""
    lines = md.splitlines()
    out: list[str] = []
    skip_next_sep = False
    for i, line in enumerate(lines):
        raw = line.strip()
        if not raw:
            continue
        cells = [c.strip() for c in line.split("|")[1:-1]]
        if not cells:
            continue
        # Ligne d’en-tête générique Col1|Col2|…
        if all(re.fullmatch(r"Col\d+", c) for c in cells if c):
            skip_next_sep = True
            continue
        if skip_next_sep and re.match(r"^\|?[\s\-:|]+\|?$", raw):
            skip_next_sep = False
            continue
        skip_next_sep = False
        # Ligne de séparation markdown standard
        if re.match(r"^\|?[\s\-:|]+\|?$", raw) and "---" in raw:
            out.append(line)
            continue
        # Ligne entièrement vide côté cellules
        if all(not c for c in cells):
            continue
        if raw.startswith("|") and "---" not in raw:
            out.append(_compress_duplicate_adjacent_cells(line))
        else:
            out.append(line)
    return "\n".join(out).strip()


def _page_to_markdown(page: fitz.Page) -> str:
    blocks = page.get_text("blocks")
    tables = list(page.find_tables())
    table_rects = [fitz.Rect(t.bbox) for t in tables]
    table_items: list[tuple[float, str]] = []
    for t in tables:
        try:
            md = t.to_markdown()
        except Exception:
            md = ""
        if md:
            cleaned = _clean_table_markdown(md)
            if cleaned:
                table_items.append((fitz.Rect(t.bbox).y0, cleaned))

    text_items: list[tuple[float, str]] = []
    for b in blocks:
        if len(b) < 7 or b[6] != 0:
            continue
        br = fitz.Rect(b[0], b[1], b[2], b[3])
        txt = (b[4] or "").strip()
        if not txt:
            continue
        if table_rects:
            mx = max(_rect_overlap_ratio(br, tr) for tr in table_rects)
            if mx > 0.38:
                continue
        text_items.append((br.y0, txt))

    tagged: list[tuple[float, str, str]] = [
        *(("text", y0, t) for y0, t in text_items),
        *(("table", y0, t) for y0, t in table_items),
    ]
    tagged.sort(key=lambda x: x[1])
    parts: list[str] = []
    for kind, _y, payload in tagged:
        if kind == "table":
            parts.append("\n" + payload + "\n")
        else:
            parts.append(payload)
    return "\n\n".join(parts).strip()


def _ordered_image_lines(legacy_md: str) -> list[str]:
    return re.findall(r"!\[Image\s+\d+\]\(\./images/[^)]+\)", legacy_md)


def _pdf_image_page_order(pdf_path: Path) -> list[int]:
    doc = fitz.open(str(pdf_path))
    try:
        order: list[int] = []
        for pi in range(len(doc)):
            for _img in doc[pi].get_images(full=True):
                order.append(pi + 1)
        return order
    finally:
        doc.close()


def _split_md_by_page(md: str) -> list[tuple[int, str]]:
    tokens = re.split(r"<!-- page (\d+) -->\s*\n*", md)
    out: list[tuple[int, str]] = []
    if tokens and not tokens[0].strip():
        tokens = tokens[1:]
    idx = 0
    while idx + 1 < len(tokens):
        out.append((int(tokens[idx]), tokens[idx + 1]))
        idx += 2
    return out


def _inject_images_by_page(pdf_md: str, legacy_md: str, pdf_path: Path) -> str:
    """Même ordre que l’extraction PyMuPDF (convert_pdf.py) : images regroupées par page."""
    imgs = _ordered_image_lines(legacy_md)
    order = _pdf_image_page_order(pdf_path)
    if len(imgs) != len(order):
        print(
            f"Avertissement : {len(imgs)} balises image dans cours_complet.md "
            f"vs {len(order)} images dans le PDF — couplage par indice min.",
        )
    bucket: dict[int, list[str]] = defaultdict(list)
    for i, pg in enumerate(order):
        if i < len(imgs):
            bucket[pg].append(imgs[i])
    chunks = _split_md_by_page(pdf_md)
    parts: list[str] = []
    for pnum, content in chunks:
        extra = bucket.get(pnum, [])
        block = content.rstrip()
        if extra:
            block = f"{block}\n\n" + "\n\n".join(extra)
        parts.append(f"<!-- page {pnum} -->\n\n{block}\n")
    return "\n\n".join(parts)


def main() -> None:
    if not PDF_PATH.is_file():
        raise SystemExit(f"PDF introuvable : {PDF_PATH}")
    if not LEGACY_MD.is_file():
        raise SystemExit(f"Markdown source introuvable : {LEGACY_MD}")

    doc = fitz.open(str(PDF_PATH))
    page_parts: list[str] = []
    try:
        for i in range(len(doc)):
            page = doc[i]
            chunk = _page_to_markdown(page)
            if chunk:
                page_parts.append(f"<!-- page {i + 1} -->\n\n{chunk}")
    finally:
        doc.close()

    merged = "\n\n".join(page_parts)
    legacy_text = LEGACY_MD.read_text(encoding="utf-8")
    final = _inject_images_by_page(merged, legacy_text, PDF_PATH)
    OUT_MD.write_text(final + "\n", encoding="utf-8")
    print(f"OK — écrit {OUT_MD} ({len(final)} car.)")


if __name__ == "__main__":
    main()
