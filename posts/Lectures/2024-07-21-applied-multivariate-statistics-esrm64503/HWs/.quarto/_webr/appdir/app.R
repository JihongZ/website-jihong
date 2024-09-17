library(shiny)
library(shinyjs)
library(dplyr)
library(DT)

dat <- readRDS("ESRM64503_Homework_Combined.rds")

# Define UI for application that draws a histogram
ui <- fluidPage(
  # Application title
  titlePanel("Overall Grade"),
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      textInput("name", "Your Full Name", value = "PATRICK MCCLAIN"), # 
      actionButton("confirm", "Confirm", 
                   style="simple", size="sm", color = "warning"),
      conditionalPanel(
        condition = "input.confirm == 1",
        checkboxGroupInput(
          inputId = "columns_selected",
          label = "Information:",
          choices = colnames(dat),
          selected =  colnames(dat)[1:6]
        )
      )
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      DTOutput(outputId = "data1")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  observeEvent(input$confirm, {
    output$data1 <- DT::renderDT({
      dat |> 
        filter(Name == input$name) |> 
        select(input$columns_selected)
    }, escape = FALSE)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
