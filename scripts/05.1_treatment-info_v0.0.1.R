# Created: 2025-12-04
# Updated: 2025-12-04

# Purpose: Complete initial data cleaning to create Treatment_Info v0.0.1.

library(tidyverse)

# Load data ---------------------------------------------------------------

treatment.info.raw <- read_csv("data/LTDL-versions/01_Treatment-info_v0.0.0.csv")


# Initial filtering -------------------------------------------------------

# Polygons only
treatment.info <- treatment.info.raw %>% 
  filter(Trt_Feature_Type == "Polygon")

# Implemented plans only
treatment.info <- treatment.info %>% 
  filter(Plan_Imp == "Implemented")






# Write out as v0.0.1 -----------------------------------------------------


