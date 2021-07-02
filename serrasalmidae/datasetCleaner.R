gbifData <- read.delim("occurrence.txt", header = TRUE, stringsAsFactors =  FALSE)
splinkData <- read.delim("speciesLink_all_49771_20190521013813.txt.out", header = TRUE, stringsAsFactors =  FALSE)

### clean the SpeciesLink dataset
# coordinate automatic cleaning
# examine the boxplot
boxplot(splinkData$latitude)
boxplot(splinkData$longitude)
# filter out all coordinates east of (South America+Panama)'s
# easternmost point: -34.7930, João Pessoa, Paraíba, and 
splinkData <- splinkData[-which(splinkData$longitude > -34.7930), ]

### Clean the GBIF dataset
# remove cases that are explicitly showing geospatial data
gbifData <- gbifData[-which(gbifData$hasGeospatialIssues == "true"),  ]
# remove all coordinates out of (South America + Panama)'s bounds
gbifData <- gbifData[-which(gbifData$decimalLongitude > -34.7930), ]
gbifData <- gbifData[-which(gbifData$decimalLongitude < -83.0521), ]
gbifData <- gbifData[-which(gbifData$decimalLatitude > 12.4583), ]
# remove serrasalmid occurrences in the ocean and west of the Andes in Peru where they are certainly erroneous
# these occurrences are said to be from Leticia, Colombia.
gbifData <- gbifData[-which(gbifData$decimalLatitude == 3.997866), ]
# remove an occurrence from "Pibas" (most likely Pebas) that mapped west of the Andes
gbifData <- gbifData[-which(gbifData$decimalLatitude == -12.454263), ]
# remove an occurrence from west of the Andes of Piaractus from Sucre, introduced to the Magdalena-Cauca
gbifData <- gbifData[-which(gbifData$decimalLatitude == 9.166804), ]
# remove fossil occurrences
gbifData <- gbifData[-which(gbifData$basisOfRecord == "FOSSIL_SPECIMEN"), ]

### Taxonomic cleaning
# remove occurrences uncertain to family level
splinkData <- splinkData[-which(splinkData$genus == ""),  ]
gbifData <- gbifData[-which(gbifData$genus == ""),  ]
### subsetting
# construct the dataframe concatenating column contents and creating on the fly a column with information on the source of the record
serraCoords <- data.frame(genus = c(gbifData$genus, splinkData$genus),
                            species = c(gbifData$species, splinkData$scientificname),
                            latitude = c(gbifData$decimalLatitude, splinkData$latitude),
                            longitude = c(gbifData$decimalLongitude, splinkData$longitude),
                            source = c(rep("gbif", times = nrow(gbifData)),
                                       rep("splink", times = nrow(splinkData))), 
                            stringsAsFactors = FALSE)
# remove missing coordinates. 
# identical(is.na(serraCoords$latitude),
#  is.na(serraCoords$longitude)) evaluates to TRUE
# so we can just pick any of the coordinate components
serraCoords <- serraCoords[!is.na(serraCoords$longitude), ]
#write the clean dataset
write.table(x = serraCoords, file = "serrasalmidae.tab", sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
