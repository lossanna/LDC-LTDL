# Created: 2025-09-30
# Updated: 2025-11-20

# Purpose: Collate Landscape Data Commons data from the four batches of downloads into single CSV
#   for each data table, and write new CSV.
#   (Except for geoindicators, because I downloaded all 61,740 plots directly online [not through data packet]
#     because the coordinates weren't formatted correctly in the data packet version.)

# There are issues with the soil stability data in columns 9 (Line) and 11 (Transect Position).
#   I started trying to fix all the issues, but really it is easiest to just drop those columns and merge
#   the batches like everything else, so that is what I am going to stick with for now. I'm not sure
#   how necessary those columns are (or even the soil data in general), so I don't want to spend too much
#   time trying to do data cleaning via manual edits.


library(tidyverse)
library(readxl)

# Load data ---------------------------------------------------------------

# Batch 1
data.gap1 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/data-gap.csv")
data.height1 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/data-height.csv")
data.lpi1 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/data-lpi.csv")
data.soil1 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/data-soil-stability.csv")
data.species1 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/data-species-inventory.csv")
geoindicators1 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/geoindicators.csv")
geospecies1 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/geospecies.csv")

# Batch 2
data.gap2 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/data-gap.csv")
data.height2 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/data-height.csv")
data.lpi2 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/data-lpi.csv")
data.soil2 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/data-soil-stability.csv")
data.species2 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/data-species-inventory.csv")
geoindicators2 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/geoindicators.csv")
geospecies2 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/geospecies.csv")

# Batch 3
data.gap3 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/data-gap.csv")
data.height3 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/data-height.csv")
data.lpi3 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/data-lpi.csv")
data.soil3 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/data-soil-stability.csv")
data.species3 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/data-species-inventory.csv")
geoindicators3 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/geoindicators.csv")
geospecies3 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/geospecies.csv")

# Batch 4
data.gap4 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/data-gap.csv")
data.height4 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/data-height.csv")
data.lpi4 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/data-lpi.csv")
data.soil4 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/data-soil-stability.csv")
data.species4 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/data-species-inventory.csv")
geoindicators4 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/geoindicators.csv")
geospecies4 <- read_csv("data/raw/downloaded/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/geospecies.csv")


# Data wrangling ----------------------------------------------------------

# Combine geoindicators to check for row count (1 row per plot)
geoindicators <- bind_rows(geoindicators1, geoindicators2, geoindicators3, geoindicators4) %>% 
  distinct(.keep_all = TRUE)
nrow(geoindicators) # all 67,740 plots included

# Combine data.gap
data.gap <- bind_rows(data.gap1, data.gap2, data.gap3, data.gap4) %>% 
  distinct(.keep_all = TRUE)

# Combine data.height
data.height <- bind_rows(data.height1, data.height2, data.height3, data.height4) %>% 
  distinct(.keep_all = TRUE)

# Combine data.lpi
data.lpi <- bind_rows(data.lpi1, data.lpi2, data.lpi3, data.lpi4) %>% 
  distinct(.keep_all = TRUE)

# Combine data.species
data.species <- bind_rows(data.species1, data.species2, data.species3, data.species4) %>% 
  distinct(.keep_all = TRUE)

# Combine geospecies
geospecies <- bind_rows(geospecies1, geospecies2, geospecies3, geospecies4) %>% 
  distinct(.keep_all = TRUE)


# Fix soil data -----------------------------------------------------------

# Inspect data.soil
#   Issues in cols 9 and 11 that will likely need manual fix
problems(data.soil1)
problems(data.soil2)
problems(data.soil3)
problems(data.soil4)

# Extract row number for problem rows
row.soil1 <- as.data.frame(problems(data.soil1))$row
row.soil2 <- as.data.frame(problems(data.soil2))$row
row.soil3 <- as.data.frame(problems(data.soil3))$row
row.soil4 <- as.data.frame(problems(data.soil4))$row

# Extract rows with problems
data.soil1.issue <- data.soil1 %>% 
  mutate(row = as.numeric(rownames(data.soil1)) + 1) %>% 
  filter(row %in% row.soil1)
data.soil2.issue <- data.soil2 %>% 
  mutate(row = as.numeric(rownames(data.soil2)) + 1) %>% 
  filter(row %in% row.soil2)
data.soil3.issue <- data.soil3 %>% 
  mutate(row = as.numeric(rownames(data.soil3)) + 1) %>% 
  filter(row %in% row.soil3)
data.soil4.issue <- data.soil4 %>% 
  mutate(row = as.numeric(rownames(data.soil4)) + 1) %>% 
  filter(row %in% row.soil4)

# There are additional problems in col 11 of data.soil3 and data.soil4
unique(data.soil3$`Transect Position`)
c("8..15", "12..3", "16..1","13m", "5m", "9m", "17m", "21m", "1m",
  "12m", "16m", "24m", "20m", "8m", "4m", "2400n", "sh", "20s", "12..5",
  "2a", "3a", "1a", "24.t", "21.2n", "NC", "`", "8,5", "24`")

unique(data.soil4$`Transect Position`)
c("20.", "13m", "17m", "21m", "5m", "9m", "1m", "12m", "4m", "16m", "20m", "8m", "24m", "2400n")

# OUTPUT: Rows with typos in cols 9 (Line) and 11 (Transect Position)
write_csv(data.soil1.issue,
          file = "data/data-wrangling-intermediate/02a_output1_soil1.csv")
write_csv(data.soil2.issue,
          file = "data/data-wrangling-intermediate/02a_output1_soil2.csv")
write_csv(data.soil3.issue,
          file = "data/data-wrangling-intermediate/02a_output1_soil3.csv")
write_csv(data.soil4.issue,
          file = "data/data-wrangling-intermediate/02a_output1_soil4.csv")

# EDITED: Typos corrected
#   Highlighted cells indicate where problem occurred; fix was made if I could figure it out,
#     (I manually checked the original row and looked for context) otherwise cell just left blank
data.soil1.fix <- read_xlsx("data/data-wrangling-intermediate/02b_edited1_soil1.xlsx") %>% 
  mutate(`Record Key` = as.character(`Record Key`))
data.soil2.fix <- read_xlsx("data/data-wrangling-intermediate/02b_edited2_soil2.xlsx") %>% 
  mutate(`Record Key` = as.character(`Record Key`))
data.soil3.fix <- read_xlsx("data/data-wrangling-intermediate/02b_edited3_soil3.xlsx") %>% 
  mutate(`Record Key` = as.character(`Record Key`),
         `Transect Position` = as.character(`Transect Position`))
data.soil4.fix <- read_xlsx("data/data-wrangling-intermediate/02b_edited4_soil4.xlsx") %>% 
  mutate(`Record Key` = as.character(`Record Key`),
         `Transect Position` = as.character(`Transect Position`))




# Make corrections
data.soil1 <- data.soil1 %>% 
  mutate(row = as.numeric(rownames(data.soil1)) + 1) %>% 
  filter(!row %in% row.soil1) %>% 
  bind_rows(data.soil1.fix) %>% 
  arrange(row)
data.soil2 <- data.soil2 %>% 
  mutate(row = as.numeric(rownames(data.soil2)) + 1) %>% 
  filter(!row %in% row.soil2) %>% 
  bind_rows(data.soil2.fix) %>% 
  arrange(row)

# has issues:
# data.soil3 <- data.soil3 %>% 
#   mutate(row = as.numeric(rownames(data.soil3)) + 1) %>% 
#   filter(!row %in% row.soil3) %>% 
#   bind_rows(data.soil3.fix) %>% 
#   arrange(row) %>% 
#   mutate(`Transect Position` = as.numeric(`Transect Position`))
# data.soil3 %>% 
#   filter(is.na(`Transect Position`))
# 
# data.soil4 <- data.soil4 %>% 
#   mutate(row = as.numeric(rownames(data.soil4)) + 1) %>% 
#   filter(!row %in% row.soil4) %>% 
#   bind_rows(data.soil4.fix) %>% 
#   arrange(row) %>% 
#   mutate(`Transect Position` = as.numeric(`Transect Position`))
# 
# data.soil <- bind_rows(data.soil1, data.soil2, data.soil3, data.soil4) %>% 
#   distinct(.keep_all = TRUE)



# Drop Line & Transect Position to fix soil data --------------------------

alt.soil1 <- data.soil1[, -c(9, 11)]
alt.soil2 <- data.soil2[, -c(9, 11)]
alt.soil3 <- data.soil3[, -c(9, 11)]
alt.soil4 <- data.soil4[, -c(9, 11)]

alt.soil <- bind_rows(alt.soil1, alt.soil2, alt.soil3, alt.soil4) %>% 
  distinct(.keep_all = TRUE)



# Write to CSV ------------------------------------------------------------

write_csv(data.gap,
          file = "data/raw/LDC/data-gap.csv")
write_csv(data.height,
          file = "data/raw/LDC/data-height.csv")
write_csv(data.lpi,
          file = "data/raw/LDC/data-lpi.csv")
write_csv(data.species,
          file = "data/raw/LDC/data-species-inventory.csv")
write_csv(geospecies,
          file = "data/raw/LDC/geospecies.csv")
write_csv(alt.soil,
          file = "data/raw/LDC/data-soil-stability.csv")
