#let project(title: "", authors: (), body) = {
  set document(author: authors.map(a => a.name), title: title)
  set page(
    paper: "a4",
    numbering: "1",
    number-align: center,
    margin: (x: 2.5cm, y: 3cm),
  )
  set text(
    size: 11pt,
    font: "Times New Roman",
    lang: "en"
  )
  
  show math.equation: set text(weight: 400)
  set math.equation(numbering: "(1)")
  show math.equation: set text(font: "New Computer Modern Math")
  show ref: it => {
    // provide custom reference for equations
    if it.element != none and it.element.func() == math.equation {
      // optional: wrap inside link, so whole label is linked
      text(rgb("FF0000"))[#lower([#it])]
    } else {
      it
    }
  }

  set heading(numbering: "1.1")
  show heading: it => {
    [#it]
    v(4pt)
  }
  
  show link: l => underline[#l]

  set list(marker: ([•], [-]))

  set par(
    first-line-indent: 1em,
    justify: true,
    spacing: 0.7em
  )

  set math.vec(delim: "[")
  set math.mat(delim: "[")

  // Title row
  align(center)[
    #block(text(weight: 700, 1.75em, title))
  ]

  // Author information
  pad(
    top: 2em,
    bottom: 2em,
    x: 2em,
    grid(
      columns: (1fr,) * calc.min(2, authors.len()),
      gutter: 1em,
      ..authors.map(author => align(center)[
        *#author.name* \
        #author.email \
        #author.affiliation
      ]),
    ),
  )

  // Main body

  body
}