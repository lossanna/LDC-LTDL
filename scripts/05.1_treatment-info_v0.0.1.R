# Created: 2025-12-04
# Updated: 2025-12-05

# Purpose: Complete initial data cleaning to create Treatment_Info v0.0.1.

# Filter for polygons, implemented plans, confirmed features only.

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

# Confirmed features only
count(treatment.info, Feature_Status)
treatment.info$Feature_Status[treatment.info$Feature_Status == "confirmed"] <- "Confirmed"
treatment.info <- treatment.info %>% 
  filter(Feature_Status == "Confirmed")



# Init_Date ---------------------------------------------------------------

# Split date into three columns
init.date <- treatment.info %>% 
  select(Trt_ID, Init_Date) %>% 
  separate(Init_Date, into = c("init_m", "init_d", "init_y"), sep = "/", remove = FALSE)

# Check for NA
apply(init.date, 2, anyNA) # no NAs

# Check for occurrences of 00
count(init.date, init_m)
count(init.date, init_d) %>% 
  print(n = 33)

# Create estimate month and day for 00 (unknown)
init.date <- init.date %>% 
  mutate(init_m_est = case_when(
    init_m == "00" ~ "06",
    TRUE ~ init_m
  ))



# Comp_Date ---------------------------------------------------------------

# Split date into three columns
comp.date <- treatment.info %>% 
  select(Trt_ID, Comp_Date) %>% 
  separate(Comp_Date, into = c("comp_m", "comp_d", "comp_y"), sep = "/", remove = FALSE)

# Check for NA
apply(comp.date, 2, anyNA) # no NAs

# Check for occurrences of 00
count(comp.date, comp_m)
count(comp.date, comp_d) %>% 
  print(n = 33)


# Write out as v0.0.1 -----------------------------------------------------


