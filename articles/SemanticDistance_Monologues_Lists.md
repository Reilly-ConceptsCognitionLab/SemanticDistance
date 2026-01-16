# SemanticDistance_Monologues_Lists

For our purposes a monologue is a ordered language sample that does not
contain turns and/or speaker information. Monologues consist of
narratives, stories, etc. An unordered list is a bag-of-words where word
order no longer matters. You might be interested in applying kmeans,
hierarchical clustering, or graph metrics to elucidate structure within
a list of words. Alternatively, you might be interested in evaluating
distances as ordered time series. Whatever your goal, the vignette to
follow will illustrate how to prep and clean your text data using
`SemanticDistance`.

## A typical monologue transcript

Included in the package

| mytext                                                                                                            |
|:------------------------------------------------------------------------------------------------------------------|
| The girl walked down the street. The wrestler punched the boxer. I could not open the door. 95 dogs jumped on me. |

## A typical unordered word list

Included in the package

| mytext                                                                                                           |
|:-----------------------------------------------------------------------------------------------------------------|
| trumpet trombone flute piano guitar gun knife missile bullet spear apple banana tomato sad angry happy disgusted |

## Step 1: Clean Monologue or List: `clean_monologue_or_list`

Transforms all text to lowercase then optionally cleans (omit stopwords,
omit non-alphabetic chars), lemmatizes (transforms morphological
derivatives of words to their standard dictionary entries), and splits
multiword utterances into a one-word-per row format. You can generally
leave split_strings in its default state (TRUE). `clean_monologue`
appends several new variables to your original dataframe:
**id_row_orig** a numeric identifier marking the original row where a
word or group of words appeared; **’id_row_postsplit** a unique
identifier marking each word’s ordered position in the dataframe after
splitting multiword utterances across rows; **word_clean** result of all
cleaning operations, needed for distance calculations.  

Function Arguments:  
`dat` raw dataframe with at least one column of text  
`wordcol` quoted variable column name where your target text lives
(e.g., ‘mytext’)  
`omit_stops` omits stopwords, T/F default is TRUE  
`lemmatize` transforms raw word to lemmatized form, T/F default is
TRUE  

``` r
Monologue_Cleaned <- clean_monologue_or_list(dat=Monologue_Typical, wordcol='mytext', omit_stops=TRUE, lemmatize=TRUE)
knitr::kable(head(Monologue_Cleaned, 12), format = "pipe", digits=2)
```

| id_row_orig | text_initialsplit | word_clean | id_row_postsplit |
|:------------|:------------------|:-----------|-----------------:|
| 1           | the               | NA         |                1 |
| 1           | girl              | girl       |                2 |
| 1           | walked            | walk       |                3 |
| 1           | down              | down       |                4 |
| 1           | the               | NA         |                5 |
| 1           | street.           | street     |                6 |
| 1           | the               | NA         |                7 |
| 1           | wrestler          | wrestler   |                8 |
| 1           | punched           | punch      |                9 |
| 1           | the               | NA         |               10 |
| 1           | boxer.            | boxer      |               11 |
| 1           | i                 | NA         |               12 |

## Step 2: Choose Distance Option/Compute Distances

### Option 1: Ngram-to-Word Distance: `dist_ngram2word`

Computes cosine distance for two models (embedding and experiential)
using a rolling ngram approach consisting of groups of words (ngrams) to
the next word. *IMPORTANT* the function looks backward from the target
word skipping over NAs until filling the desired ngram size.  

Function Arguments:  
`dat` dataframe of a monologue transcript cleaned and prepped with
clean_monologue fn  
`ngram` window size preceding each new content word, ngram=1 means each
word is compared to the word before it.

``` r
Ngram2Word_Dists1 <- dist_ngram2word(dat=Monologue_Cleaned, ngram=1) #distance word-to-word
head(Ngram2Word_Dists1)
#> # A tibble: 6 × 6
#>   id_row_orig text_initialsplit word_clean id_row_postsplit CosDist_1gram_glo
#>   <fct>       <chr>             <chr>                 <int>             <dbl>
#> 1 1           the               NA                        1            NA    
#> 2 1           girl              girl                      2            NA    
#> 3 1           walked            walk                      3             0.470
#> 4 1           down              down                      4             0.283
#> 5 1           the               NA                        5            NA    
#> 6 1           street.           street                    6             0.362
#> # ℹ 1 more variable: CosDist_1gram_sd15 <dbl>
```

### Option 2: Ngram-to-Ngram Distance: `dist_ngram2ngram`

User specifies n-gram size (e.g., ngram=2). Distance computed from each
two-word chunk to the next iterating all the way down the dataframe
until there are no more words to ‘fill out’ the last ngram. Note this
distance function **only works on monologue transcripts** where there
are no speakers delineated and word order matters.  

Function Arguments:  
`dat` dataframe w/ a monologue sample cleaned and prepped  
`ngram` chunk size (chunk-to-chunk), in this case ngram=2 means chunks
of 2 words compared to the next chunk

``` r
Ngram2Ngram_Dist1 <- dist_ngram2ngram(dat=Monologue_Cleaned, ngram=2)
head(Ngram2Ngram_Dist1)
#> # A tibble: 6 × 6
#>   id_row_orig text_initialsplit word_clean id_row_postsplit CosDist_2gram_GLO
#>   <fct>       <chr>             <chr>                 <int>             <dbl>
#> 1 1           the               NA                        1           NA     
#> 2 1           girl              girl                      2           NA     
#> 3 1           walked            walk                      3           NA     
#> 4 1           down              down                      4            0.141 
#> 5 1           the               NA                        5            0.0608
#> 6 1           street.           street                    6            0.319 
#> # ℹ 1 more variable: CosDist_2gram_SD15 <dbl>
```

### Option 3: Anchor-to-Word Distance: `dist_anchor`

Models semantic distance from each successive new word to the average of
the semantic vectors for the first block of N content words. This
anchored distance provides a metric of overall semantic drift as a
language sample unfolds relative to a fixed starting point.  

Function Arguments:  
`dat` dataframe monologue sample cleaned and prepped using
‘clean_monologue’  
`anchor_size` = size of the initial chunk of words for chunk-to-new-word
comparisons fn

``` r
Anchored_Dists1 <- dist_anchor(dat=Monologue_Cleaned, anchor_size=4)
head(Anchored_Dists1)
#> # A tibble: 6 × 4
#>   id_row_postsplit word_clean CosDist_Anchor_GLO CosDist_Anchor_SD15
#>              <int> <chr>                   <dbl>               <dbl>
#> 1                1 NA                    NA                   NA    
#> 2                2 girl                   0.164                0.433
#> 3                3 walk                   0.112                0.167
#> 4                4 down                   0.0822               0.206
#> 5                5 NA                    NA                   NA    
#> 6                6 street                 0.259                0.170
```
