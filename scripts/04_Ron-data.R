# Created: 2025-12-04
# Updated: 2025-12-04

# Purpose: Explore the data Ron used for analysis and construct Excel spreadsheets that  
#   describe the columns.

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

# fire_frq
unique(ron.data$fire_frq)


# Trt_Type_M
unique(ron.data$Trt_Type_M)

# Trt_Type_S
unique(ron.data$Trt_Type_S)

# treatment
unique(ron.data$treatment)

# rcnt_ptrt_type
unique(ron.data$rcnt_ptrt_type)

# fire_occ
unique(ron.data$fire_occ)

# fire_binary
unique(ron.data$fire_binary)

# trt_control
unique(ron.data$trt_control)
