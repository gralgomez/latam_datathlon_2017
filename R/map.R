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
                 ind.var1, 
                 by = 'id')
# // DEPARTMENTS Map
COL.d.data <- readShapeSpatial('~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp/COL_adm1.shp')
COL.d.coord <- fortify(COL.d.data)
COL.map.d <- merge(COL.d.coord, 
                   pop, 
                   by = 'id')

#// Visualize
mapColDep <- ggplot() +
  geom_polygon(data = COL.map.d,
               inherit.aes = TRUE,
               aes(x = long, y = lat, 
                   group = group, 
                   fill = pop, #pop/max(pop)
                   color = color),
                #lwd=0,
               colour ='grey24',
               alpha = 0.95,
               size = 0.1,
               na.rm = TRUE)+
  labs(title = 'Colombia', fill = '') +
  labs(x='',y='',title='Colombia - Poblacion 2010') +
  scale_x_continuous(limits=c(-80,-65))+
  scale_y_continuous(limits=c(-5,13)
  )
dev.off(); 
mapColDep + scale_fill_gradient(low='#e7e1ef', high='#dd1c77')

#"#00c5c7", "#ff6263"/#ff6263
#low='cyan4', high='indianred4'
#low='#00f2de', high='#ff6263')
#(low='#e7e1ef', high='#dd1c77')
#(low='#fee8c8', high='#e34a33')
