# Author: Charles Stoll
# Date: 02.23.2018


#################################################################################
# GGMAP Notes:
#################################################################################
# ggmap is a package that is related to ggplot, both were written by Hadley Wicham.
# Becuase of this, you have the full power of ggplot and it uses the same arguments as ggplot.
# Other than the ggmap vignette, there isn't a lot of documentation for ggmap
#
# Materials from USGS found in X drive: X:\R Statistics\Mapping
#
# The basic idea behind ggmap is to download a map image, plot it as a layer,
# and then overlay data on top of that image
#
# There are 2 main steps:
# 1. Download the image(s) and format them for plotting (get_map())
# 2. Making the plots(s) and using ggmap() or qmap(), qmplot() functions
# An important note: ggmap requires that all data are in the same projection, just like ArcMap
# If you do not specify the spatial data properly, ggmap is not going to correct it and there 
# could be error introduced into your analysis
#
#####

#################################################################################
# Set working directory
#################################################################################
setwd("C:/NYBackup/CStoll.CDrive/R_scripts/R_class/Introduction_to_ggmap/")

#################################################################################
# Open libraries
#################################################################################
library(ggmap)

#################################################################################
# Import data
#################################################################################
# Define the column classes of my site data file
colTypes <- c("character", "character", "numeric", "numeric", "character")
# Import the file
mapsites <- read.csv(file = "Input/Intro_to_GGMAP_mapSites.csv", colClasses = colTypes, stringsAsFactors = F)

#################################################################################
# Different ways to Enter a location for a map
#################################################################################
# To get a map we need a location
# 1. Use and Address
myLocation <- "Albany, NY"

# 2. A Long/Lat
myLocation_point <- c(long=-74.380519, lat = 42.074202)

# 3. A bounding box (must be in format: long, lat, long, lat)
myLocation_bounding_box <- c(-80.040921, 39.747047, -71.214456, 45.162553)

# Center of the US
# Lebanon, KS
myLocation_US_center <- c(lon = -98.5795, lat = 39.8283)

#################################################################################
# Create and display a map using stamen map type
#################################################################################
# To get a map use getmap() function

# Different Map types
# There are 4 different map types
# Refer to cheat sheets for information
#
# 1. Stamen
# 2. Google
# 3. OSM (Open Street Maps)
# 4. cloudmade (requires that you know the API of the map)

## Example using a staman map type
myMap_stamen <- get_map(location = myLocation_bounding_box, source = "stamen", maptype = "toner", crop = F) #zoom = 10
# Be careful using the zoom parameter in get_map() function
# if you want to make a higher resolution map, reduce the 
# size of your bounding box to a more appropriate size
#Display created map
ggmap(myMap_stamen)

#################################################################################
# Create and display a map using a google map
# use a more specifiec get_map() function; i.e. get_googlemap()
#################################################################################
myMap_google <- get_googlemap(center = myLocation_point, source="google", zoom = 6, maptype = "terrain", crop = F)
ggmap(myMap_google)

#################################################################################
# Adjust map properties
#################################################################################
# Turn off devtools
dev.off()
# Assign map to a variable so that you can overlay points
myMapTest <- ggmap(myMap_google)
# Add points and color them; color based on coordinate system of point
myMapTest <- myMapTest + geom_point(data=mapsites, aes(x = dec_long_va, y = dec_lat_va, color = coord_datum_cd),
                                     size = 3, shape = 20, alpha = 1)
# Display map with points
myMapTest

# Change name of axis labes; y on left of map, x on bottom
myMapTest <- myMapTest + labs(x = "Longitude", y ="Latitude")
# Assign specific color to point features
myMapTest <- myMapTest + scale_color_manual(values = c("NAD27" = "blue", "NAD83"="red"))
# Add a title to the map
myMapTest <- myMapTest + ggtitle("Northeastern HBN sites")
# Display the map
myMapTest 

#################################################################################
# Save map as multiple outputs
#################################################################################
# Name of map output as jpg
myTestmapNam_JPG <- paste0("Output/NEHBNsites_example_output.jpg")
# Name of map output as pdf
myTestmapName_PDF <- paste0("Output/NEHBNsites_example_output.pdf")
# Save map to output folder
ggsave(myTestmapNam_JPG)
ggsave(myTestmapName_PDF)

#################################################################################
# END
#################################################################################