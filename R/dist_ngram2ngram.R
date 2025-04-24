#' dist_ngram2ngram
#'
#' Function takes dataframe cleaned using 'clean_monologue', computes rolling chunk-to-chunk distance between user-specified ngram size (e.g., 2-word chunks)
#' @name dist_ngram2ngram
#' @param dat a dataframe prepped using 'clean_monologue' fn
#' @param ngram an integer specifying the window size of words for computing distance to a target word
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize
#' @importFrom dplyr mutate
#' @importFrom dplyr across
#' @importFrom dplyr where
#' @importFrom dplyr all_of
#' @importFrom lsa cosine
#' @export dist_ngram2ngram

dist_ngram2ngram <- function(dat, ngram) {
  # Load required packages
  if (!requireNamespace("lsa", quietly = TRUE)) {
    install.packages("lsa")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    install.packages("dplyr")
  }

  # Ngram splicing
  dat <- dat %>% select(id_orig, word_clean) %>% mutate(id_orig = as.factor(id_orig))
  dat$word_clean <- tolower(dat$word_clean)

  # Calculate ngram groups
  n <- nrow(dat)
  complete_groups <- floor(n / ngram)
  Ngram_var <- rep(1:complete_groups, each = ngram)

  # Handle remaining observations
  remaining <- n - length(Ngram_var)
  if (remaining > 0) {
    Ngram_var <- c(Ngram_var, rep(NA, remaining))
  }

  # Create and add ngram column as factor
  col_name <- paste0("CountID_Ngram", ngram)
  dat[[col_name]] <- as.factor(Ngram_var)

  # Join with embedding databases
  djoin_glow <- dplyr::left_join(dat, glowca_25, by = c("word_clean" = "word"))
  djoin_sd15 <- dplyr::left_join(dat, SD15_2025, by = c("word_clean" = "word"))

  # Group by Ngram and summarize numeric variables
  djoin_glow <- djoin_glow %>%
    dplyr::group_by(across(all_of(col_name))) %>%
    dplyr::summarize(id_orig = last(id_orig),
              across(where(is.numeric), ~ mean(., na.rm = TRUE)),
              .groups = 'drop')

  djoin_sd15 <- djoin_sd15 %>%
    dplyr::group_by(across(all_of(col_name))) %>%
    dplyr::summarize(id_orig = last(id_orig),
              across(where(is.numeric), ~ mean(., na.rm = TRUE)),
              .groups = 'drop')

  # Remove empty factor levels
  djoin_glow <- droplevels(djoin_glow)
  djoin_sd15 <- droplevels(djoin_sd15)

  # Function to calculate pairwise cosine distances between consecutive ngrams
  calculate_cos_dist <- function(embed_df, ngram_col, prefix) {
    cosdist_colname <- paste0("CosDist_", ngram, "gram_", prefix)
    embed_df[[cosdist_colname]] <- NA

    if (nrow(embed_df) >= 2) {
      numeric_cols <- names(embed_df)[sapply(embed_df, is.numeric)]
      numeric_cols <- setdiff(numeric_cols, c(ngram_col, cosdist_colname))

      for (i in 2:nrow(embed_df)) {
        current <- as.numeric(embed_df[i, numeric_cols])
        previous <- as.numeric(embed_df[i-1, numeric_cols])

        valid_idx <- !is.na(current) & !is.na(previous)
        current <- current[valid_idx]
        previous <- previous[valid_idx]

        if (length(current) > 0 && length(previous) > 0) {
          cos_sim <- tryCatch({
            lsa::cosine(current, previous)
          }, error = function(e) NA)

          embed_df[[cosdist_colname]][i] <- ifelse(is.na(cos_sim), NA, 1 - cos_sim)
        }
      }
    }
    return(embed_df %>% dplyr::select(id_orig, all_of(cosdist_colname)))
  }

  # Calculate distances for both embeddings
  glo_dist <- calculate_cos_dist(djoin_glow, col_name, "GLO")
  sd15_dist <- calculate_cos_dist(djoin_sd15, col_name, "SD15")

  # Combine results with original data
  result <- dat %>% left_join(glo_dist, by = "id_orig") %>% left_join(sd15_dist, by = "id_orig")

  return(result)
}
