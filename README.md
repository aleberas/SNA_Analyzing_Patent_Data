
# SNA_Analyzing_Patent_Data

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
   - This approach considers complex, multi-association events occurring at the same time.

## Data Preprocessing and Cleaning
- **R Script**: `sna_dataclean.R` Used for data cleaning and preparation.  
- **Python Script**: `levdist.py` Implements the Levenshtein Distance for string matching.
- **Cleaned Dataset (after applying Levenshtein Distance)**: `cleaned_dataset.csv`

## Configurations and Input Details
### Configuration 1:
- **Input Dataset for EventNet**: `input_df.csv`
- **EventNet XML**: `config1.txt`
- **Output from EventNet**: `resultconfig1.csv` Generated statistics from REM.

### Configuration 2:
- **Input Dataset for EventNet**: `input_df2.csv`
- **EventNet XML**: `config2.txt`  
- **Output from EventNet**: `resultconfig2.csv` Generated statistics from REM.

### Configuration 3:
- **Input Dataset for EventNet**: `input_df2.csv`
- **EventNet XML**: `config3.txt`  
- **Output**: `resultconfig3.csv` Generated statistics from RHEM.

## Model for EventNet Statistics
- **Cox Proportional Hazards Model**: Implemented in R for statistical analysis of event data.

## Coevolution 
- *Details pending.*
