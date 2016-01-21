
setwd("C:/Projects/R/plaatsnamenNL")

#  import the NL places data
data <- read.delim(file="./data/NL.txt", heade =FALSE)
colnames(data) <- c("geonameid", "name", "asciiname", "alternatenames", "latitude", "longitude", "feature.class", "feature.code", "country.code", "cc2", "admin1.code", "admin2.code", "admin3.code", "admin4.code", "population", "elevation", "dem", "timezone", "modification.date")
# create one code for all places
data$type <- substr(data$feature.code, 1, 3)
# and subset to only keep the places and the required columns
places <- subset(data, type=='PPL', select = c(name, latitude, longitude))

# and finally save the data frame with places that is required by the "zellig.R" script!
save(places, file="placenames_nl.RData")

