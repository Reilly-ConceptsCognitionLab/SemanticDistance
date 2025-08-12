#' dist_dialogue
#'
#' Function takes dataframe cleaned using 'clean_dialogue' and computes two metrics of semantic distance turn-to-turn indexing a 'talker' column. Sums all the respective semantic vectors within each tuern, cosine distance to the next turn's composite vector
#'
#' @name dist_dialogue
#' @param dat a dataframe prepped using 'clean_dialogue' fn with talker data and turncount appended
#' @param who_talking factor variable with two levels specifying an ID for the person producing the text in `word_clean`
#' @return a dataframe
#' @importFrom dplyr across
#' @importFrom dplyr all_of
#' @importFrom dplyr any_of
#' @importFrom dplyr arrange
#' @importFrom dplyr contains
#' @importFrom dplyr first
#' @importFrom dplyr full_join
#' @importFrom dplyr group_by
#' @importFrom dplyr left_join
#' @importFrom dplyr mutate
#' @importFrom dplyr n
#' @importFrom dplyr rename
#' @importFrom dplyr rename_with
#' @importFrom dplyr select
#' @importFrom dplyr summarise
#' @importFrom lsa cosine
#' @importFrom magrittr %>%
#' @importFrom purrr map2_dbl
#' @importFrom purrr transpose
#' @importFrom purrr map
#' @importFrom tidyselect everything
#' @importFrom utils install.packages
#' @export

dist_dialogue <- function(dat, who_talking) {
  # Check if required columns exist
  required_cols <- c("id_row_orig", "turn_count", "word_clean", who_talking)
  if (!all(required_cols %in% names(dat))) {
    missing_cols <- setdiff(required_cols, names(dat))
    stop(paste("Missing required columns:", paste(missing_cols, collapse = ", ")))
  }

  # Prepare data with unique row identifier
  dat <- dat %>%
    dplyr::mutate(
      row_id = dplyr::row_number(),
      word_clean = tolower(word_clean),
      talker = as.factor(.data[[who_talking]]),  # Use dynamic column name
      turn_count = as.integer(turn_count)
    ) %>%
    dplyr::select(row_id, id_row_orig, talker, turn_count, word_clean)

  # Join with embedding databases
  djoin_glo <- dplyr::left_join(dat, glowca_25, by = c("word_clean" = "word"))
  djoin_sd15 <- dplyr::left_join(dat, SD15_2025_complete, by = c("word_clean" = "word"))

  process_turn_embeddings <- function(embed_df, prefix) {
    # Get embedding dimensions
    numeric_cols <- names(embed_df)[sapply(embed_df, is.numeric)]
    numeric_cols <- setdiff(numeric_cols, c("row_id", "id_row_orig", "turn_count"))

    if (length(numeric_cols) == 0) {
      stop(paste("No numeric embedding columns found in", prefix, "data"))
    }

    # Compute mean vector for each turn - Handle all-NA cases
    turn_vectors <- embed_df %>%
      dplyr::group_by(turn_count) %>%
      dplyr::summarise(
        dplyr::across(
          .cols = dplyr::any_of(numeric_cols),
          .fns = ~ if (all(is.na(.))) NA_real_ else mean(., na.rm = TRUE)
        ),
        .groups = "drop"
      ) %>%
      dplyr::arrange(turn_count)

    # Calculate cosine distances between consecutive turns
    turn_vectors <- turn_vectors %>%
      dplyr::mutate(
        "{prefix}_cosdist" := purrr::map_dbl(
          1:dplyr::n(),
          ~ {
            if (.x == dplyr::n()) return(NA_real_)
            vec_current <- unlist(turn_vectors[.x, numeric_cols])
            vec_next <- unlist(turn_vectors[.x + 1, numeric_cols])

            # Return NA if either vector has any NA
            if (any(is.na(vec_current)) || any(is.na(vec_next))) return(NA_real_)
            if (length(vec_current) != length(vec_next)) return(NA_real_)

            tryCatch(
              lsa::cosine(vec_current, vec_next),
              error = function(e) NA_real_
            )
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
          n_words = sum(!is.na(word_clean)),  # Count actual words
          .groups = "drop"
        ),
      by = "turn_count"
    ) %>%
    dplyr::rename(!!who_talking := talker) %>%
    dplyr::select(turn_count, !!who_talking, n_words, tidyselect::everything())

  return(final_result)
}
