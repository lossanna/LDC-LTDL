# Created: 2025-12-17
# Updated: 2026-01-06

# Purpose: Extract most recent treatment for each polygon that occupies unique space, 
#   and compile a list of LDC points that have only the most recent monitoring date
#   for plots that were sampled multiple times. 

# Input: Map_002 outputs.
# Output: Treatment info v003, LDC v003.


library(tidyverse)
library(readxl)

# Load data ---------------------------------------------------------------

# GIS exports
trt.union <- read_csv("data/GIS-exports/002_TrtPoly002-Union_export.csv")
trt.countoverlapping <- read_csv("data/GIS-exports/002_TrtPoly002-Union-CountOverlapping_export.csv")
trt.overlaptable <- read_csv("data/GIS-exports/002_TrtPoly002-Union-OverlapTable_export.csv")
trt.ldc.sjoin <- read_csv("data/GIS-exports/002_TrtPoly002_LDC_SpatialJoin_export.csv")
ldc.points <- read_csv("data/GIS-exports/002_LDC-points-WGS-1984_export.csv")
ldc.countoverlapping <- read_csv("data/GIS-exports/002_LDC002-CountOverlapping_export.csv")
ldc.overlaptable <- read_csv("data/GIS-exports/002_LDC002-OverlapTable_export.csv")

# Treatment info
treatment.info.002 <- read_csv("data/versions-from-R/05.3_Treatment-info_v002.csv")

# Geoindicators
geoindicators.raw <- read_csv("data/raw/LDC/geoindicators.csv")

# LDC data
gap <- read_csv("data/raw/LDC/data-gap.csv")
height <- read_csv("data/raw/LDC/data-height.csv")
lpi <- read_csv("data/raw/LDC/data-lpi.csv")
geospecies <- read_csv("data/raw/LDC/geospecies.csv")


# Treatment polygons ------------------------------------------------------

## Join Union, CountOverlapping, and OverlapTable -------------------------

# Join with OverlapTable
trt.join <- trt.union %>% 
  left_join(trt.overlaptable)

#   Look for NAs
apply(trt.join, 2, anyNA)
OT.missing <- trt.join %>% 
  filter(is.na(ObjectID_CountOverlapping)) # probably subset of same 224 as before from 05.2.R

# Remove NAs and join with CountOverlapping
#   Shape_Length & Shape_Area cols must be removed for ObjectID_CountOverlapping join to work
trt.join <- trt.join %>% 
  filter(!is.na(ObjectID_CountOverlapping)) %>% 
  select(-Shape_Length, -Shape_Area, -Acres, -created_date, -last_edited_date, -ORIG_NAME)
trt.join <- trt.join %>% 
  left_join(trt.countoverlapping)

#   Look for NAs
apply(trt.join, 2, anyNA)
  
# Remove unnecessary cols and rename COUNT_
trt.join <- trt.join %>% 
  select(-COUNT_FC, -Shape_Length, -Shape_Area) %>% 
  rename(treatment_count = COUNT_)


## Narrow down to treatment polygons with LDC points ----------------------

# Narrow down to polygons with LDC points
trt.poly.003 <- trt.join %>% 
  filter(ObjectID_Union %in% trt.ldc.sjoin$ObjectID_Union)

#   Look for NAs
apply(trt.poly.003, 2, anyNA)

#   Look for ObjectID_Union in OT.missing table that have LDC points
trt.ldc.sjoin %>% 
  filter(ObjectID_Union %in% OT.missing$ObjectID_Union) # none

# Reformat date cols
trt.poly.003 <- trt.poly.003 %>% 
  mutate(init_date_est = as.Date(init_date_est, format = "%m/%d/%Y"),
         comp_date_est = as.Date(comp_date_est, format = "%m/%d/%Y"))


## Extract rows of most recent treatment ----------------------------------

# Extract the most recent polygon(s) per overlap group
most.recent.trt003 <- trt.poly.003 %>%
  group_by(ObjectID_CountOverlapping) %>%
  filter(comp_date_est == max(comp_date_est)) %>%
  ungroup()
length(unique(trt.poly.003$ObjectID_CountOverlapping)) == nrow(most.recent.trt003) # FALSE
#   this means that there are some polygons that have the same comp_date_est, so multiple rows
#     for those cases are created

# Separate out polygons where there is only one most recent date for comp_date_est
mr.trt003.single <- most.recent.trt003 %>%
  group_by(ObjectID_CountOverlapping) %>%
  filter(n() == 1) %>%
  ungroup()


### Multiple polygons/rows for most recent date ---------------------------

# Separate out polygons where comp_date_est is the same for multiple rows
mr.trt003.multiple <- most.recent.trt003 %>%
  group_by(ObjectID_CountOverlapping) %>%
  filter(n() > 1) %>%
  ungroup()

# Separate overlapping polygons with multiple/same comp_date_est and same Treatment_Type
mr.trt003.multiple.same.trt <- mr.trt003.multiple %>% 
  group_by(ObjectID_CountOverlapping, Treatment_Type) %>% 
  filter(n() > 1) %>% 
  ungroup()

# Append entire treatment info table and write to CSV for further inspection
mr.trt003.multiple.same.trt <- mr.trt003.multiple.same.trt %>% 
  left_join(treatment.info.002) %>% 
  arrange(ObjectID_CountOverlapping)

# OUTPUT: Treatment polygons with multiple most recent comp_date_est and same Treatment_Type
write_csv(mr.trt003.multiple.same.trt,
          file = "data/data-wrangling-intermediate/05.4a_output1_Treatment-polygons-with-multiple-most-recent-date-and-same-treatment-type.csv")

# EDITED: instances of multiple rows inspected manually, and one row is kept
#   in progress



# Write out remaining to CSV for further inspection
mr.trt003.multiple.diff.trt <- mr.trt003.multiple %>% 
  filter(!ObjectID_Union %in% mr.trt003.multiple.same.trt$ObjectID_Union) %>% 
  left_join(treatment.info.002) %>% 
  arrange(ObjectID_CountOverlapping)

# OUTPUT: Treatment polygons with multiple most recent comp_date_est and different Treatment_Type
write_csv(mr.trt003.multiple.diff.trt,
          file = "data/data-wrangling-intermediate/05.4a_output2_Treatment-polygons-with-multiple-most-recent-date-and-different-treatment-type.csv")

# EDITED: 
#   in progress



# LDC points --------------------------------------------------------------

## Join tables ------------------------------------------------------------

# Join with OverlapTable
ldc.join <- ldc.points %>% 
  left_join(ldc.overlaptable)

#   Look for NAs
apply(ldc.join, 2, anyNA)

# Join with CountOverlapping
ldc.join <- ldc.join %>% 
  left_join(ldc.countoverlapping)

#   Look for NAs
apply(ldc.join, 2, anyNA)

# Remove unnecessary cols and rename COUNT_
ldc.join <- ldc.join %>% 
  select(-COUNT_FC, -ORIG_NAME) %>% 
  rename(ldc_count = COUNT_)

# Reformat DateVisted col
ldc.join <- ldc.join %>% 
  mutate(DateVisted = as.Date(as.POSIXct(DateVisted, format = "%m/%d/%Y %H:%M:%S")))



## Rename geoindicator cols to match LDC points table ---------------------

# Col names from 03_LDC-to-shapefile.R
col_rename_map <- c(
  "Project Key" = "ProjKey",
  "Primary Key" = "PrimaryKey",
  "Date Visited" = "DateVisted",
  "Ecological Site Id" = "EcoSiteID",
  "Latitude (decimal degrees, NAD83)" = "Latitude",
  "Longitude (decimal degrees, NAD83)" = "Longitude",
  "Location Status" = "LocatStatus",
  "Location Type" = "LocatType",
  "Latitude, Actual (decimal degrees, NAD83)" = "LatAct",
  "Longitude, Actual (decimal degrees, NAD83)" = "LonAct",
  "Bare Soil (% First Hit)" = "BareSoil",
  "Annual Forb Cover (% Any Hit)" = "AnnForbC",
  "Annual Graminoid Cover (% Any Hit)" = "AnnGramC",
  "Forb Cover (% Any Hit)" = "ForbC",
  "Annual Forb and Graminoid Cover (% Any Hit)" = "AnnFGC",
  "Graminoid Cover (% Any Hit)" = "GramC",
  "Perennial Forb Cover (% Any Hit)" = "PerForbC",
  "Perennial Graminoid Cover (% Any Hit)" = "PerGramC",
  "Shrub Cover (% Any Hit)" = "ShrubC",
  "FH Cyanobacteria Cover (% First Hit)" = "CyanoC",
  "Deposited Soil Cover (% First Hit)" = "DepstSoilC",
  "Duff Cover (% First Hit)" = "DuffC",
  "Embedded Litter Cover (% First Hit)" = "EmbLitC",
  "Herbaceous Litter Cover (% First Hit)" = "HerbLitC",
  "Lichen Cover (% First Hit)" = "LichenC",
  "Moss Cover (% First Hit)" = "MossC",
  "Rock Cover (% First Hit)" = "RockC",
  "Total Litter Cover (% First Hit)" = "TotLitC",
  "Vagrant Lichen Cover (% First Hit)" = "VagrtLichC",
  "Water Cover (% First Hit)" = "WaterC",
  "Woody Litter Cover (% First Hit)" = "WoodyLitC",
  "Canopy Gaps 25 - 50 cm (%)" = "Gap25_50",
  "Canopy Gaps 51-100 cm (%)" = "Gap51_100",
  "Canopy Gaps 101 - 200 cm (%)" = "Gap101_200",
  "Canopy Gaps > 200 cm (%)" = "Gap200plus",
  "Canopy Gaps > 25 cm (%)" = "Gap25plus",
  "Mean Forb Height (cm)" = "ForbHgt",
  "Mean Graminoid Height (cm)" = "GramHgt",
  "Mean Herbaceous Plant Height (cm)" = "HerbHgt",
  "Mean Perennial Forb Height (cm)" = "PForbHgt",
  "Mean Perennial Forb Graminoid Height (cm)" = "PFbGrHgt",
  "Mean Perennial Graminoid Height (cm)" = "PGramHgt",
  "Mean Woody Plant Height (cm)" = "WoodyHgt",
  "Total Annual Production (Rangeland Health)" = "TotProd",
  "Bare Ground (Rangeland Health)" = "BareGrd",
  "Biotic Integrity (Rangeland Health)" = "BioInt",
  "Comments: Biotic Integrity (Rangeland Health)" = "CmtBioInt",
  "Comments: Hydrologic Function (Rangeland Health)" = "CmtHydFn",
  "Comments: Soil and Site Stability (Rangeland Health)" = "CmtSoilSS",
  "Compaction (Rangeland Health)" = "Compact",
  "Proportion of Dead or Dying Plant Parts (Rangeland Health)" = "DeadProp",
  "Functional/Sructural Groups (Rangeland Health)" = "FuncGrp",
  "Gullies (Rangeland Health)" = "Gullies",
  "Hydrologic Function (Rangeland Health)" = "HydFn",
  "Invasive Plants (Rangeland Health)" = "InvasPl",
  "Litter Amount (Rangeland Health)" = "LitAmt",
  "Litter Movement (Rangeland Health)" = "LitMov",
  "Pedestals/Terracettes (Rangeland Health)" = "Pedestals",
  "Plant Community Composition (Rangeland Health)" = "CommComp",
  "Perennial Reproductive Capability (Rangeland Health)" = "PerRepro",
  "Rills (Rangeland Health)" = "Rills",
  "Soil Site Stability (Rangeland Health)" = "SoilSS",
  "Soil Surface Loss/Degradation (Rangeland Health)" = "SoilLoss",
  "Soil Surface Erosion Resistance (Rangeland Health)" = "SoilEroRes",
  "Water Flow Patterns (Rangeland Health)" = "WatFlow",
  "Wind Scoured Areas (Rangeland Health)" = "WindScd",
  "Mean Soil Stability: Surface" = "SoilSurf",
  "Mean Soil Stability: Protected Samples" = "SoilProt",
  "Mean Soil Stability: Unprotected Samples" = "SoilUnp",
  "MLRA Description" = "MLRADesc",
  "MLRA Symbol" = "MLRASym",
  "Ecoregion Level I" = "EcoLvl1",
  "Ecoregion Level II" = "EcoLvl2",
  "Ecoregion Level III" = "EcoLvl3",
  "Ecoregion Level IV" = "EcoLvl4",
  "State" = "State",
  "MODIS IGBP Name" = "MODISName",
  "Database Key" = "DBKey",
  "Date Loaded in Database" = "DateLoad",
  "Total Horizontal Flux" = "TotHorizFl",
  "Total Vertical Flux" = "TotVertFlx",
  "PM 2.5 Vertical Flux" = "PM25Flux",
  "PM 10 Vertical Flux" = "PM10Flux",
  "Long-Term Mean Precipitation" = "LTPrecip",
  "Long-Term Mean Runoff" = "LTRunoff",
  "Long-Term Mean Sediment Yield" = "LTSedYield",
  "Long-Term Mean Soil Loss" = "LTSoilLoss"
)

geoindicators <- geoindicators.raw %>% 
  rename(!!!setNames(names(col_rename_map), col_rename_map))

# Identify completely empty columns
empty_cols <- geoindicators %>%
  summarise(across(everything(), ~ all(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "is_empty") %>%
  filter(is_empty) %>%
  pull(column)
empty_cols

geoindicators <- geoindicators %>% 
  select(-all_of(empty_cols))



## Extract rows with no DateVisted ----------------------------------------

# NA for DateVisted
ldc.date.na <- ldc.join %>% 
  filter(is.na(DateVisted))

# OUTPUT: LDC points with no DateVisted
write_csv(ldc.date.na,
          file = "data/data-wrangling-intermediate/05.4_LDC_no-DateVisted.csv")

# Look for DateVisted value from gap & height data
gap %>% 
  filter(`Primary Key` %in% ldc.date.na$PrimaryKey)
height %>% 
  filter(`Primary Key` %in% ldc.date.na$PrimaryKey)
lpi %>% 
  filter(`Primary Key` %in% ldc.date.na$PrimaryKey)
geospecies %>% 
  filter(`Primary Key` %in% ldc.date.na$PrimaryKey)
#   idk none of the primary keys are in any of these datasets


## Extract rows of most recent monitoring ---------------------------------

# Extract the most recent point for LDC plots that were monitored multiple times
most.recent.ldc003 <- ldc.join %>%
  group_by(ObjectID_CountOverlapping) %>%
  filter(DateVisted == max(DateVisted)) %>%
  ungroup()
length(unique(most.recent.ldc003$ObjectID_CountOverlapping)) == nrow(most.recent.ldc003) # FALSE
#   this means that there are some points that have the same DateVisted, so multiple rows
#     for those cases are created

# Separate out points where there is only one most recent date for DateVisted
mr.ldc003.single <- most.recent.ldc003 %>%
  group_by(ObjectID_CountOverlapping) %>%
  filter(n() == 1) %>%
  ungroup()


### Multiple points/rows for DateVisted -----------------------------------

# Separate out points where DateVisted is the same for multiple rows
mr.ldc003.multiple <- most.recent.ldc003 %>%
  group_by(ObjectID_CountOverlapping) %>%
  filter(n() > 1) %>%
  ungroup()

# Append full geoindicators table
mr.ldc003.multiple <- mr.ldc003.multiple %>% 
  left_join(geoindicators) %>% 
  arrange(ObjectID_CountOverlapping)

# OUTPUT: LDC points with multiple DateVisted of the same value
write_csv(mr.ldc003.multiple,
          file = "data/data-wrangling-intermediate/05.4a_output3_LDC_multiple-same-DateVisted.csv")

# EDITED: instances of multiple rows inspected manually, and one row is kept
#   in progress


rm(gap, height, lpi, geospecies)
save.image("RData/05.4_most-recent_trt_v003.RData")
