library(shiny)
library(bslib)
library(ggplot2)
library(dplyr)
library(tidyr)
set.seed(1234)
# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Chi-square distribution"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("Df",
                        "Degree of freedom:",
                        min = 1,
                        max = 20,
                        value = 1,
                        animate = animationOptions(interval = 5000, loop = TRUE)),
           verbatimTextOutput(outputId = "Df_display")
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    x <- seq(0.01, 15, .01)
    df <- reactive({input$Df}) 
    
    output$Df_display <- renderText({
        paste0("DF = ", df())
    })
    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        
        
        dt2 <- as.data.frame(sapply(df(), \(df) dchisq(x, df = df)))
        dt2_with_x <- cbind(x = x, dt2)
        dt2_with_x |> 
            pivot_longer(starts_with("V")) |> 
            ggplot() +
            geom_path(aes(x = x, y = value), linewidth = 1.2) +
            scale_y_continuous(limits = c(0, 1)) +
            labs(y = "f(x)") +
            theme_bw() +
            theme(legend.position = "top", text = element_text(size = 13))
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
