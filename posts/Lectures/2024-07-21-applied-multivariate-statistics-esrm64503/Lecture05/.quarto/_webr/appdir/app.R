library(shiny)
dat$IQ
ui <- fluidPage(
  slider
)

server <- function(input, output, session) {
  
}

shinyApp(ui, server)
