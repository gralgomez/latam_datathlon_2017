shinyUI(fluidPage(
  titlePanel("censusVis"),
  
  sidebarLayout(
    sidebarPanel(
      helpText("Create demographic maps with 
               information from the 2010 US Census."),
      
      selectInput("ind.var1", 
                  label = "VAR1",
                  choices = c("pcrparin","ttdnesti"
                              'cgrnacim',
                              'ctrmormt',
                              'pcrperca',
                              'pcrrncpn',
                              'rtrmorpu',
                              'ttdiesti'),
      
      sliderInput("range", 
                  label = "Range of interest:",
                  min = 0, max = 100, value = c(0, 100))
      ),
    
    mainPanel(plotOutput("map"))
  )
))