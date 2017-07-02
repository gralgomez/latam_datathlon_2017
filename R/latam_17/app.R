source("latam17.R")
library(shiny)

COL.m.data <- readShapeSpatial('~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp/COL_adm1.shp')

# Define UI for application that draws a histogram
ui <- fluidPage(
   
   # Application title
   titlePanel("Maternity & Health Quality in Colombia"),
   
   # Sidebar with a slider input for number of bins 
   sidebarLayout(
      sidebarPanel(
         sliderInput("bins",
                     "Number of bins:",
                     min = 1,
                     max = 50,
                     value = 30)
      ),
      
      # Show a plot of the generated distribution
      mainPanel(
        plotOutput("map"))
      )
   )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
  
  output$map <- renderPlot({
    
    percent_map()
  })
    }

# Run the application 
shinyApp(ui = ui, server = server)

