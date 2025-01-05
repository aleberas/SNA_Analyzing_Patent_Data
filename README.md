
# SNA Project: Analyzing Patent Data

## Overview
The aim of this project is to create and analyze a bipartite graph that represents the relationships between inventors and the International Classification of Patents (ICL) associated with their patents.

### Network Structure
- The network is **bipartite**, meaning edges exist only between nodes of different sets (i.e., between inventors and ICL classes) and not within the same set. 
- An edge connects an inventor node to an ICL class node if the inventor contributed to a patent classified under that technological class. 
- The network is **directed**, as the relationship between the two sets of nodes implies a specific direction: an inventor contributes to a patent, which is then classified under an ICL class.

## Methodology

### Configurations and Models
1. **First Two Configurations:**  
   We employed **Relational Event Models (REM)** to capture pairwise interactions over time. In this model:
   - A source node (e.g., inventor) connects to a single target node (e.g., ICL class) in a one-to-one relationship.

2. **Third Configuration:**  
   We extended the analysis to a **Relational Hyperevent Model (RHEM)**. This model accounts for events where:
   - A single source node (e.g., inventor) connects simultaneously to multiple target nodes (e.g., multiple ICL classes).
   - This approach considers multi-association events occurring at the same time.


## Data Preprocessing and Cleaning
- **Folder `INPUT_DATA_REDUCED`**: contains data about patents categorized by age.
- **R Script**: `sna_dataclean.R` Used for data cleaning and preparation of the network.
- **Python Script**: `levdist.py` Implements the Levenshtein Distance for string matching.
- **Cleaned Dataset (after applying Levenshtein Distance)**: [`cleaned_dataset.csv`](https://usi365.sharepoint.com/:x:/s/SNAProject/Ef1jzjqsx8VDto9HHC7H1g4BCQLDJzfParvioAG-8CktvA?e=iz5T6K)

## Configurations, Input and Output Details
### Configuration 1:
- **Input Dataset for EventNet**: [`input_df.csv`](https://usi365.sharepoint.com/:x:/s/SNAProject/ETjy0UYSpTpDrZhjJc8x8BoBl36K9FhjoR6LwDX-wg3uXA?e=0inyMh)
- **EventNet XML**: `config1.txt`
- **Output from EventNet**: [`output_config1.csv`](https://usi365.sharepoint.com/:x:/s/SNAProject/EV5RUj7p97tBo4LHiI1UpogBZgHzIStwVEj5hzn_uzcr-w?e=dK6fxr) Generated statistics from REM. 

### Configuration 2:
- **Input Dataset for EventNet**: `input_df2.csv`
- **EventNet XML**: `config2.txt`  
- **Output from EventNet**: `resultconfig2.csv` Generated statistics from REM.

### Configuration 3:
- **Input Dataset for EventNet**: `input_df2.csv` (Same as Configuration 2).
- **EventNet XML**: `config3.txt`  
- **Output from EventNet**: `resultconfig3.csv` Generated statistics from RHEM.

### Model for EventNet Statistics
- **Cox Proportional Hazards Model**: `coxph.R` Implemented in R for statistical analysis of event data (used for all the three configuration with different statistics).

### Coevolution
- **Stratified Random Sampling R Code**: `stratified.R`
- **Input Dataset for EventNet**: `sampledataset.csv`.
- **EventNet XML**: `coevolution_config.txt`  

*Note that some CSV files were too large; you can access them via SharePoint by clicking the provided links.*

The **Report** for the second submission is available in `ASN_report.pdf`
The **Final Version of the Report** is available in`ASN_final_report.pdf`
