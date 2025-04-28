#' dist_anchor
#'
#' Function takes dataframe cleaned using 'clean_monologue', computes rolling chunk-to-chunk distance between user-specified ngram size (e.g., 2-word chunks)
#' @name dist_anchor
#' @param dat a dataframe prepped using 'clean_monologue' fn
#' @param anchor_size an integer specifying the number of words in the initial chunk for comparison to new words as the sample unfolds
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom dplyr select
#' @importFrom dplyr left_join
#' @importFrom dplyr group_by
#' @importFrom dplyr summarize
#' @importFrom dplyr mutate
#' @importFrom dplyr across
#' @importFrom dplyr slice
#' @importFrom dplyr where
#' @importFrom dplyr all_of
#' @importFrom dplyr last
#' @importFrom lsa cosine
#' @importFrom utils install.packages
#' @export dist_anchor

dist_anchor <- function(dat, anchor_size = 10) {
  # Load required packages
  if (!requireNamespace("lsa", quietly = TRUE)) {
    install.packages("lsa")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    install.packages("dplyr")
  }
  if (!requireNamespace("magrittr", quietly = TRUE)) {
    install.packages("magrittr")
  }

  # Prepare data
  dat <- dat %>%
    dplyr::select(id_orig, word_clean) %>%
    dplyr::mutate(
      id_orig = as.factor(id_orig),
      word_clean = tolower(word_clean)
    )

  # Join with embedding databases
  djoin_glow <- dplyr::left_join(dat, glowca_25, by = c("word_clean" = "word"))
  djoin_sd15 <- dplyr::left_join(dat, SD15_2025, by = c("word_clean" = "word"))

  # Function to calculate anchor-based cosine distances
  calculate_anchor_dist <- function(embed_df, prefix) {
    # Get numeric columns
    numeric_cols <- names(embed_df)[sapply(embed_df, is.numeric)]

    # Calculate anchor vector (mean of first anchor_size words)
    anchor_vec <- embed_df %>%
      dplyr::slice(1:anchor_size) %>%
      dplyr::select(all_of(numeric_cols)) %>%
      colMeans(na.rm = TRUE)

    # Calculate cosine distance to anchor for each word
    embed_df[[paste0("CosDist_Anchor_", prefix)]] <- apply(
      embed_df[, numeric_cols],
      1,
      function(x) {
        if (all(is.na(x))) return(NA)
        1 - lsa::cosine(x, anchor_vec)
      }
    )

    return(embed_df %>% dplyr::select(id_orig, contains("CosDist")))
  }

  # Calculate distances for both embeddings
  glo_dist <- calculate_anchor_dist(djoin_glow, "GLO")
  sd15_dist <- calculate_anchor_dist(djoin_sd15, "SD15")

  # Combine results with original data
  result <- dat %>%
    dplyr::left_join(glo_dist, by = "id_orig") %>%
    dplyr::left_join(sd15_dist, by = "id_orig")

  return(result)
}
