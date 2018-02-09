# Instructor: McHale, Michael, Research Hydrologist, USGS
# Code transcribed by: Charles Stoll
# R-class Date: 02/09/2018
# Course: Intro to mapping


################################################################
# Set library packages for script
################################################################
library(maps)
library(readxl)
library(dplyr)
library(dataRetrieval)
library(maptools)
library(rgdal)
library(sp)

################################################################
# NOTES
################################################################
## There is a ggmap cheatsheet on the x drive
## Folder structuring for this exercise are as follows:
##  Working directory should be set to the parent folder housing data subfolders
##   Data subfolders should include: 
##     a "Data" folder for input data; 
##     an "Output" folder for data ouput; 
##     a "Scripts" folder for the class R.script
## 
################################################################
# Set lesson working directory
################################################################

# Set a working directory
setwd("C:/NYBackup/CStoll.CDrive/R_scripts/R_class")

################################################################
# Mapping with Base Map package
################################################################

# Pull in some data for plotting
sites <- read_excel("Data/QWsitesformap.xlsx") #<- Excel sheet of lesson data qwsites

# Display column names in site df
names(sites) 

################################################################
#
## An alternative way to display and work with df headers 
## is to use the colnames base funciton: e.g. colnames(sites)
#
################################################################

# Make a basic map using Base Map
map("state")

################################################################
# Mapping a specific region with Base Map package
################################################################

# Base map with a region defined
map("state", region="New York")

################################################################
# Adding a point feature to map with Base Map package
################################################################

# Add in a single point by specifying coordinates
points(x=-73.900654, y= 42.856486, pch=17, col="purple", cex=3)

################################################################
# Clearing existing map from plot window
################################################################

# Reset the plot window
dev.off()

## If you do not clear the plot window, the new map still overwrites
## the current map in plot window. The map that is generated 
## is visually confined to the plot window, and it will not automatically 
## update when the window is expanded; the map will need to be 
## regenerated to refresh the plot window

################################################################
# Mapping the continent US w/out state boundaries
################################################################

# Base Map the continent US without state boundaries
map("state", interior = F)

################################################################
# Adding point features from dataframe to map
################################################################

# Add points from sites DF
points(x=sites$longitude, y=sites$latitude, pch=20, col="blue")

################################################################
# Adding a title to map
################################################################
# Add a title
title(main="Map Example", sub="Here is a subtitle", cex.main=2, font.main=4, col.main="blue",
      cex.sub=1.25, font.sub=3, col.sub="red")

# Try adding a new title to map and see what happens
title(main="A New Title")

## Writing a title over a title does not erase the first title 
## on map. Instead it overlays them both. If you want to redo the 
## title, the map plot needs to regenerated fresh

# reset my plot window
dev.off()

################################################################
# Create map and save to .jpeg
################################################################

# Create ouput variables
mapname <- paste0("Output/MyTestMap.jpg")
jpeg(file=mapname, units="in", width=11, height=8.5, res=300)
dev.size("in")

# Create a map of PA WQ stations
map("state", region="Pennsylvania", fill=TRUE, col="gray96")

# Add a title to map
title(main="Pennsylvania", sub="Water Quality Sampling Stations", cex.main=2, font.main=4, col.main="blue",
      cex.sub=1.25, font.sub=3, col.sub="red")

# Add some points from our sites DF to map
points(x=sites$longitude, y=sites$latitude, pch=20, col="orange")

# Use the reset command to close the jpeg function and create the output
dev.off()

## It is critical to end this workflow with dev.off(). This instructs
## R to close the jpeg creation function and to produce output

################################################################
# Quick access to map package help file
################################################################
# get help on map
?map

################################################################
# Create map using multiple line types
################################################################

# Create map with nation boundaries in one linetype and states in another
map("state", interior = F)#<- Can substitute FALSE with F
map("state", boundary=FALSE, lty=2, add=TRUE)

# reset my plot window
dev.off()

# nation boundaries in one linetype and states in another V.2
## Line type 4 is what USGS uses for watershed outline
map("state", interior=F)
map("state", boundary = FALSE, lty=4, add=TRUE)

################################################################
# Access information embedded in the map objects; i.e. object attributes
################################################################

# Access the county names embedded in the object from the site DF
SJcouties <- map("county", "washington.san", names = T, plot = F)#<- Counties in the San Juan Islands, Washington State
NYcounties <- map("county", "New York", names=T, plot=F)#<- Counties in the state of New York

################################################################
# Use dataRetrieval tool to pull data from NWIS server
################################################################

## Water Quality portal has all USGS, EPA, etc water quality data
## Lesson QWsites.xlsx uses station id numbers not in QWsitesformap.xlsx

# Create variable to for QWsites.xlsx excel table
QWsites <- read_excel("Data/QWsites.xlsx", col_types = c(rep("text",3)))

# Assign station id's in DF to variable
siteNumbers <- QWsites$station_id

# Use site number variable in dataRetrieval to pull and map data
##parameter code 00681 = Organic carbon, water, filtered, milligrams per liter
qwdata <- readNWISqw(siteNumbers, parameterCd = "00681", startDate="2009-10-01", endDate="2010-09-30",
                       expanded = F, tz = "America/New_York")

################################################################
# Access metadata associated with NWIS data
################################################################

# Display attributes of qwdata
attr(qwdata, "siteInfo")
# Display names of attributtes file associated with qwdata "siteInfo"
names(attributes(qwdata))
qwDataSiteInfo <- attr(qwdata, "siteInfo")

################################################################
# Make map using NWIS data and attributes
################################################################

# Map data that was pulled from NWIS
map("state", interior = F)
map("state", boundary=F, lty=2, add=T)
points(x=qwDataSiteInfo$dec_long_va, y=qwDataSiteInfo$dec_lat_va, pch=20, col="mediumorchid4")

# Now let's use some code to limit the sites we are showing
qwDataHdoc <- filter(qwdata, qwdata$p00681>20) #<- Constrainign doc to values greater than 20 in new DF

# Isolate the sites where doc is >20 into a list
HdocSites <- unique(qwDataHdoc$site_no)

# Filter sites in qwDataSiteInfor dF to match those in HdocSites df
qwDataSiteInfoHdoc <- filter(qwDataSiteInfo, qwDataSiteInfo$site_no %in% HdocSites)

## There are multple ways to do the previous steps, the purpose of using this method was to ensure
## users were familiar with the %in% base funciton
## One example of an alternative:  
##    HdocSites <- qwDataHdoc[!duplicated(qwDataHdoc$site_no),]
##    qwDataSiteInfoHdoc <- filter(qwDataSiteInfo, qwDataSiteInfo$site_no %in% HdocSites)

# Map site locations 
map("state", interior=F)
map("state", boundary=F, lty=2, add=T)
points(x=qwDataSiteInfo$dec_long_va, y=qwDataSiteInfo$dec_lat_va, pch=20,
       col="mediumorchid4")

# Overlay qw sites that are >20 using different color point feature
points(x=qwDataSiteInfoHdoc$dec_long_va, y=qwDataSiteInfoHdoc$dec_lat_va, 
       pch=20, cex=2, col="black")


















