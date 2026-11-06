"""Mechanical checks for a resume HTML file built from resume/template.html.

Usage: python3 lint.py resume/out/<name>.html

Reports facts, not verdicts: per-bullet word counts, pronoun leaks, words and
patterns that read as filler or machine-written, and repeated bullet openers.
A reviewer decides which hits matter; one stray word is weak evidence, a
pattern across bullets is strong.
"""
import html
import re
import sys
from collections import Counter

LONG_BULLET = 35  # words; our threshold, not a sourced rule

# Third-person or first-person leaks. Resumes drop pronouns entirely.
PRONOUNS = r"\b(he|his|him|she|her|they|their|I|my|me|we|our)\b"

# Puffery and filler: Wikipedia "Signs of AI writing" word lists plus common
# resume cliches.
FILLER = [
    "leverage", "leveraged", "leveraging", "spearhead", "spearheaded",
    "utilize", "utilized", "robust", "seamless", "seamlessly", "cutting-edge",
    "passionate", "results-driven", "synergy", "pivotal", "crucial", "vital",
    "showcase", "showcasing", "foster", "fostering", "enhance", "enhancing",
    "underscore", "underscoring", "testament", "landscape", "dynamic",
    "innovative", "world-class", "best-in-class", "impactful", "meticulous",
    "meticulously", "delve", "tapestry", "multifaceted", "holistic",
    "proven track record", "key role", "instrumental",
]

PATTERNS = {
    "participle tail (', highlighting...')": r",\s+(highlighting|underscoring|ensuring|reflecting|showcasing|demonstrating|enabling|fostering|contributing)\b",
    "negative parallelism": r"\b(not just|not only|rather than)\b",
    "'from X to Y'": r"\bfrom\b[^,;.]{1,60}?\bto\b",
    "em dash in prose": r"—",
}


def text(fragment):
    return " ".join(html.unescape(re.sub(r"<[^>]+>", " ", fragment)).split())


def main(path):
    src = open(path, encoding="utf-8").read()
    summary = re.search(r"<h2>Summary</h2>\s*<p>(.*?)</p>", src, re.S)
    bullets = [text(b) for b in re.findall(r"<li>(.*?)</li>", src, re.S)]
    items = ([("summary", text(summary.group(1)))] if summary else []) + [
        (f"b{i + 1}", b) for i, b in enumerate(bullets)
    ]

    words = {k: len(t.split()) for k, t in items}
    bullet_words = [words[k] for k, _ in items if k != "summary"]
    print(f"{len(bullets)} bullets, {sum(words.values())} words "
          f"(bullets avg {sum(bullet_words) / max(len(bullet_words), 1):.0f}, "
          f"max {max(bullet_words, default=0)})")
    if "summary" in words:
        print(f"summary: {words['summary']} words")

    print(f"\nBullets over {LONG_BULLET} words:")
    for k, t in items:
        if k != "summary" and words[k] > LONG_BULLET:
            print(f"  {k} ({words[k]}): {t[:80]}...")

    def hits(label, regex, flags=re.I):
        found = [(k, m.group(0)) for k, t in items for m in re.finditer(regex, t, flags)]
        if found:
            print(f"\n{label}: {len(found)}")
            for k, m in found:
                print(f"  {k}: {m!r}")

    hits("Pronouns", PRONOUNS, 0)
    hits("Filler / puffery words", r"\b(" + "|".join(map(re.escape, FILLER)) + r")\b")
    for label, regex in PATTERNS.items():
        hits(label, regex)

    openers = Counter(b.split()[0].lower() for b in bullets if b)
    repeated = {w: n for w, n in openers.items() if n > 2}
    if repeated:
        print(f"\nOpening verbs used 3+ times: {repeated}")
    semis = [(f"b{i + 1}", b.count(";")) for i, b in enumerate(bullets) if b.count(";") >= 2]
    if semis:
        print(f"\nBullets with 2+ semicolons (packed clauses): {semis}")


if __name__ == "__main__":
    main(sys.argv[1])
