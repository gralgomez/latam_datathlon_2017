source("latam17.R")
library(shiny)

COL.m.data <- readShapeSpatial('~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp/COL_adm1.shp')

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  sidebarLayout(
    
    sidebarPanel(      
      selectInput("id", "Country:",
                  list("Burkina Faso"="BFA","Ethiopia"="ETH","Ghana"="GHA",
                       "Kenya"="KEN","Malawi"="MWI","Mali"="MLI"), selected="ETH"), 
      uiOutput("sliders")
      
    ),   
    mainPanel(
      plotOutput('map', width = "100%")
    )
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

