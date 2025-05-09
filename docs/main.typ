#set page(
  paper: "a4",
  margin: (x: 3cm, y: 1.5cm),
)

#set text(
  size: 12pt
)

#set par(
  first-line-indent: 1em,
  spacing: 0.65em,
  justify: true,
)

#set heading(numbering: "1.")
#set math.equation(numbering: "(1)")
#set page(numbering: "1/1")

#show link: underline

#let date = datetime.today().display()

#align(center, text(22pt)[
  *Social Network Analysis* \ #text(size: 10pt, date)
])

#grid(
  columns: (1fr, 1fr),
  gutter: 20pt,
  align(center)[
    #link("https://www.linkedin.com/in/massimo-r-403207136/")[Massimo Rondelli] \
    Computer Science \
    0001127063 \
    #link("mailto:massimo.rondelli@studio.unibo.it")
  ],
  align(center)[
    #link("https://www.linkedin.com/in/michele-dinelli")[Michele Dinelli] \
    Computer Science \
    0001132338 \
    #link("mailto:michele.dinelli5@studio.unibo.it")
  ],
  align(center)[
    #link("https://www.linkedin.com/in/nadia-farokhpay")[Nadia Farokhpay] \
    Artificial Intelligence \
    0001111417 \
    #link("mailto:nadiafarokhpay75@gmail.com")
  ],
  align(center)[
    #link("https://www.linkedin.com/in/youssef-hanna-5b54b0227")[Youssef Hanna] \
    Computer Science \
    0001132285 \
    #link("mailto:youssefawni.hanna@studio.unibo.it")
  ]
)
\
In this report, we will explore the various factors that influence fluid dynamics in glaciers and how they contribute to the formation and behavior of these natural structures.

#outline()

= Introduction
This is an example of a citation @Turing1937.

#lorem(45)

= Problem and Motivation
#lorem(45)

$ sum_(k=0)^n k
    &= 1 + ... + n \
    &= (n(n+1)) / 2 $

= Datasets
#lorem(45)

$ binom(n, k) $

= Validity and Reliability
#lorem(45)

= Measures and Results
#figure(
  table(
    columns: 4,
    [t], [1], [2], [3],
    [y], [0.3], [0.7], [0.5],
  ),
  caption: [Experiment results],
)

= Conclusion
#lorem(45)

#figure(
  image("figures/model.jpeg"),
  caption: [A nice example figure],
)

= Critique
#lorem(45)

#pagebreak()

#outline(
  title: [List of Figures],
  target: figure.where(kind: image),
)

#outline(
  title: [List of Tables],
  target: figure.where(kind: table),
)

#bibliography("bib.bib", style: "ieee", title: "References")

