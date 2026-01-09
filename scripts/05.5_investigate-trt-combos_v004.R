# Created: 2026-01-05
# Updated: 2026-01-06

# Purpose: Extract most recent treatment for each polygon that occupies unique space,
#   as well as any treatments within a year of most recent treatment. Investigate
#   treatment combinations.

# This script is incomplete and abandoned because I decided I would add in the missing prescribed
#   fire polygons from the combined fire dataset and then reexamine possible treatment combos.


library(tidyverse)
library(readxl)

# Load data ---------------------------------------------------------------

# GIS exports
trt.union <- read_csv("data/GIS-exports/002_TrtPoly002-Union_export.csv")
trt.countoverlapping <- read_csv("data/GIS-exports/002_TrtPoly002-Union-CountOverlapping_export.csv")
trt.overlaptable <- read_csv("data/GIS-exports/002_TrtPoly002-Union-OverlapTable_export.csv")
trt.ldc.sjoin <- read_csv("data/GIS-exports/002_TrtPoly002_LDC_SpatialJoin_export.csv")

# Treatment info
treatment.info.002 <- read_csv("data/versions-from-R/05.3_Treatment-info_v002.csv")


# Create most recent treatment combos -------------------------------------

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
trt.poly.004 <- trt.join %>% 
  filter(ObjectID_Union %in% trt.ldc.sjoin$ObjectID_Union)

#   Look for NAs
apply(trt.poly.004, 2, anyNA)

#   Look for ObjectID_Union in OT.missing table that have LDC points
trt.ldc.sjoin %>% 
  filter(ObjectID_Union %in% OT.missing$ObjectID_Union) # none


# Reformat date cols
trt.poly.004 <- trt.poly.004 %>% 
  mutate(init_date_est = as.Date(init_date_est, format = "%m/%d/%Y"),
         comp_date_est = as.Date(comp_date_est, format = "%m/%d/%Y"))



## Extract rows of most recent treatment combos ---------------------------

# Extract the most recent polygon(s) per overlap group, and polygons within 1 year
#   of most recent
most.recent.trt004 <- trt.poly.004 %>% 
  group_by(ObjectID_CountOverlapping) %>%
  mutate(most_recent_comp = max(comp_date_est)) %>%
  filter(comp_date_est >= most_recent_comp - years(1)) %>%
  ungroup() %>%
  arrange(comp_date_est) %>% 
  arrange(ObjectID_CountOverlapping)

#   Add recent_trt_count col
most.recent.trt004 <- most.recent.trt004 %>% 
  group_by(ObjectID_CountOverlapping) %>% 
  mutate(recent_trt_count = n()) %>% 
  ungroup()

# Separate out polygons with no overlaps of recent treatments
no.overlap.trt004 <- most.recent.trt004 %>% 
  filter(recent_trt_count == 1)

# Separate out polygons with overlaps (multiple recent treatments)
mr.overlaps.trt004 <- most.recent.trt004 %>% 
  filter(recent_trt_count > 1)


# Examine treatments of polygons with multiple recent treatments
count(mr.overlaps.trt004, Treatment_Type) %>% 
  arrange(n) %>% 
  print(n = 70)

count(mr.overlaps.trt004, Trt_Type_Sub) %>% 
  arrange(n)

count(mr.overlaps.trt004, Trt_Type_Major) %>% 
  arrange(n)



# Examine treatments with LDC points --------------------------------------

# Any Trt_ID that overlaps with an LDC point
trt.ldc <- trt.ldc.sjoin %>% 
  select(Prj_ID, Trt_ID, init_date_est, comp_date_est, Trt_Type_Major, Trt_Type_Sub,
         Treatment_Type) %>% 
  distinct(.keep_all = TRUE)



## Investigate treatment categories ---------------------------------------

# Check for hierarchy
trt.ldc %>%
  distinct(Trt_Type_Major, Trt_Type_Sub, Treatment_Type) %>%
  summarise(
    n_sub   = n_distinct(Trt_Type_Sub),
    n_major = n_distinct(Trt_Type_Major),
    .by = Treatment_Type
  ) %>%
  filter(n_sub > 1 | n_major > 1) # fully hierarchical

# Build hierarchy table
major.to.treatment <- trt.ldc %>% 
  distinct(Trt_Type_Major, Trt_Type_Sub, Treatment_Type) %>% 
  arrange(Trt_Type_Major) %>% 
  arrange(Trt_Type_Sub)

#   Check for matching lengths to verify hierarchy (should have only one row per Treatment_Type)
length(unique(trt.ldc$Treatment_Type)) == nrow(major.to.treatment)
