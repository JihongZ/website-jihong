library(shiny)
library(shinydashboard)
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
        actionButton(inputId = "confirm", label = "Confirm", icon = icon("circle-check", class="fa-solid fa-circle-check", style="color: #FFD43B;")),
        selectInput("hw_index", list(icon("scroll"), "Choose the homework"), choices = c("All", "Homework0", "Homework1")), 
        conditionalPanel( # information box
          condition = "!!input.name",
          checkboxGroupInput(
            inputId = "columns_selected",
            label = "Extra Information:",
            choiceNames = c("Question 1 - Reponse",
                            "Question 2 - Reponse",
                            "Homework's Score",
                            "Question 1 - Answer",
                            "Question 2 - Answer",
                            "Comment/Feedback",
                            "Your test times"),
            choiceValues = setdiff(colnames(dat), c("Name", "HW", "Starting_Time", "Code")),
            selected =  setdiff(colnames(dat), c("Name", "HW", "Starting_Time", "Code"))[1:3]
          )
        )
      )
  ),
  dashboardBody(
    width = "82%",
    # Show a pieplot
    box(
      title = "Summary",
      width = 12,
      plotOutput(outputId = "score_pie"), # Output piechart of score proportion for each person
      collapsible = TRUE, collapsed = FALSE
    ),
    # Show a plot of the generated distribution
    box(
      title = "Detailed information",
      width = 12,
      DTOutput(outputId = "data1"),
      collapsible = TRUE, collapsed = FALSE
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
    # updateTextInput(inputId = "code", value = "")
    output$data1 <- DT::renderDT({
      NULL
    })
  })
  
  observeEvent(input$confirm, {
    stored_code <- unique(unlist(dat[dat$Name == input$name, "Code"])) 
    
    ## Check wether user input code match stored code
    if (stored_code != input$code) {
      updateActionButton(inputId = "confirm", icon = icon("circle-check", class="fa-solid fa-circle-check", style="color: #f82a22;"))
      output$code_check_msg <- renderText({
        "Your code is incorrect!"
      })
    }else{
      updateActionButton(inputId = "confirm", icon = icon("circle-check", class="fa-solid fa-circle-check", style="color: #63E6BE;"))
      output$code_check_msg <- renderText({""})
      
      dat_cleaned <- dat |> 
        ungroup() |> 
        filter(Name == input$name) 
      
      observeEvent(event_trigger(), {
        if (input$hw_index == "All") {
          ## Display Summary UI
          # Create Score Data
          Score_task <- as.numeric(dat_cleaned$Score_PerHW)
          Total_Score = 41
          Score_person <- data.frame(
            assignment= c("Deducted", "Homework 0", "Homework 1"),
            score= c(Total_Score - sum(Score_task), Score_task)
          ) 
          # Compute the position of labels
          
          Score_person_withpos <- Score_person |> 
            mutate(assignment = factor(assignment, levels = Score_person$assignment)) |> 
            arrange(desc(assignment)) |> 
            mutate(ypos = cumsum(score) - 0.5*score)
          
          # Basic piechart
          output$score_pie <- renderPlot({
            ggplot(Score_person_withpos, aes(x="", y=score, fill=assignment)) +
              geom_bar(stat="identity", width=1) +
              geom_text(aes(y = ypos, label = score), color = "white", size=6) +
              coord_polar("y", start=0)  +
              theme_void()  # remove background, grid, numeric labels
          })
          
          ## remove name to save room
          dat_final <- dat_cleaned |> 
            select(c("Name", "HW", "Starting_Time"), input$columns_selected, -Name) 
        }else if(input$hw_index == "Homework0"){
          dat_final <- dat_cleaned |> 
            select(c("Name", "HW", "Starting_Time"), input$columns_selected, -Name) |> 
            filter(HW == 0) |> 
            t() |> 
            as.data.frame()
          colnames(dat_final) <- "Report"  
        }else if(input$hw_index == "Homework1"){
          dat_final <- dat_cleaned |> 
            select(c("Name", "HW", "Starting_Time"), input$columns_selected, -Name) |> 
            filter(HW == 1) |> 
            t() |> 
            as.data.frame()
          colnames(dat_final) <- "Report"  
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
