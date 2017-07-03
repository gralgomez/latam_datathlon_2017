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
# // MUNICIPALITIES Map
COL.m.data <- readShapeSpatial('~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp/COL_adm2.shp')
COL.m.coord <- fortify(COL.m.data)
COL.map <- merge(COL.m.coord, 
                 ind.var4, 
                 by = 'id')
# // DEPARTMENTS Map
COL.d.data <- readShapeSpatial('~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp/COL_adm1.shp')
COL.d.coord <- fortify(COL.d.data)
COL.map.d <- merge(COL.d.coord, 
                   ind.var9.dep, 
                   by = 'id')

#// Visualize
mapColDep <- ggplot() +
  geom_polygon(data = COL.map,
               inherit.aes = TRUE,
               aes(x = long, y = lat, 
                   group = group, 
                   fill = value, #value/max(value)
                   color = color),
               lwd=0,
               colour ='grey27',
               alpha = 0.95,
               size = 0.1,
               na.rm = TRUE)+
  labs(title = 'Colombia', fill = '') +
  labs(x='',y='',title='') +
  scale_x_continuous(limits=c(-80,-65))+
  scale_y_continuous(limits=c(-5,13)
  )
dev.off(); 
mapColDep + scale_fill_gradient(low='#edfffa', high='#008e8b')

#----------------------
# (low='#e7e1ef', high='#dd1c77') - neutral
# (low='#ffedf2', high='#ec013c') -bad
# (low='#edfffa', high='#00da9e') -good