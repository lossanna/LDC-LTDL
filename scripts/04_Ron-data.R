# Created: 2025-12-04
# Updated: 2025-12-04

# Purpose: Explore the data Ron used for analysis.

library(tidyverse)

# Load data ---------------------------------------------------------------

ron.data <- readRDS("data/from-Ron/allDATA_trts_20250910.RDS")


# Review possible values of columns ---------------------------------------

str(ron.data)

# program
unique(ron.data$program)

# mlra
unique(ron.data$mlra)

# mlra_name
unique(ron.data$mlra_name)
