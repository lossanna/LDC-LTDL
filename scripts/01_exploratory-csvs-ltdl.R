# Created: 2025-09-29
# Updated: 2026-01-06

# Purpose: Explore treatment and project info from LTDL CSVs and construct Excel spreadsheets that  
#   describe the columns for Project_Info and Treatment_Info tables. Write out v000, which has
#   fixed the issues created by overflow text of a single cell.

library(tidyverse)

# Load data ---------------------------------------------------------------

project.info.raw <- read_csv("data/raw/Project_Info_R.csv")
prjid.fix <- read_csv("data/data-wrangling-intermediate/01_project-info_fix-rows.csv")
treatment.info.raw <- read_csv("data/raw/Treatment_Info_R.csv")
trtid.fix <- read_csv("data/data-wrangling-intermediate/01_treatment-info_fix-rows.csv")

# Data wrangling ----------------------------------------------------------

# Fix rows that need replacement in Project_Info_R.csv
project.info <- project.info.raw %>% 
  filter(!Prj_ID %in% prjid.fix$Prj_ID)
project.info <- project.info %>% 
  bind_rows(prjid.fix) %>% 
  arrange(Prj_ID)

# Fix rows that need replacement in Treatment_Info_R.csv
treatment.info <- treatment.info.raw %>% 
  filter(!Trt_ID %in% trtid.fix$Trt_ID)
treatment.info <- treatment.info %>% 
  bind_rows(trtid.fix) %>% 
  arrange(Trt_ID)


# Review possible values of columns: Project ------------------------------

# Status
#   should use completed projects only
unique(project.info$Status)
count(project.info, Status)

# Prj_Start_Year
project.info %>% 
  filter(is.na(Prj_Start_Year)) # no NAs

# Prj_End_Year
project.info %>% 
  filter(is.na(Prj_End_Year)) # no NAs

# Purpose
unique(project.info$Purpose)

# Prj_Feature_Type
#   use "Polygon" only
unique(project.info$Prj_Feature_Type)

# How_Feature_Created
unique(project.info$How_Feature_Created)

# Feature_Creation_Date
#   in form of month/day/year; "00" included
unique(project.info$Feature_Creation_Date)

# Feature_Status
#   probably should use "Confirmed" only
unique(project.info$Feature_Status)
count(project.info, Feature_Status)

# Monitored
unique(project.info$Monitored)

# Major_On_Ground_Treatments
#   this column is kind of a mess - just use Treatment_Info table instead
unique(project.info$Major_On_Ground_Treatments)

prj.ground.trt <- project.info %>% 
  select(Prj_ID, Major_On_Ground_Treatments) %>% 
  separate_rows(Major_On_Ground_Treatments, sep = ",\\s*")
unique(prj.ground.trt$Major_On_Ground_Treatments)

# Major_Ground_Trt_Objectives
unique(project.info$Major_Ground_Trt_Objectives)

prj.trt.obj <- project.info %>% 
  select(Prj_ID, Major_Ground_Trt_Objectives) %>% 
  separate_rows(Major_Ground_Trt_Objectives, sep = ",\\s*")
unique(prj.trt.obj$Major_Ground_Trt_Objectives)

# Grazing_Restrict
unique(project.info$Grazing_Restrict)

# Pot_Years_not_Grazed
project.info %>% 
  filter(is.na(Pot_Years_not_Grazed))

# Livestock_Present_After_Trt
unique(project.info$Livestock_Present_After_Trt)



# Review possible values of columns: Treatment ----------------------------

# Plan_Imp
unique(treatment.info$Plan_Imp)
count(treatment.info, Plan_Imp)

# Success
unique(treatment.info$Success)

# Init_Date
#   in form of month/day/year; "00" included
unique(treatment.info$Init_Date)

# Comp_Date
#   in form of month/day/year; "00" included
unique(treatment.info$Comp_Date)

# Trt_Type_Major
unique(treatment.info$Trt_Type_Major)

# Trt_Type_Sub
unique(treatment.info$Trt_Type_Sub)

# Treatment_Type
unique(treatment.info$Treatment_Type)

# Seed_List
unique(treatment.info$Seed_List)
count(treatment.info, Seed_List)

# Seeds_or_Seedlings
unique(treatment.info$Seeds_or_Seedlings)

# Seed_List_Confirmed
unique(treatment.info$Seed_List_Confirmed)
count(treatment.info, Seed_List_Confirmed)

# Control_Areas
unique(treatment.info$Control_Areas)

# Seed_Application_Rate
unique(treatment.info$Seed_Application_Rate)

# Planned_Implementation
unique(treatment.info$Planned_Implementation)

# Trt_Feature_Type
unique(treatment.info$Trt_Feature_Type)

# Feature_Status
unique(treatment.info$Feature_Status)
count(treatment.info, Feature_Status)

# How_Feature_Created
unique(treatment.info$How_Feature_Created)

# Initiated_By
unique(treatment.info$Initiated_By)


# Examine treatment points ------------------------------------------------

trt.point <- treatment.info %>% 
  filter(Trt_Feature_Type %in% c("Point", "Multipoint"))

count(trt.point, Trt_Type_Major)
count(trt.point, Trt_Type_Sub) %>% 
  print(n = 32)



# Write out fixed CSVs as version 000 -------------------------------------

write_csv(project.info,
          file = "data/versions-from-R/01_Project-info_v000.csv")

write_csv(treatment.info,
          file = "data/versions-from-R/01_Treatment-info_v000.csv")
