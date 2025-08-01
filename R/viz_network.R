#' viz_network
#'
#' Creates a network visualization from semantic distance data
#'
#' @param dat dataframe with cosine semantic distance values (not a distance matrix!)
#' @param dist_type quoted argument specifying semantic norms for distance matrix.
#'        Default='embedding', other option is 'SD15'
#' @param ... additional arguments passed to internal functions
#' @details This function internally calls eval_kmeans_clustersize for
#'          cluster evaluation. The network visualization is based on hierarchical
#'          clustering of semantic distances.
#' @importFrom ape as.phylo
#' @importFrom graphics par
#' @importFrom igraph graph_from_adjacency_matrix
#' @importFrom igraph set_vertex_attr
#' @importFrom igraph set_edge_attr
#' @importFrom igraph delete_edges
#' @importFrom igraph E
#' @importFrom igraph layout_with_fr
#' @importFrom stats cutree
#' @importFrom stats dist
#' @importFrom stats hclust
#' @importFrom stats quantile
#' @importFrom wesanderson wes_palette
#' @return an igraph network plot
#' @export

viz_network <- function(dat, dist_type = "embedding") {

  # Remove duplicate words while preserving original order
  unique_words <- dat %>%
    dplyr::select(word_clean) %>%
    dplyr::mutate(word_clean = tolower(word_clean)) %>%
    dplyr::distinct(word_clean, .keep_all = TRUE) %>%
    dplyr::pull(word_clean)

  words <- unique_words

  if (tolower(dist_type) == "embedding") {
    embeddings <- dplyr::left_join(data.frame(word = words), glowca_25, by = "word")
  } else if (tolower(dist_type) == "sd15") {
    embeddings <- dplyr::left_join(data.frame(word = words), SD15_2025_complete, by = "word")
  } else {
    stop("Invalid distance type. Choose either 'embedding' or 'SD15'")
  }

  # Get numeric columns
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
  K <- eval_kmeans_clustersize(dist_matrix)  # Fixed variable name
  mycols <- wesanderson::wes_palette("Moonrise3", K, type = "continuous")

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
}
