# Created: 2025-12-11
# Updated: 2025-12-12

# Purpose: Try to figure out what is going on with the CountOverlapping and OverlapTable tables 
#   created from ArcGIS Pro Count Overlapping Features tool after running a Union on
#   the filtered (v0.0.1) LTDL treatment polygons.

# Basically, I am trying to connect three tables created from geoprocessing in ArcGIS Pro:
#   1. The polygon Union table, which has the treatment info,
#   2. The CountOverlapping table, which has the count of the number of overlaps per unique polygon in space
#   3. The OverlapTable, which has the ObjID of the CountOverlapping table and ObjID the Union table


library(tidyverse)

# Load data ---------------------------------------------------------------

trt.union.raw <- read_csv("data/GIS-exports/001_Trt-poly-001-union_export.csv")
trt.countoverlapping.raw <- read_csv("data/GIS-exports/001_Trt-poly-001-union-countoverlapping_export.csv")
trt.overlaptable.raw <- read_csv("data/GIS-exports/001_Trt-poly-001-union-overlaptable_export.csv")

ldc.trt.sjoin.raw <- read_csv("data/GIS-exports/001_LDC_Trt_SpatialJoin.csv")


# Find number of unique polygons in space ---------------------------------

# Check if CountOverlapping has only unique geometry
trt.countoverlapping.unqgeo <- trt.countoverlapping.raw %>% 
  select(SHAPE_Area, SHAPE_Length) %>% 
  distinct(.keep_all = TRUE)
nrow(trt.countoverlapping.raw) == nrow(trt.countoverlapping.unqgeo)
nrow(trt.countoverlapping.raw) - nrow(trt.countoverlapping.unqgeo) # one row has identical geometry

#   Examine extra row in CountOverlapping
trt.countoverlapping.raw %>%
  group_by(SHAPE_Length, SHAPE_Area) %>%
  filter(n() > 1) %>%
  arrange(SHAPE_Length, SHAPE_Area)
#   Manually check these polygons in ArcGIS Pro and see that they are not overlapping
#     (they are right next to each other and literally are just the same size);
#   this means that CountOverlapping is in fact every polygon that occupies unique space.


# Connect Union table with treatment info with OverlapTable ---------------

# Rename ObjectID columns to allow for join
trt.overlaptable <- trt.overlaptable.raw %>% 
  rename(ObjectID_CountOverlapping = OVERLAP_OID,
         ObjectID_Union = ORIG_OID)

# Join Union table with OverlapTable (which contains ObjectID_CountOverlapping)
trt.union.join <- trt.union.raw %>% 
  left_join(trt.overlaptable)

# Join Union table with CountOverlapping
trt.union.join <- trt.union.join %>% 
  left_join(trt.countoverlapping.raw)

#   Look for rows in Union table missing from OverlapTable
trt.union.OTmissing <- trt.union.join %>% 
  filter(is.na(ObjectID_CountOverlapping))
nrow(trt.union.OTmissing) + nrow(trt.overlaptable) == nrow(trt.union.raw)




# Examine treatment polygons with LDC points ------------------------------

# Look to see if the rows missing from the Union table contain LDC points
ldc.trt.sjoin.raw %>% 
  filter(ObjectID_Union %in% trt.union.OTmissing$ObjectID_Union)
#   No polygons with missing overlap info also contain LDC points, so trt.union.OTmissing does not
#     need to be addressed

# Find polygons that contain LDC points
trt.with.ldc <- trt.union.join %>% 
  filter(ObjectID_Union %in% ldc.trt.sjoin.raw$ObjectID_Union)
