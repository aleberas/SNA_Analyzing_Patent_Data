library(survival)

x1 <- x[order(x$Issue_Date),]

# FIND WHERE ISSUE DATES ARE WEONG 
result <- x1[x1$Issue_Date < x1$App_Date,]
# DELETE ALL THOSE 
x1 <- x1[!(x1$Issue_Date < x1$App_Date),]

# Ensure Issue_Date is in Date format
x1$Issue_Date <- as.Date(x1$Issue_Date)

# Remove rows where the Issue_Date year is less than 1976 or greater than 2022
x1 <- x1 %>%
  filter(format(Issue_Date, "%Y") >= 1976 & format(Issue_Date, "%Y") <= 2022)

# Process x1 to retain only specific columns and first letters of ICL_Class
x1_processed <- x1 %>%
  select(App_Date, Inventor, ICL_Class, WKU_Standardized) %>%           
  mutate(ICL_Class = ICL_Class %>%                        
           strsplit(",") %>%                              
           lapply(function(x) substr(x, 1, 1)) %>%       
           sapply(paste, collapse = ","))                 



x_hyperevent <- x1_processed %>%
  separate_rows(ICL_Class, sep = ",")  # Split ICL_Class by commas into separate rows

# eliminiamo le lettere sbagliate 
x_hyperevent <- x_hyperevent[x_hyperevent$ICL_Class %in% LETTERS[1:8], ]

write.csv(x_hyperevent, file = "x_hyperevent_INPUT.csv", row.names = FALSE) 


# FIRST CONFIGURATION ----
df <- read_csv("Results/x_hyperevent_INPUT_JOINT.csv")

# REM coxph 
summary(df)
summary(df[df$IS_OBSERVED == 0,]) # recall: variables that are constant zero on the non-events cannot be used in the model

summary(df[df$IS_OBSERVED == 1,])

names(df)
# square root transformation
df[,c(13:ncol(df))] <- sqrt(df[,c(13:ncol(df))])

# strata are identified by concatenation of time, number of authors, and number of references
df$stratum <- paste(df$TIME, df$source.size, df$target.size, sep = ":")

my.model <- coxph(Surv(time = rep(1,nrow(df)), event = df$IS_OBSERVED) ~
                    avg.patents.per.inventor 
                  + avg.submissions.per.class
                  + strata(stratum)
                  , robust = TRUE
                  , data = df)
summary(my.model)
sum(is.na(df$inventor.clas.consistency))


# HEATMAP 
x_hyperevent %>%
  group_by(Inventor) %>%               
  summarise(distinct_classes = n_distinct(ICL_Class)) %>% # Count distinct ICL classes per inventor
  summarise(average_classes = mean(distinct_classes)) # Calculate the average

average_icl_classes <- x_hyperevent %>%
  group_by(Inventor) %>%                
  summarise(distinct_classes = n_distinct(ICL_Class)) # Count distinct ICL classes per inventor


mean(average_icl_classes$distinct_classes) # 1.37
# An inventor submits on average in 1.37 different technological classes. 

combinations <- x_hyperevent %>%
  group_by(Inventor) %>% # Group by inventors
  summarise(tech_classes = list(unique(ICL_Class)), .groups = "drop") %>% 
  filter(lengths(tech_classes) > 1) %>% # Consider inventors with at least TWO class
  mutate(
    pairs = map(tech_classes, ~ if (length(.x) > 1) combn(.x, 2, simplify = FALSE) else list()),
    self_pairs = map(tech_classes, ~ map(.x, ~ c(.x, .x)))) %>% 
  mutate(all_pairs = map2(pairs, self_pairs, ~ c(.x, unlist(.y, recursive = FALSE)))) %>% # Combine pairs and self-pairs
  unnest(all_pairs) %>% # Flatten the list of all pairs
  mutate(pair = sapply(all_pairs, function(x) paste(sort(x), collapse = ","))) %>% 
  count(pair, sort = TRUE) # Count occurrences of each unique pair

combinations <- combinations %>%
  mutate(pair = ifelse(!grepl(",", pair), paste(pair, pair, sep = ","), pair))

# Create the reversed pairs
reversed_combinations <- combinations %>%
  separate(pair, into = c("Class1", "Class2"), sep = ",") %>% 
  mutate(Class1 = trimws(Class1), Class2 = trimws(Class2)) %>% 
  mutate(ReversedPair = paste(Class2, Class1, sep = ",")) %>% 
  select(pair = ReversedPair, n) 

# Combine original and reversed combinations
expanded_combinations <- bind_rows(combinations, reversed_combinations)

# Define all possible classes
all_classes <- LETTERS[1:8] # From A to H

# Split the `pair` column into `Class1` and `Class2`
heatmap_data <- expanded_combinations %>%
  separate(pair, into = c("Class1", "Class2"), sep = ",") %>% 
  mutate(Class1 = trimws(Class1), Class2 = trimws(Class2))    

# Ensure all combinations of classes from A to H are included
complete_data <- expand.grid(Class1 = all_classes, Class2 = all_classes) %>% 
  left_join(heatmap_data, by = c("Class1", "Class2")) %>% 
  mutate(n = replace_na(n, 0)) 

# Plot the heatmap
ggplot(complete_data, aes(x = Class1, y = Class2, fill = n)) +
  geom_tile(color = "white") + # Add tile borders for clarity
  scale_fill_gradient(low = "white", high = "blue", name = "Count") +
  theme_minimal() +
  labs(
    title = "Heatmap of ICL Class Combinations",
    x = "ICL Class 1",
    y = "ICL Class 2"
  ) +
  theme(
    panel.grid = element_blank() 
  )
