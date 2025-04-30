#' dist_dialogue_turns
#'
#' Function takes dataframe cleaned using 'clean_monologue', computes two metrics of semantic distance for each word relative to the average of the semantic vectors within an n-word window appearing before each word. User specifies the window (ngram) size. The window 'rolls' across the language sample providing distance metrics
#'
#' @name dist_dialogue_turns
#' @param dat a dataframe prepped using 'clean_dialogue' fn with talker data and turncount appended
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr mutate
#' @importFrom dplyr summarize
#' @importFrom dplyr group_by
#' @importFrom dplyr rename_with
#' @importFrom dplyr across
#' @importFrom dplyr all_of
#' @importFrom lsa cosine
#' @importFrom purrr map2_dbl
#' @importFrom purrr transpose
#' @importFrom purrr map
#' @importFrom utils install.packages
#' @export dist_dialogue_turns

dist_dialogue_turns <- function(dat) {
  # Load required packages
  if (!requireNamespace("lsa", quietly = TRUE)) {
    install.packages("lsa")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    install.packages("dplyr")
  }
  if (!requireNamespace("purrr", quietly = TRUE)) {
    install.packages("purrr")
  }

  # Check if required columns exist in input data
  required_cols <- c("id_orig", "talker", "turn_count", "word_clean")
  if (!all(required_cols %in% names(dat))) {
    missing_cols <- setdiff(required_cols, names(dat))
    stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
  }

  # Prepare data with unique row identifier
  dat <- dat %>%
    dplyr::mutate(
      row_id = seq_len(nrow(dat)),  # Add unique row identifier
      word_clean = tolower(word_clean),
      talker = as.factor(talker),
      turn_count = as.integer(turn_count)
    ) %>%
    dplyr::select(row_id, id_orig, talker, turn_count, word_clean)

  # Join with embedding databases
  djoin_glo <- dplyr::left_join(dat, glowca_25, by = c("word_clean" = "word"))
  djoin_sd15 <- dplyr::left_join(dat, SD15_2025_complete, by = c("word_clean" = "word"))

  # Function to compute turn-level vectors and distances
  process_turn_embeddings <- function(embed_df, prefix) {
    # Get embedding dimensions
    numeric_cols <- names(embed_df)[sapply(embed_df, is.numeric)]
    numeric_cols <- setdiff(numeric_cols, c("row_id", "id_orig", "turn_count"))

    if (length(numeric_cols) == 0) {
      stop(paste("No numeric embedding columns found in", prefix, "data"))
    }

    # Compute mean vector for each turn
    turn_vectors <- embed_df %>%
      dplyr::group_by(turn_count) %>%
      dplyr::summarize(
        dplyr::across(all_of(numeric_cols), ~ mean(., na.rm = TRUE)),
        .groups = "drop"
      ) %>%
      dplyr::arrange(turn_count)

    # Calculate cosine distances between consecutive turns
    turn_vectors <- turn_vectors %>%
      dplyr::mutate(
        "{prefix}_cosdist" := purrr::map_dbl(
          1:n(),
          ~ {
            if (. == n()) return(NA_real_)  # No next turn for last one
            vec_current <- as.numeric(turn_vectors[., numeric_cols, drop = TRUE])
            vec_next <- as.numeric(turn_vectors[.+1, numeric_cols, drop = TRUE])

            # More robust NA checking
            if (any(is.na(vec_current))) return(NA_real_)
            if (any(is.na(vec_next))) return(NA_real_)
            if (length(vec_current) != length(vec_next)) return(NA_real_)

            # Safe cosine calculation with error handling
            tryCatch({
              1 - lsa::cosine(vec_current, vec_next)
            }, error = function(e) NA_real_)
          }
        )
      ) %>%
      dplyr::select(turn_count, contains("cosdist"))

    return(turn_vectors)
  }

  # Process both embeddings
  glo_results <- process_turn_embeddings(djoin_glo, "glo")
  sd15_results <- process_turn_embeddings(djoin_sd15, "sd15")

  # Combine results and add original metadata
  final_result <- glo_results %>%
    dplyr::full_join(sd15_results, by = "turn_count") %>%
    dplyr::left_join(
      dat %>% dplyr::group_by(turn_count) %>%
        dplyr::summarize(talker = dplyr::first(talker),
          n_words = dplyr::n(),
          .groups = "drop"
        ),
      by = "turn_count"
    ) %>% dplyr::select(turn_count, talker, n_words, everything())

  return(final_result)
}
