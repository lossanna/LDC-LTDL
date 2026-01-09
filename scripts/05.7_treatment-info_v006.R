# Created: 2026-01-08
# Updated: 2026-01-08

# Purpose: Examine treatments of polygons that will be used in downstream analysis (LTDL polygons
#   plus prescribed fire polygons added from the combined fire dataset). Find most recent
#   treatment and most recent treatment combos (within one year of most recent), and make
#   appropriate categories.

# Input: Map_006 outputs.
# Output: Treatment info v006.

# Status:

# Filtering:
#   "Other" and "Cultural Protection" treatment polygons removed (Major category).


library(tidyverse)
library(readxl)

# Load data ---------------------------------------------------------------

# GIS exports
trt.union <- read_csv("data/GIS-exports/006_Trt006-Union_export.csv")
trt.countoverlapping <- read_csv("data/GIS-exports/006_Trt006-Union-CountOverlapping_export.csv")
trt.overlaptable <- read_csv("data/GIS-exports/006_Trt006-Union-OverlapTable_export.csv")

# Treatment info v001
treatment.info.001 <- read_csv("data/versions-from-R/05.1_Treatment-info_v001.csv")


# Check treatment hierarchy -----------------------------------------------

# Check for treatment hierarchy 
trt.union %>%
  distinct(Trt_Type_Major, Trt_Type_Sub, Treatment_Type) %>%
  summarise(
    n_sub   = n_distinct(Trt_Type_Sub),
    n_major = n_distinct(Trt_Type_Major),
    .by = Treatment_Type
  ) %>%
  filter(n_sub > 1 | n_major > 1) # fully hierarchical

# Build hierarchy table
trt.table <- trt.union %>% 
  distinct(Trt_Type_Major, Trt_Type_Sub, Treatment_Type) %>% 
  arrange(Treatment_Type) %>% 
  arrange(Trt_Type_Sub) %>% 
  arrange(Trt_Type_Major)

#   Check for matching lengths to verify hierarchy (should have only one row per Treatment_Type)
length(unique(trt.union$Treatment_Type)) == nrow(trt.table)



# Join Union, CountOverlapping, and OverlapTable --------------------------

# Join with OverlapTable
trt.join <- trt.union %>% 
  left_join(trt.overlaptable)

# Look for NAs
apply(trt.join, 2, anyNA)

# Join with CountOverlapping
trt.join <- trt.join %>% 
  left_join(trt.countoverlapping)

# Look for NAs
apply(trt.join, 2, anyNA)

# Remove unnecessary cols and rename COUNT_
trt.join <- trt.join %>% 
  select(-COUNT_FC, -Shape_Length, -Shape_Area, -ORIG_NAME) %>% 
  rename(treatment_count = COUNT_)

# Convert init_date_est and comp_date_est to date cols
trt.join <- trt.join %>% 
  mutate(init_date_est = as.Date(init_date_est, format = "%m/%d/%Y"),
         comp_date_est = as.Date(comp_date_est, format = "%m/%d/%Y"))



# Filter out "Other" and "Cultural Protection" ----------------------------

# Remove because these treatments are unlikely to affect veg, or categories are too broad
trt.join <- trt.join %>% 
  filter(!Trt_Type_Major %in% c("Cultural Protection", "Other"))



# Treatment based on single most recent date ------------------------------

## Extract rows of most recent treatment ----------------------------------

# Extract the most recent polygon(s) per overlap group
most.recent.single <- trt.join %>%
  group_by(ObjectID_CountOverlapping) %>%
  filter(comp_date_est == max(comp_date_est)) %>%
  ungroup()
length(unique(trt.join$ObjectID_CountOverlapping)) == nrow(most.recent.single) # FALSE
#   this means that there are some polygons that have the same comp_date_est, so multiple rows
#     for those cases are created

# Add recent_trt_count col
most.recent.single <- most.recent.single %>% 
  group_by(ObjectID_CountOverlapping) %>% 
  mutate(recent_trt_count = n()) %>% 
  ungroup()


# Separate out polygons where there is only one treatment/row for most recent date
mr.single.single <- most.recent.single %>%
  filter(recent_trt_count == 1)

# Separate out polygons where comp_date_est is the same for multiple rows
mr.single.multiple <- most.recent.single %>%
  filter(recent_trt_count > 1)


## Combinations from single most recent date ------------------------------

# Separate overlapping polygons with multiple/same comp_date_est and different Trt_Type_Sub
mr.single.multiple.diffsub <- mr.single.multiple %>% 
  arrange(Trt_Type_Sub) %>% 
  select(ObjectID_CountOverlapping, Trt_Type_Sub) %>% 
  group_by(ObjectID_CountOverlapping) %>%
  summarise(
    treatments_sub = paste(unique(Trt_Type_Sub), collapse = ", "),
    .groups = "drop"
  ) %>% 
  ungroup() %>% 
  mutate(sub_count = str_count(treatments_sub, ",") + 1) %>% 
  filter(sub_count > 1)

# Examine possible Trt_Type_Sub combos
mr.single.multiple.diffsub.types <- mr.single.multiple.diffsub %>% 
  select(-ObjectID_CountOverlapping) %>% 
  distinct(.keep_all = TRUE) %>% 
  arrange(treatments_sub) %>% 
  arrange(sub_count)

count(mr.single.multiple.diffsub, treatments_sub) %>% 
  arrange(desc(n)) %>% 
  print(n = 20)



# Treatment combos --------------------------------------------------------

## Extract rows of most recent treatment combos ---------------------------

# Extract the most recent polygon(s) per overlap group, and polygons within 1 year
#   of most recent
most.recent.combo <- trt.join %>% 
  group_by(ObjectID_CountOverlapping) %>%
  mutate(most_recent_comp = max(comp_date_est)) %>%
  filter(comp_date_est >= most_recent_comp - years(1)) %>%
  ungroup() %>%
  arrange(comp_date_est) %>% 
  arrange(ObjectID_CountOverlapping)

# Add recent_trt_count col
most.recent.combo <- most.recent.combo %>% 
  group_by(ObjectID_CountOverlapping) %>% 
  mutate(recent_trt_count = n()) %>% 
  ungroup()

# Separate out polygons with no overlaps of recent treatments
mr.no.overlap <- most.recent.combo %>% 
  filter(recent_trt_count == 1)

# Separate out polygons with overlaps (multiple recent treatments)
mr.overlaps <- most.recent.combo %>% 
  filter(recent_trt_count > 1)


## Create treatment combinations ------------------------------------------

# Build hierarchy table (all most recent)
mr.all.trt.table <- most.recent.combo %>% 
  distinct(Trt_Type_Major, Trt_Type_Sub, Treatment_Type) %>% 
  arrange(Treatment_Type) %>% 
  arrange(Trt_Type_Sub) %>% 
  arrange(Trt_Type_Major)

#   Check for matching lengths to verify hierarchy (should have only one row per Treatment_Type)
length(unique(most.recent.combo$Treatment_Type)) == nrow(mr.all.trt.table)

# Build hierarchy table (treatment combinations only)
mr.combo.trt.table <- mr.overlaps %>% 
  distinct(Trt_Type_Major, Trt_Type_Sub, Treatment_Type) %>% 
  arrange(Treatment_Type) %>% 
  arrange(Trt_Type_Sub) %>% 
  arrange(Trt_Type_Major)


# Begin assembling treatment combos based on Trt_Type_Sub
mr.combo.sub <- mr.overlaps %>% 
  arrange(Trt_Type_Sub) %>% 
  select(Trt_Type_Sub, ObjectID_CountOverlapping, most_recent_comp, recent_trt_count) %>% 
  distinct(.keep_all = TRUE) %>% 
  group_by(ObjectID_CountOverlapping) %>%
  summarise(
    combo_sub = paste(unique(Trt_Type_Sub), collapse = ", "),
    .groups = "drop"
  ) %>% 
  ungroup() %>% 
  mutate(sub_count = str_count(combo_sub, ",") + 1) %>% 
  filter(sub_count > 1)

# Examine combo options
combo.sub.types <- mr.combo.sub %>% 
  select(-ObjectID_CountOverlapping) %>% 
  distinct(.keep_all = TRUE) %>% 
  arrange(combo_sub) %>% 
  arrange(sub_count)

count(mr.combo.sub, combo_sub) %>% 
  arrange(desc(n)) %>% 
  print(n = 20)




# Apply Combo Selection 1 -------------------------------------------------

## Combo Selection 1 ------------------------------------------------------

# Based on the combinations with the highest number of polygons both when considering
#   most recent treatments with one year buffer and most recent treatment based on single date,
#   I have picked 7 treatment combinations.

# Will consider the following combos:
# 1. Aerial Seeding, Drill Seeding
# 2. Aerial Seeding, Soil Disturbance
# 3. Drill Seeding, Soil Disturbance
# 4. Ground Seeding, Soil Disturbance
# 5. Seeding, Soil Disturbance
# 6. Aerial Seeding, Herbicide
# 7. Drill Seeding, Herbicide

combo.selection1 <- c("Aerial Seeding, Drill Seeding", "Aerial Seeding, Soil Disturbance",
                      "Drill Seeding, Soil Disturbance", "Ground Seeding, Soil Disturbance",
                      "Seeding, Soil Disturbance", "Aerial Seeding, Herbicide",
                      "Drill Seeding, Herbicide")


## Separate out polygons with Selection 1 combos --------------------------

# Separate out polygons with selection 1 combos
combo1.combos <- mr.combo.sub %>% 
  filter(combo_sub %in% combo.selection1) %>% 
  left_join(trt.join)

# Separate out all other polygons
combo1.other <- trt.join %>% 
  filter(!ObjectID_CountOverlapping %in% combo1.combos$ObjectID_CountOverlapping)


## Deal with combo polygons -----------------------------------------------

# Arbitrarily keep first instance of each duplicate
combo1.combos <- combo1.combos %>% 
  group_by(ObjectID_CountOverlapping) %>% 
  slice_head(n = 1) %>% 
  ungroup()


# Create Trt_Type_Major for combos
sub.combo <- combo1.combos %>% 
  select(combo_sub) %>% 
  distinct(.keep_all = TRUE) %>% 
  arrange(combo_sub)

# OUTPUT: list of treatment combos for Combo Selection 1
write_csv(sub.combo,
          "data/data-wrangling-intermediate/05.7a_output1_combination-selection-1-sub.csv")

# EDITED: list of treatment combos with combination Trt_Type_Major added
sub.major <- read_csv("data/data-wrangling-intermediate/05.7b_edited1_combination-selection-1-sub_with-major.csv")


# Clean up columns for eventual bind_rows()
combo1.combos <- combo1.combos %>% 
  select(ObjectID_CountOverlapping, init_date_est, comp_date_est, combo_sub, treatment_count,
         sub_count) %>% 
  left_join(sub.major) %>% 
  rename(Trt_Type_Sub = combo_sub,
         recent_trt_count = sub_count) %>% 
  select(ObjectID_CountOverlapping, init_date_est, comp_date_est, Trt_Type_Major,
         Trt_Type_Sub, treatment_count, recent_trt_count)
  


## Deal with non-combo polygons -------------------------------------------

# Extract most recent treatment for others (non-combo)
combo1.other.mr <- combo1.other %>% 
  group_by(ObjectID_CountOverlapping) %>%
  filter(comp_date_est == max(comp_date_est)) %>%
  ungroup()
length(unique(combo1.other$ObjectID_CountOverlapping)) == nrow(combo1.other.mr) # FALSE
#   this means that there are some polygons that have the same comp_date_est, so multiple rows
#     for those cases are created

# Add recent_trt_count col
combo1.other.mr <- combo1.other.mr %>% 
  group_by(ObjectID_CountOverlapping) %>% 
  mutate(recent_trt_count = n()) %>% 
  ungroup()


# Separate out polygons where there is only one treatment/row for most recent date
#   these will not need further addressing
combo1.other.mr1 <- combo1.other.mr %>%
  filter(recent_trt_count == 1) %>% 
  select(ObjectID_CountOverlapping, init_date_est, comp_date_est, Trt_Type_Major,
         Trt_Type_Sub, treatment_count, recent_trt_count)

# Separate out polygons where comp_date_est is the same for multiple rows
combo1.multiple <- combo1.other.mr %>%
  filter(recent_trt_count > 1)


### Combinations from single most recent date -----------------------------

# Separate overlapping polygons with multiple/same comp_date_est and different Trt_Type_Sub
combo1.diffsub <- combo1.multiple %>% 
  arrange(Trt_Type_Sub) %>% 
  select(ObjectID_CountOverlapping, Trt_Type_Sub) %>% 
  group_by(ObjectID_CountOverlapping) %>%
  summarise(
    treatments_sub = paste(unique(Trt_Type_Sub), collapse = ", "),
    .groups = "drop"
  ) %>% 
  ungroup() %>% 
  mutate(sub_count = str_count(treatments_sub, ",") + 1) %>% 
  filter(sub_count > 1)

# Examine possible Trt_Type_Sub combos
combo1.diffsub.types <- combo1.diffsub %>% 
  select(-ObjectID_CountOverlapping) %>% 
  distinct(.keep_all = TRUE) %>% 
  arrange(treatments_sub) %>% 
  arrange(sub_count)

count(combo1.diffsub, treatments_sub) %>% 
  arrange(desc(n)) %>% 
  print(n = 20)


#### Apply (arbitrary) selection preference for diff sub ----------------

# OUTPUT: Treatment combos that need to be narrowed to just 1 treatment
write_csv(combo1.diffsub.types,
          file = "data/data-wrangling-intermediate/05.7a_output2_conflicting-multiple-treatments.csv")

# EDITED: Combinations resolved to a single treatment
#   see notes tab for preference rules (mostly they are arbitrary)
diffsub.resolved <- read_xlsx("data/data-wrangling-intermediate/05.7b_edited2_conflicting-multiple-treatments-resolved.xlsx",
                              sheet = "05.7a_output2_conflicting-multi")

# Join to get ObjectID_CountOverlapping
combo1.diffsub.resolved <- combo1.diffsub %>% 
  left_join(diffsub.resolved)

# Create finalized version to be stitched together with others at the end
combo1.other.mr2 <- combo1.other.mr %>% 
  filter(ObjectID_CountOverlapping %in% combo1.diffsub.resolved$ObjectID_CountOverlapping) %>% 
  left_join(combo1.diffsub.resolved) %>% 
  group_by(ObjectID_CountOverlapping) %>%
  filter(Trt_Type_Sub == sub_selected) %>%
  ungroup() 

#   Check for matching row length
nrow(combo1.other.mr2) == nrow(combo1.diffsub)

# Examine conflicts
#   conflicts occur because there is more than row of the selected treatment sub type
count(combo1.other.mr2, ObjectID_CountOverlapping) %>% 
  arrange(desc(n))
mr2.conflicting <- combo1.other.mr2 %>% 
  filter(ObjectID_CountOverlapping %in% c(947, 1033, 1560)) %>% 
  left_join(treatment.info.001)

# Arbitrarily decide to keep the first row for conflicting instances
#   Now every polygon has only one treatment/row and this version can be stitched
combo1.other.mr2 <- combo1.other.mr2 %>% 
  filter(!Trt_ID %in% c(37353, 45317, 1467)) %>% 
  select(-treatments_sub, -sub_count, -sub_selected) %>% 
  select(ObjectID_CountOverlapping, init_date_est, comp_date_est, Trt_Type_Major,
         Trt_Type_Sub, treatment_count, recent_trt_count)


#### Apply (arbitrary) selection preference for same sub ----------------

# Separate overlapping polygons with multiple/same comp_date_est and same Trt_Type_Sub
combo1.samesub <- combo1.multiple %>% 
  filter(!ObjectID_CountOverlapping %in% combo1.other.mr2$ObjectID_CountOverlapping) 

# Arbitrarily keep first instance of each duplicate
combo1.other.mr3 <- combo1.samesub %>% 
  group_by(ObjectID_CountOverlapping) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  select(ObjectID_CountOverlapping, init_date_est, comp_date_est, Trt_Type_Major,
         Trt_Type_Sub, treatment_count, recent_trt_count)


## Combine all ------------------------------------------------------------

# Combine
combo1 <- bind_rows(combo1.combos, combo1.other.mr1, combo1.other.mr2,
                    combo1.other.mr3)

# Check for matching row number
length(unique(trt.join$ObjectID_CountOverlapping)) == nrow(combo1)


# Write to CSV ------------------------------------------------------------

write_csv(combo1,
          file = "data/versions-from-R/05.7_treatment-info_v006.csv")

save.image("RData/05.7_treatment-info_v006.RData")
