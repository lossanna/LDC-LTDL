# Created: 2025-12-16
# Updated: 2025-12-16

# Purpose: Additional treatment filtering to create Treatment_info v002.

# Remove:
# 1. Prescribed burns (3430)
# 2. Cultural Protection treatments (17)
# 3. Monitoring treatments (40)
# 4. General Site Preparation (41)
# 5. Other Treatment: Other (See Notes) (165)
# 6. "Experimental Plots: Multiple Treatments" (11)
# 7. Treatment_Type with only 1-2 polygons of that type (45)


library(tidyverse)

# Load data ---------------------------------------------------------------

treatment.info.001 <- read_csv("data/LTDL-versions/05.1_Treatment-info_v001.csv")


# Data cleaning -----------------------------------------------------------

## Inspect treatment types ------------------------------------------------

# Inspect major treatment types
unique(treatment.info.001$Trt_Type_Major)

# Inspect sub treatment types
unique(treatment.info.001$Trt_Type_Sub)

# Inspect treatment types
unique(treatment.info.001$Treatment_Type)


# Look for prescribed burn treatments
prescribed.burn <- treatment.info.001 %>% 
  filter(Trt_Type_Major == "Prescribed Burn")
unique(prescribed.burn$Trt_Type_Sub)

# Inspect cultural treatments
cultural <- treatment.info.001 %>% 
  filter(Trt_Type_Major == "Cultural Protection")

# Inspect "Other" treatments
other.trt <- treatment.info.001 %>% 
  filter(Trt_Type_Major == "Other")
unique(other.trt$Trt_Type_Sub)

# Look for monitoring treatments
monitoring <- treatment.info.001 %>% 
  filter(str_detect(Treatment_Type, "Monitor"))

# Inspect "General Site Preparation"
general.site.prep <- treatment.info.001 %>% 
  filter(Treatment_Type == "General Site Preparation")

# Inspect "Other Treatment: Other (See Notes)" 
other.trt.other <- treatment.info.001 %>% 
  filter(Treatment_Type == "Other Treatment: Other (See Notes)")

# Inspect "Experimental Plots: Multiple Treatments"
exp.plots <- treatment.info.001 %>% 
  filter(Treatment_Type == "Experimental Plots: Multiple Treatments")


# Treatment types with only 1 or 2 polygons
trt.type.2 <- treatment.info.001 %>% 
  group_by(Treatment_Type) %>% 
  filter(n() <= 2) 
unique(trt.type.2$Treatment_Type)




## Remove selected treatments ---------------------------------------------

treatment.info <- treatment.info.001 %>% 
  filter(!Trt_ID %in% c(prescribed.burn$Trt_ID, cultural$Trt_ID, monitoring$Trt_ID,
                        general.site.prep$Trt_ID, other.trt.other$Trt_ID, exp.plots$Trt_ID,
                        trt.type.2$Trt_ID))
unique(treatment.info$Treatment_Type)


# Separate out columns for GIS join ---------------------------------------

treatment.info.gisjoin <- treatment.info %>% 
  select(Prj_ID, Trt_ID, init_date_est, comp_date_est, Trt_Type_Major, Trt_Type_Sub, Treatment_Type)



# Write out as v001 -------------------------------------------------------

write_csv(treatment.info,
          file = "data/LTDL-versions/05.3_Treatment-info_v002.csv")

write_csv(treatment.info.gisjoin,
          file = "data/LTDL-versions/05.3_Treatment-info_v002-gisjoin.csv")


save.image("RData/05.3_treatment-info_v002.RData")
