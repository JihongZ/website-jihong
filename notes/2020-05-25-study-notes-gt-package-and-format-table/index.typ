// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let suppl = it.at("supplement", default: none)
  if suppl == none or suppl == auto {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let target = query(it.target, loc).first()
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}



#let article(
  title: none,
  authors: none,
  date: none,
  abstract: none,
  cols: 1,
  margin: (x: 1.25in, y: 1.25in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: (),
  fontsize: 11pt,
  sectionnumbering: none,
  toc: false,
  toc_title: none,
  toc_depth: none,
  toc_indent: 1.5em,
  doc,
) = {
  set page(
    paper: paper,
    margin: margin,
    numbering: "1",
  )
  set par(justify: true)
  set text(lang: lang,
           region: region,
           font: font,
           size: fontsize)
  set heading(numbering: sectionnumbering)

  if title != none {
    align(center)[#block(inset: 2em)[
      #text(weight: "bold", size: 1.5em)[#title]
    ]]
  }

  if authors != none {
    let count = authors.len()
    let ncols = calc.min(count, 3)
    grid(
      columns: (1fr,) * ncols,
      row-gutter: 1.5em,
      ..authors.map(author =>
          align(center)[
            #author.name \
            #author.affiliation \
            #author.email
          ]
      )
    )
  }

  if date != none {
    align(center)[#block(inset: 1em)[
      #date
    ]]
  }

  if abstract != none {
    block(inset: 2em)[
    #text(weight: "semibold")[Abstract] #h(1em) #abstract
    ]
  }

  if toc {
    let title = if toc_title == none {
      auto
    } else {
      toc_title
    }
    block(above: 0em, below: 2em)[
    #outline(
      title: toc_title,
      depth: toc_depth,
      indent: toc_indent
    );
    ]
  }

  if cols == 1 {
    doc
  } else {
    columns(cols, doc)
  }
}

#set table(
  inset: 6pt,
  stroke: none
)
#show: doc => article(
  title: [Study Notes: `gt` package],
  authors: (
    ( name: [Jihong Zhang],
      affiliation: [],
      email: [] ),
    ),
  date: [2020-05-25],
  toc: true,
  toc_title: [Table of contents],
  toc_depth: 3,
  cols: 1,
  doc,
)
#import "@preview/fontawesome:0.1.0": *


#block[
#block[
#heading(
level: 
2
, 
numbering: 
none
, 
[
Overview
]
)
]
This post is inspired by themockup’s #link("https://themockup.blog/posts/2020-05-16-gt-a-grammer-of-tables/")[blog] and RStudio’s documentation of `gt` package#footnote[You can find the documentation #link("https://gt.rstudio.com/")[here];.];.

]
#quote(block: true)[
"We can construct a wide variety of useful tables with a cohesive set of table parts. These include the table header, the stub, the column labels and spanner column labels, the table body, and the table footer."
]

== Component
<component>
#figure([
#box(image("https://gt.rstudio.com/reference/figures/gt_parts_of_a_table.svg"))
], caption: figure.caption(
position: bottom, 
[
The Parts of a gt Table
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-component>


The typical gt table starts with converting a data frame into a gt object. The `gt` object is then modified by adding various components to it. The components include the table header, the stub, the column labels and spanner column labels, the table body, and the table footer.

== Example: sp500 data
<example-sp500-data>
As always, we install and load `gt` and `tidyverse` packages.

#block[
```r
library(gt)
library(tidyverse)
```

]
- `gt()` function can convert data.frame into `gt` object. A `gt` object can be directly output and rendered into HTML.

```r
# Define the start and end dates for the data range
start_date <- "2010-06-07"
end_date <- "2010-06-14"

# Create a gt table based on preprocessed
# `sp500` table data
sp500_gt <- sp500 |>
  dplyr::filter(date >= start_date & date <= end_date) |>
  dplyr::select(-adj_close) |>
  gt() 

sp500_gt
```

#block[
#figure(
  align(center)[#table(
    columns: 6,
    align: (auto,auto,auto,auto,auto,auto,),
    table.header([date], [open], [high], [low], [close], [volume],),
    table.hline(),
    [2010-06-14], [1095.00], [1105.91], [1089.03], [1089.63], [4425830000],
    [2010-06-11], [1082.65], [1092.25], [1077.12], [1091.60], [4059280000],
    [2010-06-10], [1058.77], [1087.85], [1058.77], [1086.84], [5144780000],
    [2010-06-09], [1062.75], [1077.74], [1052.25], [1055.69], [5983200000],
    [2010-06-08], [1050.81], [1063.15], [1042.17], [1062.00], [6192750000],
    [2010-06-07], [1065.84], [1071.36], [1049.86], [1050.47], [5467560000],
  )]
  , kind: table
  )

]
=== `tab_header`: title and subtitle
<tab_header-title-and-subtitle>
- The `gt` object can be further modified by adding components to it, for example `tab_header` adds Table Headers (including title and subtitle).
  - For narratives like #emph[title] or #emph[subtitle];, you can also use markdown format with the `md` function.

```r
sp500_gt |> 
  tab_header(
    title = "S&P 500",
    subtitle = "June 7-14, 2010"
  )
```

#block[
#figure(
  align(center)[#table(
    columns: 6,
    align: (auto,auto,auto,auto,auto,auto,),
    table.header(table.cell(colspan: 6)[S&P 500],
      table.cell(colspan: 6)[June 7-14, 2010],
      [date], [open], [high], [low], [close], [volume],),
    table.hline(),
    [2010-06-14], [1095.00], [1105.91], [1089.03], [1089.63], [4425830000],
    [2010-06-11], [1082.65], [1092.25], [1077.12], [1091.60], [4059280000],
    [2010-06-10], [1058.77], [1087.85], [1058.77], [1086.84], [5144780000],
    [2010-06-09], [1062.75], [1077.74], [1052.25], [1055.69], [5983200000],
    [2010-06-08], [1050.81], [1063.15], [1042.17], [1062.00], [6192750000],
    [2010-06-07], [1065.84], [1071.36], [1049.86], [1050.47], [5467560000],
  )]
  , kind: table
  )

]
#block[
#callout(
body: 
[
Note that if your Quarto HTML has CSS style, the markdown format in `gt` object may not work as expected. Like the following title will be #strong[bold] but with underline (my CSS style).

]
, 
title: 
[
Note
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
```r
sp500_gt |> 
  tab_header(
    title = md("**S&P 500**"),
    subtitle = md("*June 7-14*, 2010")
  )
```

#block[
#figure(
  align(center)[#table(
    columns: 6,
    align: (auto,auto,auto,auto,auto,auto,),
    table.header(table.cell(colspan: 6)[S&P 500],
      table.cell(colspan: 6)[June 7-14, 2010],
      [date], [open], [high], [low], [close], [volume],),
    table.hline(),
    [2010-06-14], [1095.00], [1105.91], [1089.03], [1089.63], [4425830000],
    [2010-06-11], [1082.65], [1092.25], [1077.12], [1091.60], [4059280000],
    [2010-06-10], [1058.77], [1087.85], [1058.77], [1086.84], [5144780000],
    [2010-06-09], [1062.75], [1077.74], [1052.25], [1055.69], [5983200000],
    [2010-06-08], [1050.81], [1063.15], [1042.17], [1062.00], [6192750000],
    [2010-06-07], [1065.84], [1071.36], [1049.86], [1050.47], [5467560000],
  )]
  , kind: table
  )

]
=== `fmt_<column_type>`: format columns
<fmt_column_type-format-columns>
- `fmt_<column_type>` functions can be used to format the columns of the table.
  - For example, `fmt_currency` can be used to format the `close` column as currency.
  - `fmt_date` can be used to format the `date` column as date.
  - `fmt_number` can be used to format the `volume` column as a number.

```r
sp500_gt |> 
  tab_header(
    title = "S&P 500",
    subtitle = "June 7-14, 2010"
  ) |> 
  fmt_currency(
    columns = vars(c(open, high, low, close)),
    currency = "USD"
  ) |> 
  fmt_date(
    columns = vars(date),
    date_style = "wday_month_day_year"
  ) |>
  fmt_number(
    columns = vars(volume),
    suffixing = TRUE
  )
```

#block[
#figure(
  align(center)[#table(
    columns: 6,
    align: (auto,auto,auto,auto,auto,auto,),
    table.header(table.cell(colspan: 6)[S&P 500],
      table.cell(colspan: 6)[June 7-14, 2010],
      [date], [open], [high], [low], [close], [volume],),
    table.hline(),
    [Monday, June 14, 2010], [\$1,095.00], [\$1,105.91], [\$1,089.03], [\$1,089.63], [4.43B],
    [Friday, June 11, 2010], [\$1,082.65], [\$1,092.25], [\$1,077.12], [\$1,091.60], [4.06B],
    [Thursday, June 10, 2010], [\$1,058.77], [\$1,087.85], [\$1,058.77], [\$1,086.84], [5.14B],
    [Wednesday, June 9, 2010], [\$1,062.75], [\$1,077.74], [\$1,052.25], [\$1,055.69], [5.98B],
    [Tuesday, June 8, 2010], [\$1,050.81], [\$1,063.15], [\$1,042.17], [\$1,062.00], [6.19B],
    [Monday, June 7, 2010], [\$1,065.84], [\$1,071.36], [\$1,049.86], [\$1,050.47], [5.47B],
  )]
  , kind: table
  )

]
=== `tab_source_note`: source note
<tab_source_note-source-note>
- `tab_source_note` can be used to add a source note to the table underneath the table.

```r
sp500_gt |> 
  tab_header(
    title = "S&P 500",
    subtitle = "June 7-14, 2010"
  ) |> 
  tab_source_note(
    source_note = "Data from Yahoo Finance"
  )
```

#block[
#figure(
  align(center)[#table(
    columns: 6,
    align: (auto,auto,auto,auto,auto,auto,),
    table.header(table.cell(colspan: 6)[S&P 500],
      table.cell(colspan: 6)[June 7-14, 2010],
      [date], [open], [high], [low], [close], [volume],),
    table.hline(),
    [2010-06-14], [1095.00], [1105.91], [1089.03], [1089.63], [4425830000],
    [2010-06-11], [1082.65], [1092.25], [1077.12], [1091.60], [4059280000],
    [2010-06-10], [1058.77], [1087.85], [1058.77], [1086.84], [5144780000],
    [2010-06-09], [1062.75], [1077.74], [1052.25], [1055.69], [5983200000],
    [2010-06-08], [1050.81], [1063.15], [1042.17], [1062.00], [6192750000],
    [2010-06-07], [1065.84], [1071.36], [1049.86], [1050.47], [5467560000],
    table.hline(),
    table.footer(table.cell(colspan: 6)[Data from Yahoo Finance],),
  )]
  , kind: table
  )

]
=== `tab_footnote`: footnotes
<tab_footnote-footnotes>
Beside the markdown format, Quarto HTML also accepts HTML code using `htmltools::p` function. But it may only apply to HTML not PDF. As @fig-component shows, footnotes are located at the bottom of the table but at the top of #emph[source notes];.

#block[
#callout(
body: 
[
We were able to supply the reference locations in the table by using the cells\_body() helper function and supplying the necessary targeting through the columns and rows arguments. Other cells\_\*() functions have similar interfaces and they allow us to target cells in different parts of the table.

]
, 
title: 
[
`cells_*()`: target cells in the table
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
```r
sp500_gt |> 
  tab_header(
    title = "S&P 500",
    subtitle = "June 7-14, 2010"
  ) |> 
  tab_source_note(
    source_note = htmltools::p(align="right", "Data from Yahoo Finance")
  ) |> 
  tab_footnote(
    footnote = "All values are in USD.",
    locations = cells_body(
      columns = vars(open),
      rows = date == "2010-06-14"
    )
  )
```

=== `tab_row_group`: row groups
<tab_row_group-row-groups>
- We can make a new row group with each tab\_row\_group() call.
- The inputs are row group names in the label argument, and row references in the rows argument.
- key arguments:
  - `label`: the name of the row group.
  - `rows`: the logical vector that specifies which rows belong to the group.

#block[
#callout(
body: 
[
Note that the sequence of adding `tab_row_group` will affect the order of the row groups in the final table. #emph[Lastest added group will be on the top.]

]
, 
title: 
[
Note
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
```r
sp500_gt |> 
  tab_header(
    title = "S&P 500",
    subtitle = "June 7-14, 2010"
  ) |> 
  tab_row_group(
    label = "Last three days",
    rows = date %in% c("2010-06-10", "2010-06-11", "2010-06-14")
  ) |> 
  tab_row_group(
    label = "First three days",
    rows = date %in% c("2010-06-07", "2010-06-08", "2010-06-09")
  ) 
```

#block[
#figure(
  align(center)[#table(
    columns: 6,
    align: (auto,auto,auto,auto,auto,auto,),
    table.header(table.cell(colspan: 6)[S&P 500],
      table.cell(colspan: 6)[June 7-14, 2010],
      [date], [open], [high], [low], [close], [volume],),
    table.hline(),
    table.cell(colspan: 6)[First three days],
    [2010-06-09], [1062.75], [1077.74], [1052.25], [1055.69], [5983200000],
    [2010-06-08], [1050.81], [1063.15], [1042.17], [1062.00], [6192750000],
    [2010-06-07], [1065.84], [1071.36], [1049.86], [1050.47], [5467560000],
    table.cell(colspan: 6)[Last three days],
    [2010-06-14], [1095.00], [1105.91], [1089.03], [1089.63], [4425830000],
    [2010-06-11], [1082.65], [1092.25], [1077.12], [1091.60], [4059280000],
    [2010-06-10], [1058.77], [1087.85], [1058.77], [1086.84], [5144780000],
  )]
  , kind: table
  )

]
=== `tab_spanner`: column groups and spann column labels
<tab_spanner-column-groups-and-spann-column-labels>
- key arguments:
  - `label`: the name of the column group.
  - `columns`: the columns that belong to the group.

```r
sp500_gt |> 
  tab_header(
    title = "S&P 500",
    subtitle = "June 7-14, 2010"
  ) |> 
  tab_spanner(
    label = "Price",
    columns = vars(open, high, low, close)
  ) |> 
  tab_spanner(
    label = "Volume",
    columns = vars(volume)
  )
```

#block[
#figure(
  align(center)[#table(
    columns: (16.67%, 16.67%, 16.67%, 16.67%, 16.67%, 16.67%),
    align: (auto,auto,auto,auto,auto,auto,),
    table.header(table.cell(colspan: 6)[S&P 500],
      table.cell(colspan: 6)[June 7-14, 2010],
      table.cell(rowspan: 2)[date], table.cell(colspan: 4)[#block[
      Price
      ]], [#block[
      Volume
      ]],
      [open], [high], [low], [close], [volume],),
    table.hline(),
    [2010-06-14], [1095.00], [1105.91], [1089.03], [1089.63], [4425830000],
    [2010-06-11], [1082.65], [1092.25], [1077.12], [1091.60], [4059280000],
    [2010-06-10], [1058.77], [1087.85], [1058.77], [1086.84], [5144780000],
    [2010-06-09], [1062.75], [1077.74], [1052.25], [1055.69], [5983200000],
    [2010-06-08], [1050.81], [1063.15], [1042.17], [1062.00], [6192750000],
    [2010-06-07], [1065.84], [1071.36], [1049.86], [1050.47], [5467560000],
  )]
  , kind: table
  )

]
=== `summary_rows`: summary rows
<summary_rows-summary-rows>
- `summary_rows` can be used to add summary rows to the table by `group`.
  - if you want to have grant summary statistics, use `grand_summary_rows` instead.
- key arguments:
  - `fns`: a list of functions to apply to the columns.
  - `columns`: the columns to which the functions are applied.

#block[
#callout(
body: 
[
Note that the `fmt` argument is used to format the summary values with a list. There are multiple formatting functions for numeric variables available in the gt package:

- `fmt_number(cols = vars(...), decimals = 2)`: format numbers with a specified number of 2 decimal places.

- `fmt_scientific(cols = vars(...), decimals = 3)`: format numbers in scientific notation with a specified number of 3 decimal places.

]
, 
title: 
[
Note
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
```r
sp500_gt |> 
  tab_header(
    title = "S&P 500",
    subtitle = "June 7-14, 2010"
  ) |> 
  grand_summary_rows(
    fns = list(
      "Mean" = ~ mean(., na.rm =TRUE),
      "SD" = ~ sd(., na.rm =TRUE)
    ),
    columns = vars(open, high, low, close, volume),
    fmt = list(
      ~ fmt_scientific(data = .,
                       columns = vars(volume), 
                       decimals = 3),
      ~ fmt_number(data = ., 
                   columns = vars(open, high, low, close), 
                   decimals = 2)
    )  
  )
```

#block[
#figure(
  align(center)[#table(
    columns: 7,
    align: (auto,auto,auto,auto,auto,auto,auto,),
    table.header(table.cell(colspan: 7)[S&P 500],
      table.cell(colspan: 7)[June 7-14, 2010],
      [], [date], [open], [high], [low], [close], [volume],),
    table.hline(),
    [], [2010-06-14], [1095.00], [1105.91], [1089.03], [1089.63], [4425830000],
    [], [2010-06-11], [1082.65], [1092.25], [1077.12], [1091.60], [4059280000],
    [], [2010-06-10], [1058.77], [1087.85], [1058.77], [1086.84], [5144780000],
    [], [2010-06-09], [1062.75], [1077.74], [1052.25], [1055.69], [5983200000],
    [], [2010-06-08], [1050.81], [1063.15], [1042.17], [1062.00], [6192750000],
    [], [2010-06-07], [1065.84], [1071.36], [1049.86], [1050.47], [5467560000],
    [Mean], [—], [1,069.30], [1,083.04], [1,061.53], [1,072.70], [5.212~×~10#super[9];],
    [SD], [—], [16.41], [15.43], [17.91], [18.66], [8.454~×~10#super[8];],
  )]
  , kind: table
  )

]
=== `cols_xxx()`: manupulate columns’ positions
<cols_xxx-manupulate-columns-positions>
- Functions:
  - `cols_move_to_start()`: move columns to the start of the table.
  - `cols_move_to_end()`: move columns to the end of the table.
  - `cols_hide()`: hide columns.

== Styling of the table
<styling-of-the-table>
A basic `gt` table can be created as so

#block[
```r
data("iris")
glimpse(iris)
```

#block[
```
Rows: 150
Columns: 5
$ Sepal.Length <dbl> 5.1, 4.9, 4.7, 4.6, 5.0, 5.4, 4.6, 5.0, 4.4, 4.9, 5.4, 4.…
$ Sepal.Width  <dbl> 3.5, 3.0, 3.2, 3.1, 3.6, 3.9, 3.4, 3.4, 2.9, 3.1, 3.7, 3.…
$ Petal.Length <dbl> 1.4, 1.4, 1.3, 1.5, 1.4, 1.7, 1.4, 1.5, 1.4, 1.5, 1.5, 1.…
$ Petal.Width  <dbl> 0.2, 0.2, 0.2, 0.2, 0.2, 0.4, 0.3, 0.2, 0.2, 0.1, 0.2, 0.…
$ Species      <fct> setosa, setosa, setosa, setosa, setosa, setosa, setosa, s…
```

]
]
You can add row names (`rowname_col` argument) and add group names (`groupname_col` argument) into the table:

```r
iris_gt <- iris |> 
  arrange(desc(Sepal.Length)) |> # 6 types of iris with largest sepal length
  mutate(Rank = 1:nrow(iris)) |> 
  slice_head(n = 3, by = Species) |> # select top 3 Sepal length of each species
  gt(groupname_col = "Species", rowname_col = "Rank")
iris_gt
```

#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [Sepal.Length], [Sepal.Width], [Petal.Length], [Petal.Width],),
    table.hline(),
    table.cell(colspan: 5)[virginica],
    [1], [7.9], [3.8], [6.4], [2.0],
    [2], [7.7], [3.8], [6.7], [2.2],
    [3], [7.7], [2.6], [6.9], [2.3],
    table.cell(colspan: 5)[versicolor],
    [13], [7.0], [3.2], [4.7], [1.4],
    [14], [6.9], [3.1], [4.9], [1.5],
    [18], [6.8], [2.8], [4.8], [1.4],
    table.cell(colspan: 5)[setosa],
    [71], [5.8], [4.0], [1.2], [0.2],
    [78], [5.7], [4.4], [1.5], [0.4],
    [79], [5.7], [3.8], [1.7], [0.3],
  )]
  , kind: table
  )

]
=== `tab_style`: change style of cells
<tab_style-change-style-of-cells>
- `tab_style(data, style, locations)` allows you to change the style (`style`) of cells (`locations`) in the table.

#block[
#callout(
body: 
[
- the background color of the cell (`cell_fill()`: color)
- the cell’s text color, font, and size (`cell_text()`: color, font, size)
- the text style (`cell_text()`: style), enabling the use of italics or oblique text.
- the text weight (`cell_text()`: weight), allowing the use of thin to bold text (the degree of choice is greater with variable fonts)
- the alignment and indentation of text (`cell_text()`: align and indent)
- the cell borders (`cell_borders()`)

```r
iris_gt_colored <- iris_gt |> 
  tab_style( # style for virginica
    style = list(
      cell_fill(color = "lightblue"),
      cell_text(weight = "bold")
    ),
    locations = cells_body(
        columns = colnames(iris),
        rows = Species == "virginica")
  ) |> 
  tab_style( # style for versicolor
    style = list(
      cell_fill(color = "royalblue"),
      cell_text(color = "red", weight = "bold")
    ),
    locations = cells_body(
        columns = colnames(iris),
        rows = Species == "versicolor")
  )
iris_gt_colored
```

#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [Sepal.Length], [Sepal.Width], [Petal.Length], [Petal.Width],),
    table.hline(),
    table.cell(colspan: 5)[virginica],
    [1], [7.9], [3.8], [6.4], [2.0],
    [2], [7.7], [3.8], [6.7], [2.2],
    [3], [7.7], [2.6], [6.9], [2.3],
    table.cell(colspan: 5)[versicolor],
    [13], [7.0], [3.2], [4.7], [1.4],
    [14], [6.9], [3.1], [4.9], [1.5],
    [18], [6.8], [2.8], [4.8], [1.4],
    table.cell(colspan: 5)[setosa],
    [71], [5.8], [4.0], [1.2], [0.2],
    [78], [5.7], [4.4], [1.5], [0.4],
    [79], [5.7], [3.8], [1.7], [0.3],
  )]
  , kind: table
  )

]
]
, 
title: 
[
Style functions for `style` argument
]
, 
background_color: 
rgb("#dae6fb")
, 
icon_color: 
rgb("#0758E5")
, 
icon: 
fa-info()
)
]
- Next, the boarder could be added into the table:

```r
iris_gt_colored |> 
  tab_style( # tab_style to change style of cells, 
    # cells_borders provides the formatting
    # locations tells it where add black borders to all column labels
    style = cell_borders(
        sides = "left",
        color = "black",
        weight = px(1.2)
    ),
    locations = cells_body(columns = colnames(iris))
  ) |> 
  # Add botton line below the column names
  tab_style(
    style = cell_borders(
        sides = "bottom",
        color = "black",
        weight = px(3)
    ),
    locations = cells_column_labels(columns = gt::everything())
  )
```

#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [Sepal.Length], [Sepal.Width], [Petal.Length], [Petal.Width],),
    table.hline(),
    table.cell(colspan: 5)[virginica],
    [1], [7.9], [3.8], [6.4], [2.0],
    [2], [7.7], [3.8], [6.7], [2.2],
    [3], [7.7], [2.6], [6.9], [2.3],
    table.cell(colspan: 5)[versicolor],
    [13], [7.0], [3.2], [4.7], [1.4],
    [14], [6.9], [3.1], [4.9], [1.5],
    [18], [6.8], [2.8], [4.8], [1.4],
    table.cell(colspan: 5)[setosa],
    [71], [5.8], [4.0], [1.2], [0.2],
    [78], [5.7], [4.4], [1.5], [0.4],
    [79], [5.7], [3.8], [1.7], [0.3],
  )]
  , kind: table
  )

]
=== `tab_options`: table output options
<tab_options-table-output-options>
- `tab_options` allows you to change the output options of the table. There are multiple options available:

+ `table.font.names=` allows you to change the font of the table.

```r
iris_gt_colored |> 
  tab_options(
    table.font.names = c("Tenor Sans")
  )
```

#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [Sepal.Length], [Sepal.Width], [Petal.Length], [Petal.Width],),
    table.hline(),
    table.cell(colspan: 5)[virginica],
    [1], [7.9], [3.8], [6.4], [2.0],
    [2], [7.7], [3.8], [6.7], [2.2],
    [3], [7.7], [2.6], [6.9], [2.3],
    table.cell(colspan: 5)[versicolor],
    [13], [7.0], [3.2], [4.7], [1.4],
    [14], [6.9], [3.1], [4.9], [1.5],
    [18], [6.8], [2.8], [4.8], [1.4],
    table.cell(colspan: 5)[setosa],
    [71], [5.8], [4.0], [1.2], [0.2],
    [78], [5.7], [4.4], [1.5], [0.4],
    [79], [5.7], [3.8], [1.7], [0.3],
  )]
  , kind: table
  )

]
#block[
#set enum(numbering: "1.", start: 2)
+ `table.width=` allows you to change the width of the table.
]

```r
iris_gt_colored |> 
  tab_options(table.width = px(700))
```

#block[
#figure(
  align(center)[#table(
    columns: 5,
    align: (auto,auto,auto,auto,auto,),
    table.header([], [Sepal.Length], [Sepal.Width], [Petal.Length], [Petal.Width],),
    table.hline(),
    table.cell(colspan: 5)[virginica],
    [1], [7.9], [3.8], [6.4], [2.0],
    [2], [7.7], [3.8], [6.7], [2.2],
    [3], [7.7], [2.6], [6.9], [2.3],
    table.cell(colspan: 5)[versicolor],
    [13], [7.0], [3.2], [4.7], [1.4],
    [14], [6.9], [3.1], [4.9], [1.5],
    [18], [6.8], [2.8], [4.8], [1.4],
    table.cell(colspan: 5)[setosa],
    [71], [5.8], [4.0], [1.2], [0.2],
    [78], [5.7], [4.4], [1.5], [0.4],
    [79], [5.7], [3.8], [1.7], [0.3],
  )]
  , kind: table
  )

]



