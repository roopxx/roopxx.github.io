# resume

One YAML file, two outputs. `_data/resume.yml` holds the content, Typst turns it
into a PDF, and Jekyll turns the same file into the page at `/resume/`. Neither
output knows anything the YAML doesn't already say.

| Output       | Built by | Ends up as                     |
| ------------ | -------- | ------------------------------ |
| the download | Typst    | `assets/resume.pdf`, committed |
| the page     | Jekyll   | `/resume/`                     |

Nothing in this folder is published. `tools/` is listed under `exclude` in
`_config.yml`, so the site only ever sees the PDF and the HTML page.

## The content

`_data/resume.yml`, and nothing else. It uses the
[JSON Resume](https://jsonresume.org/schema) field names, so the writing isn't
tied to Typst. The `resume.typ` sitting next to this README is the layout, which
means sizes and spacing, and no facts of its own.

Dates are `YYYY-MM`. Leaving `endDate` out means "Present", so I never write a
date range by hand.

## Building it

```sh
npm run resume                                          # compile, then check
typst watch --root ../.. --font-path fonts resume.typ   # preview while writing
```

The pre-commit hook rebuilds the PDF whenever `_data/resume.yml` or `resume.typ`
changes, so the committed copy keeps up with the source. Deploying doesn't touch
the resume at all.

`--creation-timestamp 0` makes the compile reproducible. Rebuilding with no edits
gives the same bytes, so git has nothing to show for it.

## What check.py catches

`check.py` reads the finished PDF back with pdfminer.six, and three things have
to come out intact:

- The contact line has to extract as text. Icon fonts have no Unicode mapping,
  so their glyphs turn into rubbish, and the contact row is the first thing a
  parser looks for.
- Every section heading has to extract as one word. Letter-spacing is per-glyph
  positioning, so a loose heading reads as `E X P E R I E N C E` and the section
  goes missing.
- One page, and no more.

I use pdfminer rather than `pdftotext` because poppler quietly rejoins words that
were tracked out. A broken contact line would sail through a `pdftotext | grep`
check that way.

## Typst

`build.sh` pins Typst to `0.15.1`, and it checks the version before compiling.
Typst is pre-1.0 and breaks things between releases, so the pin is deliberate. If
it ever stops being worth the trouble, only the layout changes.

## The typefaces

Three families in `fonts/`, with their licences beside them, all SIL OFL. Typst
takes TTF or OTF:

- **Baskervville** for the name, at 28pt, and nothing else.
- **Source Serif 4** for prose, in Regular, SemiBold and Italic.
- **JetBrains Mono** for the machine parts: section headings, dates, contact.

Left-aligned throughout, dates right-aligned per entry, A4.

## In this folder

```
resume.typ          the layout
check.py            the extraction checks
build.sh            compile, then run check.py
requirements.txt    pdfminer.six and pypdf, for check.py
fonts/              the three families and their licences
```
