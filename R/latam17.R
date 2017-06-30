#// Project - Visualizing HealthQuality in Colombia //
#@author: Laura Gabrysiak
# -- 'utf-8' --
#%>% Setup
rm(list = ls(all.names = TRUE))
options(encoding = 'UTF-8')
#// Load libraries
library(sp) #// spatial data
library(RColorBrewer)
library(ggplot2)
library(maptools)
library(scales)
library(readr)
library(data.table)

setwd('~/Documents/GitHub/latam_datathlon_2017/R/')

#// Load the data
ind.salud <- read_csv('~/Documents/GitHub/latam_datathlon_2017/data/Indicadores_de_Salud.csv')
#// View(unique(ind.salud[,'nomindicador'])) - 19 indicators 
str(ind.salud)
#View(unique(ind.salud[,c('idindicador','nomindicador')]))

#// Measure NA ratio
nacount <- sort(unlist(lapply(ind.salud, function(x) sum(is.na(x))/nrow(ind.salud))))
barplot(sort(nacount), ylab = 'Number of NAs')

#// ind: 
ind <- data.frame(ind.salud[,(2:9)])
ind$nomindicador <- NULL; ind$nomunidad <- NULL; ind$idunidad <- NULL
#// Years - cleaning
years <- subset(ind.salud, select = grep('yea+', names(ind.salud))); 
names(years) = sub('yea','',names(years)); years.rel <- years[16:21]
ind <- cbind(ind,years.rel)

#// Check out the state/municipalities names
library(stringr)
library(stringi)

#//state // decide is numeric or factor
ind$iddepto <- as.numeric(ind$iddepto)
ind$idmpio <- as.numeric(ind$idmpio)

ind$nomdepto <- tolower(ind$nomdepto); 
ind$nomdepto <- stringi::stri_trans_general(ind$nomdepto, 'Latin-ASCII') 
ind$nomdepto <- gsub('sin informacion', NA, ind$nomdepto)
ind$nomdepto <- gsub('no definido', NA, ind$nomdepto)
ind$nomdepto[ind$iddepto == 88] <- 'san andres y providencia'
ind$nomdepto[ind$iddepto == 11] <- 'bogota'
ind$nomdepto[ind$iddepto == 170] <- 'colombia'
ind$nomdepto[ind$iddepto == 54] <- 'norte de santander'
#out <- subset(ind, ind$iddepto == 75)
ind <- ind[!ind$iddepto == 75,]

ind$nommpio <- tolower(ind$nommpio); 
ind$nommpio <- stringi::stri_trans_general(ind$nommpio, 'Latin-ASCII')
ind$nommpio <- gsub("[  ]", ' ', ind$nommpio)
ind$nommpio <- gsub("miriti - parana", 'miriti-parana', ind$nommpio)
ind$nommpio <- gsub("[*]", '', ind$nommpio)
head(ind)
nacount.2 <- sort(unlist(lapply(ind, function(x) sum(is.na(x))/nrow(ind)))); barplot(nacount.2)

#// setting up levels
# Level 0 ///////
COL.ind <- subset(ind, ind$iddepto == 170); COL.ind$idmpio <- NULL; COL.ind$nommpio <- NULL; 
ind <- subset(ind, ind$iddepto < 170)

unique(COL.ind$idindicador) #// all indicators are given
# // Several instances of the same var and year thus a merge is requiered
# COL.ind.all <- as.data.frame(aggregate(COL.ind[4:9], by=list(COL.ind$idindicador),
#                      FUN = mean, 
#                      na.rm=TRUE)) 
# COL.ind.all[is.nan(COL.ind.all)] <- NA
# for (i in 1:nrow(COL.ind.all)){
#   COL.ind.all$mean[i] <- mean(COL.ind.all[2:7, i], 
#                              na.rm = TRUE)  
# }

#// Level 1 + 2 // get rid of all national data
library(tidyr)
#// Reshape data to 
ind.rshp <- gather(ind, year, value, '2005', '2006', 
                   '2007', '2008', '2009', '2010')
ind.rshp <- spread(ind.rshp,idindicador,value)
ind.rshp <- as.data.table(ind.rshp)

#write.csv2(ind.reshape, 'ind_transformed.csv')

# // Level 1 - States:
#  switch the id to standardize it to gadm
#Refreence Table
COL.gadm <- read_csv("~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp/COL_adm2.csv")
id.gadm <- COL.gadm[5:8]
id.gadm$NAME_1 <- tolower(id.gadm$NAME_1); 
id.gadm$NAME_1 <- stringi::stri_trans_general(id.gadm$NAME_1, 'Latin-ASCII')
ind.rshp$iddepto <- id.gadm$ID_1[match(ind.rshp$nomdepto, id.gadm$NAME_1)]

# // Level 2 - Municipalities:
#  switch the id to standardize it to gadm
id.gadm$NAME_2 <- tolower(id.gadm$NAME_2); 
id.gadm$NAME_2 <- stringi::stri_trans_general(id.gadm$NAME_2, 'Latin-ASCII') 
# 
ind.rshp$idmpio <- id.gadm$ID_2[match(ind.rshp$nommpio, id.gadm$NAME_2)]

#\\ Splitt by variables (check reference table)
unique(ind.rshp[,idindicador])
test <- aggregate(data=ind.rshp, by = list(ind.rshp$idindicador), FUN )

library(doBy)
nacount.var <- summaryBy(value+year+nommpio+idmpio+iddepto+nomdepto~idindicador,
          data=ind.rshp,
          FUN=function(x) sum(is.na(x)),
          keep.names=TRUE)
nacount.var <- as.data.frame(matrix(unlist(nacount.var),
    ncol=7, nrow=18, byrow=F, 
    dimnames = NULL)#list('idindicador','value','year','nommpio','idmpio','iddepto','nomdepto') 
    , stringsAsFactors=TRUE)
nacount.var

#Sort by 2010



#// Population 
pop <- read_csv("~/Documents/GitHub/latam_datathlon_2017/data/pop.csv")
pop$Departamento <- tolower(pop$Departamento); 
pop$Departamento <- stringi::stri_trans_general(pop$Departamento, 'Latin-ASCII') 
pop$Codigo <- id.gadm$ID_1[match(pop$Departamento, id.gadm$NAME_1)]
pop <- gather(pop, year, popvalue, '2005', '2006', 
                   '2007', '2008', '2009', '2010')
#//Merge pop to ind.rshp
merge.data.frame(ind.rshp)







#Set up map
#states and COL_Admin2 municipalities
# //source: http://www.gadm.org/country //
COL.m.data <- readShapeSpatial('~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp/COL_adm2.shp')
COL.m.coord <- fortify(COL.m.data)

id <- data.frame(id = unique(COL.m.coord[ , c('id')]))
id[ , 'Porcentaje'] <- runif(nrow(id), 0, 1)

COL.m.coord <- merge(COL.m.coord, id, by = 'id')

mapColDep <- ggplot() +
  geom_polygon(data=ohsColI2, 
               aes(x=long, y=lat,group = group, fill = Porcentaje), 
               colour ='black', size = 0.1) +
  labs(title = 'Colombia', fill = '') +
  labs(x='',y='',title='Colombia') +
  scale_x_continuous(limits=c(-80,-65))+
  scale_y_continuous(limits=c(-5,13) )

mapColDep

#ggsave(mapColDep, file = 'mapColDep.png',width = 5, height = 4.5, type = 'cairo-png')
