install.packages("rgdal")
library(rgdal)

dortmund <- readOGR("Statistische Bezirke.kml", #name of file
                    #if your browser adds a .txt after downloading the file
                    #you can add it here, too!
                    "Statistische_Bezirke",     #name of layer
                    encoding="utf-8"           #if our data contains german Umlauts like ä, ö and ü
)

plot(dortmund)
# Data
student1 <- read.csv("student1.csv", encoding="latin1", sep=",", dec=".")
student2 <- read.csv("student2.csv", encoding="latin1", sep=",", dec=".")

#Interactive
install.packages("leaflet")
library(leaflet)

palette <- colorBin(c('#fee0d2',  #an example color scheme. you can substitute your own colors
                      '#fcbba1',
                      '#fc9272',
                      '#fb6a4a',
                      '#ef3b2c',
                      '#cb181d',
                      '#a50f15',
                      '#67000d'), 
                    bins = c(0, 5, 8, 10, 12, 14, 18, 24, 26))

popup1 <- paste0("<span style='color: #7f0000'><strong>18-25 year olds 2000</strong></span>",
                 "<br><span style='color: salmon;'><strong>District: </strong></span>", 
                 student1$Bezirk, 
                 "<br><span style='color: salmon;'><strong>relative amount: </strong></span>", 
                 student1$Anteil
                 ,"<br><span style='color: salmon;'><strong>absolute amount: </strong></span>", 
                 student1$X2000   
)

popup2 <- paste0("18-25 year olds 2014",
                 "<br>District: ",             
                 student2$Bezirk,         #column containing the district names
                 "<br>relative amount: ", 
                 student2$Anteil          #column that contains the relative amount data
                 ,"<br>absolute amount: ", 
                 student2$X2014           #column that contains the absolute amount data
)

#Map

mymap <- leaflet() %>% 
  addProviderTiles("Esri.WorldGrayCanvas",
                   options = tileOptions(minZoom=10, maxZoom=16)) %>% 

addPolygons(data = dortmund, 
            fillColor = ~palette(student1$Anteil),  ## we want the polygon filled with 
            ## one of the palette-colors
            ## according to the value in student1$Anteil
            fillOpacity = 0.6,         ## how transparent do you want the polygon to be?
            color = "darkgrey",       ## color of borders between districts
            weight = 1.5,            ## width of borders
            popup = popup1,         ## which popup?
            group="<span style='color: #7f0000; font-size: 11pt'><strong>2000</strong></span>")%>%  

  ## for the second layer we mix things up a little bit, so you'll see the difference in the map!
  addPolygons(data = dortmund, 
              fillColor = ~palette(student2$Anteil), 
              fillOpacity = 0.2, 
              color = "white", 
              weight = 2.0, 
              popup = popup2, 
              group="2014")%>%

addLayersControl(
  baseGroups = c("<span style='color: #7f0000; font-size: 11pt'><strong>2000</strong></span>", ## group 1
                 "2014" ## group 2),
  options = layersControlOptions(collapsed = FALSE))%>% ## we want our control to be seen right away

addLayersControl(
  baseGroups = c("<span style='color: #7f0000; font-size: 11pt'><strong>2000</strong></span>", ## group 1
                 "2014" ## group 2),
  options = layersControlOptions(collapsed = FALSE))%>% ## we want our control to be seen right away

addLegend(position = 'topleft',    
    colors = c('#fee0d2',
               '#fcbba1',
               '#fc9272',
               '#fb6a4a',
               '#ef3b2c',
               '#cb181d',
               '#a50f15',
               '#67000d'), 
  labels = c('0%',"","","","","","",'26%'),  ## legend labels (only min and max)
  opacity = 0.6,      ##transparency again
  title = "relative<br>amount") 

print(mymap)

library(htmlwidgets)
saveWidget(mymap, file = "mymap.html", selfcontained = F)