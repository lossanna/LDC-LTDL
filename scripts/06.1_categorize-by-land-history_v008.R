# Created: 2026-01-12
# Updated: 2026-01-13

# Purpose: Determine fire and treatment history to make control/treatment categories.

# See scripts/06.1_Treatment-and-control categories.pptx for a schematic of the possible
#   categories.


library(tidyverse)

# Load data ---------------------------------------------------------------

ldc.wf.trt.raw <- read_csv("data/GIS-exports/008_LDC003-with-wildfire-raster-and-Trt006_export.csv")


# Data cleaning -----------------------------------------------------------

# Convert to date cols
ldc.wf.trt <- ldc.wf.trt.raw %>% 
  mutate(DateVisted = as.Date(as.POSIXct(DateVisted, format = "%m/%d/%Y %H:%M:%S"))) %>% 
  mutate(init_date_est = as.Date(init_date_est, format = "%m/%d/%Y"),
         comp_date_est = as.Date(comp_date_est, format = "%m/%d/%Y"))

# Add DateVisted_Year and comp_date_est_year cols
ldc.wf.trt <- ldc.wf.trt %>% 
  mutate(DateVisted_Year = year(DateVisted),
         comp_date_est_year = year(comp_date_est))


# Control -----------------------------------------------------------------

## LDC points without treatments ------------------------------------------

# LDC points that do not overlap with land treatments
ldc.notrt <- ldc.wf.trt %>% 
  filter(is.na(ObjectID_CountOverlapping))

# LDC points with no land treatments or fire history (1)
ldc.notrt.1 <- ldc.notrt %>% 
  filter(is.na(WF_MostRecentYear) | is.na(WF_FirstYear) | is.na(WF_Frequency))

# LDC points without land treatments but with fire history
ldc.notrt.wf <- ldc.notrt %>% 
  filter(!PrimaryKey %in% ldc.notrt.1$PrimaryKey)

#   LDC monitored before first wildfire (2)
ldc.notrt.2 <- ldc.notrt.wf %>% 
  filter(DateVisted_Year < WF_FirstYear)

#   LDC monitored after first wildfire but before most recent wildfire (3)
ldc.notrt.3 <- ldc.notrt.wf %>% 
  filter(DateVisted_Year >= WF_FirstYear & DateVisted_Year <= WF_MostRecentYear)

#   LDC monitored after most recent wildfire (4)
ldc.notrt.4 <- ldc.notrt.wf %>% 
  filter(DateVisted_Year > WF_MostRecentYear)

# Check for matching row lengths
nrow(ldc.notrt.2) + nrow(ldc.notrt.3) + nrow(ldc.notrt.4) == nrow(ldc.notrt.wf)
nrow(ldc.notrt.1) + nrow(ldc.notrt.2) + nrow(ldc.notrt.3) + nrow(ldc.notrt.4) == nrow(ldc.notrt)


## LDC monitoring happened before treatment applied -----------------------

# A land treatment was applied, but after LDC monitoring occurred
ldc.trtafter <- ldc.wf.trt %>% 
  filter(!is.na(ObjectID_CountOverlapping)) %>% 
  filter(comp_date_est > DateVisted)

# No wildfires (5)
ldc.trtafter.5 <- ldc.trtafter %>% 
  filter(is.na(WF_MostRecentYear) | is.na(WF_FirstYear) | is.na(WF_Frequency))

# LDC points with fire history
ldc.trtafter.wf <- ldc.trtafter %>% 
  filter(!PrimaryKey %in% ldc.trtafter.5$PrimaryKey)

#   LDC monitored before first wildfire (6)
ldc.trtafter.6 <- ldc.trtafter.wf %>% 
  filter(DateVisted_Year < WF_FirstYear)

#   LDC monitored after first wildfire but before most recent wildfire (7)
ldc.trtafter.7 <- ldc.trtafter.wf %>% 
  filter(DateVisted_Year >= WF_FirstYear & DateVisted_Year <= WF_MostRecentYear)

#   LDC monitored after most recent wildfire (8)
ldc.trtafter.8 <- ldc.trtafter.wf %>% 
  filter(DateVisted_Year > WF_MostRecentYear)

# Check for matching row lengths
nrow(ldc.trtafter.6) + nrow(ldc.trtafter.7) + nrow(ldc.trtafter.8) == nrow(ldc.trtafter.wf)
nrow(ldc.trtafter.5) + nrow(ldc.trtafter.6) + nrow(ldc.trtafter.7) + nrow(ldc.trtafter.8) == nrow(ldc.trtafter)


## Combine control --------------------------------------------------------

# Control, never burned
ctrl.never.burned <- bind_rows(ldc.notrt.1, ldc.notrt.2, ldc.trtafter.5, ldc.trtafter.6)

# Control, burn timing unknown
ctrl.burn.unk <- bind_rows(ldc.notrt.3, ldc.trtafter.7)

# Control, burn timing known
ctrl.burn.known <- bind_rows(ldc.notrt.4, ldc.trtafter.8)


# Check for matching row lengths
nrow(ctrl.never.burned) + nrow(ctrl.burn.unk) + nrow(ctrl.burn.known) == nrow(ldc.notrt) + nrow(ldc.trtafter)



# Treated -----------------------------------------------------------------

# LDC monitoring after treatment applied
ldc.trt <- ldc.wf.trt %>% 
  filter(!is.na(ObjectID_CountOverlapping)) %>% 
  filter(comp_date_est <= DateVisted)
  

## No wildfire ------------------------------------------------------------

# Treated, no wildfire (9)
ldc.trt.9 <- ldc.trt %>% 
  filter(is.na(WF_MostRecentYear) | is.na(WF_FirstYear) | is.na(WF_Frequency))


## Treatment applied before first wildfire --------------------------------

# Has wildfire info
ldc.trt.wf <- ldc.trt %>% 
  filter(!PrimaryKey %in% ldc.trt.9$PrimaryKey) 


# Treatment applied before first wildfire
ldc.trt.beforefire <- ldc.trt.wf %>% 
  filter(comp_date_est_year < WF_FirstYear)

#   LDC monitored before wildfires (10)
ldc.trt.10 <- ldc.trt.beforefire %>% 
  filter(DateVisted_Year < WF_FirstYear)

#   LDC monitored after first wildfire but before most recent wildfire (11)
ldc.trt.11 <- ldc.trt.beforefire %>% 
  filter(DateVisted_Year >= WF_FirstYear & DateVisted_Year <= WF_MostRecentYear)

#   LDC monitored after most recent wildfire (12)
ldc.trt.12 <- ldc.trt.beforefire %>% 
  filter(DateVisted_Year > WF_MostRecentYear)

# Check for matching row length
nrow(ldc.trt.10) + nrow(ldc.trt.11) + nrow(ldc.trt.12) == nrow(ldc.trt.beforefire)


## Treatment applied after first wildfire but before most recent ----------

# Treatment applied after first wildfire but before most recent wildfire 
ldc.trt.afterbeforefire <- ldc.trt.wf %>% 
  filter(comp_date_est_year >= WF_FirstYear & comp_date_est_year <= WF_MostRecentYear)

#   LDC monitored after first wildfire but before most recent wildfire (13)  
ldc.trt.13 <- ldc.trt.afterbeforefire %>% 
  filter(DateVisted_Year >= WF_FirstYear & DateVisted_Year <= WF_MostRecentYear)

#   LDC monitored after most recent wildfire (14)
ldc.trt.14 <- ldc.trt.afterbeforefire %>% 
  filter(DateVisted_Year > WF_MostRecentYear)

# Check for matching row length
nrow(ldc.trt.13) + nrow(ldc.trt.14) == nrow(ldc.trt.afterbeforefire)


## Treatment applied after most recent wildfire ---------------------------

# Treatment applied and LDC monitored after most recent wildfire (15)
ldc.trt.15 <- ldc.trt.wf %>% 
  filter(comp_date_est_year > WF_MostRecentYear)

# Check that LDC monitoring also occurred after most recent wildfire
unique(ldc.trt.15$DateVisted_Year > ldc.trt.15$WF_MostRecentYear)


## Combine treated --------------------------------------------------------

# Treated, never burned
trt.never.burned <- bind_rows(ldc.trt.9, ldc.trt.10)

# Treated, burn timing unknown
trt.burn.unk <- bind_rows(ldc.trt.11, ldc.trt.13, ldc.trt.14)

# Treated, burn timing known
trt.burn.known <- bind_rows(ldc.trt.12, ldc.trt.15)


# Check for matching row lengths
nrow(trt.never.burned) + nrow(trt.burn.unk) + nrow(trt.burn.known) == nrow(ldc.trt)


# Add categories ----------------------------------------------------------

ctrl.never.burned <- ctrl.never.burned %>% 
  mutate(land_history = "Control, never burned")

ctrl.burn.unk <- ctrl.burn.unk %>% 
  mutate(land_history = "Control, burn timing unknown")

ctrl.burn.known <- ctrl.burn.known %>% 
  mutate(land_history = "Control, burn timing known")

trt.never.burned <- trt.never.burned %>% 
  mutate(land_history = "Treated, never burned")

trt.burn.unk <- trt.burn.unk %>% 
  mutate(land_history = "Treated, burn timing unknown")

trt.burn.known <- trt.burn.known %>% 
  mutate(land_history = "Treated, burn timing known")



# Combine all -------------------------------------------------------------

# All
ctrl.trt <- bind_rows(ctrl.never.burned, ctrl.burn.unk, ctrl.burn.known,
                      trt.never.burned, trt.burn.unk, trt.burn.known)
  
# Check for no duplicates
nrow(distinct(ctrl.trt, .keep_all = TRUE)) == nrow(ctrl.trt) 

# Check all primary keys are represented
unique(sort(ldc.wf.trt.raw$PrimaryKey) == sort(ctrl.trt$PrimaryKey))


# Burn timing unknown
burn.unk <- bind_rows(ctrl.burn.unk, trt.burn.unk)

# Burn timing known
burn.known <- bind_rows(ctrl.burn.known, trt.burn.known)



# Write out to CSV --------------------------------------------------------

# All
write_csv(ctrl.trt,
          file = "data/versions-from-R/06.1_land-history-assigned-to-LDC_v008.csv")

# Most recent burn timing unknown
write_csv(burn.unk,
          file = "data/versions-from-R/06.1_most-recent-burn-unknown_v008.csv")

# Most recent burn for LDC is most recent burn
write_csv(burn.known,
          file = "data/versions-from-R/06.1_most-recent-burn-known_v008.csv")


save.image("RData/06.1_categorize-by-land-history_v008.RData")
