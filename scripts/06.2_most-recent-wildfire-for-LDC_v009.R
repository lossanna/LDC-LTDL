# Created: 2026-01-13
# Updated: 2026-01-13

# Purpose: Find the most recent wildfire polygon for every LDC point. Create most_recent_fire_date col.


library(tidyverse)

# Load data ---------------------------------------------------------------

ldc.wildfire.sj.raw <- read_csv("data/GIS-exports/009_LDC003-Wildfire009-SpatialJoin_export.csv")


# Data wrangling ----------------------------------------------------------

# Convert date cols
ldc.wildfire.sj <- ldc.wildfire.sj.raw %>% 
  mutate(DateVisted = as.Date(as.POSIXct(DateVisted, format = "%m/%d/%Y %H:%M:%S")),
         Ignition_Date = as.Date(as.POSIXct(Ignition_Date, format = "%m/%d/%Y %H:%M:%S")),
         Discovery_Date = as.Date(as.POSIXct(Discovery_Date, format = "%m/%d/%Y %H:%M:%S")),
         Controled_Date = as.Date(as.POSIXct(Controled_Date, format = "%m/%d/%Y %H:%M:%S")),
         Containment_Date = as.Date(as.POSIXct(Containment_Date, format = "%m/%d/%Y %H:%M:%S")),
         Growth_Cessation_Date = as.Date(as.POSIXct(Growth_Cessation_Date, format = "%m/%d/%Y %H:%M:%S")),
         Wildfire_Out_Date = as.Date(as.POSIXct(Wildfire_Out_Date, format = "%m/%d/%Y %H:%M:%S")),
         Other_Fire_Date = as.Date(as.POSIXct(Other_Fire_Date, format = "%m/%d/%Y %H:%M:%S")))

# LDC points with no fire history
never.burned <- ldc.wildfire.sj %>% 
  filter(JOIN_FID == -1)

# LDC points with fire history
ldc.burned <- ldc.wildfire.sj %>% 
  filter(JOIN_FID != -1)


# By specific date cols ---------------------------------------------------

## Look for dates present -------------------------------------------------

# Has Ignition_Date
has.ignition.date <- ldc.burned %>% 
  filter(!is.na(Ignition_Date))
nrow(has.ignition.date) / nrow(ldc.burned) # 8%

# Has Discovery_Date
has.discovery.date <- ldc.burned %>% 
  filter(!is.na(Discovery_Date))
nrow(has.discovery.date) / nrow(ldc.burned) # 21%

# Has Controled_Date
has.controled.date <- ldc.burned %>% 
  filter(!is.na(Controled_Date))
nrow(has.controled.date) / nrow(ldc.burned) # 16%

# Has Containment_Date
has.containment.date <- ldc.burned %>% 
  filter(!is.na(Containment_Date))
nrow(has.containment.date) / nrow(ldc.burned) # 8%

# Has Growth_Cessation_Date
ldc.burned %>% 
  filter(!is.na(Growth_Cessation_Date)) # none

# Has Wildfire_Out_Date 
has.wildfire.out <- ldc.burned %>% 
  filter(!is.na(Wildfire_Out_Date))
nrow(has.wildfire.out) / nrow(ldc.burned) # 0.2%

# Has Other_Fire_Date 
has.other.fire.date <- ldc.burned %>% 
  filter(!is.na(Other_Fire_Date))
nrow(has.other.fire.date) / nrow(ldc.burned) # 12%
count(ldc.burned, Other_Fire_Date_Type) %>% 
  arrange(desc(n))


## Most recent based on date cols -----------------------------------------

# By Wildfire_Out_Date 
mr.wildfire.out <- ldc.burned %>% 
  filter(!is.na(Wildfire_Out_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Wildfire_Out_Date)) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(most_recent_fire_date = Wildfire_Out_Date,
         most_recent_fire_date_col = "Wildfire_Out_Date")

# By Containment_Date
mr.containment <- ldc.burned %>% 
  filter(!PrimaryKey %in% mr.wildfire.out$PrimaryKey) %>% 
  filter(!is.na(Containment_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Containment_Date)) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(most_recent_fire_date = Containment_Date,
         most_recent_fire_date_col = "Containment_Date")

# By Controled_Date
mr.controled <- ldc.burned %>% 
  filter(!PrimaryKey %in% c(mr.wildfire.out$PrimaryKey, mr.containment$PrimaryKey)) %>% 
  filter(!is.na(Controled_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Controled_Date)) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(most_recent_fire_date = Controled_Date,
         most_recent_fire_date_col = "Controled_Date")

# By Discovery_Date
mr.discovery <- ldc.burned %>% 
  filter(!PrimaryKey %in% c(mr.wildfire.out$PrimaryKey, mr.containment$PrimaryKey,
                            mr.controled$PrimaryKey)) %>% 
  filter(!is.na(Discovery_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Discovery_Date)) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(most_recent_fire_date = Discovery_Date,
         most_recent_fire_date_col = "Discovery_Date")

# By Ignition_Date
mr.ignition <- ldc.burned %>% 
  filter(!PrimaryKey %in% c(mr.wildfire.out$PrimaryKey, mr.containment$PrimaryKey,
                            mr.controled$PrimaryKey, mr.discovery$PrimaryKey)) %>% 
  filter(!is.na(Ignition_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Ignition_Date)) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(most_recent_fire_date = Ignition_Date,
         most_recent_fire_date_col = "Ignition_Date")

# By Other_Fire_Date
mr.other <- ldc.burned %>% 
  filter(!PrimaryKey %in% c(mr.wildfire.out$PrimaryKey, mr.containment$PrimaryKey,
                            mr.controled$PrimaryKey, mr.discovery$PrimaryKey,
                            mr.ignition$PrimaryKey)) %>% 
  filter(!is.na(Other_Fire_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Other_Fire_Date)) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(most_recent_fire_date = Other_Fire_Date,
         most_recent_fire_date_col = "Other_Fire_Date")


# Combine
mr.by.datecol <- bind_rows(mr.wildfire.out, mr.containment, mr.controled, mr.discovery,
                           mr.ignition, mr.other)

# Check for matching row length
nrow(mr.wildfire.out) + nrow(mr.containment) + nrow(mr.controled) + nrow(mr.discovery) +
  nrow(mr.ignition) + nrow(mr.other) == nrow(mr.by.datecol)



# By Fire_Calendar_Year ---------------------------------------------------

# Separate out ones already assigned fire date by date col
mr.by.year <- ldc.burned %>% 
  filter(!PrimaryKey %in% mr.by.datecol$PrimaryKey) %>% 
  mutate(most_recent_fire_date = paste0(Fire_Calendar_Year, "-12-31")) %>% 
  mutate(most_recent_fire_date = as.Date(most_recent_fire_date)) %>% 
  mutate(most_recent_fire_date_col = "Fire_Calendar_Year (estimated month and day)") %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(most_recent_fire_date)) %>% 
  slice_head(n = 1) %>% 
  ungroup()



# Combine all -------------------------------------------------------------

# Add cols to never.burned for bind_rows() to work
never.burned <- never.burned %>% 
  mutate(most_recent_fire_date = NA,
         most_recent_fire_date_col = NA)

# Combine
most.recent.fire <- bind_rows(never.burned, mr.by.datecol, mr.by.year)

# Check for no duplicate primary keys
count(most.recent.fire, PrimaryKey) %>% 
  arrange(desc(n))

# Check all primary keys are represented
unique(sort(unique(ldc.wildfire.sj.raw$PrimaryKey)) == sort(most.recent.fire$PrimaryKey))



# Write to CSV ------------------------------------------------------------

write_csv(most.recent.fire,
          file = "data/versions-from-R/06.2_LDC003-with-most-recent-wildfire-polygon_v009.csv")


save.image("RData/06.2_most-recent-wildfire-for-LDC_v009.RData")
