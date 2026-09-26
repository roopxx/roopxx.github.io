# resume

The resume, typeset from source.

```
_data/resume.yml ──typst──► assets/resume.pdf   (committed)
                 └─jekyll─► /resume/            (HTML page, same data)
```

`_data/resume.yml` is the only file you normally edit. It uses
[JSON Resume](https://jsonresume.org/schema) field names, so the content
outlives the renderer. `resume.typ` is layout only — nothing in it is a fact
about you.

## Editing it

```sh
npm run resume                 # build assets/resume.pdf, then run the gates
typst watch --root .. --font-path fonts resume.typ   # live preview while writing
```

Dates are ISO `YYYY-MM`. An absent `endDate` means "Present"; do not write
display strings in the YAML.

The PDF is **committed on purpose** so the deploy has no resume build step. The
pre-commit hook rebuilds it whenever `_data/resume.yml` or `resume.typ` changes,
so it cannot go stale.

## The gates

`check.py` reads the compiled PDF with **pdfminer.six** (not `pdftotext`) and
fails if:

1. **The contact line is not plain text.** Icon fonts have no Unicode mapping, so
   their glyphs extract as garbage instead of the email or URLs.
2. **A section heading does not extract as a word.** Letter-spacing is per-glyph
   positioning, so a tracked-out heading extracts as `E X P E R I E N C E` and
   an ATS finds no Experience section.
3. **It is not exactly one page.**

Why not `pdftotext`: poppler silently reassembles tracked-out words, so a
`pdftotext | grep` gate passes on exactly the document it should catch.

## Typst

Pinned to `0.15.1` in `build.sh`. `--creation-timestamp 0` makes the output
reproducible. The compiler is the disposable half: if Typst becomes a bad bet,
`_data/resume.yml` is unchanged and only `resume.typ` gets rewritten.

## Fonts

Vendored in `fonts/`, all SIL OFL 1.1 (see the `*-LICENSE.txt` files):

- **Baskervville** — the name, at 28pt, and nothing else.
- **Source Serif 4** — prose (bullets, company names). Regular, SemiBold, Italic.
- **JetBrains Mono** — the "machine" role: section headings, dates, contact.

Typst needs TTF/OTF, so these are the static TTFs from the upstream releases,
committed as-is.

The layout is left-aligned throughout: serif prose, a display serif name, bold
mono section headings with no rules, and dates right-aligned per entry. Paper is
A4.
