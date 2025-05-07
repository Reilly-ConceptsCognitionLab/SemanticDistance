#' dist_matrix
#'
#' Function takes dataframe cleaned using 'clean_unordered4matrix', pairwise distance between all elements as a matrix
#' @name dist_matrix
#' @param dat a dataframe prepped using 'clean_unordered4matrix' fn
#' @param dist_type semantic norms for running distance matrix on default='embedding', other is 'SD15'
#' @return a dataframe
#' @importFrom dplyr left_join
#' @importFrom lsa cosine
#' @importFrom magrittr %>%
#' @importFrom utils install.packages
#' @export dist_matrix

dist_matrix <- function(dat, dist_type = "embedding") {
  my_packages <- c("dplyr", "lsa", "magrittr", "utils")
  for (pkg in my_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  }

  # Prepare data - just get the words we need to compare
  words <- tolower(dat$word_clean)

  if (tolower(dist_type) == "embedding") {
    # Join with GLO embeddings
    embeddings <- dplyr::left_join(data.frame(word = words), glowca_25, by = "word")
  } else if (tolower(dist_type) == "SD15") {
    # Join with SD15 embeddings
    embeddings <- dplyr::left_join(data.frame(word = words), SD15_2025_complete, by = "word")
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
