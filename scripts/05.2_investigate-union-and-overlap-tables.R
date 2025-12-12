# Created: 2025-12-11
# Updated: 2025-12-11

# Purpose: Try to figure out what is going on with the CountOverlapping and OverlapTable tables 
#   created from ArcGIS Pro Count Overlapping Features tool after running a Union on
#   the filtered (v0.0.1) LTDL treatment polygons.

# Basically, I am trying to connect three tables created from geoprocessing in ArcGIS Pro:
#   1. The polygon Union table, which has the treatment info,
#   2. The CountOverlapping table, which has the count of the number of overlaps per unique polygon in space
#   3. The OverlapTable, which has the ObjID of the CountOverlapping table and ObjID the Union table
# 

library(tidyverse)
