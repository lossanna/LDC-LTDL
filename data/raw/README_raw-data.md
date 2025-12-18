# README for `data/raw/`

Created: 2025-09-30  
Updated: 2025-12-04

## Notes
LDC 
- I couldn't download all the LDC data for all 67,740 plots within the continental US, so I had to download it in four batches.
- Things are a little weird because when I downloaded the LDC data in batches, the coordinates columns weren't formatted correctly in the `geoindicators.csv`. You can, however, download only the geoindicators data for all 67,740 plots directly from the website, and when I did that, the coordinates columns were formatted correctly.
- Also, there were some issues in the raw LDC `data-soil-stability.csv` files, and so for now I have gone with the easy fix of dropping the two problematic columns rather than trying to fix everything manually.

LTDL
- There were also issues with the LTDL `Project_Info.csv` and `Treatment_Info.csv` files because they were probably tables taken directly from ArcGIS Pro, but in Excel there is a limit on the number of a characters a single cell can have, so in a couple of instances when there was too much text for a single cell, a new row was created (and then cells were thereafter delinated by commas in the text).
    - I had to create new versions of these files where the extra row was deleted, as well as additional files to handle the manual fixes (see `data-wrangling-intermediate/` folder).

## Data downloads
- Land Treatment Digital Library:
    - Downloaded from: https://doi.org/10.5066/P98OBOLS on 2025-06-24 (v7.0, released Sept 2024; download `LTDL_Sept_2024_Release.zip` to get folder of CSVs).
- Landscape Data Commons:
    - Downloaded from https://landscapedatacommons.org/ldc-map on 2025-09-30.
        - Four data packets downloaded in sections (see `Batches-of-LDC-data-downloaded.pptx`).
            - Select plots on map -> Download -> Data packet
        - Download of geoindicators for all plots (to get coordinates formatted properly, because they weren't in data packet version).
            - Select plots on map -> Download -> Indicators


## Directory
- `downloaded/`
    - Raw downloaded files, not altered in any way.
    - `ldc-data-2025-09-30/`
        - Direct download of geoindicators data for all plots, downloaded directly from LDC website as single file.
        - `geoindicators.csv`
            - Has coordinate columns formatted correctly.
        - `table.schema.csv`
    - LDC data packet downloads (see below for more information):
        - `ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-152944/`
        - `ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153051/`
        - `ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-153912/`
        - `ldc-lossanna-dot-nmsu-at-gmail-dot-com-20250930-172514/`
    - `LTDL_data_csvs/` (see below for more information)
    - `Batches-of-LDC-data-downloaded.pptx`
        - Screenshots of the four batches of LDC data downloaded.
- `LDC/` (see below for more information)
- `Project_Info_Columns.xlsx`
    - A spreadsheet to describe each of the columns in the `Project_Info` table.
- `Project_Info_R.csv`
    - Manually edited version of `Project_Info.csv` (from LTDL CSVs) to delete extra rows created from overflow text cells; created so it is easier to read into R (see `data/data-wrangling-intermediate/01_project-info_fix-rows.xlsx`). Still needs to be fixed in R with the `01_project-info_fix-rows.csv` file.
- `Treatment_Info_columns.xlsx`
    - A spreadsheet to describe each of the columns in the `Treatment_Info` table.
- `Treatment_Info_R.csv`
    - Manually edited version of `Treatment_Info.csv` (from LTDL CSVs) to delete extra rows created from overflow text cells; created so it is easier to read into R (see `data/data-wrangling-intermediate/01_treatment-info_fix-rows.xlsx`). Still needs to be fixed in R with the `01_treatment-info_fix-rows.csv` file.

### `LDC/`
- Collated Landscape Data Commons data, which was downloaded from data packets (see below).
- CSVs produced from `02_collate-ldc.R`:
    - `data-gap.csv`
    - `data-height.csv`
    - `data-lpi.csv`
    - `data-species-inventory.csv`
    - `data-soil-stability.csv`
    - `geospecies.csv`
- Other CSVs:
    - `geoindicators.csv`: This was downloaded directly from LDC website (same as the file in `downloaded/ldc-data-202-09-30/` folder) and includes all 61,740 plots of the continental US, because the data packet download didn't have coordinates formatted correctly.
    - `table-schema.csv`: This was included in all the data packet downloads and is the same for each packet (it describes the columns for each of the data tables).
- The `LDC-soil-fix/` folder is a kind of intermediate data wrangling folder with fixes for the `data-soil.csv` files from the batch downloads to fix small typos (these corrections aren't enough to warrant actual data cleaning and cleaned data).

### LDC data packet downloads
- In the format `ldc-lossanna-dot-nmsu-at-gmail-dot-com-xxxxxxxx-xxxxxx/`.
- Includes the following files:
    - `table-metadata/table-schema.csv` (same for all four batches)
    - `data-gap.csv`
    - `data-height.csv`
    - `data-lpi.csv`
    - `data-soil-stability.csv`
    - `data-species-inventory.csv`
    - `geoindicators.csv` (not used because coordinates aren't formatted correctly)
    - `geospecies.csv`

### `LTDL_data_csvs/`
- CSV format of LTDL data. I think it was formatted for ArcGIS, so some of the formatting doesn't transfer great (such as causing overflow text cells from having too much text in one cell).
- Includes the following files:
    - `Equipment_Used.csv`
    - `Herbicide.csv`
    - `LTDL_Project_Lines.csv`
    - `LTDL_Project_Points.csv`
    - `LTDL_Project_Polygons.csv`
    - `LTDL_Treatment_Lines.csv`
    - `LTDL_Treatment_Points.csv`
    - `LTDL_Treatment_Polygons.csv`
    - `Project_Identifiers.csv`
    - `Project_Info.csv` (not used because overflow text causes extra rows)
    - `Related_Project.csv`
    - `Related_Treatments.csv`
    - `Seed_Species.csv`
    - `Seed_Species_Vendor_Info.csv`
    - `Treatment_Info.csv` (not used because overflow text causes extra rows)