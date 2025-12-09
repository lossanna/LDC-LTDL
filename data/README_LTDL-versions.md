# README for `data/LTDL-versions/`

Created: 2025-12-04  
Updated: 2025-12-09

## Notes
- This file is kept in the `data/` folder and not the `data/LTDL-versions/` folder because the latter is not pushed to GitHub, but I would like to have version control for the README, which will document all the data cleaning changes for the LTDL data.
- Because data cleaning will have many iterations and occur over multiple scripts, this folder is used to document those changes and versions. 
    - CSVs in this folder are written out at the end of the script as a quasi-equivalent of "cleaned" version of one of the original LTDL CSVs. 
    - `data-wrangling-intermediate/` folder contains files CSVs written out in the body of the script or other intermediate files.
- Files are named starting with the script number from which they were produced, and ending with the version number.

## Versions

### v0.0.0
- All rows from original data; only thing changed is that the problems caused by overflow cells have been corrected for `Project_Info` and `Treatment_Info` tables.
- CSVs ending in `_v0.0.0gisjoin` are versions with only a few selected columns, intended to be loaded into ArcGIS and joined to LTDL point/polygon/line features to append some useful data to the features (makes it easier to understanding what is going on when viewing a pop-up window).

### v0.0.1


## Directory
- `01_Project-info_v0.0.0.csv` (created 2025-12-04)
- `01_Project-info_v0.0.0gisjoin.csv` (created 2025-12-09)
- `01_Treatment-info_v0.0.0.csv` (created 2025-12-04)
- `01_Treatment-info_v0.0.0gisjoin.csv` (created 2025-12-09)