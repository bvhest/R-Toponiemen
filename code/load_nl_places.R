library(tidyverse)

#  import the NL places data
data <- 
  read.delim(file="./data/NL.txt", header = FALSE) %>%
  # only keep locations
  dplyr::mutate(type = substr(V8, 1, 3)) %>%
  dplyr::filter(type == 'PPL') %>%
  # only keep required columns
  dplyr::select(V2, V5, V6) %>%
  # rename those columns
  dplyr::rename(name = V2, 
                latitude = V5, 
                longitude = V6)

# and finally save the data frame with places that is required by the "zellig.R" script!
save(places, 
     file = "./data/placenames_nl.RData")

