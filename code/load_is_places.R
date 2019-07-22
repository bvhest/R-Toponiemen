#
# based on https://nsaunders.wordpress.com/2019/04/03/mapping-the-vikings-using-r/
#

library(tidyverse)

#  import the UK places data
places <- 
  readr::read_delim("./data/STADFANG.dsv",
                    delim = "|") %>%
  # only keep locations
#  dplyr::filter(descnm == "LOC") %>%
  # only keep required columns
  dplyr::select(HEITI_NF, LAT_WGS84, LONG_WGS84) %>%
  # correct lat/lon for places like Tregonissey
  dplyr::mutate(latitude  = dplyr::if_else(LAT_WGS84 < 0, LONG_WGS84, LAT_WGS84),
                longitude = dplyr::if_else(LAT_WGS84 < 0, LAT_WGS84, LONG_WGS84)) %>%
  # rename some columns
  dplyr::rename(name = HEITI_NF) %>%
  # remove numbers from names:
  dplyr::mutate(name = gsub("[[:digit:]]+", "", name)) %>%
  # keep 
  dplyr::select(name, latitude, longitude)
  
glimpse(places)


# and finally save the data frame with places that is required by the "zellig.R" script!
save(places, 
     file = "./data/placenames_is.RData")

