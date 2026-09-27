// resume.typ - the layout for the resume. The content is in the site's
// _data/resume.yml, and this file only ever reads it.
//
// Three choices here are deliberate, because each one breaks text extraction:
//   1. No letter-spacing on section headings. Tracked-out text comes back as
//      "E X P E R I E N C E", so the parser never finds the section.
//   2. No icon fonts. Their glyphs have no Unicode mapping, so they extract as
//      junk in place of an email or a URL.
//   3. Ragged right, never justified.
// The page count is asserted at the bottom: one page, exactly.
//
// Type roles, in the spirit of the site: a display face for the name, a text
// serif for prose, a mono for facts (headings, dates, contact).

#let r = yaml("../../_data/resume.yml")
#let basics = r.basics

// -- tokens ----------------------------------------------------------------
#let ink = rgb("#100f0f")
#let quiet = rgb("#6f6e69")

#let display = "Baskervville"
#let paper = "Source Serif 4"
#let machine = "JetBrains Mono"

// -- date helpers ----------------------------------------------------------
#let MONTHS = (
  "01": "Jan", "02": "Feb", "03": "Mar", "04": "Apr",
  "05": "May", "06": "Jun", "07": "Jul", "08": "Aug",
  "09": "Sep", "10": "Oct", "11": "Nov", "12": "Dec",
)

#let fmt-date(d) = {
  if d == none or d == "" { return "Present" }
  let s = str(d)
  if s.contains("-") {
    let parts = s.split("-")
    MONTHS.at(parts.at(1)) + " " + parts.at(0)
  } else { s }
}

#let date-range(item, ongoing: true) = {
  let start = fmt-date(item.at("startDate", default: none))
  let raw-end = item.at("endDate", default: none)
  if raw-end == none and not ongoing { return start }
  let end = fmt-date(raw-end)
  if start == end { start } else { start + " - " + end }
}

// -- page ------------------------------------------------------------------
#set document(
  title: basics.name + " - " + basics.label,
  author: basics.name,
  keywords: r.skills.map(g => g.keywords).flatten(),
)

#set page(paper: "a4", margin: (x: 1.5cm, top: 1.5cm, bottom: 1.4cm))

#set text(font: paper, size: 11.5pt, fill: ink, lang: "en")
#set par(justify: false, leading: 0.78em, spacing: 0.78em)

// Links are not coloured: half the page would go blue, and this has to survive
// being printed in black and white. The URL text is the affordance.
#show link: set text(fill: ink)

// -- components ------------------------------------------------------------
// The small-label feel comes from face, size, weight and case - never from
// tracking (rule 1).
#let section(title) = block(above: 2.2em, below: 0.8em, breakable: false)[
  #text(font: machine, size: 9pt, weight: "bold", fill: ink)[#upper(title)]
]

// Prose left, facts right. One right-aligned fact per entry, and it is the date.
#let row(left-text, right-text) = block(
  above: 0.35em,
  below: 0em,
  grid(
    columns: (1fr, auto),
    column-gutter: 1em,
    align: (left + horizon, right + horizon),
    left-text,
    text(font: machine, size: 8.5pt, fill: quiet)[#right-text],
  ),
)

#let subrow(body) = block(above: 0.5em, below: 0em, text(style: "italic")[#body])

#let bullets(items) = {
  set list(marker: text(fill: quiet, size: 0.9em)[•], indent: 0em, body-indent: 0.5em)
  set par(leading: 0.62em)
  block(above: 0.7em, below: 0em, list(..items.map(i => [#i])))
}

#let entry(body) = block(above: 1.7em, below: 0em, breakable: false, body)

// -- header ----------------------------------------------------------------
// Stacked, left-aligned, no wide horizontal gap - the contact line is what a
// parser most wants. URLs are spelled out; there are no icons (rule 2).
#{
  set block(spacing: 0em)
  text(font: display, size: 28pt)[#basics.name]
  v(0.34em)

  let contact = (
    link(basics.url)[#basics.url.replace("https://", "").replace("www.", "")],
    link("mailto:" + basics.email)[#basics.email],
    ..basics.profiles.map(p => link(p.url)[
      #p.url.replace("https://", "").replace("www.", "")
    ]),
    basics.location.country,
  )

  // 7.5pt keeps all six items on one line.
  text(font: machine, size: 7.5pt, fill: quiet)[
    #contact.join(text(fill: quiet)[ · ])
  ]
}

// The summary gets no heading: a reader who just read the name knows whose it
// is. Set a little narrower than the page so it reads as a paragraph.
#block(above: 1.6em, below: 0em, width: 94%)[#basics.summary]

// -- experience ------------------------------------------------------------
#section("Experience")

#for job in r.work {
  entry[
    #row(text(size: 12.5pt, weight: 600)[#job.position], date-range(job))
    #subrow[#job.name]
    #if job.at("summary", default: none) != none [
      #block(above: 0.55em, below: 0em)[#job.summary]
    ]
    #bullets(job.highlights)
  ]
}

// -- education -------------------------------------------------------------
#section("Education")

#for e in r.education {
  entry[
    #row(text(size: 12.5pt, weight: 600)[#e.studyType of #e.area], fmt-date(e.at("endDate", default: none)))
    #subrow[#e.institution]
  ]
}

// -- skills ----------------------------------------------------------------
// One row per group: the label in the machine face, the keywords in prose. The
// rows need real spacing between them - packed at zero they collide.
#section("Skills")

#for group in r.skills {
  grid(
    columns: (4.6cm, 1fr),
    column-gutter: 0.6em,
    align: (left + horizon, left + horizon),
    text(font: machine, size: 8.5pt, fill: quiet)[#group.name],
    text(size: 10.5pt)[#group.keywords.join(" · ")],
  )
  v(0.5em)
}

// -- certifications --------------------------------------------------------
#section("Certifications")

#for c in r.certificates {
  entry[
    #row(text(size: 12.5pt, weight: 600)[#c.name], "")
    #subrow[#c.issuer]
  ]
}

// -- the one-page invariant ------------------------------------------------
// Kept in the document rather than in the build script, so an overlong bullet
// shows up in `typst watch` while I'm still writing it.
#context {
  let n = counter(page).final().first()
  assert(
    n == 1,
    message: "resume must be exactly one page, got " + str(n)
      + " - cut a bullet, do not shrink the type",
  )
}
