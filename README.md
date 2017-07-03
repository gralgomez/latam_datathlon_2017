# Bienvenidos al wiki del DATATHON LATAM 2017!  
Visualización de indicadores de salud en Colombia.
***

## Introducción
El objetivo de este proyecto es generar una visualización que transforme los datos del área de salud de Colombia a algo que genere conocimientos para líderes y ciudadanos. Específicamente, buscamos informar sobre las diferencias en salud a través de los departamentos colombianos. 

## Proceso
Descripción y documentación del proceso.

![Diagrama](https://github.com/gralgomez/latam_datathlon_2017/blob/master/images/Data%20Diagram.png)

### Adquisición de Datos
Empezamos por revisar los archivos de datos que fueron compartidos con nosotros por los organizadores del Datathon. Llegamos al sitio web de datos abiertos del gobierno de Colombia, donde pudimos encontrar varios archivos de datos del tema de salud. Usamos la herramienta de [datos.gov.co](https://datos.gov.co/) para explorar los conjuntos de datos (datasets), y encontramos que no todos los archivos eran muy informativos. Muchos datasets no tenían información por departamento o municipio, lo cual es muy importante para nuestra propuesta. 

* Dataset seleccionado: [Indicadores de Salud](https://www.datos.gov.co/Salud-y-Protecci-n-Social/Indicadores-de-Salud/5q5i-ydf8)

### Pre-procesamiento de Datos de Salud
### Herramienta
* R: librerías 
  * readr
  * data.table
  * Hmisc
  * tidyr

  * ggplot2
  * sp
  * RColorBrewer
  * maptools
  * scales
  
### Exploración Inicial:
**Tamaño de tabla de datos:** (2868, 102)  
**Numero de indicadores de salud:** 19  
**Numero de departamentos únicos:** 36 (contando a Colombia y a Bogotá)  
**Numero de municipios únicos:** 1122  

### Exploración de columnas:
Notamos que muchas de las columnas no tenían valores (campos vacíos). Decidimos ignorar las columnas con menos de la mitad de los valores ausentes. Esto nos dejó con las siguientes variables:  

       ['consecutivo', 'idindicador', 'nomindicador', 'idunidad', 'nomunidad',
       'iddepto', 'nomdepto', 'idmpio', 'nommpio', 'yea2005', 'yea2006', 'yea2007',
       'yea2008', 'yea2009', 'yea2010', 'fue2005', 'fue2006', 'fue2007',
       'fue2008', 'fue2009', 'fue2010']

Al analizar estas variables, las definimos de la siguiente manera:
* consecutivo: index
* idindicador: id del indicador de salud
* nomindicador: nombre del indicador de salud
* idunidad: id de la unidad usada para describir al indicador
* nomunidad: nombre de la unidad usada para describir al indicador
* iddepto: id del departamento geográfico
* nomdepto: nombre del departamento geográfico
* idmpio: id del municipio geográfico
* nommpio: nombre del municipio geográfico
* yea2005: valor para el año 2005
* yea2006: valor para el año 2006
* yea2007: valor para el año 2007
* yea2008: valor para el año 2008
* yea2009: valor para el año 2009
* yea2010: valor para el año 2010
* fue2005: fuente del valor para el año 2005
* fue2006: fuente del valor para el año 2006
* fue2007: fuente del valor para el año 2007
* fue2008: fuente del valor para el año 2008
* fue2009: fuente del valor para el año 2009
* fue2010: fuente del valor para el año 2010  

Decidimos que aunque no existían muchos valores ausentes para el 'consecutivo' y las variables de fuente, esas variable no agregaban mucho a nuestro análisis, entonces los sacamos de nuestro dataset. 

### Exploración de departamentos
Notamos algunas ocurrencias extrañas con relación a los departamentos, las cuales exploramos  a continuación.
* Diferencia de nombres: nomdepto. Por cada departamento colombiano, identificado por un 'iddepto' único, existían varias variables de 'nomdepto', ya que los nombres de los departamentos no estaban estandarizados.
* Extranjeros: Existía un nomdepto llamado Extranjeros que no corresponde con un departamento colombiano actual.
* Bogotá: La capital de Colombia se presentaba como un departamento en el dataset 
* Sin Información / No Definidos: Existía un departamento ('iddepto' = 9), el cual representa datos no definidos por departamentos.
* Colombia: Existía una variable entre departamentos que representaba los valores de indicadores por todo el país ('iddepto = 170').  

### Exploración de indicadores
Los indicadores encontrados en el dataset de Indicadores de Salud son los siguientes:    
* Variables de datos abiertos (19)  
   * ttdiesti: Tasa de mortalidad infantil estimada  
   * ctrmormt: Mortalidad materna a 42 días  
   * caelacex: Duración de la lactancia materna exclusiva en menores de 3 años  
   * pcrparin: Porcentaje partos institucionales  
   * rtrmorpu: Razón de mortalidad materna a 42 días  
   * pbepredc: Prevalencia de desnutrición crónica  
   * ptrldeng: Letalidad de Dengue grave    
   * pbretaia: Porcentaje de brotes de ETA con identificación de agentes patógenos en muestras biológicas alimentos y superficies /ambientales  
   * pcrperca: Porcentaje de partos atendidos por personal calificado  
   * pbehtaco: Porcentaje de población con hipertensión arterial diagnosticada en 2 o más consultas  
   * igrtgfec: Tasa Global de Fecundidad  
   * pbrmivih: Porcentaje de transmisión materno infantil de VIH  
   * ttdnesti: Tasa de mortalidad estimada en menores de 5 años  
   * rgrtgfec: Tasa General de Fecundidad  
   * pcrrncpn: Porcentaje de nacidos vivos con cuatro o más consultas de control prenatal  
   * cgrnacim: Número anual de nacimientos  
   * pbepredg: Prevalencia de desnutrición global  
   * pgeembar: Porcentaje de mujeres de 15 a 19 años alguna vez embarazadas (ya son madres o están embarazadas por primera vez)  
   * paemetmo: Porcentaje de mujeres con uso actual de métodos modernos

Agrupamos los indicadores en cuatro categorías:
1. Infantil
2. Maternidad/Fecundidad
3. Nutrición
4. Otro  

![Tabla Indicadores Categorias](https://github.com/gralgomez/latam_datathlon_2017/blob/master/images/Indicadores_descripcion.gif)

Notamos que no todos los indicadores tenían valores para todos los años, por lo cual decidimos usar solo los indicadores con los cuales podríamos comparar valores a través de los años. 

### Exploración de relación entre indicadores
 * Alta correlación negativa entre 'ttdiesti' (Tasa de mortalidad infantil estimada) y 'pcrparin' (Porcentaje partos institucionales)
 * Alta correlación positiva entre 'pcrrncpn' (Porcentaje de nacidos vivos con cuatro o más consultas de control prenatal) y 'pcrparin' (Porcentaje partos institucionales)
 * Alta correlación negativa entre 'pcrrncpn' (Porcentaje de nacidos vivos con cuatro o más consultas de control prenatal) y 'ttdiesti'(Tasa de mortalidad infantil estimada), al igual que entre 'pcrrncpn y 'ttdnesti' (Tasa de mortalidad estimada en menores de 5 años)

![Table correlacion indicadores 2010](https://github.com/gralgomez/latam_datathlon_2017/blob/master/images/2010_indicador_corr_by_depto.gif)

### Formateo de Datos de Salud ###
Decidimos visualizar los datos de salud a nivel departamental, lo cual requería reformatear la tabla y aggregar los valores de los indicadores a nivel del 'iddepto' ya que cada instancia en el dataset original representa un municipio. Para esto usamos la el siguiente codigo, aggregando con el promedio del valor del indicador para todos los municipios formando parte del departamento. 

`ind.var1.dep <- aggregate(ind.var1[,c(7)], list(ind.var1$iddepto), mean)`  
 
`colnames(ind.var1.dep)[1] <- 'id'`  

`ind.var1.dep$id =  ind.var1.dep$id -1`

### Datos geoespaciales (GIS) y Visualización 

Para visualizar los datos en un formato geográfico utilizamos los datos en formato '.shp' (shapefile) del GADM. [GADM](http://www.gadm.org/) es una base de datos espacial con mapas administrativos de todos los países del mundo. Nos brinda los datos necesarios para visualizar el mapa de Colombia, y los departamentos. Los pasos que seguimos fueron:

1. Obtención de los datos geo-espaciales (Fuente: GADM)
2. Lectura de los datos y creación de los mapas
3. Integración de los mapas con base de datos. (Valores a visualizar)

#### Obtención de los datos geo-espaciales (Fuente: GADM)
Los datos pueden ser adquiridos en el portal de GADM y ser descargados en diversos formatos (ESRI, shp, etc.). EL formato seleccionado para este proyecto es el 'shapefile'(.shp).

#### Lectura de los datos y creación de los mapas
Los datos .shp pueden ser integrados a R con la librería 'sp'. Además de leer los datos con las coordenadas, un mapa se crea con el comando `fortify`:

`COL.m.data <- readShapeSpatial('~/GitHub/latam_datathlon_2017/../COL_adm2.shp')`

`COL.m.coord <- fortify(COL.m.data)`

El mapa creado se utilizará como base para luego visualizar los valores calculados.

#### Integración de los mapas con base de datos. (Valores a visualizar)

Luego del proceso de limpieza de datos y de calcular los valores relevantes para este proyecto, estos se pueden integrar con el mapa con el comando `merge`. El comando merge necesita un primary key/index para integrar los dos datos. En este caso, adaptamos el código de departamento y de municipalidad al estándar de GADM. Este procedimiento será descrito en la próxima sección. 

`COL.map <- merge(COL.m.coord, variable, by = 'id')`

Al integrar los valores con el mapa base, podemos utilizar la librería `ggplot2` para visualizar los datos. Antes de visualizar las variables seleccionadas visualizamos la población de Colombia de 2010 como variable de control:

`mapColDep <- ggplot() +`
  `geom_polygon(data = COL.map,`
               `inherit.aes = TRUE,`
               `aes(x = long, y = lat, `
                   `group = group, `
                   `fill = pop, #pop/max(pop)`
                   `color = color),`
               `colour ='grey24',`
               `alpha = 0.95,`
               `size = 0.1,`
               `na.rm = TRUE) +`
  `labs(title = 'Colombia', fill = '') +`
  `labs(x='',y='',title='Colombia - Poblacion 2010') +`
  `scale_x_continuous(limits=c(-80,-65))+`
  `scale_y_continuous(limits=c(-5,13)  )`


Como es de esperar el departamento con mayor población es el de Cundinamarca/Bogotá:

![Poblacion de Colombia 2010](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Pop_dep.png)

La población puede ser representada en número total o como proporción (ratio). A continuacion procederemos a explicar el proceso de integracion de datos y estandardizacion del id de departamento y municipalidad.

#### Normalización de los Identificadores (IDs)

Los ids de los datos procedentes del OpenData no coincidían con los de los datos geográficos de GADM por lo que una normalización de datos era requerida en este caso. Decidimos adaptarnos al formato de GADM ya que los archivos geográficos se regían por este estándar. Para normalizar los ids decidimos utilizar el nombre de los departamentos/municipios. Utilizando técnicas de minería de texto (Text Mining) (Expresiones regulares) Para ello utilizamos las librerias stringr y stringi para convertir todos los nombres a minuscula y normalizar nombres alternativos de algunos departamentos, por ejemplo: (_n.santander - norte de santander_) o (_s.andres - san andres - san andres y providencia_). Normalizamos los datos textuales de las dos fuentes de datos (OpenData y GADM) para crear una tabla de referencia. Otra dificultad estuvo constituida por características lingüísticas del castellano por ejemplo: _tildes_ y otros caracteres espaciales. Para ello formateamos todo el texto de UTF-8 a _Latin-ASCII _. Otras normalizaciones que se hicieron fueron todo *indefinido | sin valor --> NA*. Ademas, separamos los valores que eran a nivel nacional (_Colombia, id = 170_) para solo analizar valores que estuviesen vinculados a departamentos o municipalidades. Aun despues de este proceso, experimentamos muchas dificultades a nivel de municipalidad ya que la normalizacion de las municipalidades (n = 1065) no resulto tan exitosa como los departamentos (n = 32). Muchas de las municipalidades no estaban incluidas en el directorio del GADM y por lo tanto no pudieron ser normalizadas. 

`ind$nommpio <- tolower(ind$nommpio); `
`ind$nommpio <- stringi::stri_trans_general(ind$nommpio, 'Latin-ASCII')`

#### Visualización

Como previamente mencionado, las variables fueron elegidas en base a capacidad informacional (cantidad de NA's) y categoría semántica (maternidad/fecundidad). Las variables a visualizar escogidas fueron por lo tantos las siguientes:

![Variables elegidas](https://github.com/gralgomez/latam_datathlon_2017/blob/master/images/variables.gif)

A continuación, los mapas creados. Los departamentos con zonas indicadas en gris indican que los datos no cubrian estas zonas (NAs) y por lo tanto no se pueden representar en el mapa.

#### 1. ttdiesti (1) - Tasa de mortalidad infantil estimada

![Var1: Tasa de mortalidad infantil estimada](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Var1_dep_2.png)

![Var1: Tasa de mortalidad infantil estimada](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Var1_mun.png)

La tasa de mortalidad infantil esta presente en zonas mayormente rurales y tiene una correlacion inversa con los partos institucionales. La mayor taza de mortalidad infantil en 2010 fue documentada en el Amazonas. A nivel de municipalidad, hay mucha informacion sobre las municipalidades (id, valores) faltantes lo cual se refleja en el mapa. Las zonas rurales 'criticas' no ofrecen una informacion mas detallada sobre que municipalidades requieren de mayor atencion. Esto seria foco para el futuro de este proyecto.

#### 2. ctrmormt (2) - Mortalidad materna a 42 días

![Var2: Mortalidad materna a 42 días](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Var2_dep.png)

![Var2: Mortalidad materna a 42 días](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Var2_mun.png)

Esta variable representa la taza de mortalidad materna (/1000) pero los valores varian cuando se visualiza el mapa a nivel de municipalidad. Las variables 2 y 5 estan relacionadas sin embargo a la hora de visualizarlas muestran diferencias entre que departamentos son zonas criticas. Varias variables vienen de la misma fuente.

#### 3. pcrparin (4)- Porcentaje partos institucionales

 En el mapa se puede ver las diferencias de las zonas rurales y las urbanas. A nivel de estado no hay informacion presente para los varios departamentos (gris).

![Var4: Porcentaje partos institucionales](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Var4_dep.png)

![Var4: Porcentaje partos institucionales (municipal)](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Var4_mun.png)

#### 4. rtrmorpu (5) - Razón de mortalidad materna a 42 días

![Var5: Razón de mortalidad materna a 42 días](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Var5_dep.png)

Se puede percibir que esta variable es inversamente proporcional a la variable anterior (pcrparin). 

#### 5. pcrperca (9) - Porcentaje de partos por personal calificado

![Var9: Porcentaje de partos por personal calificado](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/var9_dep.png)

#### 6. ttdnesti (13) - Tasa de mortalidad estimada en menores de 5 años

![Var13: Tasa de mortalidad estimada en menores de 5 años](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Var13_dep.png)

#### 7. pcrrncpn (15) - Porcentaje de nacidos vivos con cuatro o más consultas

![Var15: Porcentaje de nacidos vivos con cuatro o más consultas](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Var15_dep.png)

#### 8. cgrnacim (16) - Número anual de nacimientos

![Var16: Número anual de nacimientos](https://github.com/gralgomez/latam_datathlon_2017/blob/master/R/Var16_dep.png)


#### Conclusiones

Gracias al analisis de los datos podemos concluir que existe un impacto positivo de la infrastructura en la mortalidad infantil y materna. Todavia el numero de partos institucionales esta un poco limitado a las areas urbanas pero a la misma vez pudimos observar un alto nivel de partos con equipo calificado. Estas dos variables serian de interes para un proyecto en el futuro. Gracias a la visualizacion de los datos y a pesar de las limitaciones de este trabajo pudimos obtener un rapido entendimiento de la situacion de la salud materna en Colombia e identificar posibles departamentos y zonas criticas p.e el departamento de Choco y/o el Amazonas. Esperamos que estos graficos ayuden al personal que este familiarizados con este campo a una mejor interpretacion de los resultados y feedback en posible desarrollo de este proyecto.

#### Limitaciones de este trabajo

Las mayores limitaciones de este trabajo fueron el mantenimiento de datos y el tiempo requerido para el proyecto. Un analisis de mayor profundidad requiere mayor tiempo ya que una gran parte del proyecto estuvo enfocada en el proceso inicial de la normalizacion y limpieza de datos.

Para un mejor mantenimiento de datos es necesario fuentes de informacion compatibles con bases de datos estandard p.e Banco Mundial. Esto hace posible el aumento y complementacion de las base de datos local con otras fuentes de informacion. Muchas variables no pudieron ser analizadas a fondo por falta de datos o por la imposibilidad de normalizar los datos y asi complementarlos con otras fuentes de informacion.


#### Consideraciones para Futuros Proyectos

Con el objectivo de crear una visualización para informar a lideres y ciudadanos del estado de la salud en el pais con un enfoque geografico, se podria mejorar este analisis creando una applicacion web que permita que el usuario 
investigue por su propia cuenta diferentes variables y pueda ver como estos indicadores cambian por departamento y através del tiempo. La libreria y plataforma de Shiny basada en el lenguaje R brinda los recursos necesarios para crear una aplicacion como la mencionada.   

Para proyectos futuros, nos gustaria también analizar y visualizar los indicadores de salud contra indicadores de inversion gubernamental para entender como el gobierno puede mejor distribuir fondos para mejorar la salud del pais.

#### Recomendaciones para Datos Abiertos

Al usar la plataforma de Datos Abiertos del gobierno Colombiano, nos impresiono mucho la inversion de recursos que han
asignado para asegurarsen de que el país se beneficie de las oportunidades que existen en las Ciencias de Datos. Recomendaríamos un enfoque mas grande el la documentacion de las fuentes de datos, explicando con mas detalle exactamente que representa cada variable, ya que fue un area donde encontramos que no teniamos toda la informacion necesaria. También es importante que al tiempo de adquirir los datos en el campo se estandarizen los nombres de los municipios y los departamentos ya que existian muchas variaciones de estos en el dataset original. 
