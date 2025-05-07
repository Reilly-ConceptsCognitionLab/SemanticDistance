#' dist_paired_cols
#'
#' Function takes dataframe cleaned using 'clean_2columns', computes two metrics of semantic distance for each word pair arrayed in Col1 vs. Col2
#'
#' @name dist_paired_cols
#' @param dat a dataframe prepped using clean_2columns' with word pairs arrayed in two columns
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom tidyr pivot_longer
#' @importFrom lsa cosine
#' @importFrom rlang sym
#' @importFrom dplyr rename
#' @importFrom utils install.packages
#' @export dist_paired_cols

dist_paired_cols <- function(dat) {
  # Load required packages
  required_packages <- c("dplyr", "magrittr", "lsa", "rlang", "tidyr", "utils")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  }

  # Find columns ending with _clean1 and _clean2
  clean_cols <- grep("_clean1$|_clean2$", names(dat), value = TRUE)

  if (length(clean_cols) != 2) {
    stop("Could not find exactly two columns ending with '_clean1' and '_clean2'")
  }

  col_1 <- clean_cols[grep("_clean1$", clean_cols)]
  col_2 <- clean_cols[grep("_clean2$", clean_cols)]

  dat_small <- dat %>% dplyr::select(id_row_orig, !!rlang::sym(col_1), !!rlang::sym(col_2))
  unspooled_txt <- dat_small %>%
    tidyr::pivot_longer(cols = c(!!sym(col_1), !!rlang::sym(col_2)),
                 names_to = "word_type",
                 values_to = "word") %>%
    dplyr::select(-word_type)  # Drop 'word_type' column

  djoin_sd15 <- dplyr::left_join(unspooled_txt, SD15_2025_complete, by = "word")
  djoin_glow <- dplyr::left_join(unspooled_txt, glowca_25, by = 'word')

  # Initialize dataframes to store results
  result_sd15 <- data.frame(id_row_orig = levels(djoin_sd15$id_row_orig), CosDist = NA)
  result_glo <- data.frame(id_row_orig = levels(djoin_glow$id_row_orig), CosDist = NA)

  # Cosine distance function
  cos_dist <- function(row1, row2) {
    vec1 <- as.numeric(row1)
    vec2 <- as.numeric(row2)

    # Calculate cosine distance
    cos_sim <- lsa::cosine(vec1, vec2)
    cos_dist <- 1 - cos_sim
    return(cos_dist)
  }

  # Loop SD15
  for (group in levels(djoin_sd15$id_row_orig)) {
    subset_df <- djoin_sd15[djoin_sd15$id_row_orig == group, ]  # Subset data
    if (nrow(subset_df) >= 2) {
      row1 <- subset_df[1, sapply(subset_df, is.numeric)]
      row2 <- subset_df[2, sapply(subset_df, is.numeric)]
      result_sd15$CosDist[result_sd15$id_row_orig == group] <- cos_dist(row1, row2)
    }
  }

  # Loop glove
  for (group in levels(djoin_glow$id_row_orig)) {
    subset_df <- djoin_glow[djoin_glow$id_row_orig == group, ]  # Subset data
    if (nrow(subset_df) >= 2) {
      row1 <- subset_df[1, sapply(subset_df, is.numeric)]
      row2 <- subset_df[2, sapply(subset_df, is.numeric)]
      result_glo$CosDist[result_glo$id_row_orig == group] <- cos_dist(row1, row2)
    }
  }

  result_sd15 <- result_sd15 %>% dplyr::rename(CosDist_SD15 = CosDist)
  result_glo <- result_glo %>% dplyr::rename(CosDist_GLO = CosDist)
  all <- dat %>% dplyr::left_join(result_sd15, by = "id_row_orig")
  all <- all %>% dplyr::left_join(result_glo, by = "id_row_orig")
  return(all)
}
