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
#' @importFrom dplyr last
#' @importFrom lsa cosine
#' @importFrom utils install.packages
#' @export dist_ngram2ngram

dist_ngram2ngram <- function(dat, ngram) {
  if (!requireNamespace("utils", quietly = TRUE)) {
    install.packages("utils")
  }
  if (!requireNamespace("lsa", quietly = TRUE)) {
    install.packages("lsa")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    install.packages("dplyr")
  }
  if (!requireNamespace("magrittr", quietly = TRUE)) {
    install.packages("magrittr")
  }

  # Create unique row identifier and prepare data
  dat <- dat %>%
    dplyr::mutate(
      row_id_unique = seq_len(nrow(dat)),  # Unique identifier for each row
      id_orig = as.factor(id_orig),
      word_clean = tolower(word_clean)
    ) %>%
    dplyr::select(row_id_unique, id_orig, word_clean)

  # Join with embedding databases first to get all parameters
  djoin_glow <- dplyr::left_join(dat, glowca_25, by = c("word_clean" = "word"))
  djoin_sd15 <- dplyr::left_join(dat, SD15_2025_complete, by = c("word_clean" = "word"))

  # Function to find valid previous ngram (skipping NAs)
  find_previous_ngram <- function(data, current_index, ngram) {
    param_cols <- grep("Param_", names(data), value = TRUE)
    prev_ngram <- NULL
    lookback <- 1

    while (is.null(prev_ngram) && (current_index - lookback - ngram + 1) >= 1) {
      candidate_indices <- (current_index - lookback - ngram + 1):(current_index - lookback)

      # Check if all words in candidate ngram are complete (no NAs)
      if (all(complete.cases(data[candidate_indices, param_cols]))) {
        prev_ngram <- candidate_indices
      }
      lookback <- lookback + 1
    }

    if (!is.null(prev_ngram)) {
      return(colMeans(data[prev_ngram, param_cols, drop = FALSE], na.rm = TRUE))
    } else {
      return(NULL)
    }
  }

  # Function to process embeddings and calculate distances
  process_embeddings <- function(embed_df, prefix) {
    cosdist_colname <- paste0("CosDist_", ngram, "gram_", prefix)
    embed_df[[cosdist_colname]] <- NA_real_

    param_cols <- grep("Param_", names(embed_df), value = TRUE)

    # Create current ngrams (allowing NAs)
    current_ngrams <- lapply(seq_len(nrow(embed_df)), function(i) {
      if (i >= ngram) {
        indices <- (i - ngram + 1):i
        colMeans(embed_df[indices, param_cols, drop = FALSE], na.rm = TRUE)
      } else {
        NULL
      }
    })

    # Calculate distances
    for (i in (ngram + 1):nrow(embed_df)) {
      current <- current_ngrams[[i]]
      previous <- find_previous_ngram(embed_df, i, ngram)

      if (!is.null(current) && !is.null(previous)) {
        valid_dims <- !is.na(current) & !is.na(previous)

        if (sum(valid_dims) > 0) {
          cos_sim <- tryCatch(
            lsa::cosine(current[valid_dims], previous[valid_dims]),
            error = function(e) NA_real_
          )
          embed_df[[cosdist_colname]][i] <- ifelse(is.na(cos_sim), NA, 1 - cos_sim)
        }
      }
    }

    embed_df %>%
      dplyr::select(row_id_unique, all_of(cosdist_colname)) %>%
      dplyr::filter(!is.na(row_id_unique))
  }

  # Process both embeddings
  glo_dist <- process_embeddings(djoin_glow, "GLO")
  sd15_dist <- process_embeddings(djoin_sd15, "SD15")

  # Combine results
  result <- dat %>%
    dplyr::left_join(glo_dist, by = "row_id_unique") %>%
    dplyr::left_join(sd15_dist, by = "row_id_unique")

  return(result)
}
