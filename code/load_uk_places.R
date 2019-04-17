#
# based on https://nsaunders.wordpress.com/2019/04/03/mapping-the-vikings-using-r/
#

library(tidyverse)

#  import the UK places data
places <- 
  readr::read_csv("https://opendata.arcgis.com/datasets/a6c138d17ac54532b0ca8ee693922f10_0.csv?outSR=%7B%22latestWkid%22%3A27700%2C%22wkid%22%3A27700%7D") %>%
  # only keep locations
  dplyr::filter(descnm == "LOC") %>%
  # only keep required columns
  dplyr::select(place15nm, lat, long_) %>%
  # correct lat/lon for places like Tregonissey
  dplyr::mutate(latitude  = dplyr::if_else(lat < 0, long_, lat),
                longitude = dplyr::if_else(lat < 0, lat, long_)) %>%
  # rename some columns
  dplyr::rename(name = place15nm) %>%
  # keep 
  dplyr::select(name, latitude, longitude)
  
glimpse(places)


# and finally save the data frame with places that is required by the "zellig.R" script!
save(places, 
     file = "./data/placenames_uk.RData")

