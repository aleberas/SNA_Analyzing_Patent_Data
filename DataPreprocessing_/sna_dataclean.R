# Project SNA about patent data ----

# Load libraries
library(dplyr)
library(igraph) 
library(readr)
library(igraph)
library(tidyr)
library(stringr)
library(lubridate)
library(ggplot2)
library(purrr) 
# install.packages('stringdist')
library(stringdist)

rm(list = ls(all = TRUE))     
cat("\014")                    

# Setting working directory ----
working_dir = "/Users/federicamarini/Desktop/USI/Analysis of Social Networks/Project"            
#working_dir = getwd()             
setwd(working_dir)            #Working directory: ProjectSNA    

# Set the directory for the input data
input_dir <- "Archive/INPUT_DATA_REDUCED/"


## TRY WITH 10 YEARS ----
# Define the path to the folder with the CSV files
start_year <- 1976
end_year <- start_year + 10 - 1

# List all CSV files 
csv_files <- list.files(input_dir, pattern = "PATENTS_\\d{4}_CC_NOCLAIMS\\.csv$", full.names = TRUE)

# Read all CSV files
data <- csv_files %>%
  lapply(function(file) {
    # Extract year from file name
    year <- as.numeric(gsub("PATENTS_(\\d{4})_CC_NOCLAIMS\\.csv$", "\\1", basename(file)))
    
    # Read the file with specified column types
    read_csv(file, 
             col_types = cols(
               App_Date = col_date(),       
               Issue_Date = col_date(),     
               ICL_Class = col_character(), 
               .default = col_character()   
             )) %>%
      mutate(year = year) 
  }) %>%
  bind_rows() %>%          # Combine all data frames into one
  filter(year >= start_year & year <= end_year) # Filter rows within the year range

print(data) #515670 rows 

# REMOVE ALL JR. AND SR. FROM VARIABLE INVENTOR ----
# JR
data$Inventor <- gsub("[,;]?\\s*Jr\\.?\\s*[,;]?", "", data$Inventor, ignore.case = TRUE)

# SR
data$Inventor <- gsub("[,;]?\\s*(Jr|Sr)\\.?\\s*[,;]?", "", data$Inventor, ignore.case = TRUE)

# Removing extra whitespace
data$Inventor <- trimws(data$Inventor)

print(data)

# Count occurrences of "Jr." in all variations (case-insensitive)
jr_count <- sum(str_count(data$Inventor, "(?i)\\bJr\\.?\\b"))
sr_count <- sum(str_count(data$Inventor, "(?i)\\bSr\\.?\\b"))


# REPEAT THE SAME PROCESS FOR ASSIGNEE VARIABLE ----
data$Assignee <- gsub("[,;]?\\s*(Jr|Sr)\\.?\\s*[,;]?", "", data$Assignee, ignore.case = TRUE)

# Removing extra whitespace
data$Assignee <- trimws(data$Assignee)

# Count occurrences of "Jr." in all variations (case-insensitive) in the 'Assignee' column
jr_count_assignee <- sum(str_count(data$Assignee, "(?i)\\bJr\\.?\\b"))
sr_count_assignee <- sum(str_count(data$Assignee, "(?i)\\bSr\\.?\\b"))

# Print the counts for the 'Assignee' column
print(jr_count_assignee)
print(sr_count_assignee)

# REMOVING ADDITIONAL PROBLEMS FROM INVENTOR COLUMN ----
data$Inventor <- gsub("\\(deceased\\)", "", data$Inventor)
data$Inventor <- gsub("deceased", "", data$Inventor)
data$Inventor <- gsub(", heiress", "", data$Inventor)
data$Inventor <- gsub(", legal representative and heir", "", data$Inventor)
data$Inventor <- gsub("legal representative and heir", "", data$Inventor)
data$Inventor <- gsub(", heir and legal successor", "", data$Inventor)

data$Inventor <- gsub(", heir at law", "", data$Inventor)
data$Inventor <- gsub(", legal representative", "", data$Inventor)
data$Inventor <- gsub(", legal successor", "", data$Inventor)
data$Inventor <- gsub(", co-executrix", "", data$Inventor)
data$Inventor <- gsub(", legal guardian", "", data$Inventor)
data$Inventor <- gsub(", executrix", "", data$Inventor)

data$Inventor <- gsub("legal heir", "", data$Inventor)
data$Inventor <- gsub(", heir", "", data$Inventor)
data$Inventor <- gsub("heiress", "", data$Inventor)
data$Inventor <- gsub("heir", "", data$Inventor)
data$Inventor <- gsub(", legal authorized ", "", data$Inventor)
data$Inventor <- gsub(",a legal representative", "", data$Inventor)
data$Inventor <- gsub(", administrator\\s*$", "", data$Inventor) 
data$Inventor <- gsub(", trust administrator\\s*$", "", data$Inventor) 
data$Inventor <- gsub(", administratrix\\s*$", "", data$Inventor) 
data$Inventor <- gsub(", Administrator\\s*$", "", data$Inventor)
data$Inventor <- gsub(", personal representative", "", data$Inventor)
data$Inventor <- gsub(", representative", "", data$Inventor)
data$Inventor <- gsub(", joint personal representative", "", data$Inventor)
data$Inventor <- gsub(", joint", "", data$Inventor)

data$Inventor <- gsub(", Executrix", "", data$Inventor)
data$Inventor <- gsub(", exectrix", "", data$Inventor)
data$Inventor <- gsub("executrix", "", data$Inventor)
data$Inventor <- gsub("heir-at-law", "", data$Inventor)
data$Inventor<-gsub("heirs", "", data$Inventor)
data$Inventor <- gsub(" Heir", "", data$Inventor)
data$Inventor <- gsub("executor", "", data$Inventor)
data$Inventor <- gsub("Executor", "", data$Inventor)
data$Inventor <- gsub(" by ", "", data$Inventor) 
data$Inventor<- gsub(" BY ","", data$Inventor)
data$Inventor<- gsub(" By ","", data$Inventor)
data$Inventor <- gsub("\\bby\\b", "", data$Inventor, ignore.case = TRUE)
#Eliminate by but not names/surnames that end with by
data$Inventor <- gsub(" also known as [^;]*;", "", data$Inventor) 

#### Pattern ----
# We include a minimum of 2 letters of aaBa
patternn2<- "(?<=\\w{3})(?<=[a-z])(?=[A-Z])(?<!Mc|Van|De|de|Mac|Mc|Di|De|Du|Ver|Del|Le|La|Lo|DelVecchio|Li|Jean|DueYves|Jean-|den|Den|den|Den|mc|mac|le|la|lo|Au|De|Van|Ten|Fitz|Ma|Sor|Fe|van|El|Bo|Yu|Wu|Ko|Vander|von|Tate|Maa|VON|Ki|Sen|Do|Min|Gim|Gian|Ka|VonDer|da|Delli|Chou|Des|Abo|Gros|Jo|Ro|Lee|Lu|Des|Da|McDer|Eer|Sa|Pier|Vi|Sunder|Ganga)"

data_full_inventors <- data %>%
  # Replace the identified boundary with a semicolon
  mutate(Inventor = str_replace_all(Inventor, patternn2, ";"))

# Find the data_full_inventors ----
data_full_inventors2 <- data_full_inventors %>%
  separate_rows(Inventor, sep = ";")%>%
  # Trim any leading or trailing whitespace from the Inventor names
  mutate(Inventor = str_trim(Inventor))


# Find the data_full_inventors ----
data_uncorrect <- data %>%
  separate_rows(Inventor, sep = ";")%>%
  # Trim any leading or trailing whitespace from the Inventor names
  mutate(Inventor = str_trim(Inventor))

long_inventor_uncorrect <- data_uncorrect %>%
  filter(str_count(Inventor, "\\w+") > 5)

small_inventors_uncorrect <- data_uncorrect %>%
  filter(sapply(strsplit(Inventor, "\\s+"), length) == 1)


# Apply string transformations to the Inventor column
data_full_inventors3 <- data_full_inventors2 %>%
  mutate(
    Inventor = Inventor %>%
      str_remove_all("[^a-zA-Z\\s]") %>%
      str_to_lower() %>%
      str_squish()
  ) %>%
  filter(!is.na(Inventor) & Inventor != "") %>%
  arrange(Inventor) 

# LONG INVENTORS AND SMALL INVENTORS ----
# Create long_inventor: Inventor names with more than 5 words
long_inventor <- data_full_inventors3 %>%
  filter(str_count(Inventor, "\\w+") > 5)

# Create small_inventor: Inventor names with exactly 1 word
small_inventor <- data_full_inventors3 %>%
  filter(str_count(Inventor, "\\w+") == 1)

# Distinct inventors 
data_distinct_inventors <- data_full_inventors3 %>% select(Inventor) %>% distinct() #403721

# write.csv(data_full_inventors3,file='/Users/alessiabera/Desktop/data_full_inventors3.csv', row.names=FALSE)
## Apply Levenshtein

x <- read_csv("cleaned_dataset.csv")

df_is<-as.data.frame(c(x['Inventor'],x['Inventor_Standardized']))

df_differences <- df_is[df_is$Inventor != df_is$Inventor_Standardized, ]

data_distinct_standard_inventors <- x %>% select(Inventor_Standardized) %>% distinct() 

# COINVENTORS NETWORK ----
edges <- x %>%
  distinct(WKU, Inventor_Standardized)                   

# Create a co-inventor edge list
co_inventor_edges <- edges %>%
  inner_join(edges, by = "WKU") %>%            
  filter(Inventor_Standardized.x != Inventor_Standardized.y) %>%        
  select(Inventor_Standardized.x, Inventor_Standardized.y) %>%           
  distinct()                                   

# Create graph from edge list 
g <- graph_from_data_frame(d = co_inventor_edges, vertices = data_distinct_standard_inventors, directed = FALSE) # IGRAPH OBJECT 
table(degree(g))

# Calculate average degree
average_degree <- mean(degree(g))
cat("Average Degree:", average_degree, "\n") # 5.215377

# Calculate density
density <- edge_density(g)
cat("Density:", density, "\n") # 1.367283e-05 

# Degree distribution
degree_distribution <- degree(g)
degree_dist_table <- table(degree_distribution) 
degree_dist_table

# Plot degree distribution
plot(degree_dist_table, 
     type = "h",              
     xlab = "Degree", 
     ylab = "Frequency", 
     main = "Degree Distribution of Co-Inventor Network",
     col = "skyblue")

names(degree_distribution[degree_distribution == 334])


# Local and global clustering coefficient
global_clustering <- transitivity(g, type = "average")
cat("Global Clustering Coefficient:", global_clustering, "\n") # 0.7184537 

local_clustering <- transitivity(g, type = "local")

# Find isolated nodes (degree 0)
isolated_nodes <- sum(degree(g) == 0)
cat("Number of isolated nodes:", isolated_nodes, "\n") # 83304

# COMMUNITY DETECTION - LOUVIAN ALGORITHM ----
set.seed(1234)
louvain_communities <- cluster_louvain(g)
cat("Number of Communities:", length(louvain_communities), "\n") # 134691
community_sizes <- sizes(louvain_communities)
# Many inventors work in small, independent teams

largest_communities <- sort(community_sizes, decreasing = TRUE)[1:10]
print(largest_communities)


singletons <- sum(community_sizes == 1)
cat("Singleton Communities:", singletons, "\n")
cat("Percentage of Singleton Communities:", (singletons / length(louvain_communities)) * 100, "%\n")
# 61.84823 % are singletons

# largest community 
largest_community <- induced_subgraph(g, which(membership(louvain_communities) == which.max(community_sizes)))

cat("Number of Nodes:", vcount(largest_community), "\n")
cat("Number of Edges:", ecount(largest_community), "\n")

# plot of the largest community
plot(largest_community, 
     vertex.size = 5, 
     vertex.label = NA, 
     main = "Largest Community")


# HIROSHI KATO 
# Check node names or attributes in the largest community
node_names <- V(largest_community)$name  # Replace 'name' with the actual attribute name, e.g., 'Inventor'

# Check if "Hiroshi Kato" is in the node list
is_present <- "hiroshi kato" %in% node_names

# Output result
if (is_present) {
  cat("Hiroshi Kato is present in the largest community.\n")
} else {
  cat("Hiroshi Kato is NOT present in the largest community.\n")
}


print(vertex_attr_names(g)) 
node_names <- V(g)$name  

# Check if "Hiroshi Kato" exists in the node list
if ("hiroshi kato" %in% node_names) {
  cat("Hiroshi Kato is in the graph.\n")
} else {
  cat("Hiroshi Kato is NOT in the graph.\n")
}


# Get the node index for Hiroshi Kato
kato_index <- which(node_names == "hiroshi kato")

# Find Hiroshi Kato's community using membership()
kato_community <- membership(louvain_communities)[kato_index]
cat("Hiroshi Kato belongs to Community:", kato_community, "\n")  #25


# Size of Hiroshi Kato's community
cat("Size of Hiroshi Kato's Community:", community_sizes[kato_community], "\n")

# Nodes in the same community
same_community_nodes <- which(membership(louvain_communities) == kato_community)
print(V(g)$name[same_community_nodes]) 


# BIPARTITE GRAPH ICL_CLASS ----

# FIRST LEVEL OF GRANULARITY ----
# Create the dataset with unique inventors and ICL_1
data_ICL1 <- x %>%
  separate_rows(ICL_Class, sep = ",") %>%
  mutate(ICL_1 = substr(ICL_Class, 1, 1)) %>%
  mutate(is_valid = ICL_1 %in% LETTERS[1:8]) %>%
  group_by(Inventor) %>%
  summarise(
    ICL_1 = paste(unique(ICL_1[is_valid]), collapse = ","),
    .groups = "drop"
  )

# Check for invalid letters
invalid_codes <- data_full_inventors %>%
  separate_rows(ICL_Class, sep = ",") %>%
  mutate(ICL_1 = substr(ICL_Class, 1, 1)) %>%
  filter(!ICL_1 %in% LETTERS[1:8]) %>%
  pull(ICL_1) %>%
  unique()

# Notify if invalid letters are found
if (length(invalid_codes) > 0) {
  cat("Warning: Invalid ICL_Class codes detected:\n")
  print(invalid_codes)
}


# Split the ICL_1 column into separate columns 
max_classes <- max(str_count(data_ICL1$ICL_1, ",") + 1) 

data_granularity_1 <- data_ICL1 %>%
  separate(ICL_1, into = paste0("ICL_Class_", 1:max_classes), sep = ",", fill = "right")

# OCCURRENCES 
data_occurrences1 <- x %>%
  separate_rows(ICL_Class, sep = ",") %>%
  mutate(ICL_Letter = substr(ICL_Class, 1, 1)) %>%
  filter(ICL_Letter %in% LETTERS[1:8]) %>%
  group_by(Inventor, ICL_Letter) %>%
  summarise(Occurrences = n(), .groups = "drop") %>%
  pivot_wider(names_from = ICL_Letter, 
              values_from = Occurrences, 
              values_fill = 0) %>%
  select(Inventor, sort(setdiff(names(.), "Inventor")))

# DATASET WITH 0 AND 1 
# Create a dataset where each class letter from A to H is a column with values 0 or 1
# Create dataset (presence/absence) from occurrences
data_binary1 <- data_occurrences1 %>%
  mutate(across(-Inventor, ~ ifelse(. > 0, 1, 0)))


# HIGHER LEVEL OF GRANULARITY: 2 ----
data_ICL2 <- data_full_inventors %>%
  separate_rows(ICL_Class, sep = ",") %>%
  mutate(ICL_Letter_Number = str_extract(ICL_Class, "^[A-H][0-9]")) %>%
  filter(!is.na(ICL_Letter_Number)) %>%
  group_by(Inventor) %>%
  summarise(
    ICL_1 = paste(unique(ICL_Letter_Number), collapse = ","),
    .groups = "drop"
  )

# Expand the ICL_1 column into separate columns dynamically
max_classes <- max(str_count(data_ICL2$ICL_1, ",") + 1) # Calculate the maximum number of classes for any inventor

data_granularity_2 <- data_ICL2 %>%
  separate(ICL_1, into = paste0("ICL_Class_", 1:max_classes), sep = ",", fill = "right") %>%
  distinct(Inventor, .keep_all = TRUE)


# OCCURRENCES
data_occurrences2 <- data_full_inventors %>%
  separate_rows(ICL_Class, sep = ",") %>%
  mutate(ICL_Letter_Number = str_extract(ICL_Class, "^[A-H][0-9]")) %>%
  filter(!is.na(ICL_Letter_Number)) %>%
  group_by(Inventor, ICL_Letter_Number) %>%
  summarise(Occurrences = n(), .groups = "drop") %>%
  pivot_wider(names_from = ICL_Letter_Number, 
              values_from = Occurrences, 
              values_fill = 0) %>%
  select(Inventor, sort(setdiff(names(.), "Inventor")))

# DATASET WITH 0 AND 1
# Create a dataset where each class is a column with binary values (0 or 1)
# Create binary dataset (presence/absence) from occurrences
data_binary2 <- data_occurrences2 %>%
  mutate(across(-Inventor, ~ ifelse(. > 0, 1, 0)))


# THIRD LEVEL OF GRANULARITY ----
data_ICL3 <- data_full_inventors %>%
  separate_rows(ICL_Class, sep = ",") %>%
  mutate(ICL_Letter_Number_Number = str_extract(ICL_Class, "^[A-H][0-9][0-9]")) %>%
  filter(!is.na(ICL_Letter_Number_Number)) %>%
  group_by(Inventor) %>%
  summarise(
    ICL_1 = paste(unique(ICL_Letter_Number_Number), collapse = ","),
    .groups = "drop"
  )

# Expand the ICL_1 column into separate columns 
max_classes <- max(str_count(data_ICL3$ICL_1, ",") + 1) 

data_granularity_3 <- data_ICL3 %>%
  separate(ICL_1, into = paste0("ICL_Class_", 1:max_classes), sep = ",", fill = "right")


# OCCURRENCES
data_occurrences3 <- data_full_inventors %>%
  separate_rows(ICL_Class, sep = ",") %>%
  mutate(ICL_Letter_Number_Number = str_extract(ICL_Class, "^[A-H][0-9][0-9]")) %>%
  filter(!is.na(ICL_Letter_Number_Number)) %>%
  group_by(Inventor, ICL_Letter_Number_Number) %>%
  summarise(Occurrences = n(), .groups = "drop") %>%
  pivot_wider(names_from = ICL_Letter_Number_Number, 
              values_from = Occurrences, 
              values_fill = 0) %>%
  select(Inventor, sort(setdiff(names(.), "Inventor")))


# DATASET WITH 0 AND 1
# Create a dataset where each class is a column with binary values 
# Create binary dataset (presence/absence) from occurrences
data_binary3 <- data_occurrences3 %>%
  # Replace all non-zero occurrences with 1, keeping zeros as is
  mutate(across(-Inventor, ~ ifelse(. > 0, 1, 0)))
