library(vegan)
library(pvclust)
library(sf)

### faunal similarity analyses for the Marakaipao fish fauna
dataset <- read.delim(file = "neogeneFishOccs.tab", stringsAsFactors = FALSE)

#################### only freswater taxa
dataset <- dataset[which(dataset$Environment == "Freshwater" | dataset$Environment == "Both"), ]

### Solimões-Pebas does not seem to be a fauna but a collection of different faunas across the Amazon, remove it
dataset <- dataset[, -grep(pattern = "Pebas", x = colnames(dataset))]

comMatrix <- dataset[, -c(1, 3, 18)]
rownames(comMatrix) <- comMatrix$Taxon
comMatrix <- comMatrix[-1]
comMatrix <- t(comMatrix)

### number of occurrences per fauna
sort(x = apply(X = comMatrix, MARGIN = 2, FUN = sum), decreasing = TRUE)

### include only those faunas with at least the number of occurrences
### of Makaraipao
selectFaunas <- names(which(apply(X = comMatrix, MARGIN = 1, FUN = sum) >= apply(X = comMatrix, MARGIN = 1, FUN = sum)["Makaraipao"]))
comMatrix <- comMatrix[selectFaunas, ]

### remove zero-sum species after faunal selection
selectSpp <- names(which(apply(X = comMatrix, MARGIN = 2, FUN = sum) > 0))
comMatrix <- comMatrix[, selectSpp]

### calculate the distance matrix using Bray-Curtis' method
distMatrixBray <- vegan::vegdist(comMatrix, method = "bray", binary = TRUE)
# rename labels in order to replace dots with spaces
attr(distMatrixBray, "Labels") <- gsub(pattern = "\\.", replacement = " ", x = attr(distMatrixBray, "Labels"))
# rename trans-Andean labels in order to place a leading asterisk
attr(distMatrixBray, "Labels") <- gsub(pattern = "Urumaco", replacement = "( T ) Urumaco", x = attr(distMatrixBray, "Labels"), fixed = TRUE)
attr(distMatrixBray, "Labels") <- gsub(pattern = "La Venta", replacement = "( T ) La Venta", x = attr(distMatrixBray, "Labels"), fixed = TRUE)
attr(distMatrixBray, "Labels") <- gsub(pattern = "Makaraipao", replacement = "( T ) Makaraipao", x = attr(distMatrixBray, "Labels"), fixed = TRUE)


### bootstrap on clustering

fBinary <- pvclust::pvclust(t(comMatrix), method.hclust = "average", method.dist = "binary")
fBray <- pvclust::pvclust(comMatrix, method.hclust = "average", method.dist = function(x) vegdist(x, method = "bray", binary = TRUE), nboot = 10000)
#plot(fBinary)
#plot(fBray)

### plot the dendrogram
pdf(file = "faunalSimBinary.pdf")
plot(fBinary, main = "Faunal similarity")
dev.off()

########## Similarity of modern units

### replace ? with absent 0
system("sed 's/?/0/g' dagosta2017/modern_incidence.tab > dagosta2017/modern_incidence_nomissing.tab")

modernData <- read.delim(file = "dagosta2017/modern_incidence_nomissing.tab", header = FALSE, stringsAsFactors = FALSE)
rownames(modernData) <- modernData[,1] 
modernData <- modernData[-1, ]
modernData <- modernData[,-1]

modernDistMatrixBray <- vegan::vegdist(modernData, method = "bray", binary = TRUE)

modern_fBinary <- pvclust::pvclust(t(modernData), method.hclust = "average", method.dist = "binary", nboot = 1000, parallel = TRUE)

### plot the dendrogram
pdf(file = "modern_faunalSimBinary.pdf", height = 10, width = 14)
plot(modern_fBinary, main = "Modern faunal similarity")
dev.off()
