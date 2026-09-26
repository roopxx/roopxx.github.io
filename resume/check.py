#!/usr/bin/env python3
"""Prove the compiled resume is still readable by a machine.

Why pdfminer.six and not pdftotext: poppler runs a word-reassembly heuristic
that silently repairs tracked-out text, so a `pdftotext | grep` gate passes on
exactly the document it is meant to catch. pdfminer does not do that, and it is
closer to the Python extraction used by real ATS pipelines. See resume/README.md.

Exits non-zero if any gate fails.
"""
import sys

from pdfminer.high_level import extract_text
from pypdf import PdfReader

PDF = sys.argv[1] if len(sys.argv) > 1 else "../assets/resume.pdf"

# Gate 1 — the contact line must survive extraction (no icon fonts).
CONTACT = (
    "roopxx.github.io",
    "rupesh.roopxx@gmail.com",
    "github.com/roopxx",
    "x.com/roopxx",
    "linkedin.com/in/roopxx",
)

# Gate 2 — section headings must extract as words (no letter-spacing).
HEADINGS = ("EXPERIENCE", "EDUCATION", "SKILLS", "CERTIFICATIONS")


def main():
    text = extract_text(PDF)
    reader = PdfReader(PDF)
    failures = []

    def check(ok, label, detail=""):
        print(f"  {'ok  ' if ok else 'FAIL'} {label}{detail}")
        if not ok:
            failures.append(label)

    print("→ exactly one page")
    check(len(reader.pages) == 1, "single page", f" ({len(reader.pages)} pages)")

    print("→ contact line extracts as text (no icon fonts)")
    for needle in CONTACT:
        check(needle in text, f"{needle!r}")

    print("→ section headings extract as words (no letter-spacing)")
    for heading in HEADINGS:
        check(heading in text, f"heading {heading}")

    if failures:
        print(f"\n{len(failures)} gate(s) failed")
        sys.exit(1)
    print("\nall gates passed")


if __name__ == "__main__":
    main()
