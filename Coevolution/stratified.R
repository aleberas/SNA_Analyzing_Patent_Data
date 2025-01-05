library(dplyr)
df<-merged_dataset_INPUT

filtered_df <- df %>%
  filter(App_Date >= as.Date("1981-01-01") & App_Date <= as.Date("1984-12-31"))

# View the filtered data
print(filtered_df)
write.csv(filtered_df,'filtered_df82.csv',row.names = FALSE)
# Convert the 'App_Date' column in the dataset to the Date format (YYYY-MM-DD).
filtered_df$App_Date <- as.Date(filtered_df$App_Date, format = "%Y-%m-%d")

# Extract the year from the 'App_Date' column and create a new column called 'Year'.
filtered_df$Year <- format(filtered_df$App_Date, "%Y")

# Step 1: Filter for rows of type 'inv.sub.class'.
inv_sub_class <- filtered_df[filtered_df$type == 'inv.sub.class', ]

# Calculate the total number of rows to sample.
total_sample_size <- 5000
library(dplyr)

submission_counts <- inv_sub_class %>%
  group_by(Year) %>%
  summarize(count = n()) %>%
  mutate(
    proportion = count / sum(count),                 # Proportion of submissions for each year.
    sample_size = floor(proportion * total_sample_size) # Compute sample sizes (rounded down).
  )


inv_sub_class <- inv_sub_class %>%
  left_join(submission_counts, by = "Year")

# Perform stratified random sampling:
# - For each year, randomly sample the calculated number of rows (without replacement).
# - Use set.seed() to ensure the results are reproducible.
set.seed(123) # Ensures consistent results when the code is re-run.
sampled_inv_sub_class <- inv_sub_class %>%
  group_by(Year) %>%
  sample_n(size = unique(sample_size), replace = FALSE)

# Step 2: Extract unique values of the 'WKU_Standardized' from the sampled data.
# These values will be used to filter another subset of data.
selected_WKU <- unique(sampled_inv_sub_class$WKU_Standardized)

# Step 3: Filter rows of type 'inv.auth.inv' where the 'WKU_Standardized' matches the sampled values.
inv_auth_inv <- filtered_df[filtered_df$type == 'inv.auth.inv', ]
matched_rows <- inv_auth_inv[inv_auth_inv$WKU_Standardized %in% selected_WKU, ]

# Combine the two types
final_dataset <- bind_rows(sampled_inv_sub_class, matched_rows)
write.csv(final_dataset, 'sampledataset.csv', row.names = FALSE)


