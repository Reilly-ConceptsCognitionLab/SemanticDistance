# SemanticDistance_Word_Pairs

## Word Pairs

Sample dataframe included in package. Word pairs are arrayed in columns.
Columns need not be immediately adjacent within your dataframe.

| word1 | word2     |
|:------|:----------|
| Dog   | trumpet   |
| the   | BANANA    |
| rat   | astronaut |
| \*&^% | lizard    |
| bird  | bird      |

### Clean Word Pairs in Columns Transcript

Arguments to `clean_paired_cols` are:  
`dat` your raw dataframe with two columns of paired text  
`word1` quoted variable reflecting the column name where your first word
lives  
`word2` quoted variable reflecting the column name where your first word
lives  
`lemmatize` transforms raw word to lemmatized form, T/F default is TRUE

``` r
WordPairs_Clean <- clean_paired_cols(dat=Word_Pairs, wordcol1='word1', wordcol2='word2', lemmatize=TRUE)
knitr::kable(head(WordPairs_Clean, 6), format = "simple", digits=2) 
```

| id_row_orig | word1_clean | word2_clean | word1 | word2     |
|:------------|:------------|:------------|:------|:----------|
| 1           | dog         | trumpet     | Dog   | trumpet   |
| 2           | the         | banana      | the   | BANANA    |
| 3           | rat         | astronaut   | rat   | astronaut |
| 5           | bird        | bird        | bird  | bird      |
| 6           | shark       | shark       | shark | shark     |
| 8           | dog         | leash       | Dog   | leash     |

### Word Pairs Semantic Distance

Generates semantic distances (Glove and SD15) between word pairs in
separate columns. Output of ‘dist_paired_cols’ on 2-column arrayed
dataframe. Argument to `dist_paired_cols`: `dat` = dataframe with word
pairs arrayed in columns cleaned and prepped using ‘clean_2cols’ fn

``` r
Columns_Dists <- dist_paired_cols(dat=WordPairs_Clean) 
knitr::kable(head(Columns_Dists, 6), format = "simple", digits=2) 
```

| id_row_orig | word1_clean | word2_clean | word1 | word2     | CosDist_SD15 | CosDist_GLO |
|:------------|:------------|:------------|:------|:----------|-------------:|------------:|
| 1           | dog         | trumpet     | Dog   | trumpet   |         0.45 |        0.84 |
| 2           | the         | banana      | the   | BANANA    |         1.18 |        0.77 |
| 3           | rat         | astronaut   | rat   | astronaut |         1.22 |        0.93 |
| 5           | bird        | bird        | bird  | bird      |         0.00 |        0.00 |
| 6           | shark       | shark       | shark | shark     |         0.00 |        0.00 |
| 8           | dog         | leash       | Dog   | leash     |         0.68 |        0.50 |
