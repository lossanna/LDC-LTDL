# README for `data/LTDL-versions/`

Created: 2025-12-04  
Updated: 2025-12-11

## Notes
- This file is kept in the `data/` folder and not the `data/LTDL-versions/` folder because the latter is not pushed to GitHub, but I would like to have version control for the README, which will document all the data cleaning changes for the LTDL data.
- Because data cleaning will have many iterations and occur over multiple scripts, this folder is used to document those changes and versions. 
    - CSVs in this folder are written out at the end of the script as a quasi-equivalent of "cleaned" version of one of the original LTDL CSVs. 
    - `data-wrangling-intermediate/` folder contains files CSVs written out in the body of the script or other intermediate files.
- Files are named starting with the script number from which they were produced, and ending with the version number. The version number connects to the same number map in the ArcGIS Pro project `01_LDC-LTDL.gdb`.

## Versions

### v000 (all)
- All rows from original data; only thing changed is that the problems caused by overflow cells have been corrected for `Project_Info` and `Treatment_Info` tables.


### v001
- Filtered to only include polygons, implemented plans, and comfirmed features.
- Estimated dates of initiation and completion added.
- CSVs ending in `_v001-gisjoin` are versions with only a few selected columns, intended to be loaded into ArcGIS and joined to LTDL polygon features to append some useful data to the features (makes it easier to understanding what is going on when viewing a pop-up window).

## Directory
- `01_Project-info_v000.csv` (created 2025-12-04)
- `01_Treatment-info_v000csv` (created 2025-12-04)
- `05.1_Treatment-info_v001.csv` (created 2025-12-08)
- `05.1_Treatment-info_v001-gisjoin.csv` (created 2025-12-09)