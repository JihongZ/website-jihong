library(shiny)
library(shinydashboard)
library(stringr)
library(shinyjs)
library(readxl)
library(dplyr)
library(ggplot2)
library(DT)

# Publish to https://jihongz.shinyapps.io/ESRM64503-Grading/ 
# https://jihongzhang.org/posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/Grading_ShinyApp.html
# hw_root_path <- "posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/" 
dat <- readRDS("ESRM64503_Homework_Combined.rds")

## Alphabatical order
dat <- dat |> 
  arrange(Name)

score_summary <- dat |> 
  group_by(Name, HW) |> 
  summarise(
    total_score = unique(TotalScore)
  ) |> 
  group_by(Name) |> 
  summarise(total_total_score = sum(total_score))

# Define UI for application that draws a histogram
ui <-  dashboardPage(
  skin = "purple",
  dashboardHeader(title = "ESRM 64503 v0.1", titleWidth = "18%"), # Application title
  dashboardSidebar(
      width = "18%",
      column(12, 
        selectInput("name", label = list(icon("file-signature"), "Select the name"), choices = unique(dat$Name)), 
        textInput(inputId = "code", label = list(icon("key"), "Enter a unique code"), value = "", placeholder = "4-digit code"), # 4-digit code
        conditionalPanel(
          condition = "input.confirm >= 1",
          verbatimTextOutput(outputId = "code_check_msg")
        ),
        actionButton(inputId = "confirm", label = "Confirm", 
                     icon = icon("circle-check", class="fa-solid fa-circle-check", 
                                 style="color: #FFD43B;")),
        selectInput("hw_index", list(icon("scroll"), "Choose the homework"), 
                    choices = paste0("Homework ", unique(dat$HW)))
        )
  ),
  dashboardBody(
    width = "82%",
    fluidRow(
      column(
        width = 6, 
        valueBox(
          subtitle = "Average Score",
          width = 12,
          value = round(mean(score_summary$total_total_score), 2),
          color = "yellow",
          icon = icon("face-smile-wink", class="fa-solid fa-face-smile-wink")
        ),
        valueBox(
          subtitle = "Standard Deviation", 
          width = 12,
          value = round(sd(score_summary$total_total_score), 2),
          color = "fuchsia",
          icon = icon("face-grin-tears", class="fa-solid fa-face-grin-tears")
        ),
        valueBoxOutput(width = 12, outputId = "personal_total_score")
      )
    ),
    fluidRow(
      # Show the table
      box(
        title = "Detailed information",
        width = 12,
        DTOutput(outputId = "data1"),
        downloadButton("downloadData", "Download"), # Download Button
        collapsible = TRUE, collapsed = FALSE
      )
    )
  ),
  tags$head(
    # Note the wrapping of the string in HTML()
    tags$style(HTML("
      @import url('https://fonts.googleapis.com/css2?family=Titillium+Web:ital,wght@0,200;0,300;0,400;0,600;0,700;0,900;1,200;1,300;1,400;1,600;1,700&display=swap');
      * {
        font-family: 'Titillium Web', sans-serif;
      }"))
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  event_trigger <- reactive({ # observe any change
    list(input$hw_index, input$columns_selected, input$confirm)
  })
  dat_cleaned <- NULL
  
  observeEvent(input$name,{
    # updateTextInput(inputId = "code", value = "")
    output$data1 <- DT::renderDT({
      NULL
    })
    output$personal_total_score <- renderValueBox({
      valueBox(
        subtitle = "Your current total score",
        value = NULL,
        color = "teal"
      )
    })
  })
  
  observeEvent(input$confirm, {
    stored_code <- unique(unlist(dat[dat$Name == input$name, "Code"])) 
    
    ## Check whether user input code match stored code
    if (stored_code != input$code) { # if not match
      updateActionButton(inputId = "confirm", icon = icon("circle-check", class="fa-solid fa-circle-check", style="color: #f82a22;"))
      output$code_check_msg <- renderText({
        "Your code is incorrect!"
      })
    }else{ # if match
      updateActionButton(inputId = "confirm", icon = icon("circle-check", class="fa-solid fa-circle-check", style="color: #63E6BE;"))
      output$code_check_msg <- renderText({""})
      
      ## filter the personal total score
      
      dat_cleaned <- dat |> 
        ungroup() |> 
        filter(Name == input$name) 
      
      output$personal_total_score <- renderValueBox({
        valueBox(
          subtitle = "Your current total score",
          value = score_summary |> filter(Name == input$name) |> pull(total_total_score),
          color = "teal"
        )
      })
      
      observeEvent(event_trigger(), {
        dat_final <- dat_cleaned |> 
          relocate(HW) |> 
          filter(HW == stringr::str_replace(input$hw_index, "Homework ", "")) |> 
          as.data.frame()
          
        output$data1 <- DT::renderDT({
          dat_final
        }, escape = FALSE)
        
        # Downloadable csv of selected dataset ----
        output$downloadData <- downloadHandler(
          filename = function() {
            paste(input$name, "_report.csv", sep = "")
          },
          content = function(file) {
            write.csv(dat_final, file, row.names = FALSE)
          }
        )
        
      })
    }
  })
    
  
}

# Run the application 
shinyApp(ui = ui, server = server)
