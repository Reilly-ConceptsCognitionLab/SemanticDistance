#' dist_ngram2word
#'
#' Function takes dataframe cleaned using 'clean_monologue', computes two metrics of semantic distance for each word relative to the average of the semantic vectors within an n-word window appearing before each word. User specifies the window (ngram) size. The window 'rolls' across the language sample providing distance metrics
#'
#' @name dist_ngram2word
#' @param dat a dataframe prepped using 'clean_monologue' fn
#' @param ngram an integer specifying the window size of words for computing distance to a target word
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr mutate
#' @importFrom lsa cosine
#' @importFrom utils install.packages
#' @export dist_ngram2word

dist_ngram2word <- function(dat, ngram) {
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

  # Store original columns to preserve them in output
  orig_cols <- names(dat)

  # Prepare working data and create unique row IDs
  dat <- dat %>%
    dplyr::mutate(
      row_id_unique = seq_len(nrow(dat)),  # Create unique row identifier
      word_clean = tolower(word_clean)
    )

  # Join with lookup databases using row_id_glo
  djoin_glo <- left_join(dat, glowca_25, by = c("word_clean" = "word"))
  djoin_sd15 <- left_join(dat, SD15_2025, by = c("word_clean" = "word"))

  # Create result column names
  cosdist_colname_glo <- paste0("CosDist_", ngram, "gram_glo")
  cosdist_colname_sd15 <- paste0("CosDist_", ngram, "gram_sd15")

  # Check if column names already exist and append suffix if they do
  suffix <- 1
  while(cosdist_colname_glo %in% names(dat)) {
    cosdist_colname_glo <- paste0("CosDist_", ngram, "gram_glo_", suffix)
    suffix <- suffix + 1
  }

  suffix <- 1
  while(cosdist_colname_sd15 %in% names(dat)) {
    cosdist_colname_sd15 <- paste0("CosDist_", ngram, "gram_sd15_", suffix)
    suffix <- suffix + 1
  }

  djoin_glo[[cosdist_colname_glo]] <- NA_real_
  djoin_sd15[[cosdist_colname_sd15]] <- NA_real_

  # Isolate parameter columns (temporary use only)
  param_cols_glo <- grep("Param_", names(djoin_glo), value = TRUE, ignore.case = TRUE)
  param_cols_sd15 <- grep("Param_", names(djoin_sd15), value = TRUE, ignore.case = TRUE)

  # Compute cosine distances (unchanged)
  compute_cosdist <- function(data, param_cols, result_col) {
    if (length(param_cols) == 0) {
      warning("No parameter columns found for cosine distance calculation")
      return(data)
    }

    if (nrow(data) >= (ngram + 1)) {
      param_matrix <- as.matrix(data[, param_cols])

      for (i in (ngram + 1):nrow(data)) {
        current_word <- param_matrix[i, ]
        ngram_window <- param_matrix[(i-ngram):(i-1), , drop = FALSE]

        ngram_vector <- colMeans(ngram_window, na.rm = TRUE)
        ngram_vector[is.nan(ngram_vector)] <- NA

        valid_dims <- !is.na(current_word) & !is.na(ngram_vector)

        if (sum(valid_dims) > 0) {
          cos_sim <- tryCatch(
            lsa::cosine(
              current_word[valid_dims],
              ngram_vector[valid_dims]
            ),
            error = function(e) NA_real_
          )

          if (!is.na(cos_sim)) {
            data[i, result_col] <- 1 - cos_sim
          }
        }
      }
    } else {
      warning(paste("Not enough rows (", nrow(data),
                    ") to calculate", ngram, "-gram distances"))
    }

    return(data)
  }

  # Compute distances
  result_glo <- compute_cosdist(djoin_glo, param_cols_glo, cosdist_colname_glo)
  result_sd15 <- compute_cosdist(djoin_sd15, param_cols_sd15, cosdist_colname_sd15)

  # Combine results using row_id_glo instead of id_orig
  final_result <- dat %>%
    dplyr::select(all_of(orig_cols), row_id_unique) %>%
    dplyr::left_join(
      result_glo %>%
        dplyr::select(row_id_unique, word_clean, contains("CosDist"), -contains("Param_")),
      by = c("row_id_glo", "word_clean")) %>%
    dplyr::left_join(
      result_sd15 %>%
        dplyr::select(row_id_unique, word_clean, contains("CosDist"), -contains("Param_")),
      by = c("row_id_unique", "word_clean"))

  return(final_result)
}
