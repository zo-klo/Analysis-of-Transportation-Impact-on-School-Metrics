
library(sf)
library(spdep)
library(dplyr)

setwd("~/Downloads")
school_shap_analys <- st_read("schools_shap.shp")


gpkg_path <- "~/Downloads/GISfinal_joined_tract+points.gpkg"

data <- st_read(gpkg_path)

st_geometry_type(data)

schoolshappath <- "gis_final_geoda.csv"
school_shap <- st_read(schoolshappath)


library(tidyverse)


# Correct function definition
read_regression_txt <- function(file_path) {
  lines <- readLines(file_path)
  
  # Find the "Coefficients" section
  start <- which(grepl("Coefficients", lines, ignore.case = TRUE)) + 1
  coef_lines <- lines[start:length(lines)]
  
  # Keep lines with numbers (skip empty lines)
  coef_lines <- coef_lines[grepl("\\S", coef_lines)]
  
  # Split each line by whitespace
  coef_split <- str_split_fixed(coef_lines, "\\s+", 5)
  
  # Convert to tibble and name columns
  coef_df <- as_tibble(coef_split, .name_repair = "unique") %>%
    rename(Term = V1, Estimate = V2, Std.Error = V3, t.value = V4, p.value = V5) %>%
    mutate(across(c(Estimate, Std.Error, t.value, p.value), as.numeric),
           File = basename(file_path)) # keep track of source file
  
  return(coef_df)
}

library(tidyverse)
folder_path <- "~/Desktop/GIS/GIS Final Project"
files <- list.files(folder_path, pattern = "\\.txt$", full.names = TRUE)

all_results <- map_df(files, read_regression_txt)





#create spatial weights
nb_q <- poly2nb(data, queen = TRUE)
lw_q <- nb2listw(nb_q, style = "W", zero.policy = TRUE)

#LISA
lisa <- localmoran(
  data$`Performance Score`,
  lw_q,
  zero.policy = TRUE
)

schools_joined$lisa_I <- lisa[, "Ii"]
schools_joined$lisa_p <- lisa[, "Pr(z > 0)"]
