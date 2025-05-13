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
  show math.equation: set text(font: "New Computer Modern Math")
  set math.equation(numbering: "(1)", supplement: [Eq.])
  
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

  show figure: it => [
    #pad(y: 1.25em, it)
  ]

  show figure.caption: it => [
    #align(left)[
      *#it.supplement*
      #context it.counter.display(it.numbering):
      #it.body]
  ]

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