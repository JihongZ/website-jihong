library(shiny)
library(shinydashboard)
library(shinyjs)
library(readxl)
library(dplyr)
library(ggplot2)
library(DT)

# Publish to https://jihongz.shinyapps.io/ESRM64503-Grading/ 
# hw_root_path <- "posts/Lectures/2024-07-21-applied-multivariate-statistics-esrm64503/HWs/" 
dat <- readRDS("ESRM64503_Homework_Combined.rds")

## Alphabatical order
dat <- dat |> 
  arrange(Name)
  
# Define UI for application that draws a histogram
ui <-  dashboardPage(
  dashboardHeader(title = "ESRM 64503"), # Application title
  dashboardSidebar(
      column(12, 
        selectInput("name", "Your Full Name", choices = unique(dat$Name)), 
        textInput(inputId = "code", label = "Your Unique Code", value = ""), 
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
    # Show a pieplot
    box(
      width = 12,
      plotOutput(outputId = "score_pie")
    ),
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
    # updateTextInput(inputId = "code", value = "")
    output$data1 <- DT::renderDT({
      NULL
    })
  })
  
  observeEvent(input$confirm, {
    stored_code <- unique(unlist(dat[dat$Name == input$name, "Code"])) 
    
    ## Check wether user input code match stored code
    if (stored_code != input$code) {
      print("You code is incorrect!")
    }else{
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
            arrange(assignment) |> 
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
