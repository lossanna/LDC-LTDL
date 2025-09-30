# Created: 2025-09-29
# Updated: 2025-09-30

# Purpose: Explore treatment and project info from LTDL CSVs.

library(tidyverse)

# Load data ---------------------------------------------------------------

project.info.raw <- read_csv("data/raw/Project_Info_LO.csv")
prjid.fix <- read_csv("data/data-wrangling-intermediate/01_project-info_fix-rows.csv")
treatment.info.raw <- read_csv("data/raw/Treatment_Info_LO.csv")
trtid.fix <- read_csv("data/data-wrangling-intermediate/01_treatment-info_fix-rows.csv")

# Data wrangling ----------------------------------------------------------

# Fix rows that need replacement - Project_Info.csv
project.info <- project.info.raw %>% 
  filter(!Prj_ID %in% prjid.fix$Prj_ID)
project.info <- project.info %>% 
  bind_rows(prjid.fix) %>% 
  arrange(Prj_ID)

# Fix rows that need replacement - Treatment_Info.csv
treatment.info <- treatment.info.raw %>% 
  filter(!Trt_ID %in% trtid.fix$Trt_ID)
treatment.info <- treatment.info %>% 
  bind_rows(trtid.fix) %>% 
  arrange(Trt_ID)


# Review possible values of columns ---------------------------------------

# Status
unique(project.info$Status)

# Purpose
unique(project.info$Purpose)

# How_Feature_Created
unique(project.info$How_Feature_Created)

# Feature_Status
unique(project.info$Feature_Status)


