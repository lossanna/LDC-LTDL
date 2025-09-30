# Created: 2025-09-30
# Updated: 2025-09-30

# Purpose: Collate Landscape Data Commons data from the four batches of downloads into single CSV
#   for each data table, and write new CSV.
#   (Except for geoindicators, because I downloaded all 61,740 plots directly online [not through data packet]
#     because the coordinates weren't formatted correctly in the data packet version; and also not for soil stability,
#     because there appear to be some problems with the data and I don't think I really need that data right now,
#     anyway.)

library(tidyverse)

# Load data ---------------------------------------------------------------

# Batch 1
data.gap1 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/data-gap.csv")
data.height1 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/data-height.csv")
data.lpi1 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/data-lpi.csv")
data.soil1 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/data-soil-stability.csv")
data.species1 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/data-species-inventory.csv")
geoindicators1 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/geoindicators.csv")
geospecies1 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/geospecies.csv")

# Batch 2
data.gap2 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/data-gap.csv")
data.height2 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/data-height.csv")
data.lpi2 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/data-lpi.csv")
data.soil2 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/data-soil-stability.csv")
data.species2 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/data-species-inventory.csv")
geoindicators2 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/geoindicators.csv")
geospecies2 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/geospecies.csv")

# Batch 3
data.gap3 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/data-gap.csv")
data.height3 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/data-height.csv")
data.lpi3 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/data-lpi.csv")
data.soil3 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/data-soil-stability.csv")
data.species3 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/data-species-inventory.csv")
geoindicators3 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/geoindicators.csv")
geospecies3 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/geospecies.csv")

# Batch 4
data.gap4 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/data-gap.csv")
data.height4 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/data-height.csv")
data.lpi4 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/data-lpi.csv")
data.soil4 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/data-soil-stability.csv")
data.species4 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/data-species-inventory.csv")
geoindicators4 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/geoindicators.csv")
geospecies4 <- read_csv("data/raw/ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/geospecies.csv")


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

# Inspect data.soil
#   something is going on that I will figure out later lol (binding gives error)
problems(data.soil1)
problems(data.soil2)
problems(data.soil3)
problems(data.soil4)

# data.soil <- bind_rows(data.soil1, data.soil2, data.soil3, data.soil4) %>% 
#   distinct(.keep_all = TRUE)

# Combine data.species
data.species <- bind_rows(data.species1, data.species2, data.species3, data.species4) %>% 
  distinct(.keep_all = TRUE)

# Combine geospecies
geospecies <- bind_rows(geospecies1, geospecies2, geospecies3, geospecies4) %>% 
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
