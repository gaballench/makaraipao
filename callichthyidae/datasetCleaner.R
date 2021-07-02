gbifData <- read.delim("occurrence.txt", header = TRUE, stringsAsFactors =  FALSE)
splinkData <- read.delim("speciesLink_all_49771_20190521013813.txt.out", header = TRUE, stringsAsFactors =  FALSE)

### clean the SpeciesLink dataset
# remove data from specieslinkData with notes containing "bloqueado"
splinkData <- splinkData[-grep(x = splinkData$notes, pattern = "bloqueado"), ]
# the latter case was messing with the type of the coordinate columns, coerce them to numeric
splinkData$longitude <- as.numeric(splinkData$longitude)
splinkData$latitude <- as.numeric(splinkData$latitude)
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
# remove an erroneous record of Corydoras from Guajira along with caribbean marine occurrences
gbifData <- gbifData[-which(gbifData$decimalLatitude > 12.20), ]
# remove erroneous records from the Pacific
gbifData <- gbifData[-which(gbifData$decimalLatitude == 3.997866), ]
# remove erroneous records from the Caribbean
gbifData <- gbifData[-which(gbifData$decimalLatitude == 11.616667), ]
# remove erroneous records from the Caribbean
gbifData <- gbifData[-which(gbifData$decimalLatitude == 11), ]
# remove erroneous records from the Atlantic
gbifData <- gbifData[-which(gbifData$decimalLatitude == -16.851667), ]
# remove erroneous records from the Atlantic
gbifData <- gbifData[-which(gbifData$decimalLatitude == -24.134167), ]
# remove erroneous records from the Atlantic
gbifData <- gbifData[-which(gbifData$decimalLatitude == -23.983333), ]
# remove erroneous records from the Atlantic
gbifData <- gbifData[-which(gbifData$decimalLatitude == -24.134167), ]
# remove erroneous records from the Atlantic
gbifData <- gbifData[-which(gbifData$decimalLatitude == -29.943333), ]
# remove fossil occurrences
gbifData <- gbifData[-which(gbifData$basisOfRecord == "FOSSIL_SPECIMEN"),  ]

### Clean the specieslink dataset
# remove an erroneous record of Corydoras from Guajira along with caribbean marine occurrences
splinkData <- splinkData[-which(splinkData$latitude > 12.20), ]
# remove erroneous records from the Atlantic
splinkData <- splinkData[-which(splinkData$latitude == -24.134167), ]
# remove erroneous records from the Atlantic
splinkData <- splinkData[-which(splinkData$latitude == -29.943333), ]

### Taxonomic cleaning
# remove data w/o genus
gbifData <- gbifData[-which(gbifData$genus == ""), ]
splinkData <- splinkData[-which(splinkData$genus == ""), ]
splinkData <- splinkData[-which(splinkData$genus == "Callichthyidae"), ]

### subsetting
# construct the dataframe concatenating column contents and creating on the fly a column with information on the source of the record
callichCoords <- data.frame(genus = c(gbifData$genus, splinkData$genus),
                            species = c(gbifData$species, splinkData$scientificname),
                            latitude = c(gbifData$decimalLatitude, splinkData$latitude),
                            longitude = c(gbifData$decimalLongitude, splinkData$longitude),
                            source = c(rep("gbif", times = nrow(gbifData)),
                                       rep("splink", times = nrow(splinkData))), 
                            stringsAsFactors = FALSE)
# remove missing coordinates. 
# identical(is.na(callichCoords$latitude),
#  is.na(callichCoords$longitude)) evaluates to TRUE
# so we can just pick any of the coordinate components
callichCoords <- callichCoords[!is.na(callichCoords$longitude), ]
#write the clean dataset
write.table(x = callichCoords, file = "callichtyidae.tab", sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
