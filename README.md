
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SemanticDistance

<img src="man/figures/header4readme.png" alt="semantic relations between cat, dog, leash" width="40%" />

<!-- badges: start -->

[![R-CMD-check](https://github.com/Reilly-ConceptsCognitionLab/SemanticDistance/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Reilly-ConceptsCognitionLab/SemanticDistance/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

SemanticDistance cleans and formats text then computes pairwise metrics
of cosine semantic distance between different adjacent chunks (e.g.,
ngrams, words, turns) within language samples. We offer two different
semantic distance metrics, experiential and embedding. Experiential
semantic distance reflects cosine (normalized from 0) between two
vectors spanning 15 meaningful semantic dimensions (e.g., color, sound,
valence). Embedding-based semantic distances are derived by contrasting
each word’s corresponding semantic vector spanning 300 hyperparameters
as trained on the GLOVE word embedding model. The SemamticDistance
package contains lookup databases with semantic vectors spanning \>70k
English words. <br/>

SemanticDistance operates on a dataframe that nominally has one column
of text that has been split into a one word-per-row format. However,
SemanticDistance can also produce distance values for words arrayed in
two columns. Users have numerous ‘chunking’ options for rolling distance
comparisons in either monologues (no speaker information) or dialogues
(speakers identifed as in conversation transcripts). Chunk options
include: <br/> 1) word-to-word <br/> 2) ngram-to-ngram <br/> 3)
ngram-to-word (rolling) <br/> 4) turn-to-turn (split by talker ID) <br/>

## Installation

You can install the development version of SemanticDistance from
[GitHub](https://github.com/) with:

``` r
install.packages("devtools")
devtools::install_github("Reilly-ConceptsCognitionLab/ConversationAlign")
```

You will nominally need one column of text within a dataframe. Your text
should be pre-formatted so that it is split into a one word per row
format. However, SemanticDistance is also capable of computing pairwise
cosine distance across two columns (e.g., dog leash).

# Let’s do it!

Pre-format your language transcript. SemanticDistance works on
monologues (no talker information) or dialogues (two or more speakers).
First load the package. Then read your transcript into R. It doesn’t
matter how you label your variables. You will specify these names in the
arguments to your function calls. The first critical step is to clean
and format your transcript. There are three cleaning functions to choose
from based on the structure of your data: clean_monologue,
clean_dialogue, clean_columns <br/>

## load the package

``` r
library(SemanticDistance)
#> Loading required package: DescTools
#> Loading required package: dplyr
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
#> Loading required package: here
#> here() starts at /Users/Jamie/Library/CloudStorage/OneDrive-TempleUniversity/Reilly_RData/SemanticDistance
#> Loading required package: magrittr
#> Loading required package: tidyverse
#> ── Attaching core tidyverse packages ──────────────────────── tidyverse 2.0.0 ──
#> ✔ forcats   1.0.0     ✔ readr     2.1.5
#> ✔ ggplot2   3.5.2     ✔ stringr   1.5.1
#> ✔ lubridate 1.9.4     ✔ tibble    3.2.1
#> ✔ purrr     1.0.4     ✔ tidyr     1.3.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ tidyr::extract()   masks magrittr::extract()
#> ✖ dplyr::filter()    masks stats::filter()
#> ✖ dplyr::lag()       masks stats::lag()
#> ✖ purrr::set_names() masks magrittr::set_names()
#> ℹ Use the conflicted package (<http://conflicted.r-lib.org/>) to force all conflicts to become errors
#> Loading required package: stringi
#> 
#> Loading required package: textstem
#> 
#> Loading required package: koRpus.lang.en
#> 
#> Loading required package: koRpus
#> 
#> Loading required package: sylly
#> 
#> For information on available language packages for 'koRpus', run
#> 
#>   available.koRpus.lang()
#> 
#> and see ?install.koRpus.lang()
#> 
#> 
#> 
#> Attaching package: 'koRpus'
#> 
#> 
#> The following object is masked from 'package:readr':
#> 
#>     tokenize
#> 
#> 
#> Loading required package: textclean
#> 
#> Loading required package: tidytable
#> 
#> Warning: tidytable was loaded after dplyr.
#> This can lead to most dplyr functions being overwritten by tidytable functions.
#> 
#> Warning: tidytable was loaded after tidyr.
#> This can lead to most tidyr functions being overwritten by tidytable functions.
#> 
#> 
#> Attaching package: 'tidytable'
#> 
#> 
#> The following objects are masked from 'package:purrr':
#> 
#>     map, map_chr, map_dbl, map_df, map_dfc, map_dfr, map_int, map_lgl,
#>     map_vec, map2, map2_chr, map2_dbl, map2_df, map2_dfc, map2_dfr,
#>     map2_int, map2_lgl, map2_vec, pmap, pmap_chr, pmap_dbl, pmap_df,
#>     pmap_dfc, pmap_dfr, pmap_int, pmap_lgl, pmap_vec, walk
#> 
#> 
#> The following objects are masked from 'package:tidyr':
#> 
#>     complete, crossing, drop_na, expand, expand_grid, extract, fill,
#>     nest, nesting, pivot_longer, pivot_wider, replace_na, separate,
#>     separate_longer_delim, separate_rows, separate_wider_delim,
#>     separate_wider_regex, tribble, uncount, unite, unnest,
#>     unnest_longer, unnest_wider
#> 
#> 
#> The following objects are masked from 'package:tibble':
#> 
#>     enframe, tribble
#> 
#> 
#> The following object is masked from 'package:magrittr':
#> 
#>     extract
#> 
#> 
#> The following objects are masked from 'package:dplyr':
#> 
#>     across, add_count, add_tally, anti_join, arrange, between,
#>     bind_cols, bind_rows, c_across, case_match, case_when, coalesce,
#>     consecutive_id, count, cross_join, cume_dist, cur_column, cur_data,
#>     cur_group_id, cur_group_rows, dense_rank, desc, distinct, filter,
#>     first, full_join, group_by, group_cols, group_split, group_vars,
#>     if_all, if_any, if_else, inner_join, is_grouped_df, lag, last,
#>     lead, left_join, min_rank, mutate, n, n_distinct, na_if, nest_by,
#>     nest_join, nth, percent_rank, pick, pull, recode, reframe,
#>     relocate, rename, rename_with, right_join, row_number, rowwise,
#>     select, semi_join, slice, slice_head, slice_max, slice_min,
#>     slice_sample, slice_tail, summarise, summarize, tally, top_n,
#>     transmute, tribble, ungroup
#> 
#> 
#> The following object is masked from 'package:DescTools':
#> 
#>     %like%
#> 
#> 
#> The following objects are masked from 'package:stats':
#> 
#>     dt, filter, lag
#> 
#> 
#> The following object is masked from 'package:base':
#> 
#>     %in%
#> 
#> 
#> Loading required package: tm
#> 
#> Loading required package: NLP
#> 
#> 
#> Attaching package: 'NLP'
#> 
#> 
#> The following object is masked from 'package:ggplot2':
#> 
#>     annotate
#> 
#> 
#> 
#> Attaching package: 'tm'
#> 
#> 
#> The following object is masked from 'package:koRpus':
#> 
#>     readTagged
#> 
#> 
#> Loading required package: tidyselect
#> 
#> Loading required package: lsa
#> 
#> Loading required package: SnowballC
#> 
#> 
#> Attaching package: 'lsa'
#> 
#> 
#> The following object is masked from 'package:koRpus':
#> 
#>     query
```

## View raw data

### monologue

This could be a story or instructions - anything where you don’t care
about talker information. You should format your transcript so that
there is a vector (column) of words. All other metadata will be
retained. Here’s a sample monologue with all sorts of junk in a column
called ‘mytext’. It’s not split and vectorized the way it should be, but
the clean_monologue function should fix it and append a unique
identifier to each word while retaining empty strings that could be
meaningful.

``` r
#raw messy transcript of a monologue with missing obs and text that needs to be split
#head(MonologueSample1, n=25)
```

### clean_monologue

Appends a unique numeric identifier to each row. Then splits all the
elenents of each row into separate rows. Defaults are to omit stopwords
and lemmatize. Note: if you want to lemmatize and omit stopwords you
don’t need to do anything or specify the arguments. You do, however,
need to tell the package your dataframe name and the column name (in
quotes) you want to run your operation on,

``` r
#arguments: df, wordcol, omit_stops=TRUE, lemmatize = TRUE
#df=dataframe name 
#wordcol = quoted column name where your text data live
#omit_stops - omit stopwords default is TRUE
#lemnatize - lemmatizes strings default is TRUE
#my_clean_dat <- clean_monologue(MonologueSample1, 'word', omit_stops=T, lemmatize=T)
```
