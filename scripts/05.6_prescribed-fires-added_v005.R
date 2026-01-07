# Created: 2026-01-06
# Updated: 2026-01-07

# Purpose: Create the equivalent of a Treatment_info table (GIS join cols only) for the 
#   prescribed fires identified in the USGS Combined Wildland Fire Dataset that are
#   missing from the LTDL dataset.

# Input: Map_005 outputs.
# Output: prescribed-fires-added_v003, a table with columns equivalent to 
#   LTDL treatment info table (GIS join version).


library(tidyverse)

# Load data ---------------------------------------------------------------

pf.missing.raw <- read_csv("data/GIS-exports/005_PrescribedFiresMissing005_export.csv")
treatment.info.001.gisjoin <- read_csv("data/versions-from-R/05.1_Treatment-info_v001-gisjoin.csv")
treatment.info.001 <- read_csv("data/versions-from-R/05.1_Treatment-info_v001.csv")


# Examine empty columns ---------------------------------------------------

# Identify completely empty columns
empty_cols <- pf.missing.raw %>%
  summarise(across(everything(), ~ all(is.na(.)))) %>%
  pivot_longer(everything(), names_to = "column", values_to = "is_empty") %>%
  filter(is_empty) %>%
  pull(column)
empty_cols

# Drop completely empty cols
pf.missing <- pf.missing.raw %>% 
  select(-all_of(empty_cols))


# Assign Trt_ID -----------------------------------------------------------

# Figure out range of current Trt_ID from LTDL
range(treatment.info.001$Trt_ID)

# Assign Trt_ID beyond current range
#   Use ID of PrescribedFires005, because that retains ID of original polygons
pf.missing <- pf.missing %>% 
  mutate(Trt_ID = FID_PrescribedFires005 + 73350)



# Assign treatment --------------------------------------------------------

# Major
treatment.info.001 %>% 
  filter(str_detect(Trt_Type_Major, "Burn")) %>% 
  select(Trt_Type_Major) %>% 
  unique()

# Sub
treatment.info.001 %>% 
  filter(str_detect(Trt_Type_Sub, "Burn")) %>% 
  select(Trt_Type_Sub) %>% 
  unique()

# Treatment_Type
treatment.info.001 %>% 
  filter(str_detect(Treatment_Type, "Burn")) %>% 
  select(Treatment_Type) %>% 
  unique()

# Assign Major, Sub, and Treatment_Type
pf.missing <- pf.missing %>% 
  mutate(Trt_Type_Major = "Prescribed Burn",
         Trt_Type_Sub = "Prescribed Burn",
         Treatment_Type = "Prescribed Burn")


# Inspect date columns ----------------------------------------------------

# Reformat as dates
pf.missing <- pf.missing %>% 
  mutate(Rx_Start_Date = as.Date(as.POSIXct(Rx_Start_Date, format = "%m/%d/%Y %H:%M:%S")),
         Rx_End_Date = as.Date(as.POSIXct(Rx_End_Date, format = "%m/%d/%Y %H:%M:%S")))

# Inspect Fire_Year_Status
unique(pf.missing$Fire_Year_Status)

# Inspect treatment.info.001 actual/estimated cols
unique(treatment.info.001$init_est)
unique(treatment.info.001$comp_est)


## Categorize -------------------------------------------------------------

# Rows with both start & end dates
both.dates <- pf.missing %>% 
  filter(!is.na(Rx_Start_Date) & !is.na(Rx_End_Date))

# Missing both start & end dates
dates.missing <- pf.missing %>% 
  filter(is.na(Rx_Start_Date) & is.na(Rx_End_Date))

# Missing start date only
start.missing <- pf.missing %>% 
  filter(is.na(Rx_Start_Date) & !is.na(Rx_End_Date))

# Missing end date only
end.missing <- pf.missing %>% 
  filter(!is.na(Rx_Start_Date) & is.na(Rx_End_Date))

# Check for matching row length
nrow(pf.missing) == nrow(both.dates) + nrow(dates.missing) + nrow(start.missing) + nrow(end.missing)


## Both dates present -----------------------------------------------------

# Check for matching Fire_Calendar_Year and Rx_Start_Date
both.dates <- both.dates %>% 
  mutate(Start_Year = str_sub(Rx_Start_Date, 1, 4))
unique(both.dates$Fire_Calendar_Year == both.dates$Start_Year) # all TRUE

# Calculate and examine burn duration
both.dates <- both.dates %>% 
  mutate(duration = as.numeric(Rx_End_Date - Rx_Start_Date))
summary(both.dates$duration)
hist(both.dates$duration)

# Inspect fires with duration greater than 365 days
duration.365 <- both.dates %>% 
  filter(duration > 365)

# Create init_date_est, comp_date_est, init_est, and comp_est columns
both.dates <- both.dates %>% 
  mutate(init_date_est = Rx_Start_Date,
         comp_date_est = Rx_End_Date,
         init_est = "actual",
         comp_est = "actual")


## Missing both start & end dates -----------------------------------------

# Remove rows without Fire_Calendar_Year
#   idk how to estimate anything if Fire_Calendar_Year is also missing
dates.missing <- dates.missing %>% 
  filter(!is.na(Fire_Calendar_Year))

# Inspect burn duration when both dates are provided
summary(both.dates$duration)
count(both.dates, duration) %>% 
  arrange(desc(n)) %>% 
  print(n = 20)

# Inspect start months
start.months <- pf.missing %>% 
  filter(!is.na(Rx_Start_Date)) %>% 
  mutate(Start_Month = as.numeric(str_sub(Rx_Start_Date, 6, 7)))
count(start.months, Start_Month) %>% 
  arrange(desc(n))

# Assign start date as March 1, and use Fire_Calendar_Year provided 
#   (majority of fires started in March or April)
dates.missing <- dates.missing %>% 
  mutate(Rx_Start_Date = paste0(Fire_Calendar_Year, "-03-01")) %>% 
  mutate(Rx_Start_Date = as.Date(Rx_Start_Date))

# Assign end date as March 15
#   (majority of fires lasted <12 days)
dates.missing <- dates.missing %>% 
  mutate(Rx_End_Date = paste0(Fire_Calendar_Year, "-03-15")) %>% 
  mutate(Rx_End_Date = as.Date(Rx_End_Date))

# Create init_date_est, comp_date_est, init_est, comp_est, and duration columns
dates.missing <- dates.missing %>% 
  mutate(init_date_est = Rx_Start_Date,
         comp_date_est = Rx_End_Date,
         init_est = "estimated month and day",
         comp_est = "estimated month and day",
         duration = as.numeric(Rx_End_Date - Rx_Start_Date))


## Start date missing -----------------------------------------------------

# Check for matching Fire_Calendar_Year and Rx_End_Date
start.missing <- start.missing %>% 
  mutate(Start_Year = str_sub(Rx_End_Date, 1, 4))
unique(start.missing$Fire_Calendar_Year == start.missing$Start_Year)

# Separate out where Fire_Calendar_Year matches Rx_End_Date year
start.missing.sameyear <- start.missing %>% 
  filter(Fire_Calendar_Year == Start_Year)

#   Assign Rx_Start_Date of 15 days before Rx_End_Date
start.missing.sameyear <- start.missing.sameyear %>% 
  mutate(Rx_Start_Date = Rx_End_Date - 15)

# Separate out where Fire_Calendar_Year does not match Rx_End_Date year
start.missing.diffyear <- start.missing %>% 
  filter(Fire_Calendar_Year != Start_Year)

#   Assign Rx_Start_Date as March 1 of Fire_Calendar_Year
start.missing.diffyear <- start.missing.diffyear %>% 
  mutate(Rx_Start_Date = as.Date(paste0(Fire_Calendar_Year, "-03-01")))

# Combine
start.missing <- start.missing.sameyear %>% 
  bind_rows(start.missing.diffyear)

# Create init_date_est, comp_date_est, init_est, comp_est, and duration columns
start.missing <- start.missing %>% 
  mutate(init_date_est = Rx_Start_Date,
         comp_date_est = Rx_End_Date,
         init_est = "estimated month and day",
         comp_est = "actual",
         duration = as.numeric(Rx_End_Date - Rx_Start_Date))


## End date missing -------------------------------------------------------

# Check for matching Fire_Calendar_Year and Rx_End_Date
end.missing <- end.missing %>% 
  mutate(Start_Year = str_sub(Rx_Start_Date, 1, 4))
unique(end.missing$Fire_Calendar_Year == end.missing$Start_Year)

# Assign Rx_End_Date of 15 days after Rx_Start_Date
end.missing <- end.missing %>% 
  mutate(Rx_End_Date = Rx_Start_Date + 15)

# Create init_date_est, comp_date_est, init_est, comp_est, and duration columns
end.missing <- end.missing %>% 
  mutate(init_date_est = Rx_Start_Date,
         comp_date_est = Rx_End_Date,
         init_est = "actual",
         comp_est = "estimated month and day",
         duration = as.numeric(Rx_End_Date - Rx_Start_Date))


## Combine all with correct dates -----------------------------------------

# Remove Start_Year col so bind_rows() will work
both.dates <- both.dates %>% 
  select(-Start_Year)
start.missing <- start.missing %>% 
  select(-Start_Year)
end.missing <- end.missing %>% 
  select(-Start_Year)

# Combine
pf.missing.fixed <- both.dates %>% 
  bind_rows(dates.missing) %>% 
  bind_rows(start.missing) %>% 
  bind_rows(end.missing)

# Check for matching lengths
nrow(filter(pf.missing, !is.na(Fire_Calendar_Year))) == nrow(pf.missing.fixed)



# Separate out columns for GIS join ---------------------------------------

pf.missing.fixed.gisjoin <- pf.missing.fixed %>% 
  select(ObjectID_PFMissing, Trt_ID, init_date_est, comp_date_est, Trt_Type_Major, Trt_Type_Sub, Treatment_Type)


# Write to CSV ------------------------------------------------------------

write_csv(pf.missing.fixed,
          file = "data/versions-from-R/05.6_RxFiresAdded-treatment-info_v005.csv")

write_csv(pf.missing.fixed.gisjoin,
          file = "data/versions-from-R/05.6_RxFiresAdded-treatment-info_v005-gisjoin.csv")


save.image("RData/05.6_prescribed-fires-added_v005.RData")
