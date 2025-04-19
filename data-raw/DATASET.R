## code to prepare `DATASET` dataset goes here

#add stopword list
reillylab_stopwords25 <- readRDS("~/Library/CloudStorage/OneDrive-TempleUniversity/Reilly_RData/Psycholing_DbaseAggregation/lookup_databases/reillylab_stopwords25.rds")
usethis::use_data(reillylab_stopwords25, overwrite = TRUE, internal=TRUE)

#add glove vectors
load("~/Library/CloudStorage/OneDrive-TempleUniversity/Reilly_RData/Psycholing_DbaseAggregation/lookup_databases/glowca_25.rda")
usethis::use_data(glowca_25, overwrite = TRUE, internal=TRUE)

#add SD15 vectors
SD15_2025 <- readRDS("~/Library/CloudStorage/OneDrive-TempleUniversity/Reilly_RData/Psycholing_DbaseAggregation/lookup_databases/SD15_2025.rds")
usethis::use_data(SD15_2025, overwrite = TRUE, internal=TRUE)
