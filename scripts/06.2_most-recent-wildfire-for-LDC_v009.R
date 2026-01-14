# Created: 2026-01-13
# Updated: 2026-01-14

# Purpose: Find the most recent wildfire polygon for every LDC point that occurred
#   BEFORE LDC monitoring (fires after LDC monitoring not relevant). Create LDC_MR_wildfire_date col.


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

# Combine
has.datecol <- bind_rows(has.ignition.date, has.discovery.date, has.controled.date,
                         has.containment.date, has.wildfire.out, has.other.fire.date)


## Most recent based on date cols -----------------------------------------

# By Wildfire_Out_Date 
mr.wildfire.out <- ldc.burned %>% 
  filter(!is.na(Wildfire_Out_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Wildfire_Out_Date)) %>% 
  filter(DateVisted >= Wildfire_Out_Date) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(LDC_MR_wildfire_date = Wildfire_Out_Date,
         LDC_MR_wildfire_date_col = "Wildfire_Out_Date")


# By Containment_Date
mr.containment <- ldc.burned %>% 
  filter(!PrimaryKey %in% mr.wildfire.out$PrimaryKey) %>% 
  filter(!is.na(Containment_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Containment_Date)) %>% 
  filter(DateVisted >= Containment_Date) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(LDC_MR_wildfire_date = Containment_Date,
         LDC_MR_wildfire_date_col = "Containment_Date")

# By Controled_Date
mr.controled <- ldc.burned %>% 
  filter(!PrimaryKey %in% c(mr.wildfire.out$PrimaryKey, mr.containment$PrimaryKey)) %>% 
  filter(!is.na(Controled_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Controled_Date)) %>% 
  filter(DateVisted >= Controled_Date) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(LDC_MR_wildfire_date = Controled_Date,
         LDC_MR_wildfire_date_col = "Controled_Date")

# By Discovery_Date
mr.discovery <- ldc.burned %>% 
  filter(!PrimaryKey %in% c(mr.wildfire.out$PrimaryKey, mr.containment$PrimaryKey,
                            mr.controled$PrimaryKey)) %>% 
  filter(!is.na(Discovery_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Discovery_Date)) %>% 
  filter(DateVisted >= Discovery_Date) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(LDC_MR_wildfire_date = Discovery_Date,
         LDC_MR_wildfire_date_col = "Discovery_Date")

# By Ignition_Date
mr.ignition <- ldc.burned %>% 
  filter(!PrimaryKey %in% c(mr.wildfire.out$PrimaryKey, mr.containment$PrimaryKey,
                            mr.controled$PrimaryKey, mr.discovery$PrimaryKey)) %>% 
  filter(!is.na(Ignition_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Ignition_Date)) %>% 
  filter(DateVisted >= Ignition_Date) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(LDC_MR_wildfire_date = Ignition_Date,
         LDC_MR_wildfire_date_col = "Ignition_Date")

# By Other_Fire_Date
mr.other <- ldc.burned %>% 
  filter(!PrimaryKey %in% c(mr.wildfire.out$PrimaryKey, mr.containment$PrimaryKey,
                            mr.controled$PrimaryKey, mr.discovery$PrimaryKey,
                            mr.ignition$PrimaryKey)) %>% 
  filter(!is.na(Other_Fire_Date)) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(Other_Fire_Date)) %>% 
  filter(DateVisted >= Other_Fire_Date) %>% 
  slice_head(n = 1) %>% 
  ungroup() %>% 
  mutate(LDC_MR_wildfire_date = Other_Fire_Date,
         LDC_MR_wildfire_date_col = "Other_Fire_Date")


# Combine
mr.by.datecol <- bind_rows(mr.wildfire.out, mr.containment, mr.controled, mr.discovery,
                           mr.ignition, mr.other)

# Check for matching row length
nrow(mr.wildfire.out) + nrow(mr.containment) + nrow(mr.controled) + nrow(mr.discovery) +
  nrow(mr.ignition) + nrow(mr.other) == nrow(mr.by.datecol)



## When wildfire date is after DateVisted ---------------------------------

# Separate out instances
#   By Wildfire_Out_Date
post.wildfire.out <- ldc.burned %>% 
  filter(!PrimaryKey %in% mr.by.datecol$PrimaryKey) %>% 
  filter(!is.na(Wildfire_Out_Date)) %>% 
  filter(DateVisted < Wildfire_Out_Date) 

#   By Containment_Date
post.containment <- ldc.burned %>% 
  filter(!PrimaryKey %in% mr.by.datecol$PrimaryKey) %>% 
  filter(!PrimaryKey %in% post.wildfire.out$PrimaryKey) %>% 
  filter(!is.na(Containment_Date)) %>% 
  filter(DateVisted < Containment_Date)

#   By Controled_Date
post.controled <- ldc.burned %>% 
  filter(!PrimaryKey %in% mr.by.datecol$PrimaryKey) %>% 
  filter(!PrimaryKey %in% c(post.wildfire.out$PrimaryKey, post.containment$PrimaryKey)) %>% 
  filter(!is.na(Controled_Date)) %>% 
  filter(DateVisted < Controled_Date)

#   By Discovery_Date
post.discovery <- ldc.burned %>% 
  filter(!PrimaryKey %in% mr.by.datecol$PrimaryKey) %>% 
  filter(!PrimaryKey %in% c(post.wildfire.out$PrimaryKey, post.containment$PrimaryKey,
                            post.controled$PrimaryKey)) %>% 
  filter(!is.na(Discovery_Date)) %>% 
  filter(DateVisted < Discovery_Date)

#   By Ignition_Date
post.ignition <- ldc.burned %>% 
  filter(!PrimaryKey %in% mr.by.datecol$PrimaryKey) %>% 
  filter(!PrimaryKey %in% c(post.wildfire.out$PrimaryKey, post.containment$PrimaryKey,
                            post.controled$PrimaryKey, post.discovery$PrimaryKey)) %>% 
  filter(!is.na(Ignition_Date)) %>% 
  filter(DateVisted < Ignition_Date)

#   By Other_Fire_Date
post.other <- ldc.burned %>% 
  filter(!PrimaryKey %in% mr.by.datecol$PrimaryKey) %>% 
  filter(!PrimaryKey %in% c(post.wildfire.out$PrimaryKey, post.containment$PrimaryKey,
                            post.controled$PrimaryKey, post.discovery$PrimaryKey,
                            post.ignition$PrimaryKey)) %>% 
  filter(!is.na(Other_Fire_Date)) %>% 
  filter(DateVisted < Other_Fire_Date)


# Combine
post.all <- bind_rows(post.wildfire.out, post.containment, post.controled,
                      post.discovery, post.ignition, post.other)


# Look for primary keys that only have wildfire dates after DateVisted
post.primarykeys.missing <- ldc.burned %>% 
  filter(!PrimaryKey %in% mr.by.datecol$PrimaryKey) %>% 
  select(PrimaryKey) %>% 
  distinct(.keep_all = TRUE)

# Create df for bind_rows() with NA for all fire columns
post.add <- post.all %>% 
  filter(PrimaryKey %in% post.primarykeys.missing$PrimaryKey) %>% 
  mutate(Join_Count = 0,
         JOIN_FID = -1,
         Fire_Tier = NA,
         Fire_Type = NA,
         Data_Source = NA,
         Fire_Calendar_Year = NA,
         Fire_Year_Status = NA,
         Estimated_Year_or_Range = NA,
         GIS_Acres = NA,
         GIS_Hectares = NA,
         Rx_Reported_Acres = NA,
         Rx_Reported_vs_GIS_Difference = NA,
         Fire_Name = NA, 
         Fire_Code = NA,
         Fire_ID = NA,
         IRWIN_ID = NA, 
         Fire_Cause = NA,
         Cause_Classification = NA,
         Ignition_Date = NA,
         Discovery_Date = NA,
         Controled_Date = NA,
         Containment_Date = NA,
         Growth_Cessation_Date = NA,
         Wildfire_Out_Date = NA,
         Rx_Start_Date = NA,
         Rx_End_Date = NA,
         Other_Fire_Date = NA,
         Other_Fire_Date_Type = NA,
         Upload_Date = NA,
         Map_Digitization_Method = NA,
         Data_Notes = NA,
         Processing_Notes = NA,
         LDC_MR_wildfire_date = NA,
         LDC_MR_wildfire_date_col = NA) %>% 
  distinct(.keep_all = TRUE)


## Combine ----------------------------------------------------------------

# Combine most recent fires with newly made df of primary keys with no fire history
by.datecol <- bind_rows(mr.by.datecol, post.add)
 
# Check for missing primary keys
setdiff(has.datecol$PrimaryKey, by.datecol$PrimaryKey)


# By Fire_Calendar_Year ---------------------------------------------------

# Separate out ones already assigned fire date by date col
has.year <- ldc.burned %>% 
  filter(!PrimaryKey %in% by.datecol$PrimaryKey) 

# Assign fire date as Fire_Calendar_Year, plus Dec 31
mr.by.year <- has.year %>% 
  mutate(LDC_MR_wildfire_date = paste0(Fire_Calendar_Year, "-12-31")) %>% 
  mutate(LDC_MR_wildfire_date = as.Date(LDC_MR_wildfire_date)) %>% 
  mutate(LDC_MR_wildfire_date_col = "Fire_Calendar_Year (estimated month and day)") %>% 
  filter(DateVisted >= LDC_MR_wildfire_date) %>% 
  group_by(PrimaryKey) %>% 
  arrange(desc(LDC_MR_wildfire_date)) %>% 
  slice_head(n = 1) %>% 
  ungroup()


# When wildfire date is after DateVisted
post.year <- has.year %>% 
  mutate(most_recent_fire_date = paste0(Fire_Calendar_Year, "-12-31")) %>% 
  mutate(LDC_MR_wildfire_date = as.Date(most_recent_fire_date)) %>% 
  mutate(LDC_MR_wildfire_date_col = "Fire_Calendar_Year (estimated month and day)") %>% 
  filter(DateVisted < LDC_MR_wildfire_date) 
  
# Look for primary keys that only have wildfire dates after DateVisted
post.year.primarykeys.missing <- has.year %>% 
  filter(!PrimaryKey %in% mr.by.year$PrimaryKey) %>% 
  select(PrimaryKey) %>% 
  distinct(.keep_all = TRUE)

# Create df for bind_rows() with NA for all fire columns
post.year.add <- post.year %>% 
  filter(PrimaryKey %in% post.year.primarykeys.missing$PrimaryKey) %>% 
  mutate(Join_Count = 0,
         JOIN_FID = -1,
         Fire_Tier = NA,
         Fire_Type = NA,
         Data_Source = NA,
         Fire_Calendar_Year = NA,
         Fire_Year_Status = NA,
         Estimated_Year_or_Range = NA,
         GIS_Acres = NA,
         GIS_Hectares = NA,
         Rx_Reported_Acres = NA,
         Rx_Reported_vs_GIS_Difference = NA,
         Fire_Name = NA, 
         Fire_Code = NA,
         Fire_ID = NA,
         IRWIN_ID = NA, 
         Fire_Cause = NA,
         Cause_Classification = NA,
         Ignition_Date = NA,
         Discovery_Date = NA,
         Controled_Date = NA,
         Containment_Date = NA,
         Growth_Cessation_Date = NA,
         Wildfire_Out_Date = NA,
         Rx_Start_Date = NA,
         Rx_End_Date = NA,
         Other_Fire_Date = NA,
         Other_Fire_Date_Type = NA,
         Upload_Date = NA,
         Map_Digitization_Method = NA,
         Data_Notes = NA,
         Processing_Notes = NA,
         LDC_MR_wildfire_date = NA,
         LDC_MR_wildfire_date_col = NA) %>% 
  distinct(.keep_all = TRUE)


# Combine
by.year <- bind_rows(mr.by.year, post.year.add)

# Check for missing primary keys
setdiff(has.year$PrimaryKey, by.year$PrimaryKey)

# Inspect missing primary keys
#   They are missing because they have no Fire_Calendar_Year or any other dates
by.year.missing <- ldc.burned %>% 
  filter(PrimaryKey %in% setdiff(has.year$PrimaryKey, by.year$PrimaryKey))

# For simplicity, I will remove these fire polygons and assign no fire history to these LDC points
by.year.missing.add <- by.year.missing %>% 
  mutate(Join_Count = 0,
         JOIN_FID = -1,
         Fire_Tier = NA,
         Fire_Type = NA,
         Data_Source = NA,
         Fire_Calendar_Year = NA,
         Fire_Year_Status = NA,
         Estimated_Year_or_Range = NA,
         GIS_Acres = NA,
         GIS_Hectares = NA,
         Rx_Reported_Acres = NA,
         Rx_Reported_vs_GIS_Difference = NA,
         Fire_Name = NA, 
         Fire_Code = NA,
         Fire_ID = NA,
         IRWIN_ID = NA, 
         Fire_Cause = NA,
         Cause_Classification = NA,
         Ignition_Date = NA,
         Discovery_Date = NA,
         Controled_Date = NA,
         Containment_Date = NA,
         Growth_Cessation_Date = NA,
         Wildfire_Out_Date = NA,
         Rx_Start_Date = NA,
         Rx_End_Date = NA,
         Other_Fire_Date = NA,
         Other_Fire_Date_Type = NA,
         Upload_Date = NA,
         Map_Digitization_Method = NA,
         Data_Notes = NA,
         Processing_Notes = NA,
         LDC_MR_wildfire_date = NA,
         LDC_MR_wildfire_date_col = NA) %>% 
  distinct(.keep_all = TRUE)



# Combine all -------------------------------------------------------------

# Add cols to never.burned for bind_rows() to work
never.burned <- never.burned %>% 
  mutate(LDC_MR_wildfire_date = NA,
         LDC_MR_wildfire_date_col = NA)

# Combine
most.recent.fire <- bind_rows(never.burned, by.datecol, by.year, by.year.missing.add)

# Check for no duplicate primary keys
count(most.recent.fire, PrimaryKey) %>% 
  arrange(desc(n))

# Check all primary keys are represented
unique(sort(unique(ldc.wildfire.sj.raw$PrimaryKey)) == sort(most.recent.fire$PrimaryKey))



# Write to CSV ------------------------------------------------------------

write_csv(most.recent.fire,
          file = "data/versions-from-R/06.2_LDC003-with-most-recent-wildfire-polygon_v009.csv")


save.image("RData/06.2_most-recent-wildfire-for-LDC_v009.RData")
