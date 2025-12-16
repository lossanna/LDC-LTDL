# Created: 2025-12-11
# Updated: 2025-12-16

# Purpose: Try to figure out what is going on with the CountOverlapping and OverlapTable tables 
#   created from ArcGIS Pro Count Overlapping Features tool after running a Union on
#   the filtered (v001) LTDL treatment polygons.

# Basically, I am trying to connect three tables created from geoprocessing in ArcGIS Pro:
#   1. The polygon Union table, which has the treatment info,
#   2. The CountOverlapping table, which has the count of the number of overlaps per unique polygon in space
#   3. The OverlapTable, which has the ObjectID of the CountOverlapping table and ObjectID the Union table

# Ultimately, I want a table with an ObjectID that connects to treatment info (includes overlaps), 
#   an ObjectID that is unique in space (doesn't have overlaps), and the count of the number of overlaps.
# Doing a left_join() between all three tables creates a table that has all the polygons with treatment info,
#   as well as if they are unique overlaps in space.

# A few polygons in the Union table were weirdly missing from the OverlapTable table, but those polygons
#   don't contain LDC points, so they won't be used for further analysis, anyway.

library(tidyverse)

# Load data ---------------------------------------------------------------

trt.union <- read_csv("data/GIS-exports/001_TrtPoly001-Union_export.csv")
trt.countoverlapping <- read_csv("data/GIS-exports/001_TrtPoly001-Union-CountOverlapping_export.csv")
trt.overlaptable <- read_csv("data/GIS-exports/001_TrtPoly001-Union-OverlapTable_export.csv")

trt.ldc.sjoin <- read_csv("data/GIS-exports/001_TrtPoly001_LDC_SpatialJoin_export.csv")


# Find number of unique polygons in space ---------------------------------

# Check if CountOverlapping has only unique geometry
trt.countoverlapping.unqgeo <- trt.countoverlapping %>% 
  select(Shape_Area, Shape_Length) %>% 
  distinct(.keep_all = TRUE)
nrow(trt.countoverlapping.raw) == nrow(trt.countoverlapping.unqgeo)
nrow(trt.countoverlapping.raw) - nrow(trt.countoverlapping.unqgeo) # one row has identical geometry

#   Examine extra row in CountOverlapping
trt.countoverlapping %>%
  group_by(Shape_Length, Shape_Area) %>%
  filter(n() > 1) %>%
  arrange(Shape_Length, Shape_Area)
#   Manually check these polygons in ArcGIS Pro and see that they are not overlapping
#     (they are right next to each other and literally are just the same size);
#   this means that CountOverlapping is in fact every polygon that occupies unique space.


# Connect Union table with treatment info with OverlapTable ---------------

# Join Union table with OverlapTable (which contains ObjectID_CountOverlapping)
trt.union.join <- trt.union %>% 
  left_join(trt.overlaptable)

# Join Union table with CountOverlapping
trt.union.join <- trt.union.join %>% 
  left_join(trt.countoverlapping)

#   Look for rows in Union table missing from OverlapTable
trt.union.OTmissing <- trt.union.join %>% 
  filter(is.na(ObjectID_CountOverlapping))
nrow(trt.union.OTmissing) + nrow(trt.overlaptable) == nrow(trt.union)



# Examine treatment polygons with LDC points ------------------------------

# Look to see if the rows missing from the Union table contain LDC points
trt.ldc.sjoin %>% 
  filter(ObjectID_Union %in% trt.union.OTmissing$ObjectID_Union)
#   No polygons with missing overlap info also contain LDC points, so trt.union.OTmissing does not
#     need to be addressed
