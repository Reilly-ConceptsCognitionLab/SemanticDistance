# dist_ngram2ngram

Function takes dataframe cleaned using 'clean_monologue', computes
rolling chunk-to-chunk distance between user-specified ngram size (e.g.,
2-word chunks)

## Usage

``` r
dist_ngram2ngram(dat, ngram)
```

## Arguments

- dat:

  a dataframe prepped using 'clean_monologue' fn

- ngram:

  an integer specifying the window size of words for computing distance
  to a target word

## Value

a dataframe
