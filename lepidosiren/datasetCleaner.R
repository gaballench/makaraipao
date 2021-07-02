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
# remove fossil occurrences
gbifData <- gbifData[-which(gbifData$basisOfRecord == "FOSSIL_SPECIMEN"),  ]

### Taxonomic cleaning

### subsetting
# construct the dataframe concatenating column contents and creating on the fly a column with information on the source of the record
lepidoCoords <- data.frame(genus = c(gbifData$genus, splinkData$genus),
                            species = c(gbifData$species, splinkData$scientificname),
                            latitude = c(gbifData$decimalLatitude, splinkData$latitude),
                            longitude = c(gbifData$decimalLongitude, splinkData$longitude),
                            source = c(rep("gbif", times = nrow(gbifData)),
                                       rep("splink", times = nrow(splinkData))), 
                            stringsAsFactors = FALSE)
# remove missing coordinates. 
# identical(is.na(lepidoCoords$latitude),
#  is.na(lepidoCoords$longitude)) evaluates to TRUE
# so we can just pick any of the coordinate components
lepidoCoords <- lepidoCoords[!is.na(lepidoCoords$longitude), ]
#write the clean dataset
write.table(x = lepidoCoords, file = "lepidosiren.tab", sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
