# wordlist_to_network

Takes a vector of words with semantic distance ratings, converts to a
square matrix, then to a euclidean distance matrix (all word pairs),
then plots the words in either a cluster dendrogram or simple igraph
network

## Usage

``` r
wordlist_to_network(
  dat,
  wordcol,
  output = "dendrogram",
  dist_type = "embedding"
)
```

## Arguments

- dat:

  dataframe with text in it (cleaned using clean_monologue_or_list
  function

- wordcol:

  quoted argument identifying column in dataframe with target text

- output:

  quoted argument for type of output default is 'dendrogram', alternate
  is 'network'

- dist_type:

  quoted argument semantic norms for running distance matrix on
  default='embedding', other is 'SD15'

## Value

a plot of a dendrogram or an igraph network AND a cosine distance matrix

## Details

This function internally calls eval_kmeans_clustersize for cluster
evaluation. The dendrogram visualization is based on hierarchical
clustering of semantic distances.
