# README for `scripts/`

Created: 2025-12-04  
Updated: 2025-12-17

A list of scripts, including their purpose, output files (includes entire file path), and any input files created from ArcGIS geoprocessing (from `data/GIS-exports/` folder).


## Directory
### `01_exploratory-csvs-LTDL.R`
- <u>Purpose:</u> Explore treatment and project info from LTDL CSVs and construct Excel spreadsheets that describe the columns for Project_Info and Treatment_Info tables. Write out v000, which has fixed the issues created by overflow text of a single cell.
- <u>Outputs:</u>
    - `data/LTDL-versions/01_Project-info_v000.csv`
    - `data/LTDL-versions/01_Treatment-info_v000.csv`


### `02_collate-LDC.R`
- <u>Purpose:</u> Collate Landscape Data Commons data from the four batches of downloads into single CSV for each data table, and write new CSV.
- <u>Outputs:</u>
    - `data/raw/LDC/data-gap.csv`
    - `data/raw/LDC/data-height.csv`
    - `data/raw/LDC/data-lpi.csv`
    - `data/raw/LDC/data-species-inventory.csv`
    - `data/raw/LDC/geospecies.csv`
    - `data/raw/LDC/data-soil-stability.csv`


### `03_LDC-to-shapefile.R`
- <u>Purpose:</u> Write the LDC points to shapefiles.
- <u>Outputs:</u>
    - Entire `data/LDC-points/` folder, which includes `03_LDC-points.shp`


### `04_Ron-data.R`
- <u>Purpose:</u> Explore the data Ron used for analysis and construct Excel spreadsheet that describes the columns.


### `05.1_treatment-info_v001.R`
- <u>Purpose:</u> Complete initial data cleaning to create Treatment_Info v001.
-  Filtered for polygons, implemented plans, confirmed features only; also cleaned dates.
- <u>Outputs:</u>
    - `data/LTDL-versions/05.1_Treatment-info_v001.csv`
    - `data/LTDL-versions/05.1_Treatment-info_v001-gisjoin.csv`


### `05.2_investigate-union-and-overlap-tables.R`
- <u>Purpose:</u> Try to figure out what is going on with the CountOverlapping and OverlapTable tables created from ArcGIS Pro Count Overlapping Features tool after running a Union on the filtered (v001) LTDL treatment polygons.
- <u>ArcGIS geoprocessing inputs:</u> (from `data/GIS-exports/`)
    - `001_TrtPoly001-Union_export.csv`
    - `001_TrtPoly001-Union-CountOverlapping_export.csv`
    - `001_TrtPoly001-Union-OverlapTable_export.csv`
    - `001_TrtPoly001_LDC_SpatialJoin_export.csv`


### `05.3_treatment-info_v002.R`
- <u>Purpose:</u> Additional treatment filtering to create Treatment_info v002.
- Filtered out prescribed burns and other treatments that likely did not impact vegetation or were not described well enough to understand what was happening, as well as treatments with only 1 or 2 polygons in total.
- <u>Outputs:</u>
    - `data/LTDL-versions/05.3_Treatment-info_v002.csv`
    - `data/LTDL-versions/05.3_Treatment-info_v002-gisjoin.csv`


### `05.4_most_recent_v003.R`
