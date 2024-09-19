---
title: "2024 Fall Timeline"
author: Jihong Zhang
date: "Sep 18 2024" 
sidebar: false
keep-md: true
execute:
  eval: true
  echo: false
  message: false
  warning: false
  output: true
  include: true
format: 
  html:
    code-fold: false
    grid:
      sidebar-width: 0px
      body-width: 1600px
      margin-width: 0px
---


::: {.cell}

:::



::::::{.cell}

```{.js .cell-code .hidden startFrom="45" source-offset="-0"}
Plot = import("https://cdn.jsdelivr.net/npm/@observablehq/plot/+esm")
import {controlPanel, Ctrls} from "@analyzer2004/control-panel"
tasks = transpose(ojsd)
myColors = [{group: "MS-NNS", color: "gold"},
            {group: "MS-RFS-P", color: "tomato"}];
domainByDate = tasks.sort((a, b) => d3.ascending(a.startDate, b.startDate)).map(d => d.task)
domainByGroup = d3.groups(tasks, d => d.group).sort((a, b) => d3.ascending(a.startDate, b.startDate)).map(d => d[0])
parser = d3.utcParse("%Y-%m-%d")
colorMap = new Map(myColors.map((obj) => [obj.group, obj.color]))
colors = domainByGroup.map(d => colorMap.get(d))
```

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-1-1 nodetype="declaration"}
:::
::::
:::::

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-1-2 nodetype="declaration"}
:::
::::
:::::

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-1-3 nodetype="declaration"}
:::
::::
:::::

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-1-4 nodetype="declaration"}
:::
::::
:::::

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-1-5 nodetype="declaration"}
:::
::::
:::::

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-1-6 nodetype="declaration"}
:::
::::
:::::

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-1-7 nodetype="declaration"}
:::
::::
:::::

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-1-8 nodetype="declaration"}
:::
::::
:::::

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-1-9 nodetype="declaration"}
:::
::::
:::::
::::::






## 2024-2025 Projects List





::: {.cell}
::: {.cell-output-display}

`````{=html}
<table class=" lightable-classic-2" style='font-family: "Arial Narrow", "Source Sans Pro", sans-serif; margin-left: auto; margin-right: auto;'>
 <thead>
  <tr>
   <th style="text-align:left;"> Label </th>
   <th style="text-align:left;"> FullName </th>
   <th style="text-align:left;"> First Author </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> MS-MNA </td>
   <td style="text-align:left;"> Methodological Study of Missingness of Network Analysis </td>
   <td style="text-align:left;"> AQ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ES-MAD </td>
   <td style="text-align:left;"> Empirical Study of Missingness method in Acceralation Data </td>
   <td style="text-align:left;"> AQ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MS-NNS </td>
   <td style="text-align:left;"> Methodological Study of Novel Network Score </td>
   <td style="text-align:left;"> JZ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MS-RFS-P </td>
   <td style="text-align:left;"> Methodological Study of Rating Factor Score (Paper) </td>
   <td style="text-align:left;"> JZ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MS-NAR </td>
   <td style="text-align:left;"> Methodological Study of Network Analysis Reliability (Spencer) </td>
   <td style="text-align:left;"> JZ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> MS-RFS-C </td>
   <td style="text-align:left;"> Methodological Study of Rating Factor Score (Conference) </td>
   <td style="text-align:left;"> LJ </td>
  </tr>
  <tr>
   <td style="text-align:left;"> PD-SGD </td>
   <td style="text-align:left;"> Program Development of ShinyApp of SEM of Gene Data </td>
   <td style="text-align:left;"> ZJ </td>
  </tr>
</tbody>
</table>

`````

:::
:::





## Gantt Plot for Research Plan







::::::{.cell}

```{.js .cell-code .hidden startFrom="68" source-offset="-0"}
Plot.plot({
    marks: [
      Plot.frame({ stroke: settings.panelBorder == "show" ? "#ccc" : null }),
      Plot.barX(tasks, {
        y: "task",
        x1: (d) => parser(d.startDate),
        x2: (d) => parser(d.endDate),
        fill: "group",
        rx: settings.barRoundness,
        insetTop: settings.barHeight,
        insetBottom: settings.barHeight
      }),
      Plot.text(tasks, {
        y: "task",
        x: (d) => parser(d.startDate),
        text: (d) => d.task,
        textAnchor: "start",
        dy: settings.textPosition,
        fontSize: settings.fontSize,
        stroke: "white",
        fill: "dimgray",
        fontWeight: 500
      }),
      Plot.tip(tasks, Plot.pointerY({
        y: "task",
        x1: (d) => parser(d.startDate),
        x2: (d) => parser(d.endDate),
        title: (d) =>
          `FullName: ${d.FullName}\nStart: ${d.startDate}\nEnd: ${d.endDate}`
      }))
    ],
    height: settings.plotHeight,
    width: settings.plotWidth,
    x: { 
      grid: (settings.gridlines == "x") | (settings.gridlines == "both") ? true : null 
    },
    y: {
      domain: domainByDate,
      label: null,
      tickFormat: null,
      tickSize: null,
      grid: (settings.gridlines == "y") | (settings.gridlines == "both") ? true : null
    },
    color: { domain: domainByGroup, range: colors, legend: true }
})
```

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-2-1 nodetype="expression"}
:::
::::
:::::

```{.js .cell-code .hidden startFrom="114" source-offset="-1355"}
viewof settings = controlPanel([
  [
    Ctrls.slider("plotHeight", {label: "Plot height: ", min:500, max:1000, value:600}),
    Ctrls.slider("plotWidth", {label: "Plot width: ", min:900, max:1600, value:1365})
  ],
  [
    Ctrls.slider("barHeight", {label: "Adjusted bar height: ", min:0, max:20, value:10}),
    Ctrls.slider("textPosition", {label: "Label dodge: ", min:-50, max:50, value:0}),
    Ctrls.slider("fontSize", {label: "Font size: ", min:8, max:24, value:17})
  ],
  [    
    Ctrls.radioGroup("panelBorder", ["show", "hide"], {label: "Panel border:", value: "show"}),    
    Ctrls.radioGroup("gridlines", ["x", "y", "both", "none"], {label: "Gridlines:", value: "x"})
  ],
  [Ctrls.rule()]
], {style: "font-family:sans-serif;font-size:10pt;pointer:default"});
```

:::::{.cell-output .cell-output-display}

::::{}

:::{#ojs-cell-2-2 nodetype="declaration"}
:::
::::
:::::
::::::
