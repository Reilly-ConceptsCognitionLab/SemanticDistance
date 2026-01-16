# clean_paired_cols

Cleans a transcript where word pairs are arrayed in two columns.

## Usage

``` r
clean_paired_cols(dat, wordcol1, wordcol2, lemmatize = TRUE)
```

## Arguments

- dat:

  a dataframe with two columns of words you want pairwise distance for

- wordcol1:

  quoted column name storing the first string for comparison

- wordcol2:

  quoted column name storing the second string for comparison

- lemmatize:

  T/F user wishes to lemmatize each string (default is TRUE)

## Value

a dataframe
