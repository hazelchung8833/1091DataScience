library(ggvis)
library(shiny)
shinyUI(pageWithSidebar(
  div(),
  sidebarPanel(
    numericInput(
    'vert',
    'Vertical:',
    1,
    min = 1,
    max = 341,
    step = 1,
    width = NULL
    ),
    numericInput(
    'horz',
    'Horizonal:',
    2,
    min = 1,
    max = 341,
    step = 1,
    width = NULL
    ),
  ),
  mainPanel(
    plotOutput("plot_ui"),
    titlePanel('PCA.rotation'),
    tableOutput("table2"),
    titlePanel('Summary'),
    tableOutput('table3'),
    titlePanel('Data'),
    dataTableOutput("table1"),

    )
))