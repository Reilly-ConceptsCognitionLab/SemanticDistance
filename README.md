
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SemanticDistance

<!-- badges: start -->
<!-- badges: end -->

The goal of SemanticDistance is to …

## Installation

You can install the development version of SemanticDistance from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("Reilly-ConceptsCognitionLab/SemanticDistance")
```

## Example

This is a basic example which shows you how to solve a common problem:

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
## basic example code
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date. `devtools::build_readme()` is handy for this.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub and CRAN.
