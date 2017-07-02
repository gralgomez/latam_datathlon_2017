setwd("/Users/laurita/Documents/GitHub/latam_datathlon_2017/R")

#Set up map
library(sp)
library(RColorBrewer)
library(ggplot2)
library(maptools)
library(scales)

source('latam17.R')

#states and COL_Admin2 municipalities
# //source: http://www.gadm.org/country //
COL.m.data <- readShapeSpatial('~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp/COL_adm2.shp')
COL.m.coord <- fortify(COL.m.data)
COL.map <- merge(COL.m.coord, 
                 ind.var13, 
                 by = 'id')

COL.d.data <- readShapeSpatial('~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp/COL_adm1.shp')
COL.d.coord <- fortify(COL.d.data)
COL.map.d <- merge(COL.d.coord, 
                   ind.var5.dep, 
                   by = 'id')

#// Visualize
mapColDep <- ggplot() +
  geom_polygon(data = COL.map.d,
               inherit.aes = TRUE,
               aes(x = long, y = lat, group = group, fill = value),
               colour ='white',
               size = 0.1,
               na.rm = TRUE)+
  labs(title = 'Colombia', fill = '') +
  labs(x='',y='',title='Colombia') +
  scale_x_continuous(limits=c(-80,-65))+
  scale_y_continuous(limits=c(-5,13)
  )

dev.off(); mapColDep