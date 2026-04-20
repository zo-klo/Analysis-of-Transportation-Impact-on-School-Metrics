
# Spatial data cleaning and preparation pipeline for analyzing relationships between
# transit access, neighborhood and school characteristics, and school output (test scores) in NYC.

# packages
library(sf)
library(dplyr)
library(readr)
library(readxl)
library(tmap)
library(ggplot2)
library(units)
library(stringr)
library(fuzzyjoin)
library(nngeo)
library(tidyr)

#set working directory
setwd("~/Downloads") #Your preferred directory here

# Load school shapefile 
path_schools_shp <- st_read("SchoolPoints_APS_2024_08_28/SchoolPoints_APS_2024_08_28.shp") 

# Load SAT CSV (File from NYC Open data)
path_sat_csv <- read_csv("~/Downloads/2012_SAT_Results_20251109.csv") 
sat <- path_sat_csv

# Load transit CSVs
subways_csv <- read_csv("~/Downloads/MTA_Subway_Stations_20251109.csv")
bus_csv <- read_csv("~/Downloads/Bus_Stop_Shelter_20251109.csv")


#Load ACS and NYC tracts 
#Load ACS CSV
acs_df <- read.csv("~/Downloads/R50057829_SL140.csv") %>% 
  mutate(Geo_ID_CLEAN = as.character(Geo__geoid_))  # ensure GEOID is character

# Load NYC census tract shapefile
nyc_tracts <- st_read("~/Downloads/tl_2023_36_tract/tl_2023_36_tract.shp")

#join ACS and Tracts
nyc_tracts_acs <- nyc_tracts %>%
  mutate(GEOID = as.character(GEOID)) %>%   # ensure same type
  left_join(acs_df, by = c("GEOID" = "Geo_ID_CLEAN"))


# Load SQR summary sheet only (school average test scores) 
file_path <- "~/Downloads/202324-hs-sqr-results.xlsx"

sqr_df <- read_excel(file_path, sheet = 1, skip = 3) %>%  # only first sheet
  mutate(DBN_clean = toupper(trimws(DBN)))                # clean DBN

# Filter schools to only those in summary sheet
path_schools_hs <- path_schools_shp %>%
  mutate(ATS_clean = toupper(trimws(ATS))) %>%
  filter(ATS_clean %in% sqr_df$DBN_clean)


# Convert transit CSVs to sf (make spatial) 

subways <- st_as_sf(subways_csv,
                    coords = c("GTFS Longitude", "GTFS Latitude"),
                    crs = 4326) 

busshelters <- st_as_sf(bus_csv,
                        coords = c("Longitude", "Latitude"),
                        crs = 4326)

# Transform all layers to same CRS
target_crs <- 3857

schools <- st_transform(path_schools_hs, crs = target_crs)
subways <- st_transform(subways, crs = target_crs)
busshelters <- st_transform(busshelters, crs = target_crs)


# Count unique subway train lines within 0.5 and 1 mile radius of each school

# Define buffer distances (meters)
mile_0_5 <- units::set_units(0.5, "mi") |> 
  units::set_units("m") |> 
  units::drop_units()

mile_1 <- units::set_units(1, "mi") |> 
  units::set_units("m") |> 
  units::drop_units()

# Create buffers
schools_buf_05 <- st_buffer(schools, dist = mile_0_5)
schools_buf_1  <- st_buffer(schools, dist = mile_1)

# 0.5 mile: count unique train lines within buffer
lines_05 <- st_join(
  schools_buf_05,
  subways,
  join = st_intersects,
  left = TRUE
) %>%
  st_drop_geometry() %>%
  filter(!is.na(`Daytime Routes`)) %>%
  separate_rows(`Daytime Routes`, sep = " ") %>%   # split routes
  distinct(ATS, `Daytime Routes`) %>%              # unique lines per school
  count(ATS, name = "subway_lines_05mi")

# 1 mile: count unique train lines within buffer
lines_1 <- st_join(
  schools_buf_1,
  subways,
  join = st_intersects,
  left = TRUE
) %>%
  st_drop_geometry() %>%
  filter(!is.na(`Daytime Routes`)) %>%
  separate_rows(`Daytime Routes`, sep = " ") %>%
  distinct(ATS, `Daytime Routes`) %>%
  count(ATS, name = "subway_lines_1mi")

# Join back to schools
schools <- schools %>%
  left_join(lines_05, by = "ATS") %>%
  left_join(lines_1,  by = "ATS") %>%
  mutate(
    subway_lines_05mi = ifelse(is.na(subway_lines_05mi), 0, subway_lines_05mi),
    subway_lines_1mi  = ifelse(is.na(subway_lines_1mi),  0, subway_lines_1mi)
  )

# Compute nearest transit distances
# Nearest subway
nn_subway <- st_nn(schools, subways, k = 1, returnDist = TRUE)
schools$nearest_subway_dist_m <- sapply(nn_subway$dist, `[`, 1)

# Nearest bus
nn_bus <- st_nn(schools, busshelters, k = 1, returnDist = TRUE)
schools$nearest_bus_dist_m <- sapply(nn_bus$dist, `[`, 1)

# Convert to km
schools <- schools %>%
  mutate(
    nearest_subway_dist_km = nearest_subway_dist_m / 1000,
    nearest_bus_dist_km    = nearest_bus_dist_m / 1000
  )

# Clean SAT dataset IDs

sat <- sat %>%
  mutate(DBN_clean = toupper(trimws(DBN)))  # replace DBN with actual SAT column name

schools <- schools %>%
  mutate(ATS_clean = toupper(trimws(ATS)))

# Using a left join, join SAT data to schools data
schools_joined <- left_join(schools, sat, by = c("ATS_clean" = "DBN_clean"))

# Create Total SAT Score variable
schools_joined <- schools_joined %>%
  mutate(across(ends_with("Score"), ~ as.numeric(gsub(",", "", .)))) %>%
  mutate(Total_SAT_Score =
           `SAT Critical Reading Avg. Score` +
           `SAT Math Avg. Score` +
           `SAT Writing Avg. Score`)

# Join SQR summary sheet to school data
schools_joined <- left_join(schools_joined, sqr_df, by = c("ATS_clean" = "DBN_clean"))

schools_joined <- st_transform(schools_joined, st_crs(nyc_tracts_acs))
schools_joined <- st_join(schools_joined, nyc_tracts_acs, join = st_within)

schools_joined<- schools_joined %>% 
  rename(Med_income = SE_A14006_001)

schools_joined<-  schools_joined %>% 
  rename(child_pov = SE_A13003A_002)



# Rename distance columns for readability

schools_shp <- schools_joined %>%
  rename(
    nrst_sub_m = nearest_subway_dist_m,
    nrst_bus_m = nearest_bus_dist_m,
    nrst_sub_km = nearest_subway_dist_km,
    nrst_bus_km = nearest_bus_dist_km
  )


# Select variables for export
schools_shp <- schools_joined %>%
  select(`Percent English Language Learners`, Med_income, child_pov, `Percent Students with IEPs`, `Economic Need Index`, `Instruction/Learning Environment - School Percent Positive`, `Performance Score`,
         nearest_subway_dist_km, nearest_subway_dist_m,subway_lines_05mi,subway_lines_1mi, Name, Latitude, Longitude, Total_SAT_Score, GEOID, geometry, INTPTLAT, INTPTLON, ATS)

# Rename columns for readability
schools_shp <- schools_shp %>%
  rename(
    nrst_sub_km = nearest_subway_dist_km,
    nrst_sub_m  = nearest_subway_dist_m,
    ELL_pct     = `Percent English Language Learners`,
    IEP_pct     = `Percent Students with IEPs`,
    EconNeed    = `Economic Need Index`,
    InstrEnv    = `Instruction/Learning Environment - School Percent Positive`,
    PerfScore   = `Performance Score`,
    sub_line_05 = `subway_lines_05mi`,
    sub_line_1mi = `subway_lines_1mi`
  )

# Export final shapefile for analysis using other software (GeoDA, QGIS) 

output_path <- "[ADD YOUR PATH HERE]"

# Remove existing shapefile components if they exist
if (file.exists(output_path)) {
  unlink(c(
    "[ADD YOUR PATH HERE]/schools_shap.shp", #update to match your path
    "[ADD YOUR PATH HERE]/schools_shap.shx",
    "[ADD YOUR PATH HERE]/schools_shap.dbf",
    "[ADD YOUR PATH HERE]/schools_shap.prj"
  ))
}

# Write new shapefile
st_write(schools_shp, output_path, driver = "ESRI Shapefile")

#Export tract geopackage
#filter for only NYC
nyc_counties <- c("005", "047", "061", "081", "085")

#export your geopackage 
nyc_tracts_acs <- nyc_tracts_acs %>%
  filter(COUNTYFP %in% nyc_counties) #make sure we're only exporting NYC counties 

st_write(
  nyc_tracts_acs,
  "[ADD YOUR PATH HERE]/nyc_tracts.gpkg", #update to match your path
  delete_layer = TRUE
)




