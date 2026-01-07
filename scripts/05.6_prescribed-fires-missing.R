# Created: 2026-01-06
# Updated: 2026-01-06

# Purpose: Create the equivalent of a Treatment_info table for the prescribed fires
#   identified in the USGS Combined Wildland Fire Dataset that are missing from the LTDL dataset.


library(tidyverse)

# Load data ---------------------------------------------------------------

pf.missing.raw <- read_csv("data/GIS-exports/005_PrescribedFiresMissing005_export.csv")
treatment.info.001 <- read_csv("data/versions-from-R/05.1_Treatment-info_v001-gisjoin.csv")
