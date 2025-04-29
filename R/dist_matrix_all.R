#' dist_matrix_all
#'
#' Function takes dataframe cleaned using 'clean_unordered4matrix', pairwise distance between all elements as a matrix
#' @name dist_matrix_all
#' @param dat a dataframe prepped using 'clean_unordered4matrix' fn
#' @param dist_type semantic norms for running distance matrix on default='embedding', other is 'SD15'
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom dplyr left_join
#' @importFrom lsa cosine
#' @importFrom utils install.packages
#' @export dist_matrix_all

dist_matrix_all <- function(dat, dist_type = "embedding") {
  if (!requireNamespace("lsa", quietly = TRUE)) {
    install.packages("lsa")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    install.packages("dplyr")
  }
  if (!requireNamespace("magrittr", quietly = TRUE)) {
    install.packages("magrittr")
  }

  # Prepare data - just get the words we need to compare
  words <- tolower(dat$word_clean)

  if (tolower(dist_type) == "embedding") {
    # Join with GLO embeddings
    embeddings <- dplyr::left_join(data.frame(word = words), glowca_25, by = "word")
  } else if (tolower(dist_type) == "sd15") {
    # Join with SD15 embeddings
    embeddings <- dplyr::left_join(data.frame(word = words), SD15_2025, by = "word")
  } else {
    stop("dist_type must be either 'embedding' or 'SD15'")
  }

  # Get numeric columns (the embedding vectors)
  numeric_cols <- names(embeddings)[sapply(embeddings, is.numeric)]
  embedding_matrix <- as.matrix(embeddings[, numeric_cols])

  # Calculate pairwise cosine distances
  dist_matrix <- matrix(NA, nrow = nrow(embedding_matrix), ncol = nrow(embedding_matrix))

  for (i in 1:nrow(embedding_matrix)) {
    for (j in 1:nrow(embedding_matrix)) {
      if (all(is.na(embedding_matrix[i, ])) || all(is.na(embedding_matrix[j, ]))) {
        dist_matrix[i, j] <- NA
      } else {
        dist_matrix[i, j] <- 1 - lsa::cosine(embedding_matrix[i, ], embedding_matrix[j, ])
      }
    }
  }

  # Set row and column names to the words for reference
  rownames(dist_matrix) <- words
  colnames(dist_matrix) <- words

  return(dist_matrix)
}
