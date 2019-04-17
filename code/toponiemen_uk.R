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


ct <- v8()
if (!file.exists("./data/suffixlist_uk.js"))
  download.file(url="./data/suffixlist_uk.js", destfile="./data/suffixlist_uk.js")
ct$source("./data/suffixlist_uk.js")

#' Retrieve suffix list as end-matching regexes
#'
#' A slightly modified version of the suffix group list from Moritz's post.
#' It's read in using the \code{V8} package since it was left as a javascript
#' data structure.
#'
#' @return A character vector of regular expressions
#' @export
suffix_regex <- function() {
  sprintf("(%s)$", sapply(ct$get("suffixList"), paste0, collapse="|"))
}

#' Retrieve suffix list as a list of vectors with suffix names
#'
#' A slightly modified version of the suffix group list from Moritz's post.
#' It's read in using the \code{V8} package since it was left as a javascript
#' data structure.
#'
#' @return A list of suffix character vectors
#' @export
suffix_names <- function() { ct$get("suffixList") }

#' add geo-coordinates based on town names
#'
#' @param df with place names and postal codes
#' @return \code{data.frame} of enriched places
#' @export
add.geoCoordinates <- function(x) {
   
   if (!("lon" %in% names(x))) {
      x$lon <- NA
      x$lat <- NA
   }
   j <- 0
   jMax <- geocodeQueryCheck()
   for (i in 1:nrow(x)) { # the Google Maps api limits to 2500 queries a day.
      if (is.na(x$lon[i]) & j < jMax) {
         j <- j+1
         valor <- geocode(paste(x$naam[i],x$provincie[i],sep=","))
         x$lon[i] <- valor$lon
         x$lat[i] <- valor$lat
      }
   }
   return(x)
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

   if (!file.exists("./data/placenames_uk.RData")) {
      #####################################################################################
      # load data from internet:
      #####################################################################################
      # build the URL
      url <- "http://home.kpn.nl/pagklein/almanak.html"
      
      # read the tables and select the one that has the most rows
      tables <- readHTMLTable(url)
      n.rows <- unlist(lapply(tables, function(t) dim(t)[1]))
      #tables[[which.max(n.rows)[[1]]]]
      
      # select the table we need (the "ledenlijst") - read as a dataframe
      my.table <- tables[[which.max(n.rows)+1]]
      colnames(my.table) <- c("code","naam", "postcode", "gemeente", "provincie")
      # first some data cleaning:
      my.table$code <- as.character(my.table$code)
      my.table$naam <- as.character(my.table$naam)
      my.table$postcode <- as.character(my.table$postcode)
      my.table$gemeente <- as.character(my.table$gemeente)
      my.table$provincie <- as.character(my.table$provincie)
      my.table$postcode <- gsub("–","-",my.table$postcode)
      my.table$provincie <- gsub("Fryslân","Friesland",my.table$provincie)
      my.table <- my.table[complete.cases(my.table$naam),]
      
      write.table(my.table, "/data/placenames_uk.csv", sep="~")
      remove(my.table,n.rows,url,tables)
      
      # add geo-coordinates
      places <- add.geoCoordinates(my.table)
      save(places, file="./data/placenames_uk.RData")
   }
   #plc <- read.csv("/data/placenames_uk.csv", stringsAsFactors=FALSE, sep="~")
   load(file="./data/placenames_uk.RData")
   #plc <- places[!is.na(places$lon), c("naam", "lat", "lon")]
   #colnames(plc) <- c("name", "latitude", "longitude")
   plc <- places

   lapply(suf, function(regex) {
    which(stri_detect_regex(plc$name, regex))
   }) -> matched_endings
   
   plc$found <- ""
   
   for(i in 1:length(matched_endings)) {
    where_found <- matched_endings[[i]]
    plc$found[where_found] <-
      paste0(plc$found[where_found], sprintf("%d|", i))
   }
   
   dplyr::mutate(dplyr::filter(plc, found != ""), found=sub("\\|$", "", found))

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

  de_shp <- raster::getData("GADM", country="GBR", level=0, path=tempdir())

  de_hex_pts <- sp::spsample(de_shp, type="hexagonal", n=10000, cellsize=0.19,
                             offset=c(0.5, 0.5), pretty=TRUE)

  sp::HexPoints2SpatialPolygons(de_hex_pts)

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
  hex_polys_uk <- create_hexgrid()

  if (verbose) message("Making the gridded heat maps")

  # we'll need this for the plotting
  de_hex_map <- ggplot2::fortify(hex_polys_uk)

  # find the hex each town is in
  plc$id <- sprintf("ID%s",
                    over(SpatialPoints(coordinates(plc[,c(3,2)]), # select lon, lat
                                       CRS(proj4string(hex_polys_uk))),
                         hex_polys_uk))

  # count up all the towns in each hex (by line ending grouping)
  plc <- tidyr::separate(plc, found, c("f1", "f2", "f3"), sep="\\|", fill="right")
  plc <- tidyr::gather(plc, where, found, f1, f2, f3)
  plc <- dplyr::select(filter(plc, !is.na(found)), -where)
  de_heat <- dplyr::count(plc, found, id)

  # scale the values properly
  de_heat$log <- log(de_heat$n)

  # assign colors to the mapped, scaled values
  bin_ct <- 20
  no_fill <- "#fde725"
  vir <- rev(viridis::viridis_pal()(bin_ct+1))
  vir_col <- col_bin(vir[2:length(vir)],
                     range(de_heat$log),
                     bins=bin_ct,
                     na.color=no_fill)

  de_heat$fill <- vir_col(de_heat$log)

  # we'll use a proper projection for Germany
  epsg_31468 <- "+proj=tmerc +lat_0=0 +lon_0=12 +k=1 +x_0=4500000 +y_0=0 +ellps=bessel +datum=potsdam +units=m +no_defs"

  suf_nam <- suffix_names()

  lapply(1:length(suf_nam), function(i) {

    cur_heat <- dplyr::filter(de_heat, found==i)

    gg <- ggplot()
    gg <- gg + geom_map(data=de_hex_map, map=de_hex_map,
                        aes(x=long, y=lat, map_id=id),
                        size=0.6, color="#ffffff", fill=no_fill)
    gg <- gg + geom_map(data=cur_heat, map=de_hex_map,
                        aes(fill=fill, map_id=id),
                        color="#ffffff", size=0.6)
    gg <- gg + scale_fill_identity(na.value=no_fill)
    gg <- gg + coord_proj(epsg_31468)
    gg <- gg + theme_map()
    gg <- gg + theme(strip.background=element_blank())
    gg <- gg + theme(strip.text=element_blank())
    gg <- gg + theme(legend.position="right")
    
    list(title=sprintf("&#8209;%s", suf_nam[[i]][1]),
         subtitle=ifelse(length(suf_nam[[i]])<=1, "",
                         paste0(sprintf("&#8209;%s", suf_nam[[i]][2:length(suf_nam[[i]])]),
                                collapse=", ")),
         total=sum(cur_heat$n),
         gg=gg)

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
  
  tags$html(
    tags$head(includeHTML("./css/styles.html")),
    tags$body(
      h1("-thorpe, -ness, -by"),
      p(HTML("Some <a href='https://nl.wikipedia.org/wiki/Toponiem'>English toponyms</a> showing the <a href='https://www.jorvikvikingcentre.co.uk/the-vikings/viking-place-names/'>Viking-heritage</a>.<br/>Credits: visualisation is based on the inspiring publications <a href='http://truth-and-beauty.net/experiments/ach-ingen-zell/'>-ach, -inge, -zell</a> and <a href='http://rud.is/b/2016/01/03/zellingenach-a-visual-exploration-of-the-spatial-patterns-in-the-endings-of-german-town-and-village-names-in-r/'>Zellingenach</a>.<br/><br/>")),
      pblapply(1:length(syl_maps), function(i) {
        div(class="map",
            h2(class="map", HTML(syl_maps[[i]]$title)),
            h4(class="map", HTML(syl_maps[[i]]$subtitle)),
            suppressMessages(htmlSVG(print(syl_maps[[i]]$gg))),
            h3(class="map", sprintf("%s places", comma(syl_maps[[i]]$total))))
      })
    )
  ) -> the_maps

  html_print(the_maps, background = "#dfdada;")

  if (!is.null(output_file)) 
    htmltools::save_html(html = the_maps, 
                         file = output_file, 
                         background = "#dfdada;")
}


# after all the hard work, finally...
display_maps("./output/toponiemen_uk.html")
