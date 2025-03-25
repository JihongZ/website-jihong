---
title: "DiagrammeR package"
author: Jihong Zhang
date: "2025-03-24"
fig-cap-location: top  
execute: 
  eval: true
format: html
keep-md: true
---





::: objectives
## Overview {.unnumbered}

- This section is based on the official [documentation](https://rich-iannone.github.io/DiagrammeR/) of `DiagrammeR`.
- This html widget is developed by Richard Iannone. 
- The DiagrammeR package allows create, modify, analyze, and visualize **network graph** diagrams
:::

## Installation




::: {.cell}

```{.r .cell-code}
devtools::install_github("rich-iannone/DiagrammeR")
```
:::




or 




::: {.cell}

```{.r .cell-code}
install.packages("DiagrammeR")
```
:::




## Start from scratch

Use `create_graph` to start with a empty graph object and use `add_node()` and `add_edge` functions to add nodes and edges, respectively.




::: {.cell}

```{.r .cell-code}
library(DiagrammeR)

create_graph() |> 
  add_node() |> 
  add_node() |> 
  add_edge(from = 1, to = 2) |> 
  render_graph(layout = "nicely")
```

::: {.cell-output-display}


```{=html}
<div class="grViz html-widget html-fill-item" id="htmlwidget-5d9bb2ea43e515392e32" style="width:100%;height:464px;"></div>
<script type="application/json" data-for="htmlwidget-5d9bb2ea43e515392e32">{"x":{"diagram":"digraph {\n\ngraph [layout = \"neato\",\n       outputorder = \"edgesfirst\",\n       bgcolor = \"white\"]\n\nnode [fontname = \"Helvetica\",\n      fontsize = \"10\",\n      shape = \"circle\",\n      fixedsize = \"true\",\n      width = \"0.5\",\n      style = \"filled\",\n      fillcolor = \"aliceblue\",\n      color = \"gray70\",\n      fontcolor = \"gray50\"]\n\nedge [fontname = \"Helvetica\",\n     fontsize = \"8\",\n     len = \"1.5\",\n     color = \"gray80\",\n     arrowsize = \"0.5\"]\n\n  \"1\" [fillcolor = \"#F0F8FF\", fontcolor = \"#000000\", pos = \"-0.658871714452341,0.380468358446846!\"] \n  \"2\" [fillcolor = \"#F0F8FF\", fontcolor = \"#000000\", pos = \"0.190718754261513,-0.147451195705517!\"] \n  \"1\"->\"2\" \n}","config":{"engine":"dot","options":null}},"evals":[],"jsHooks":[]}</script>
```


:::
:::




## aesthetic for node and edge

Use `node_aes()` inside `add_node` and `edge_aes()` inside `add_edge` to specify aesthetic attributes.




::: {.cell}
::: {.cell-output-display}


|Aesthetic |Attributes |
|:---------|:----------|
|Node      |color      |
|          |fillcolor  |
|          |fontcolor  |
|Edge      |color      |
|          |arrowhead  |
|          |tooltip    |


:::
:::
