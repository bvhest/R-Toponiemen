#' The single-file, 'source'-able version of https://github.com/hrbrmstr/zellingenach
#' More info here: http://bit.ly/zellingenach
#' By @hrbrmstr (2016)
#' MIT LICENSE 

# NOTE THAT YOU NEED INTERNET ACCESS TO RUN THIS SCRIPT
# it pulls the three necessary files (only once) from my web site

library(V8)
library(dplyr)
library(stringi)
library(ggplot2)
library(ggthemes)
library(ggalt) # devtools::install_github("hrbrmstr/ggalt")
library(viridis)
library(sp)
library(rgeos)
library(raster)
library(scales)
library(pbapply)
library(htmltools)
library(svglite)
library(tidyr)
# toevoegingen
library(XML)
library(ggmap)


rm(list=ls()) 

ct <- v8()
ct$source("./data/suffixlist_is.js")

#' Retrieve suffix list as end-matching regexes
#'
#' A slightly modified version of the suffix group list from Moritz's post.
#' It's read in using the \code{V8} package since it was left as a javascript
#' data structure.
#'
#' @return A character vector of regular expressions
#' @export
suffix_regex <- function() {
  sprintf("(%s)$", sapply(ct$get("suffixList"), paste0, collapse = "|"))
}

#' Retrieve suffix list as a list of vectors with suffix names
#'
#' A slightly modified version of the suffix group list from Moritz's post.
#' It's read in using the \code{V8} package since it was left as a javascript
#' data structure.
#'
#' @return A list of suffix character vectors
#' @export
suffix_names <- function() {
  ct$get("suffixList") 
}

#' Retrieve town names and determine which suffix bucket they belong in
#'
#' The CSV file that Mortiz used is bundled with this package.
#'
#' It reads the names, determines which suffix group a town belongs in and
#' then filters out all the ones that weren't found.
#'
#' @param suf list of regular expressions to match suffixes
#' @return \code{data.frame} of enriched places
#' @note My version is more inclusive than Moritz's (if a town matches more
#'       than one suffix it will be counted in more than one suffix group).
#' @export
read_places <- 
  function(suf = suffix_regex()) {
   #plc <- read.csv("/data/placenames_is.csv", stringsAsFactors=FALSE, sep="~")
   load(file="./data/placenames_is.RData")
   #plc <- places[!is.na(places$lon), c("naam", "lat", "lon")]
   plc <- places
   plc$found <- ""

   lapply(suf, function(regex) {
    which(stri_detect_regex(plc$name, regex))
   }) -> matched_endings
   
   
   for(i in 1:length(matched_endings)) {
    where_found <- matched_endings[[i]]
    plc$found[where_found] <-
      paste0(plc$found[where_found], sprintf("%d|", i))
   }
   
   # dplyr::mutate(dplyr::filter(plc, 
   #                             found != ""), 
   #               found = sub("\\|$", 
   #                           "", 
   #                           found))

   plc <-
     plc %>%
     dplyr::filter(found != "") %>%
     dplyr::mutate(found = sub("\\|$", "", found)) %>%
#     dplyr::filter(found >= 50) %>%
     as.data.frame()
   
   return(plc)
}

#' Make a uniform hexgrid version of a GADM Germany shapefile
#'
#' This reads in an Admin 0 shapefile of Germany using \code{getData}
#' then turns that into a hexgrid map using built-in spatial routines.
#'
#' @return a SpatialPolygons hex grid
#' @export
create_hexgrid <- 
  function() {

  is_shp <- raster::getData("GADM", country = "ISL", level = 0, path = tempdir())

  is_hex_pts <- sp::spsample(is_shp, 
                             type = "hexagonal", 
                             n = 10000, 
                             cellsize = 0.19,
                             offset=c(0.5, 0.5), 
                             pretty = TRUE)

  sp::HexPoints2SpatialPolygons(is_hex_pts)

}

#' Do all the hard work
#'
#' This should be called to build the data structures for the ultimate
#' map / HTML page production.
#'
#' This function reads in the places data, builds the base map hexgrid,
#' identifies which towns belong in which hex, assigns the colors
#' (assignment is based on a log scale of the colors vs an pre-determined
#' cutoff in the pure-javascript version) then builds a \code{list}
#' with an element for each suffix group that contains the title,
#' subtitle, ggplot2 object and count of towns.
#'
#' @param verbose tell folks what's going on
#' @return a \code{list} with an element for each suffix group that
#'   contains the title, subtitle, ggplot2 object and count of towns.
#' @export
make_maps <- 
  function(verbose = TRUE) {

  if (verbose) message("Reading & processing towns")
  plc <- read_places()

  if (verbose) message("Creating the map hexes")
  hex_polys_is <- create_hexgrid()


  # we'll need this for the plotting
  if (verbose) message("Making the gridded heat maps")
  is_hex_map <- ggplot2::fortify(hex_polys_is)

  # find the hex each town is in
  if (verbose) message("Finding the hex each town is in")
  plc$id <- sprintf("ID%s",
                    sp::over(sp::SpatialPoints(sp::coordinates(plc[,c(3,2)]), # select lon, lat
                                               sp::CRS(sp::proj4string(hex_polys_is))),
                             hex_polys_is))

  # count up all the towns in each hex (by line ending grouping)
  if (verbose) message("Counting up all the towns in each hex (by line ending grouping)")
  plc <- tidyr::separate(plc, found, c("f1", "f2", "f3"), sep = "\\|", fill = "right")
  plc <- tidyr::gather(plc, where, found, f1, f2, f3)
  plc <- dplyr::select(filter(plc, !is.na(found)), -where)
  is_heat <- dplyr::count(plc, found, id)

  # scale the values properly
  if (verbose) message("Scaling the values properly")
  is_heat$log <- log(is_heat$n)

  # assign colors to the mapped, scaled values
  if (verbose) message("Assigning colors to the mapped, scaled values")
  bin_ct <- 20
  no_fill <- "#fde725"
  vir <- rev(viridis::viridis_pal()(bin_ct+1))
  vir_col <- col_bin(vir[2:length(vir)],
                     range(is_heat$log),
                     bins = bin_ct,
                     na.color = no_fill)

  is_heat$fill <- vir_col(is_heat$log)

  # we'll use a proper projection for Germany (change for Iceland)
  if (verbose) message("Applying a proper projection")
  epsg_31468 <- "+proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=4500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs"
  
  suf_nam <- suffix_names()
  max_list <- length(suf_nam)

  lapply(1:max_list, function(i) {

    if (verbose) message(paste("\n\nprocessing:", suf_nam[[i]][1]))
    
    cur_heat <- dplyr::filter(is_heat, found == i)
    
    if (verbose) message(paste("\ncur_heat = ",cur_heat))
    
    gg <- ggplot()
    gg <- gg + geom_map(data = is_hex_map, 
                        map = is_hex_map,
                        aes(x = long, y = lat, map_id = id),
                        size = 0.975,
                        color = "#ffffff", 
                        fill = no_fill)
    gg <- gg + geom_map(data = cur_heat,
                        map = is_hex_map,
                        aes(fill = fill, map_id = id),
                        color = "#ffffff",
                        size = 0.975)
    gg <- gg + scale_fill_identity(na.value = no_fill)
    gg <- gg + coord_proj(epsg_31468)
    gg <- gg + theme_map()
    gg <- gg + theme(strip.background = element_blank())
    gg <- gg + theme(strip.text = element_blank())
    gg <- gg + theme(legend.position = "right")
    
    list(title = sprintf("&#8209;%s", suf_nam[[i]][1]),
         subtitle = ifelse(length(suf_nam[[i]]) <= 1, 
                           "",
                           paste0(sprintf("&#8209;%s", suf_nam[[i]][2:length(suf_nam[[i]])]),
                                  collapse = ", ")),
         total = sum(cur_heat$n),
         gg = gg)

  })

}

# one more global, used to not recreate data that takes a bit to process
syl_maps <- NULL

#' Call this function to make magic happen!
#'
#' This is the function that makes the HTML page with the maps.
#'
#' It calls \code{make_maps()} if it hasn't been called before and
#' caches the resultant data, then builds the HTML page.
#'
#' @param output_file where to save the built HTML (optional)
#' @export
display_maps <- 
  function(output_file = NULL) {

  # don't recreate the data
  if (is.null(syl_maps)) 
    syl_maps <- make_maps()

  if (!file.exists("./css/styles.html"))
    download.file("http://rud.is/zellingenach/styles.html", "./css/styles.html")
  
  # message("pos 2.5")
  # pblapply(1:length(syl_maps), function(i) {
  #   print(syl_maps[[i]]$gg)
  # })
  
  message("\n\ncreating HTML")
  the_maps <-
    tags$html(
      tags$head(includeHTML("./css/styles.html")),
      tags$body(
        h1("-bær, -bakki, -borg"),
        p(HTML("Some <a href='https://nl.wikipedia.org/wiki/Toponiem'>Icelandic toponyms</a> showing the origin of different Icelandic names.<br/><br/>Credits: visualisation is based on the inspiring publications <a href='http://truth-and-beauty.net/experiments/ach-ingen-zell/'>-ach, -inge, -zell</a> and <a href='http://rud.is/b/2016/01/03/zellingenach-a-visual-exploration-of-the-spatial-patterns-in-the-endings-of-german-town-and-village-names-in-r/'>Zellingenach</a>.<br/><br/>")),
        pblapply(1:length(syl_maps), function(i) {
          message(paste("\n\nplotting:", syl_maps[[i]]$title))
          div(class="map",
              h2(class="map", HTML(syl_maps[[i]]$title)),
              h4(class="map", HTML(syl_maps[[i]]$subtitle)),
              suppressMessages(svglite::htmlSVG(print(syl_maps[[i]]$gg))),
              h3(class="map", sprintf("%s places", comma(syl_maps[[i]]$total)))
            )
        })
      )
    )

  message("pos 4")
  html_print(the_maps, background = "#dfdada;")

  if (!is.null(output_file)) 
    htmltools::save_html(html = the_maps, 
                         file = output_file, 
                         background = "#dfdada;")
}


# after all the hard work, finally... 
# output to file is no longer working
display_maps()
