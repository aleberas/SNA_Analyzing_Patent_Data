!pip install pandas python-Levenshtein pandarallel
import pandas as pd
import Levenshtein
from pandarallel import pandarallel

# Initialize pandarallel
pandarallel.initialize(progress_bar=True)

# Dataset
data = pd.read_csv('/Users/alessiabera/Desktop/data_full_inventors3.csv', encoding='latin')

# Initialize the inventor mapping dictionary
inventor_mapping = {}

# Check if the difference is only a single letter with spaces
def is_single_letter_difference(name1, name2):
    if len(name1) == len(name2):
        for i in range(len(name1)):
            if name1[i] != name2[i]:
                # Check if the differing character is a single letter with spaces around it
                if i > 0 and i < len(name1) - 1 and name1[i - 1] == ' ' and name1[i + 1] == ' ':
                    return True
                else:
                    return False
    return False


def find_standardized_name(row):
    name, wku = row['Inventor'], row['WKU']
    
    # Check if a similar name is already in the mapping
    for standard_name, standard_wku in inventor_mapping.values():
        distance = Levenshtein.distance(name, standard_name)
        
        # Check distance and WKU conditions
        if distance == 1 and not is_single_letter_difference(name, standard_name) and wku != standard_wku:
            return standard_name, standard_wku
    
    # If no similar name is found, map to itself
    return name, wku

# Apply the standardization in parallel
data[['Inventor_Standardized', 'WKU_Standardized']] = data.parallel_apply(
    lambda row: pd.Series(inventor_mapping.setdefault(
        row['Inventor'], find_standardized_name(row)
    )),
    axis=1
)


print("Standardized Data:")
print(data.head())


data.to_csv('cleaned_dataset2.csv', index=False)
