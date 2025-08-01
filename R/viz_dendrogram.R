#' viz_dendrogram
#'
#' Takes a vector of words with semantic distance ratings, converts to a square matrix, then to a euclidean distance
#' matrix (all word pairs), then plots the words s a cluster dendrogram, behind
#' the scenes optimizing for k-cluster size.
#'
#' @name viz_dendrogram
#' @param dat datafrane with cosine semantic dist values (not a distance matrix!)
#' @param dist_type quoted argument semantic norms for running distance matrix on default='embedding', other is 'SD15'
#' @param ... additional arguments passed to internal functions
#' @details This function internally calls eval_kmeans_clustersize for
#' cluster evaluation. The dendrogram visualization is based on hierarchical
#' clustering of semantic distances.
#' @importFrom ape as.phylo
#' @importFrom dendextend set
#' @importFrom dendextend raise.dendrogram
#' @importFrom dplyr left_join
#' @importFrom graphics par
#' @importFrom lsa cosine
#' @importFrom magrittr %>%
#' @importFrom stats order.dendrogram
#' @importFrom stats cutree
#' @importFrom stats dist
#' @importFrom stats hclust
#' @importFrom stats quantile
#' @importFrom stats as.dendrogram
#' @importFrom wesanderson wes_palette
#' @return a plot of a dendrogram
#' @export

viz_dendrogram <- function(dat, dist_type = "embedding") {
  # Remove duplicate words while preserving original order
  unique_words <- dat %>%
    dplyr::select(word_clean) %>%
    dplyr::mutate(word_clean = tolower(word_clean)) %>%
    dplyr::distinct(word_clean, .keep_all = TRUE) %>%
    dplyr::pull(word_clean)

  words <- unique_words

  # Get appropriate embeddings
  if (tolower(dist_type) == "embedding") {
    embeddings <- dplyr::left_join(data.frame(word = words), glowca_25, by = "word")
  } else if (tolower(dist_type) == "sd15") {
    embeddings <- dplyr::left_join(data.frame(word = words), SD15_2025_complete, by = "word")
  } else {
    stop("Invalid distance type. Choose either 'embedding' or 'SD15'")
  }

  # Process embeddings matrix
  numeric_cols <- names(embeddings)[sapply(embeddings, is.numeric)]
  embedding_matrix <- as.matrix(embeddings[, numeric_cols, drop = FALSE])

  # Calculate cosine distance matrix
  dist_matrix <- matrix(NA, nrow = nrow(embedding_matrix), ncol = nrow(embedding_matrix))
  for (i in 1:nrow(embedding_matrix)) {
    for (j in 1:nrow(embedding_matrix)) {
      if (!all(is.na(embedding_matrix[i, ])) && !all(is.na(embedding_matrix[j, ]))) {
        dist_matrix[i, j] <- 1 - lsa::cosine(embedding_matrix[i, ], embedding_matrix[j, ])
      }
    }
  }
  rownames(dist_matrix) <- words
  colnames(dist_matrix) <- words

  # Compute Euclidean distance and hierarchical clustering
  dist_euclid <- stats::dist(dist_matrix, method = 'euclidean')
  hc <- stats::hclust(dist_euclid, method = "ward.D2")

  # Determine optimal clusters and get colors
  K <- eval_kmeans_clustersize(dist_matrix)
  mycols <- wesanderson::wes_palette("Moonrise3", K, type = "continuous")

  # Create and style dendrogram
  dend <- stats::as.dendrogram(hc) %>%
    dendextend::set(
      "labels_cex" = 1.25,
      "branches_lwd" = 1.5,
      "branches_k_color" = list(k = K, value = mycols),
      "leaves_pch" = 19,
      "leaves_cex" = 1.4,
      "leaves_col" = mycols[stats::cutree(hc, k = K)][stats::order.dendrogram(.)]
    ) %>%
    dendextend::raise.dendrogram(2)

  # Plot triangle dendrogram
  plot(dend, horiz = FALSE, type = "triangle")

  # Return dendrogram invisibly with cluster info
  invisible(structure(dend,
                      k_clusters = stats::cutree(hc, k = K),
                      words = words))
}
