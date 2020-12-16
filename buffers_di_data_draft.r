plot(counties)

plot(blocks)
str(blocks)

install.packages("geosphere")
library(geosphere)

# create df of centroids of each block
block_centroids <- centroid(blocks)
block_centroids <- as.data.frame(block_centroids)

# project block centroids
coordinates(block_centroids) <- block_centroids
proj4string(block_centroids) <- crs_wgs84
plot(block_centroids)

#block_centroids <- spTransform(block_centroids, crs_wgs84)
#grid_subset <- spTransform(grid_subset, crs_wgs84)

# add points corresponding to monitors
plot(grid_subset, col = "blue", pch = 20, add = TRUE)

# create 1km buffers around block centroids
#buffer <- gBuffer(block_centroids, width = 1, byid = FALSE)
#plot(buffer)

# convert to sf
block_centroids_sf <- st_as_sf(block_centroids, coords = c("longitude", "latitude"))
grid_subset_sf <- st_as_sf(grid_subset, coords = c("longitude", "latitude"))

# remove attributes
block_centroids_sf <- block_centroids_sf %>%
  select(-V1, -V2)

# transform to metric coordinate system
block_centroids_m <- st_transform(block_centroids_sf, 24878) #not sure about the EPSG code used here, from https://epsg.io/24878
grid_subset_m <- st_transform(grid_subset_sf, 24878)

# plot
plot(block_centroids_m$geometry, pch = 3, col = "red")
plot(grid_subset_m$geometry, add = T, col = "blue", pch = 20)

# # create buffer around block centroids
# buffer <- st_buffer(block_centroids_m, dist = 1000)
# buffer
# plot(buffer, add = T)
# 
# # find intersection
# intersection <- st_intersection(buffer[5,], grid_subset_m$geometry)
# plot(intersection)
# intersection
# plot(buffer[1,])
# plot(block_centroids_m, add = T)
# plot(grid_subset_m$geometry, add = T, col = "blue", pch = 20)

# actually, you don't need centroids...

blocks
plot(blocks)
blocks_sf <- st_as_sf(blocks)
blocks_sf

blocks_sf_proj <- st_transform(blocks_sf, 24878)
plot(blocks_sf_proj$geometry)
plot(grid_subset_m$geometry, add = T)

block_of_interest <- blocks_sf_proj$geometry[150,]
plot(block_of_interest)
intersection <- st_intersection(block_of_interest, grid_subset_m$geometry)
intersection
plot(intersection) # seems like block groups are too small for some of them to have intersections

# try with tracts, which are larger

## read in block group levels
pm25.tract <- read.csv("data/processed_data/dietal_annual_dc_tract_pm25.csv")
pm25.tract <- subset(pm25.tract, year %in% c("2016"))
names(pm25.tract)[2] <- "GEOID"

## read in tract group shapefile
tracts <- tracts(state="11", cb=FALSE, year=2016)
tracts <- as(tracts, Class = "Spatial")
tracts <- spTransform(tracts, crs_wgs84)
tracts <- merge(tracts, pm25.tract, by="GEOID")
tracts
names(tracts)

plot(tracts)
tracts_sf <- st_as_sf(tracts)
tracts_sf
names(tracts_sf)

tracts_sf_proj <- st_transform(tracts_sf, 24878)
plot(tracts_sf_proj["mean"])
plot(grid_subset_m$geometry, add = T)

tract_of_interest <- tracts_sf_proj$geometry[10,]
plot(tract_of_interest)
intersection <- st_intersection(tract_of_interest, grid_subset_m$geometry)
intersection
plot(intersection)
