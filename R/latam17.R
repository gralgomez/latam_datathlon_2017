#// Project - Visualizing HealthQuality in Colombia
#%>% Setup
rm(list=ls(all=TRUE))
options(encoding = "UTF-8")
library(sp) #// spatial data
library(RColorBrewer)
library(ggplot2)
library(maptools)
library(scales)
library(readr)
library(data.table)

# read the shapes of your map
setwd('~/Documents/Work/Data Science/Datathlon/')
#Set up map
#COL_admin1 -> states and COL_Admin2 municipalities
# //source: http://www.gadm.org/country //
COL.m.data <- readShapeSpatial('~/Documents/Work/Data Science/Datathlon/COL_adm/COL_adm2.shp')
COL.m.coord <- fortify(COL.m.data)

ind.salud <- read_csv("~/Documents/Work/Data Science/Datathlon/Indicadores_de_Salud.csv")
#// View(unique(ind.salud[,'nomindicador'])) - 19 indicators 

#// ind: 
ind <- data.frame(ind.salud[,(2:7)]); ind$nomindicador <- NULL; ind$nomunidad <- NULL;
years <- subset(ind.salud, select = grep("yea+", names(ind.salud))); 
names(years) = sub("yea","",names(years)); years.rel <- years[16:21]
ind <- cbind(ind,years.rel)

#// Check out the state names
library(stringr)
library(stringi)
ind$nomdepto <- tolower(ind$nomdepto); 
ind$nomdepto <- stringi::stri_trans_general(ind$nomdepto, "Latin-ASCII") #// check stri_trans_list()


ind$nomdepto <- gsub("sin informacion", NA, ind$nomdepto)
ind$nomdepto <- gsub("no definido", NA, ind$nomdepto)
ind$nomdepto[ind$iddepto == '88'] <- "san andres"
ind$nomdepto[ind$iddepto == '11'] <- "bogota"
ind$nomdepto[ind$iddepto == '170'] <- "colombia"
ind$nomdepto[ind$iddepto == '54'] <- "n.santander"

#// Looking up the ind
View(unique(ind$idindicador));

caelacex <- subset(ind, ind$idindicador == 'caelacex')








id <- data.frame(id = unique(COL.m.coord[ , c("id")]))
id[ , "Porcentaje"] <- runif(nrow(id), 0, 1)


COL.m.coord <- merge(COL.m.coord, id, by = "id")


mapColDep <- ggplot() +
  geom_polygon(data=ohsColI2, 
               aes(x=long, y=lat,group = group, fill = Porcentaje), 
               colour ="black", size = 0.1) +
  labs(title = "Colombia", fill = "") +
  labs(x="",y="",title="Colombia") +
  scale_x_continuous(limits=c(-80,-65))+
  scale_y_continuous(limits=c(-5,13) )

mapColDep

#ggsave(mapColDep, file = "mapColDep.png",width = 5, height = 4.5, type = "cairo-png")
