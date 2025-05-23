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
#' @importFrom stats complete.cases
#' @importFrom utils install.packages
#' @export dist_ngram2ngram

dist_ngram2ngram <- function(dat, ngram) {
  my_packages <- c("dplyr", "lsa", "magrittr", "utils", "stats")
  for (pkg in my_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  }

  # Store original columns to preserve them in output
  orig_cols <- names(dat)

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
      if (all(stats::complete.cases(data[candidate_indices, param_cols]))) {
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
  process_embeddings <- function(embed_dat, prefix) {
    cosdist_colname <- paste0("CosDist_", ngram, "gram_", prefix)
    embed_dat[[cosdist_colname]] <- NA_real_

    param_cols <- grep("Param_", names(embed_dat), value = TRUE)

    # Create current ngrams (allowing NAs)
    current_ngrams <- lapply(seq_len(nrow(embed_dat)), function(i) {
      if (i >= ngram) {
        indices <- (i - ngram + 1):i
        colMeans(embed_dat[indices, param_cols, drop = FALSE], na.rm = TRUE)
      } else {
        NULL
      }
    })

    # Calculate distances
    for (i in (ngram + 1):nrow(embed_dat)) {
      current <- current_ngrams[[i]]
      previous <- find_previous_ngram(embed_dat, i, ngram)

      if (!is.null(current) && !is.null(previous)) {
        valid_dims <- !is.na(current) & !is.na(previous)

        if (sum(valid_dims) > 0) {
          cos_sim <- tryCatch(
            lsa::cosine(current[valid_dims], previous[valid_dims]),
            error = function(e) NA_real_
          )
          embed_dat[[cosdist_colname]][i] <- ifelse(is.na(cos_sim), NA, 1 - cos_sim)
        }
      }
    }

    embed_dat %>%
      dplyr::select(id_row_postsplit, all_of(cosdist_colname)) %>%
      dplyr::filter(!is.na(id_row_postsplit))
  }

  # Process both embeddings
  glo_dist <- process_embeddings(djoin_glow, "GLO")
  sd15_dist <- process_embeddings(djoin_sd15, "SD15")

  # Combine results
  result <- dat %>%
    dplyr::left_join(glo_dist, by = "id_row_postsplit") %>%
    dplyr::left_join(sd15_dist, by = "id_row_postsplit")

  return(result)
}
