library(shiny)
library(shinydashboard)
library(shinyjs)
library(readxl)
library(dplyr)
library(DT)

# Publish to https://jihongz.shinyapps.io/ESRM64503-Grading/ 
# hw_root_path <- "posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/" 
dat <- readRDS("ESRM64503_Homework_Combined.rds")
dat$Name[3]
# Define UI for application that draws a histogram
ui <-  dashboardPage(
  dashboardHeader(title = "ESRM 64503"), # Application title
  dashboardSidebar(
      column(12, 
        selectInput("name", "Your Full Name", choices = unique(dat$Name), selected = unique(dat$Name)[2]), 
        textInput(inputId = "code", label = "Your Unique Code"), 
        actionButton(inputId = "confirm", label = "Confirm"),
        selectInput("hw_index", "Which Homework", choices = c("All", "Homework0", "Homework1")), 
        conditionalPanel( # information box
          condition = "!!input.name",
          checkboxGroupInput(
            inputId = "columns_selected",
            label = "Extra Information:",
            choices = setdiff(colnames(dat), c("Name", "HW", "Starting_Time", "Code")),
            selected =  setdiff(colnames(dat), c("Name", "HW", "Starting_Time", "Code"))[1:3]
          )
        )
      )
  ),
  dashboardBody(
    # Show a plot of the generated distribution
    box(
      width = 12,
      DTOutput(outputId = "data1")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  event_trigger <- reactive({ # observe any change
    list(input$hw_index, input$columns_selected, input$confirm)
  })
  dat_cleaned <- NULL
  
  observeEvent(input$name,{
    updateTextInput(inputId = "code", value = "")
    output$data1 <- DT::renderDT({
      NULL
    })
  })
  
  observeEvent(input$confirm, {
    stored_code <- unique(unlist(dat[dat$Name == input$name, "Code"]))
    if (stored_code != input$code) {
      print("You code is incorrect!")
    }else{
      dat_cleaned <<- dat |> 
        ungroup() |> 
        filter(Name == input$name) 
      
      observeEvent(event_trigger(), {
        if (input$hw_index == "All") {
          dat_final <- dat_cleaned |> 
            select(c("Name", "HW", "Starting_Time"), input$columns_selected, -Name) 
        }else if(input$hw_index == "Homework0"){
          dat_final <- dat_cleaned |> 
            select(c("Name", "HW", "Starting_Time"), input$columns_selected, -Name) |> 
            filter(HW == 0) |> 
            t()
        }else if(input$hw_index == "Homework1"){
          dat_final <- dat_cleaned |> 
            select(c("Name", "HW", "Starting_Time"), input$columns_selected, -Name) |> 
            filter(HW == 1) |> 
            t()
        }else{
          dat_final <- dat_cleaned
        }
        output$data1 <- DT::renderDT({
          dat_final
        }, escape = FALSE)
      })
    }
  })
    
  
}

# Run the application 
shinyApp(ui = ui, server = server)
