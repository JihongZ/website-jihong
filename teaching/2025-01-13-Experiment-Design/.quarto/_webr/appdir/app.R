library(shiny)
library(DT)

Student_name = c(
  "Ayankoya, Monisola Beauty",
  "Barr, Stephanie Marie",
  "Binhuwaimel, Azizah Abdulrahman A",
  "Bonge, Nicole Grace",
  "Cascante  Vallejo,Diana Carolina",
  "Hughes, Yale",
  "Lan, Xi",
  "Negrete  Becerra,Luis Arturo",
  "Shakeri, Sepideh",
  "West, Abigail Joan"
)
Student_ID = 
c(
  "011021830",
  "002796491",
  "010686196",
  "010734654",
  "010827156",
  "011088780",
  "010848887",
  "010866994",
  "011015879",
  "010953825"
)

# Example data: Student IDs and their corresponding grades
grades_data <- data.frame(
  Student_ID = Student_ID,
  Name = Student_name,
  Bonus = rep("2pts", 10),
  HW1_Grade = rep("10/10", 10),
  Total = rep("12", 10)
)

# Define the UI
ui <- fluidPage(
  titlePanel("Enter Student ID to Check Grade"),
  sidebarLayout(
    sidebarPanel(
      textInput("student_id", "Enter Student ID:", value = ""),
      actionButton("submit", "Submit")
    ),
    mainPanel(
      tableOutput("grade_output"),
      verbatimTextOutput("grade_output_error")
    )
  )
)

# Define server logic
server <- function(input, output) {
  
  observeEvent(input$submit, {
    req(input$student_id)
    
    student_info <- grades_data[grades_data$Student_ID == input$student_id, ]
    # student_info <- grades_data[grades_data$Student_ID == "011021830", ]
    
    if (input$student_id %in% Student_ID) {
      output$grade_output <- renderTable(student_info)
    } else {
      output$grade_output_error <- renderText({
        paste("No grade found for Student ID", input$student_id)
      })
    }
  })
}

# Run the application
shinyApp(ui = ui, server = server)
