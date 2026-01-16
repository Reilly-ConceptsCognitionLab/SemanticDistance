# dist_anchor

Function takes dataframe cleaned using 'clean_monologue', computes
rolling chunk-to-chunk distance between user-specified ngram size (e.g.,
2-word chunks)

## Usage

``` r
dist_anchor(dat, anchor_size = 10)
```

## Arguments

- dat:

  a dataframe prepped using 'clean_monologue' fn

- anchor_size:

  an integer specifying the number of words in the initial chunk for
  comparison to new words as the sample unfolds

## Value

a dataframe
