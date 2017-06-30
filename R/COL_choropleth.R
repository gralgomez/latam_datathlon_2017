#// Source: http://hagutierrezro.blogspot.com/2015/04/making-maps-in-r-with-ggplot.html

rm(list = ls(all = TRUE))
options(encoding = "UTF-8")

library(sp)
library(RColorBrewer)
library(ggplot2)
library(maptools)
library(scales)

setwd('~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp')
#// Read map
ohsCol2 <- readShapeSpatial("COL_adm2.shp")
ohsColI2 <- fortify(ohsCol2)
#//Create variable
grupo2 <- data.frame(id = unique(ohsColI2[ , c("id")]))
grupo2[ , "Porcentaje"] <- runif(nrow(grupo2), 0, 1)
#// Merge both
ohsColI2 <- merge(ohsColI2, grupo2, by = "id")
#// Use ggplot2 to visualize the map
mapColDep <- ggplot() +
  geom_polygon(data= ohsColI2, aes(x=long, y=lat, group = group,
                                  fill = Porcentaje), colour ="black", size = 0.1) +
  labs(title = "Colombia", fill = "") +
  labs(x="",y="",title="Colombia") +
  scale_x_continuous(limits=c(-80,-65))+
  scale_y_continuous(limits=c(-5,13))

dev.off(); mapColDep