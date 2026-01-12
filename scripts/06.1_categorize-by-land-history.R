# Created: 2026-01-12
# Updated: 2026-01-12

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

# Add DateVisted_Year col
ldc.wf.trt <- ldc.wf.trt %>% 
  mutate(DateVisted_Year = year(DateVisted))


# Control -----------------------------------------------------------------

## LDC points without treatments ------------------------------------------

# LDC points that do not overlap with land treatments
ldc.notrt <- ldc.wf.trt %>% 
  filter(is.na(ObjectID_CountOverlapping))

# LDC points without land treatments or fire history (1)
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
  filter(DateVisted_Year >= WF_FirstYear & WF_MostRecentYear >= DateVisted_Year)

#   LDC monitored after most recent wildfire (4)
ldc.notrt.4 <- ldc.notrt.wf %>% 
  filter(DateVisted_Year > WF_MostRecentYear)



## LDC monitoring happened before treatment applied -----------------------

# A land treatment was applied, but after LDC monitoring occurred
ldc.trtafter <- ldc.wf.trt %>% 
  filter(!is.na(ObjectID_CountOverlapping)) %>% 
  filter(comp_date_est > DateVisted)

# No wildfires (5)
ldc.trtafter.5 <- ldc.trtafter %>% 
  filter(is.na(WF_MostRecentYear) | is.na(WF_FirstYear) | is.na(WF_Frequency))

# LDC points with fire history
ldc.trtafter.wf <- ldc.wf.trt %>% 
  filter(!PrimaryKey %in% ldc.trtafter.5$PrimaryKey)

#   LDC monitored before first wildfire (6)
ldc.trtafter.6 <- ldc.trtafter %>% 
  filter(DateVisted_Year < WF_FirstYear)

#   LDC monitored after first wildfire but before most recent wildfire (7)
ldc.trtafter.7 <- ldc.trtafter.wf %>% 
  filter(DateVisted_Year >= WF_FirstYear & WF_MostRecentYear >= DateVisted_Year)

#   LDC monitored after most recent wildfire (8)
ldc.trtafter.8 <- ldc.trtafter.wf %>% 
  filter(DateVisted_Year > WF_MostRecentYear)


## Combine ----------------------------------------------------------------

# Control, never burned
ctrl.never.burned <- bind_rows(ldc.notrt.1, ldc.notrt.2, ldc.trtafter.5, ldc.trtafter.6)

# Control, burn timing unknown
ctrl.burn.unk <- bind_rows(ldc.notrt.3, ldc.trtafter.7)

# Control burn timing known
ctrl.burn.known <- bind_rows(ldc.notrt.3, ldc.trtafter.8)



# Treated -----------------------------------------------------------------

## No wildfire ------------------------------------------------------------

# Treated, no wildfire (9)
ldc.trt.9 <- ldc.wf.trt %>% 
  filter(!is.na(ObjectID_CountOverlapping)) %>% 
  filter(comp_date_est <= DateVisted)


## Treatment applied before first wildfire --------------------------------



save.image("RData/06.1_categorize-by-land-history.RData")
