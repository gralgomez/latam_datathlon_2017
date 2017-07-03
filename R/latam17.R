#// Project - Visualizing HealthQuality in Colombia //
#@author: Laura Gabrysiak
# -- 'utf-8' --
#%>% Setup
rm(list = ls(all.names = TRUE))
options(encoding = 'UTF-8')
setwd('~/Documents/GitHub/latam_datathlon_2017/R/')

# Load libraries
library(readr)
library(data.table)
library(Hmisc)

#// Load the data
ind.salud <- read_csv('~/Documents/GitHub/latam_datathlon_2017/data/Indicadores_de_Salud.csv')
#// View(unique(ind.salud[,'nomindicador'])) - 19 indicators 
str(ind.salud); #describe(ind.salud)
#View(unique(ind.salud[,c('idindicador','nomindicador')]))

#// Measure NA ratio
nacount <- sort(unlist(lapply(ind.salud, function(x) sum(is.na(x))/nrow(ind.salud))))
# barplot(sort(nacount), ylab = 'Number of NAs')

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
nacount.2 <- sort(unlist(lapply(ind, function(x) sum(is.na(x))/nrow(ind)))); 
#barplot(nacount.2)
rm(COL.ind,years,years.rel)

#// Level 1 + 2 // get rid of all national data
ind <- subset(ind, ind$iddepto < 170)

library(tidyr)
#// Reshape data to 
ind.rshp <- gather(ind, year, value, '2005', '2006', 
                   '2007', '2008', '2009', '2010')

#ind.rshp <- spread(ind.rshp,idindicador,value)
ind.rshp <- as.data.table(ind.rshp)
ind.rshp$year <- as.numeric(ind.rshp$year)

# // Level 1 - States:

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
ind.rshp$idmpio <- id.gadm$ID_2[match(ind.rshp$nommpio, id.gadm$NAME_2)]

#// Population 
pop <- read_csv("~/Documents/GitHub/latam_datathlon_2017/data/pop.csv")
pop$Departamento <- tolower(pop$Departamento); 
pop$Departamento <- stringi::stri_trans_general(pop$Departamento, 'Latin-ASCII') 
pop$Codigo <- id.gadm$ID_1[match(pop$Departamento, id.gadm$NAME_1)]
pop <- gather(pop, year, popvalue, '2005', '2006', 
              '2007', '2008', '2009', '2010')
pop <- subset(pop, pop$year == '2010')
pop$Codigo[pop$Departamento == 'bogota'] = 14
#merge bogota + cundinamarca
pop <- pop[,c(1,3,4)]
pop <- aggregate(pop$popvalue, by = list(pop$Codigo), FUN = sum)
colnames(pop)[1] <- 'id' 
pop$id = pop$id -1
colnames(pop)[2] <- 'pop' 

#//Merge pop to ind.rshp
#merge.data.frame(ind.rshp)

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

#// Select relevant variables for year 2010
  #pcrparin (4)- Porcentaje partos institucionales
  #ttdnesti (13) - Tasa de mortalidad estimada en menores de 5 años
  #cgrnacim (16) - Número anual de nacimientos
  #ctrmormt (2) - Mortalidad materna a 42 días
  #pcrperca (9) - Porcentaje de partos por personal calificado
  #pcrrncpn (15) - Porcentaje de nacidos vivos con cuatro o más consultas
  #rtrmorpu (5) - Razón de mortalidad materna a 42 días
  #ttdiesti (1) - Tasa de mortalidad infantil estimada
ind.rshp.2010 <- subset(ind.rshp, ind.rshp$year == 2010)
ind.rshp.2010$year <- NULL
#municipalities
# ind.rshp.2010 %>% spread(iddepto,
#                          idindicador,
#                           value)
# VAR 4 ----------------------------------------------------------------------
ind.var4 <- subset(ind.rshp, ind.rshp$idindicador == 'pcrparin')
  #ind.var4 <- subset(ind.var4, ind.var4$year == 2010)
  # Aggregate by state: (State ID -5)
  ind.var4.dep <- aggregate(ind.var4[,c(7)], list(ind.var4$iddepto), mean)
  colnames(ind.var4.dep)[1] <- 'id'
  ind.var4.dep$id =  ind.var4.dep$id -1
  # By municipality
  ind.var4 <- ind.var4[,c(4,6,7)]
  ind.var4 <- ind.var4[,c(1,3)]
  colnames(ind.var4)[1] <- 'id'
  ind.var4$id =  ind.var4$id -1
# VAR 13 ----------------------------------------------------------------------
ind.var13 <- subset(ind.rshp, ind.rshp$idindicador == 'ttdnesti')
  ind.var13 <- subset(ind.var13, ind.var13$year == 2010)
  # Aggregate by state: (State ID -5)
  ind.var13.dep <- aggregate(ind.var13[,c(7)], list(ind.var13$iddepto), mean)
  colnames(ind.var13.dep)[1] <- 'id'
  ind.var13.dep$id =  ind.var13.dep$id -1
  # By municipality
  # NO IDs
# VAR 16 ----------------------------------------------------------------------
# /100000 - hwr no action taken
ind.var16 <- subset(ind.rshp, ind.rshp$idindicador == 'cgrnacim')
  ind.var16 <- subset(ind.var16, ind.var16$year == 2010)
  # Aggregate by state: (State ID -5)
  ind.var16.dep <- aggregate(ind.var16[,c(7)], list(ind.var16$iddepto), mean)
  colnames(ind.var16.dep)[1] <- 'id'
  ind.var16.dep$id =  ind.var16.dep$id -1
  # By municipality
  # NO IDs
# VAR 2 ----------------------------------------------------------------------
ind.var2 <- subset(ind.rshp, ind.rshp$idindicador == 'ctrmormt')
  ind.var2 <- subset(ind.var2, ind.var2$year == 2010)
  # Aggregate by state: (State ID -5)
  ind.var2.dep <- aggregate(ind.var2[,c(7)], list(ind.var2$iddepto), mean)
  colnames(ind.var2.dep)[1] <- 'id'
  ind.var2.dep$id =  ind.var2.dep$id -1
  # By municipality
  # NO iDs
# VAR 9 ----------------------------------------------------------------------
  ind.var9 <- subset(ind.rshp, ind.rshp$idindicador == 'pcrperca')
  # Aggregate by state: (State ID -5)
  ind.var9.dep <- aggregate(ind.var9[,c(7)], list(ind.var9$iddepto), mean)
  colnames(ind.var9.dep)[1] <- 'id'
  ind.var9.dep$id =  ind.var9.dep$id -1
# VAR 15 ----------------------------------------------------------------------
ind.var15 <- subset(ind.rshp, ind.rshp$idindicador == 'pcrrncpn')
  ind.var15 <- subset(ind.var15, ind.var15$year == 2010)
  # mult by 10 to measure the % ratio
  ind.var15$value <- as.numeric(ind.var15$value) * 10
  # Aggregate by state: (State ID -5)
  ind.var15.dep <- aggregate(ind.var15[,c(7)], list(ind.var15$iddepto), mean)
  colnames(ind.var15.dep)[1] <- 'id'
  ind.var15.dep$id =  ind.var15.dep$id -1
  #Group by municipality (MUN ID -1)
  # No IDs
# VAR 1 (%) ----------------------------------------------------------------------
ind.var1 <- subset(ind.rshp, ind.rshp$idindicador == 'ttdiesti')
  # mult by 10 to measure the % ratio
  ind.var1$value <- as.numeric(ind.var1$value)
  # Aggregate by state: (State ID -1)
  ind.var1.dep <- aggregate(ind.var1[,c(7)], list(ind.var1$iddepto), mean)
  colnames(ind.var1.dep)[1] <- 'id'
  ind.var1.dep$id =  ind.var1.dep$id -1
  #Group by municipality (MUN ID -1)
  ind.var1 <- ind.var1[,c(4,6,7)]
  ind.var1 <- ind.var1[ind.var1$year == 2010]
  ind.var1 <- ind.var1[,c(1,3)]
  colnames(ind.var1)[1] <- 'id'
  ind.var1$id =  ind.var1$id -1
  #ind.var1$value <- ind.var1$value/919.7000
  #ind.var1[ , "value"] <- runif(nrow(ind.var1), 0, 1)
  
# VAR 5 ----------------------------------------------------------------------
ind.var5 <- subset(ind.rshp, ind.rshp$idindicador == 'rtrmorpu')
  ind.var5 <- subset(ind.var5, ind.var5$year == 2010)
  # Aggregate by state: (State ID -5)
  ind.var5.dep <- aggregate(ind.var5[,c(7)], list(ind.var5$iddepto), mean)
  colnames(ind.var5.dep)[1] <- 'id'
  ind.var5.dep$id =  ind.var5.dep$id -1
  # By municipality
  ind.var5 <- ind.var5[,c(4,6,7)]
  ind.var5 <- ind.var5[,c(1,3)]
  colnames(ind.var5)[1] <- 'id'
  ind.var5$id =  ind.var5$id -1
