## code to prepare `DATASET` dataset goes here

#add stopword list
reillylab_stopwords25 <- readRDS("~/Library/CloudStorage/OneDrive-TempleUniversity/Reilly_RData/Psycholing_DbaseAggregation/lookup_databases/reillylab_stopwords25.rds")

#add glove vectors
glowca_25 <- load("~/Library/CloudStorage/OneDrive-TempleUniversity/Reilly_RData/Psycholing_DbaseAggregation/lookup_databases/glowca_25.rda")

#add SD15 vectors
SD15_2025 <- readRDS("~/Library/CloudStorage/OneDrive-TempleUniversity/Reilly_RData/Psycholing_DbaseAggregation/lookup_databases/SD15_2025.rds")
