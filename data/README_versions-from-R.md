# README for `data/versions-from-R/`

Created: 2025-12-04  
Updated: 2026-01-09

## Notes
- Files are named starting with the script number from which they were produced, and ending with the version number. The version number connects to the same number map in the ArcGIS Pro project `01_LDC-LTDL`.
- This README file is kept in the `data/` folder and not the `data/versions-from-R/` folder because the latter is not pushed to GitHub, but I would like to have version control for the README, which will document all the data cleaning changes for everything produced from R intended to be used in ArcGIS Pro analysis.
- Because data cleaning will have many iterations and occur over multiple scripts, this folder is used to document those changes and versions. 
    - CSVs in this folder are written out at the end of the script as a quasi-equivalent of "cleaned" version of one of the original LTDL CSVs (or other data). 
    - `data-wrangling-intermediate/` folder contains files CSVs written out in the body of the script or other intermediate files.
- The README contains a summary of each version and a directory; for more detailed notes, see the [Google Notes doc](https://docs.google.com/document/d/1gshsoIPIgJ5tUT7jBK2LmrB_ZmTPzvl8P9q5xpuQqKA/edit?tab=t.0).



## Versions

### v000
- <u>Script:</u> `01_exploratory-csvs-LTDL.R`
- All rows from original data; only thing changed is that the problems caused by overflow cells have been corrected for `Project_Info` and `Treatment_Info` tables.


### v001
- <u>Script:</u> `05.1_treatment-info_v001.R`
- Filtered to only include polygons, implemented plans, and confirmed features.
- Estimated dates of initiation and completion added.
- CSVs ending in `_v001-gisjoin` are versions with only a few selected columns, intended to be loaded into ArcGIS and joined to LTDL polygon features to append some useful data to the features (makes it easier to understanding what is going on when viewing a pop-up window).
- For more information, see [Google Doc notes (section bookmark)](https://docs.google.com/document/d/1gshsoIPIgJ5tUT7jBK2LmrB_ZmTPzvl8P9q5xpuQqKA/edit?tab=t.0#bookmark=id.1ryfqcz8wuqj).

### v002
- <u>Script:</u> `05.3_treatment-info_v002.R`
- Additional filtering of treatment polygons to exclude prescribed burns and other treatments that likely did not impact vegetation or were not described well enough to understand what was happening, as well as treatments with only 1 or 2 polygons in total.
- For more information, see [Google Doc notes (section bookmark)](https://docs.google.com/document/d/1gshsoIPIgJ5tUT7jBK2LmrB_ZmTPzvl8P9q5xpuQqKA/edit?tab=t.0#bookmark=id.hdgg4s980amh).

### v003
- <u>Script:</u> `05.4_most-recent_v003.R`
- Cleaning on LTDL polygons incomplete and abandoned because I decided I didn't want to do it manually and will figure out another way.
- v003 for LDC points was created, though, and filters out any repeat points that occupy the same location, retaining only the most recent monitoring.
    - Rows with no `DateVisted` value were removed.
    - For rules about decisions regarding multiple rows/instances of the same `DateVisted` value, see the `data-wrangling-intermediate/05.4b_edited3_LDC_multiple-same-DateVisted.xlsx` spreadsheet (only one row per location was preserved).
- For more information (LDC points), see [Google Doc notes (section bookmark)](https://docs.google.com/document/d/1gshsoIPIgJ5tUT7jBK2LmrB_ZmTPzvl8P9q5xpuQqKA/edit?tab=t.0#bookmark=id.wlqh0ktljytv).

### v004
- <u>Script:</u> `05.5_investigate-trt-combos_v004.R`
- Incomplete and abandoned because I decided I would add in the missing prescribed fire polygons from the combined fire dataset and then reexamine possible treatment combos.

### v005
- <u>Script:</u> `05.6_prescribed-fires-added_v003.R`
- Treatment info (GIS join columns) for prescribed fire polygons included in the USGS Combined Wildland Fire Datasets but not in the LTDL dataset.
- For more information, see [Google Doc notes (section bookmark)](https://docs.google.com/document/d/1gshsoIPIgJ5tUT7jBK2LmrB_ZmTPzvl8P9q5xpuQqKA/edit?tab=t.0#bookmark=id.e44g2o456sup).

### v006
- <u>Script:</u> `05.7_treatment-info_v006`
 - Additional prescribed fires from Combined Wildland Fires dataset added; single treatment (based on `Trt_Type_Sub`) applied to each polygon occupying unique space, including 7 treatment combinations (treated as own separate categories).
- For more information, see [Google Doc notes (section bookmark)](https://docs.google.com/document/d/1gshsoIPIgJ5tUT7jBK2LmrB_ZmTPzvl8P9q5xpuQqKA/edit?tab=t.0#bookmark=id.ela71hc2ej2).


## Directory
- `01_Project-info_v000.csv` (created 2025-12-04)
- `01_Treatment-info_v000.csv` (created 2025-12-04)
- `05.1_Treatment-info_v001.csv` (created 2025-12-08)
- `05.1_Treatment-info_v001-gisjoin.csv` (created 2025-12-09)
- `05.3_Treatment-info_v002.csv` (created 2025-12-16)
- `05.3_Treatment-info_v002-gisjoin.csv` (created 2025-12-16)
- `05.4_LDC-points_v003.csv` (created 2026-01-07)
- `05.4_LDC-points_v003-gisjoin.csv` (created 2026-01-07)
- `05.6_RxFiresAdded-treatment-info_v005.csv` (created 2026-01-07)
- `05.6_RxFiresAdded-treatment-info_v005-gisjoin.csv` (created 2026-01-07)
- `05.7_all-treatments-used-to-create-TreatmentInfo006.csv` (created 2026-01-09)
- `05.7_treatment-info_v006.csv` (created 2026-01-08)
