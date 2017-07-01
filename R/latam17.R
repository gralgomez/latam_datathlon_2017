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
library(Hmisc)

setwd('~/Documents/GitHub/latam_datathlon_2017/R/')

#// Load the data
ind.salud <- read_csv('~/Documents/GitHub/latam_datathlon_2017/data/Indicadores_de_Salud.csv')
#// View(unique(ind.salud[,'nomindicador'])) - 19 indicators 
str(ind.salud); #describe(ind.salud)
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
#ind.rshp <- spread(ind.rshp,idindicador,value)
ind.rshp <- as.data.table(ind.rshp)
#years
ind.rshp$year <- as.numeric(ind.rshp$year)

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

#// Population 
pop <- read_csv("~/Documents/GitHub/latam_datathlon_2017/data/pop.csv")
pop$Departamento <- tolower(pop$Departamento); 
pop$Departamento <- stringi::stri_trans_general(pop$Departamento, 'Latin-ASCII') 
pop$Codigo <- id.gadm$ID_1[match(pop$Departamento, id.gadm$NAME_1)]
pop <- gather(pop, year, popvalue, '2005', '2006', 
              '2007', '2008', '2009', '2010')
#//Merge pop to ind.rshp
merge.data.frame(ind.rshp)

#\\ Splitt by variables (check reference table)
unique(ind.rshp[,idindicador])
library(doBy)
nacount.var <- summaryBy(value+year+nommpio+idmpio+iddepto+nomdepto~idindicador,
                         data=ind.rshp,
                         FUN=function(x) sum(is.na(x)),
                         keep.names=TRUE)
nacount.var <- as.data.frame(matrix(unlist(nacount.var),
                                    ncol=7, nrow=18, byrow=F, 
                                    dimnames = NULL)
                             , stringsAsFactors=TRUE)
nacount.var

#// Select relevant variables
  #pcrparin (4)
  #ttdnesti (13)
  #cgrnacim (16)
  #ctrmormt (2)
  #pcrperca (9)
  #pcrrncpn (15)
  #rtrmorpu (5)
  #ttdiesti (1)
#----------
ind.var4 <- subset(ind.rshp, ind.rshp$idindicador == 'pcrparin')
ind.var13 <- subset(ind.rshp, ind.rshp$idindicador == 'ttdnesti')
ind.var16 <- subset(ind.rshp, ind.rshp$idindicador == 'cgrnacim')
ind.var2 <- subset(ind.rshp, ind.rshp$idindicador == 'ctrmormt')
ind.var9 <- subset(ind.rshp, ind.rshp$idindicador == 'pcrperca')
ind.var15 <- subset(ind.rshp, ind.rshp$idindicador == 'pcrrncpn')

ind.var1 <- subset(ind.rshp, ind.rshp$idindicador == 'ttdiesti')
  # mult by 10 to measure the % ratio
  ind.var1$value <- as.numeric(ind.var1$value) * 10
  # Aggregate by state: (State ID -1)
  ind.var1.dep <- aggregate(ind.var1[,c(7)], list(ind.var1$iddepto), mean)
  colnames(ind.var1.dep)[1] <- 'id'
  ind.var1.dep$id =  ind.var1.dep$id -1
  
  #Group by municipality (MUN ID -1)
  ind.var1 <- ind.var1[,c(4,6,7)]
  ind.var1 <- ind.var1[ind.var1$year == 2010]
  ind.var1 <- ind.var1[,c(1,3)]
  colnames(ind.var1)[1] <- 'id'
  #ind.var1$value <- ind.var1$value/919.7000
  #ind.var1[ , "value"] <- runif(nrow(ind.var1), 0, 1)
  

ind.var5 <- subset(ind.rshp, ind.rshp$idindicador == 'rtrmorpu')
#----------
rm(COL.ind,ind,years,years.rel)
#----------

#Set up map
library(sp)
library(RColorBrewer)
library(ggplot2)
library(maptools)
library(scales)
#states and COL_Admin2 municipalities
# //source: http://www.gadm.org/country //
COL.m.data <- readShapeSpatial('~/Documents/GitHub/latam_datathlon_2017/GIS_data/COL_adm_shp/COL_adm1.shp')
COL.m.coord <- fortify(COL.m.data)
COL.map <- merge(COL.m.coord, ind.var1.dep, by = 'id')

mapColDep <- ggplot() +
  geom_polygon(data = COL.map,
               inherit.aes = TRUE,
               aes(x = long, y = lat, group = group, fill = value),
               colour ='black',
               size = 0.1,
               na.rm = TRUE)+
   labs(title = 'Colombia', fill = '') +
  labs(x='',y='',title='Colombia') +
  scale_x_continuous(limits=c(-80,-65))+
  scale_y_continuous(limits=c(-5,13)
  )
 
dev.off(); mapColDep

#ggsave(mapColDep, file = 'mapColDep.png',width = 5, height = 4.5, type = 'cairo-png')
