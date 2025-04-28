
<!-- README.md is generated from README.Rmd. Please edit that file -->

<img src="man/figures/header4readme.png" alt="semantic relations between cat, dog, leash" width="45%" />
<br/>

<!-- badges: start -->

[![R-CMD-check](https://github.com/Reilly-ConceptsCognitionLab/SemanticDistance/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/Reilly-ConceptsCognitionLab/SemanticDistance/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

## Before Starting

SemanticDistance nominally requires a dataframe with at least one column
variable and one row of text. The package is capable of processing many
more dataframe formats (e.g., word pairs arrayed in columns,
conversation transcripts, unordered word lists). SemanticDistance will
retain all of your original metadata after splitting/unlisting your text
into a one-word-per-row structure. This sequential structure is ideal
for joining distance values to timestamps and other variables as
language unfolds (e.g., reaction time, pupil diameter).

## Install & Load

Install the development version of SemanticDistance from
[GitHub](https://github.com/) using devtools.

``` r
#install.packages("devtools")
#devtools::install_github("Reilly-ConceptsCognitionLab/SemanticDistance")
library(SemanticDistance)
```

# <span style="color: darkred;">—Step 1: Cleaning— </span>

The semantic distance functions work by indexing unique numeric
identifiers. You MUST first clean/prep your raw text to append these
identifers. Prepare your lexical data for computing pairwise semantic
distances by first doing the following: <br/>

1)  Read your data into R. Label your text and metadata columns however
    you like. <br/>
2)  Your dataframe should contain at least one column with the target
    string data (e.g., mytext). <br/>
3)  Identify the format of your sample (e.g., monologue, dialogue,
    columns, unstructured). <br/>
4)  Decide on your cleaning parameters (lemmatize, omit stopwords, omit
    punctuation). <br/>
5)  Run the approproate cleaning function specifying the parameters that
    best fit your data and aims. <br/> <br/>

## <span style="color: brown;">1.1 Clean Monologue Transcript (clean_monologue)</span>

A monologue transcript consists of any ordered text sample NOT
delineated by a talker/speaker (e.g., stories, narratives). Clean a
monologue transcript by calling the ‘clean_monologue’ function. Specific
arguments include: <br/>

df = raw dataframe with at least one column of text  
wordcol = quoted variable reflecting the column name where your target
text lives (e.g., ‘mytext’)  
clean = applies cleaning functions (e.g., punct out, lowercase, etc);
default is TRUE  
omit_stops = omits stopwords, default is TRUE  
lemmatize = transforms raw word to lemmatized form, default is TRUE

#### <span style="color: green;">Example Raw Monologue Transcript and Cleaning</span>

``` r
MyCleanMonologue <- clean_monologue(MonologueSample1, 'word', clean=T)
head(MyCleanMonologue, n=10)
#> # A tibble: 10 × 3
#>    word              id_orig word_clean
#>    <chr>             <fct>   <chr>     
#>  1 The dog is blue.  1       ""        
#>  2 The dog is blue.  1       "dog"     
#>  3 The dog is blue.  1       "blue"    
#>  4 Dog               2       "dog"     
#>  5 Dog               3       "dog"     
#>  6 Some              4       ""        
#>  7 My name is Frank. 5       ""        
#>  8 My name is Frank. 5       "name"    
#>  9 My name is Frank. 5       "frank"   
#> 10 Dog               6       "dog"
```

<br/>

## <span style="color: brown;">1.4 Clean Dialogue Transcript (clean_dialogue)</span>

This could be a conversation transcript or any language sample where you
care about talker/interlocutor information (e.g., computing semantic
distance across turns in a conversation). Your dataframe should
nominally contain a text column and a speaker/talker column. Arguments
clean_dialogue are: <br/> \| df = your raw dataframe with at least one
column of text AND a talker column \| wordcol = column name (quoted)
containing the text you want cleaned \| whotalks = column name (quoted)
containing the talker ID (will convert to factor) \| clean = T/F
(default is T) applies cleaning functions \| omit_stops = T/F omits
stopwords, default is TRUE \| lemmatize = T/F transforms raw word to
lemmatized form, default is TRUE

### <span style="color: green;">Example ‘clean_dialogue’ on Dialogue Transcript</span>

``` r
MyCleanDialogue <- clean_dialogue(DialogueSample1, "word", "speaker", omit_stops=T, lemmatize=T)
head(MyCleanDialogue, n=6)
#> # A tibble: 6 × 6
#>   word                speaker id_orig talker word_clean turn_count
#>   <chr>               <chr>   <fct>   <fct>  <chr>           <dbl>
#> 1 Hi Peter            Mary    1       Mary   peter               1
#> 2 Donkeys are gray    Mary    2       Mary   donkey              1
#> 3 Donkeys are gray    Mary    2       Mary   gray                1
#> 4 Leopard             Mary    3       Mary   leopard             1
#> 5 pop goes the weasel Mary    4       Mary   pop                 1
#> 6 pop goes the weasel Mary    4       Mary   go                  1
```

<br/> <br/>

## <span style="color: brown;">1.2 Clean Word Pairs Arrayed in Columns (clean_2columns)</span>

SemanticDistance also computes pairwise distance for data arrayed in
columns. Run the function, the cleaned columns will appear in the
dataframe. Arguments to the ‘clean_monologue’ function call are: <br/>
\| df = your raw dataframe with at least one column of text \| word1 =
quoted variable reflecting the column name where your first word lives
\| word2 = quoted variable reflecting the column name where your first
word lives \| clean = T/F (default is T) applies cleaning functions \|
omit_stops = T/F omits stopwords, default is TRUE \| lemmatize = T/F
transforms raw word to lemmatized form, default is TRUE

### <span style="color: green;">Example Column Arrays Word Pair Cleaning</span>

``` r
MyClean2Columns <- clean_2cols(ColumnSample, 'word1', 'word2', clean=T, omit_stops=T, lemmatize=T)
head(MyClean2Columns, n=6) #view head cleaned data
#>   word1     word2 id_orig word1_clean1 word2_clean2
#> 1   Dog   trumpet       1          dog      trumpet
#> 2   the    BANANA       2         <NA>       banana
#> 3   rat astronaut       3          rat    astronaut
#> 4  *&^%    lizard       4         <NA>       lizard
#> 5  bird      bird       5         bird         bird
#> 6 shark     shark       6        shark        shark
```

<br/> <br/>

## <span style="color: brown;">1.3 Clean Unordered Word List (clean_4cluster)</span>

This cleaning option is used for prepping a vector of words for
hierarchical clustering. Word order is no longer a factor since all
words will be shuffled. This cleaning function retains only one instance
of a word (no duplicates). Arguments to the ‘clean_4cluster’ function
call are: <br/> \| df = your raw dataframe with at least one column of
text \| wordcol = quoted variable reflecting where your text lives \|
clean = T/F (default is T) applies cleaning functions \| omit_stops =
T/F omits stopwords, default is TRUE \| lemmatize = T/F transforms raw
word to lemmatized form, default is TRUE

### <span style="color: green;">Example ‘clean_4clustering’ on Unordered Word List </span>

``` r
#Run clean fn 
MyCleanUnordered <- clean_unordered(FakeCats, wordcol="word", clean=TRUE, omit_stops=TRUE, lemmatize=TRUE) 
head(MyCleanUnordered, n=8)
#> # A tibble: 8 × 6
#>   ID_JR word     category prediction id_orig word_clean
#>   <int> <chr>    <chr>    <chr>        <int> <chr>     
#> 1     1 trumpet  music    within           1 trumpet   
#> 2     2 trombone music    within           2 trombone  
#> 3     3 flute    music    within           3 flute     
#> 4     4 piano    music    within           4 piano     
#> 5     5 guitar   music    within           5 guitar    
#> 6     6 cymbals  music    within           6 cymbal    
#> 7     7 horn     music    within           7 horn      
#> 8     8 drum     music    within           8 drum
```

<br/> <br/>

# <span style="color: darkred;">—Step 2: Compute Semantic Distance—</span>

SemanticDistance will append cosine distance values between each pair of
elements specified by the user (e.g., word-to-word, ngram-to-word).
These distance values are derived from two large lookup databases in the
package with fixed semantic vectors for \>70k English words. CosDist_Glo
reflects cosine distance between vectors derived from training a GLOVE
word embedding model (300 hyperparameters per word). CodDist_SD15
refects cosine distance between two chunks (words, groups of words)
characterized across 15 meaningful perceptual and affective dimensions
(e.g., color, sound, valence). <br/>

Users specify an ngram window size. This window rolls successively over
your language sample to compute a semantic distance value for each new
word relative to the n-words (ngram size) before it. This model of
compouting distance is illustrated in the figure. The larger your
specified ngram size the more smoothed the semantic vector will be over
your language sample. Once you settle on a window size and clean your
language transcript (works for monologues only), you are ready to roll.
Here’s the general idea… <br>

## <span style="color: brown;">2.1: Compute Ngram-to-Word Distance (dist_ngram2word)</span>

<img src="man/figures/RollingNgramIllustrate.png" alt="illustrates how rolling ngrams work on a vector of words by moving a window and contrasting each chunk to each new word" width="40%" />

Remember to call a cleaned/prepped dataframe! Arguments to
‘dist_ngram2word_roll’ are: <br/> \| dat dataframe cleaned and prepped
<br/> \| ngram ngram window size preceding each new content word <br/>

### <span style="color: green;">Output ‘dist_ngram2word’ on monologue transcript </span>

``` r
MyNgram2WordDists <- dist_ngram2word(MyCleanUnordered, ngram=1) #distance word-to-word
head(MyNgram2WordDists, n=8)
#> # A tibble: 8 × 8
#>   ID_JR word     category prediction id_orig word_clean CosDist_1gram_glo
#>   <int> <chr>    <chr>    <chr>      <fct>   <chr>                  <dbl>
#> 1     1 trumpet  music    within     1       trumpet               NA    
#> 2     2 trombone music    within     2       trombone               0.572
#> 3     3 flute    music    within     3       flute                  0.670
#> 4     4 piano    music    within     4       piano                  0.451
#> 5     5 guitar   music    within     5       guitar                 0.273
#> 6     6 cymbals  music    within     6       cymbal                 0.929
#> 7     7 horn     music    within     7       horn                   0.933
#> 8     8 drum     music    within     8       drum                   0.720
#> # ℹ 1 more variable: CosDist_1gram_sd15 <dbl>
```

<br/>

## <span style="color: brown;">2.2: Compute Ngram-to-Ngram Distance (dist_ngram2ngram)</span>

User specifies n-gram size (e.g., ngram=2). Distance computed from each
two-word chunk to the next iterating all the way down the dataframe
until there are no more words to ‘fill out’ the last ngram.

<img src="man/figures/Ngram2Ngram_Dist.png" alt="illustrates how semantic distance is derived from chunk to chunk groupings of words" width="50%" />

Arguments to dist_ngram2ngram are: <br/> \| dat = dataframe w/ a
monologue sample cleaned and prepped <br/> \| ngram = chunk size
(chunk-to-chunk) <br/>

### <span style="color: green;">Output ‘dist_ngram2ngram’ on monologue transcript </span>

``` r
#Give the function a cleaned monologue transcript
MyNgram2NgramDists <- dist_ngram2ngram(MyCleanMonologue, ngram=2)
head(MyNgram2NgramDists, n=8)
#> # A tibble: 8 × 5
#>   id_orig word_clean CountID_Ngram2 CosDist_2gram_GLO CosDist_2gram_SD15
#>   <fct>   <chr>      <fct>                      <dbl>              <dbl>
#> 1 1       ""         1                         NA                 NA    
#> 2 1       "dog"      1                         NA                 NA    
#> 3 1       "blue"     2                         NA                 NA    
#> 4 2       "dog"      2                          0.173              0.125
#> 5 3       "dog"      3                         NA                 NA    
#> 6 4       ""         3                          0.173              0.125
#> 7 5       ""         4                          0.496              1.09 
#> 8 5       "name"     4                          0.496              1.09
```

<br/>

## <span style="color: brown;">2.3: Compute Turn-by-Turn Distance (dist_dialogue)</span>

Averages the semantic vectors for all content words in a turn. Computes
the cosine distance to the average of the semantic vectors of the
content words in the subsequent turn. <br/>

Arguments to ‘dist_dialogue’ are: <br/> \| dat = dataframe w/ a dialogue
sample cleaned and prepped using ‘clean_dialogue’ fn<br/>

### <span style="color: green;">Output ‘dist_dialogue’ on sample dialogue transcript </span>

``` r
#TBA
```

<br/>

## <span style="color: brown;">2.4: Compute Distances Between Word Pairs in Columns (dist_2cols)</span>

When your data are arrayed in two columns and you are interested in
computing pairwise distance across the columns. The only critical
argument is your dataframe name. Remember to pass a cleaned dataframe
(even if you disable stopwords and lemmatization). Arguments to the
function: <br/> \| dat = your cleaned dataframe with two paired columns
of text <br/>

Arguments to ‘dist_2cols’ are: <br/> \| dat = dataframe w/ word pairs
arrayed in columns cleaned and prepped using ‘clean_2cols’ fn<br/>

### <span style="color: green;">Output ‘dist_2cols’ on 2-column arrayed dataframe </span>

``` r
MyDistsColumns <- dist_2cols(MyClean2Columns) #only argument is dataframe
head(MyDistsColumns, n=8)
#>   word1     word2 id_orig word1_clean1 word2_clean2 CosDist_SD15 CosDist_GLO
#> 1   Dog   trumpet       1          dog      trumpet    0.4534507   0.8409885
#> 2   the    BANANA       2         <NA>       banana           NA          NA
#> 3   rat astronaut       3          rat    astronaut    1.2154729   0.9272540
#> 4  *&^%    lizard       4         <NA>       lizard           NA          NA
#> 5  bird      bird       5         bird         bird    0.0000000   0.0000000
#> 6 shark     shark       6        shark        shark    0.0000000   0.0000000
#> 7 table     38947       7        table         <NA>           NA          NA
#> 8   Dog     leash       8          dog        leash    0.6760924   0.5014043
```

<br/>

## <span style="color: brown;">2.5: Compute Distance from a Fixed Cluster of Words in the Beginning of a Language Sample to each new word in the sample (anchor_dist)</span>

This approach models the semantic distance from each successive new word
in a language sample to the average of the semantic vectors for the
first block of 10 content words in that sample. This anchored distance
provides a metric of overall semantic drift as a language sample unfolds
relative to a fixed starting point.<br/>

Arguments to ‘anchor_dist’ are: <br/> \| dat = dataframe w/ a monologue
sample cleaned and prepped using ‘clean_monologue’ fn<br/> \|
anchor_size = size of the initial chunk of words for chunk-to-new-word
comparisons fn<br/>

<img src="man/figures/Anchor_2Word_Dist.png" alt="illustrates distance from each new word of a language sample to an initial chunk of n-words" width="60%" />

### <span style="color: green;">Output of ‘anchor_dist’ on a sample monologue transcript</span>

``` r
MyDistsAnchored <- dist_anchor(MyCleanMonologue, anchor_size=8)
head(MyDistsAnchored, n=10)
#> # A tibble: 10 × 4
#>    id_orig word_clean CosDist_Anchor_GLO CosDist_Anchor_SD15
#>    <fct>   <chr>                   <dbl>               <dbl>
#>  1 1       ""                    NA                  NA     
#>  2 1       ""                    NA                   0.0266
#>  3 1       ""                    NA                   1.26  
#>  4 1       ""                     0.0640             NA     
#>  5 1       ""                     0.0640              0.0266
#>  6 1       ""                     0.0640              1.26  
#>  7 1       ""                     0.353              NA     
#>  8 1       ""                     0.353               0.0266
#>  9 1       ""                     0.353               1.26  
#> 10 1       "dog"                 NA                  NA
```

<br/>

### <span style="color: brown;">2.6: Compute Distances Unordered Set of Words (dist_unordered)</span>

Input a set of words cleaned/prepped with ‘clean_unordered’ function
<br/>

Arguments to ‘dist_unorderd’ are: <br/> \| dat = dataframe w/ a
monologue sample cleaned and prepped using ‘clean_monologue’ fn<br/> \|
anchor_size = size of the initial chunk of words for chunk-to-new-word
comparisons fn<br/>

### <span style="color: green;">Output of ‘dist_unordered’ on unordered word list</span>

``` r
#TBA
```

<br/> <br/>

# <span style="color: darkred;">—Step 3: Data Visualization Options—</span>

## Time series plot for monologues

id_orig (as x-axis time) by distance measure (facetted GLO and SD15).
Add red line annotation if semantic distance jump is z\>3 based on the
distribution of that time series

``` r
#Select id_orig, "CosDist_Glo", "CosDist_SD15", pivot_longer
```

## Time series plot for dialogues

Color point by talker

\#Animate Time Series
