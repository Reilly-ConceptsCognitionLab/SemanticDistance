#' dist_dialogue
#'
#' Function takes dataframe cleaned using 'clean_dialogue' and computes two metrics of semantic distance turn-to-turn indexing a 'talker' column. Sums all the respective semantic vectors within each tuern, cosine distance to the next turn's composite vector
#'
#' @name dist_dialogue
#' @param dat a dataframe prepped using 'clean_dialogue' fn with talker data and turncount appended
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom dplyr arrange
#' @importFrom dplyr contains
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr full_join
#' @importFrom dplyr mutate
#' @importFrom dplyr summarize
#' @importFrom dplyr group_by
#' @importFrom dplyr rename_with
#' @importFrom dplyr across
#' @importFrom dplyr all_of
#' @importFrom dplyr any_of
#' @importFrom dplyr first
#' @importFrom lsa cosine
#' @importFrom purrr map2_dbl
#' @importFrom purrr transpose
#' @importFrom purrr map
#' @importFrom tidyselect everything
#' @importFrom utils install.packages
#' @export dist_dialogue

dist_dialogue <- function(dat) {
  # Load required packages
  required_packages <- c("purrr", "magrittr", "dplyr", "lsa", "utils")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  }

  # Check if required columns exist in input data
  required_cols <- c("id_row_orig", "talker", "id_turn", "word_clean")
  if (!all(required_cols %in% names(dat))) {
    missing_cols <- setdiff(required_cols, names(dat))
    stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
  }

  # Prepare data with unique row identifier
  dat <- dat %>%
    dplyr::mutate(
      row_id = seq_len(nrow(dat)),
      word_clean = tolower(word_clean),
      talker = as.factor(talker),
      turn_count = as.integer(id_turn)
    ) %>%
    dplyr::select(row_id, id_row_orig, talker, turn_count, word_clean)

  # Join with embedding databases
  djoin_glo <- dplyr::left_join(dat, glowca_25, by = c("word_clean" = "word"))
  djoin_sd15 <- dplyr::left_join(dat, SD15_2025_complete, by = c("word_clean" = "word"))

  process_turn_embeddings <- function(embed_df, prefix) {
    # Get embedding dimensions - safer approach
    numeric_cols <- names(embed_df)[sapply(embed_df, is.numeric)]
    numeric_cols <- setdiff(numeric_cols, c("row_id", "id_row_orig", "turn_count"))

    # Verify we have numeric columns to work with
    if (length(numeric_cols) == 0) {
      stop(paste("No numeric embedding columns found in", prefix, "data"))
    }

    # Ensure all numeric_cols actually exist in the data
    existing_cols <- numeric_cols[numeric_cols %in% names(embed_df)]
    if (length(existing_cols) == 0) {
      stop(paste("None of the identified numeric columns exist in the data:",
                 paste(numeric_cols, collapse = ", ")))
    }

    # Compute mean vector for each turn - safer across implementation
    turn_vectors <- embed_df %>%
      dplyr::group_by(turn_count) %>%
      dplyr::summarise(dplyr::across(
          dplyr::any_of(numeric_cols),  # Use any_of() instead of all_of() to be forgiving
          ~mean(., na.rm = TRUE)
        ),
        .groups = "drop"
      ) %>% dplyr::arrange(turn_count)

    # Rest of your function remains the same...
    # Calculate cosine distances between consecutive turns
    turn_vectors <- turn_vectors %>%
      dplyr::mutate("{prefix}_cosdist" := purrr::map_dbl(
          1:n(),
          ~ {
            if (. == n()) return(NA_real_)
            vec_current <- as.numeric(turn_vectors[., existing_cols, drop = TRUE])
            vec_next <- as.numeric(turn_vectors[.+1, existing_cols, drop = TRUE])

            if (any(is.na(vec_current))) { return(NA_real_) }
            if (any(is.na(vec_next))) { return(NA_real_) }
            if (length(vec_current) != length(vec_next)) { return(NA_real_) }

            tryCatch({
              1 - lsa::cosine(vec_current, vec_next)
            }, error = function(e) NA_real_)
          }
        )
      ) %>%
      dplyr::select(turn_count, dplyr::contains("cosdist"))

    return(turn_vectors)
  }
  # Process both embeddings
  glo_results <- process_turn_embeddings(djoin_glo, "glo")
  sd15_results <- process_turn_embeddings(djoin_sd15, "sd15")

  # Combine results and add original metadata
  final_result <- glo_results %>%
    dplyr::full_join(sd15_results, by = "turn_count") %>%
    dplyr::left_join(
      dat %>%
        dplyr::group_by(turn_count) %>%
        dplyr::summarise(
          talker = dplyr::first(talker),
          n_words = dplyr::n(),
          .groups = "drop"
        ),
      by = "turn_count"
    ) %>%
    dplyr::select(turn_count, talker, n_words, tidyselect::everything())

  return(final_result)
}
