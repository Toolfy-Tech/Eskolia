# -*- coding: utf-8 -*-
"""Reequilibre positions A-D et reduit le biais 'bonne reponse unique la plus longue' pour O01/O02."""
from __future__ import annotations

import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OPT = ROOT / "data" / "questions" / "optimus"

def trim_double_clause(s: str) -> str:
    """Si plusieurs ajouts ' — …' se cumulent, ne garder que la derniere precision."""
    if s.count(" — ") < 2:
        return s
    first = s.find(" — ")
    last = s.rfind(" — ")
    if first != last:
        return s[:first] + s[last:]
    return s


SUFFIXES = [
    " — cas courant en atelier.",
    " — variante frequente selon le materiel.",
    " — situation type en support.",
    " — contexte standard PC bureau.",
    " — configuration usuelle.",
    " — pratique courante entreprise.",
]


def is_unique_longest(options: list[str], correct_index: int) -> bool:
    lens = [len(o) for o in options]
    c = lens[correct_index]
    return all(c > lens[i] for i in range(4) if i != correct_index)


def reduce_length_bias(options: list[str], correct_index: int, salt: int) -> None:
    ci = correct_index
    wrong_idx = [i for i in range(4) if i != ci]
    k = 0
    while is_unique_longest(options, ci) and k < 72:
        lens = [len(options[i]) for i in wrong_idx]
        j = wrong_idx[lens.index(min(lens))]
        suf = SUFFIXES[(salt + k) % len(SUFFIXES)]
        options[j] = options[j].rstrip() + suf
        k += 1


def set_correct_at(options: list[str], old_ci: int, target: int) -> tuple[int, list[str]]:
    correct = options[old_ci]
    wrong = [options[i] for i in range(4) if i != old_ci]
    new_opts: list[str] = [""] * 4
    new_opts[target] = correct
    wi = 0
    for i in range(4):
        if i != target:
            new_opts[i] = wrong[wi]
            wi += 1
    return target, new_opts


def process_section(section_dir: Path, section_label: str) -> None:
    files = sorted(section_dir.glob("*.json"))
    idx = 0
    for fp in files:
        data = json.loads(fp.read_text(encoding="utf-8"))
        changed = False
        for q in data:
            target = idx % 4
            idx += 1
            opts = list(q["options"])
            oci = int(q["correct_index"])
            nci, new_opts = set_correct_at(opts, oci, target)
            q["options"] = new_opts
            q["correct_index"] = nci
            salt = sum(ord(c) for c in q["id"]) % 10_000
            reduce_length_bias(q["options"], q["correct_index"], salt)
            for i in range(4):
                q["options"][i] = trim_double_clause(q["options"][i])
            if is_unique_longest(q["options"], q["correct_index"]):
                reduce_length_bias(q["options"], q["correct_index"], salt + 17)
                for i in range(4):
                    q["options"][i] = trim_double_clause(q["options"][i])
            changed = True
        if changed:
            fp.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(section_label, "questions processed:", idx)


def main() -> None:
    process_section(OPT / "section-01", "O01")
    process_section(OPT / "section-02", "O02")


if __name__ == "__main__":
    main()
