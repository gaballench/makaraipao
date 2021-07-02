gbifData <- read.delim("occurrence.txt", header = TRUE, stringsAsFactors =  FALSE)
splinkData <- read.delim("speciesLink_all_49771_20190521013813.txt.out", header = TRUE, stringsAsFactors =  FALSE)

### clean the SpeciesLink dataset
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
gbifData <- gbifData[-which(gbifData$decimalLongitude < -83.0521), ]
gbifData <- gbifData[-which(gbifData$decimalLatitude > 12.4583), ]
# remove fossil occurrences
gbifData <- gbifData[-which(gbifData$basisOfRecord == "FOSSIL_SPECIMEN"), ]
# two doubtful records removed, one b/c of geographic mismatch
# the other because of geographic uncertainty placing the record out of the known distribution
gbifData <- gbifData[-which(gbifData$occurrenceID == "086E2F34-26EC-4270-9CC8-771FFCCA737B"), ]
gbifData <- gbifData[-which(gbifData$occurrenceID == "BR:UEL:MZUEL-Peixes:18116"), ]
# the last case was duplicated in the specieslink dataset
splinkData <- splinkData[-which(splinkData$catalognumber == "17189"),  ]


### Taxonomic cleaning
# remove an erroneous record of Paracanthopoma
splinkData <- splinkData[-which(splinkData$genus == "Paracanthopoma"),  ] 
### subsetting
# construct the dataframe concatenating column contents and creating on the fly a column with information on the source of the record
phractoCoords <- data.frame(genus = c(gbifData$genus, splinkData$genus),
                            species = c(gbifData$species, splinkData$scientificname),
                            latitude = c(gbifData$decimalLatitude, splinkData$latitude),
                            longitude = c(gbifData$decimalLongitude, splinkData$longitude),
                            source = c(rep("gbif", times = nrow(gbifData)),
                                       rep("splink", times = nrow(splinkData))), 
                            stringsAsFactors = FALSE)
# remove missing coordinates. 
# identical(is.na(phractoCoords$latitude),
#  is.na(phractoCoords$longitude)) evaluates to TRUE
# so we can just pick any of the coordinate components
phractoCoords <- phractoCoords[!is.na(phractoCoords$longitude), ]
#write the clean dataset
write.table(x = phractoCoords, file = "phractocephalus.tab", sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
