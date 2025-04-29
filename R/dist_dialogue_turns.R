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

  library(dplyr)
  library(purrr)

  # Check if required columns exist in input data
  required_cols <- c("id_orig", "talker", "turn_count", "word_clean")
  if (!all(required_cols %in% names(dat))) {
    missing_cols <- setdiff(required_cols, names(dat))
    stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
  }

  # Prepare data
  dat <- dat %>%
    dplyr::select(id_orig, talker, turn_count, word_clean) %>%
    dplyr::mutate(
      word_clean = tolower(word_clean),
      talker = as.factor(talker),
      turn_count = as.integer(turn_count)  # Keep as integer for ordering
    )

  # Join with embedding databases (assuming these exist in global environment)
  djoin_glo <- dplyr::left_join(dat, glowca_25, by = c("word_clean" = "word"))
  djoin_sd15 <- dplyr::left_join(dat, SD15_2025, by = c("word_clean" = "word"))

  # Function to compute average vectors and consecutive turn distances
  process_embeddings <- function(embed_df, prefix) {
    # Get numeric columns (embedding dimensions), excluding grouping vars
    numeric_cols <- setdiff(
      names(embed_df)[sapply(embed_df, is.numeric)],
      c("turn_count", "id_orig")  # Exclude non-embedding numeric columns
    )

    # Check if we have any numeric columns to process
    if (length(numeric_cols) == 0) {
      stop(paste("No numeric columns found in", prefix, "embedding data"))
    }

    # Compute average vector for each turn_count
    avg_vectors <- embed_df %>%
      dplyr::group_by(turn_count) %>%
      dplyr::summarize(
        dplyr::across(all_of(numeric_cols), ~mean(., na.rm = TRUE)),
        .groups = "drop"
      ) %>%
      dplyr::arrange(turn_count)  # Ensure proper ordering

    # Calculate distances between consecutive turns
    avg_vectors <- avg_vectors %>%
      dplyr::mutate(
        next_turn_vector = purrr::map(
          dplyr::lead(dplyr::across(all_of(numeric_cols))),  # Get next turn's vector
          ~ if (all(is.na(.))) NA else .
        ),
        distance_to_next = purrr::map2_dbl(
          dplyr::across(all_of(numeric_cols)) %>% purrr::transpose(),
          next_turn_vector,
          ~ {
            if (all(is.na(.y))) return(NA)
            1 - lsa::cosine(unlist(.x), unlist(.y))
          }
        )
      ) %>%
      dplyr::select(-next_turn_vector) %>%  # Remove temporary column
      dplyr::rename_with(~paste0(prefix, "_", .), -turn_count)

    return(avg_vectors)
  }


  # Process both embeddings
  glo_results <- process_embeddings(djoin_glo, "glo")
  sd15_results <- process_embeddings(djoin_sd15, "sd15")

  # Combine results
  final_result <- dplyr::full_join(glo_results, sd15_results, by = "turn_count")

  return(final_result)
}
