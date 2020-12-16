
## load gridded data
load("data/processed_data/dietal_annual_dc_gridded_pm25.rda")

## WGS84 -- the preferred CRS
crs_wgs84 <- CRS(SRS_string = "EPSG:4326")

## read in county shapefile
counties <- counties(state="11", cb=FALSE, year=2016)
counties <- as(counties, Class = "Spatial")
counties <- spTransform(counties, crs_wgs84)

## read in tract group shapefile
tracts <- tracts(state="11", cb=FALSE, year=2016)
tracts <- as(tracts, Class = "Spatial")
tracts <- spTransform(tracts, crs_wgs84)

## extract grid
pm25grid <- unique(pm25[,c("longitude","latitude","gridid")])
coordinates(pm25grid) <- ~ longitude + latitude
proj4string(pm25grid) <- crs_wgs84

## plot grid
plot(pm25grid, main="Di et al. (2019) Pollution Grid for Washington D.C.")
plot(counties, add=TRUE)

## create buffers around each monitor
pm25grid_sf <- st_as_sf(pm25grid) # convert to sf
pm25grid_proj <- st_transform(pm25grid_sf, 24878) # project using metric units. not sure about the EPSG code used here, from https://epsg.io/24878
buffer <- st_buffer(pm25grid_proj, dist = 500)

# reproject tracts
tracts_sf <- st_as_sf(tracts)
tracts_proj <- st_transform(tracts_sf, 24878)

## plot to check
plot(pm25grid_proj$geometry, pch = 4, col = "blue")
plot(buffer$geometry, add = T)
plot(tracts_proj$geometry, add = T, lwd = 3)

## find intersections
plot(tracts_proj$geometry[1,])
tract_intersections <- list()
tract_intersections[1] <- st_intersection(tracts_proj$geometry[1,], buffer)

st_intersection(tracts_proj$geometry[1,], buffer) # intersection
length(st_intersection(tracts_proj$geometry[1,], buffer)) # number of intersections with monitors
st_area(st_intersection(tracts_proj$geometry[1,], buffer)) #area of each intersection -- could use as weighting?

for (i in 1:nrow(tracts_proj)) {
  tract_intersections[i] <- st_intersection(tracts_proj$geometry[i,], buffer$geometry)
}
