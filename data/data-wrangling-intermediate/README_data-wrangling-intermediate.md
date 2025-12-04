# README for `data/data-wrangling-intermediate/`

Created: 2025-12-04  
Updated: 2025-12-04

## Directory
### `01`
Relates to `scripts/01_exploratory-csvs-LTDL.R`
- `01_Monitoring_Desc-overflow-text.docx`
    - A Word document containing all the overflow text from the `Monitoring_Desc` column in `data/raw/downloaded/LTDL_data_csvs/Project_Info.csv`. 
    - Overflow text was created because Excel CSVs have a limit on the number of characters a single cell can hold. This problem does not happen in the GIS geodatabase version of the table.
- `01_project-info_fix-rows.csv`
    - A CSV of the fixed rows to be read into R to fix the rows in `data/raw/Project_Info_R.csv`.
    - Same as the `replacement` tab in `01_project-info_fix-rows.xlsx`.
- `01_project-info_fix-rows.xlsx`
    - A more detailed explanation of what rows need to be fixed and how.
- `01_Treatment_Effect_and_Results-overflow-text.docx`
    - A Word document containing all the overflow text from the `Treatment_Effect_and_Results` column in `data/raw/downloaded/LTDL_data_csvs/Treatment_Info.csv`. 
    - Overflow text was created because Excel CSVs have a limit on the number of characters a single cell can hold. This problem does not happen in the GIS geodatabase version of the table.
- `01_treatment-info_fix-rows.csv`
    - A CSV of the fixed rows to be read into R to fix the rows in `data/raw/Treatment_Info_R.csv`.
    - Same as the `replacement` tab in `01_treatment-info_fix-rows.xlsx`.
- `01_treatment-info_fix-rows.xlsx`
    - A more detailed explanation of what rows need to be fixed and how.

### `02`
Relates to `scripts/02_collate-LDC.R`.
- `02a_output1_soil1.csv`
- `02a_output1_soil2.csv`
- `02a_output1_soil3.csv`
- `02a_output1_soil4.csv`
- `02b_edited1_soil1.xlsx`
- `02b_edited1_soil2.xlsx`
- `02b_edited1_soil3.xlsx`
- `02b_edited1_soil4.xlsx`