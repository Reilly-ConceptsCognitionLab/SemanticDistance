#' words_to_network
#'
#' Takes a vector of words with semantic distance ratings, converts to a square matrix, then to a euclidean distance
#' matrix (all word pairs), then plots the words in either a cluster dendrogram or simple igraph network
#'
#' @name words_to_network
#' @param dat dataframe with text in it (not cleaned or formatted)
#' @param wordcol quoted argument identifying column in dataframe with target text
#' @param dist_type quoted argument semantic norms for running distance matrix on default='embedding', other is 'SD15'
#' @param output quoted argument for type of output default is 'dendrogram', alternate is 'network'
#' @param ... additional arguments passed to internal functions
#' @details This function internally calls eval_kmeans_clustersize for
#' cluster evaluation. The dendrogram visualization is based on hierarchical
#' clustering of semantic distances.
#' @importFrom ape as.phylo
#' @importFrom dendextend set
#' @importFrom dendextend raise.dendrogram
#' @importFrom dplyr left_join
#' @importFrom graphics par
#' @importFrom igraph graph_from_adjacency_matrix
#' @importFrom igraph set_vertex_attr
#' @importFrom igraph set_edge_attr
#' @importFrom igraph delete_edges
#' @importFrom igraph E
#' @importFrom igraph layout_with_fr
#' @importFrom lsa cosine
#' @importFrom magrittr %>%
#' @importFrom stats order.dendrogram
#' @importFrom stats cutree
#' @importFrom stats dist
#' @importFrom stats hclust
#' @importFrom stats quantile
#' @importFrom stats as.dendrogram
#' @importFrom wesanderson wes_palette
#' @return a plot of a dendrogram or an igraph network AND a cosine distance matrix
#' @export

words_to_network <- function(dat, wordcol, output = 'dendrogram', dist_type = "embedding") {
  # Validate wordcol exists
  if (!wordcol %in% names(dat)) {
    stop(paste("Column", wordcol, "not found in dataframe"))
  }

  # Remove duplicate words while preserving original order
  unique_words <- dat %>%
    dplyr::select(!!sym(wordcol)) %>%
    dplyr::mutate(!!sym(wordcol) := tolower(!!sym(wordcol))) %>%
    dplyr::distinct(!!sym(wordcol), .keep_all = TRUE) %>%
    dplyr::pull(!!sym(wordcol))

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

if (output == "dendrogram") {
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
  return(invisible(structure(dend,
                             k_clusters = stats::cutree(hc, k = K),
                             words = words)))

} else if (output == "network") {
  # Convert to igraph
  g <- tryCatch({
    leaf_order <- hc$order
    n_leaves <- length(leaf_order)

    # Create adjacency matrix
    adj_matrix <- as.matrix(dist_matrix)
    adj_matrix <- adj_matrix[leaf_order, leaf_order]
    diag(adj_matrix) <- 0  # Remove self-loops

    # Create graph
    net <- igraph::graph_from_adjacency_matrix(
      adj_matrix,
      mode = "undirected",
      weighted = TRUE
    )

    # Get cluster assignments
    clusters <- if (K == 1) rep(1, n_leaves) else stats::cutree(hc, k = K)
    vertex_colors <- mycols[clusters]

    # Set node labels
    node_labels <- rownames(dist_matrix)[leaf_order]

    # Set graph attributes
    net %>%
      igraph::set_vertex_attr("cluster", value = clusters) %>%
      igraph::set_vertex_attr("color", value = vertex_colors) %>%
      igraph::set_edge_attr("color", value = "gray70") %>%
      igraph::set_vertex_attr("size", value = 12) %>%
      igraph::set_vertex_attr("label", value = node_labels) %>%
      igraph::set_vertex_attr("label.color", value = "black") %>%
      igraph::set_vertex_attr("label.cex", value = 0.8) %>%
      igraph::set_edge_attr("width", value = 1.5) %>%
      igraph::delete_edges(which(igraph::E(net)$weight < quantile(igraph::E(net)$weight, 0.5)))
  }, error = function(e) stop("Network conversion failed: ", e$message))

  # Plot network
  graphics::par(mar = c(1, 1, 1, 1))
  plot(g,
       layout = igraph::layout_with_fr(g),
       vertex.frame.color = "white",
       main = "Cluster Network",
       margin = -0.15,
       vertex.label.dist = 0.5)

  return(invisible(g))

} else {
  stop("Invalid output type. Choose either 'dendrogram' or 'network'")
}
}
