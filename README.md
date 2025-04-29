
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

### Output of ‘clean_monologue’ on cleaning/prepping a raw monologue transcript</span>

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

### Output of ‘clean_dialogue’ prepping a dialogue transcript

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

<br/>

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

### Output of ‘clean_2columns’ cleaning word pairs arrayed in columns

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

## <span style="color: brown;">1.3 Clean Unordered Word List (clean_unordered4matrix)</span>

This cleaning option is used for prepping a vector of words for
hierarchical clustering. Word order is no longer a factor since all
words will be shuffled. This cleaning function retains only one instance
of a word (no duplicates). Arguments to the ‘clean_unordered4matrix’
function call are: <br/> \| df = your raw dataframe with at least one
column of text \| wordcol = quoted variable reflecting where your text
lives \| clean = T/F (default is T) applies cleaning functions \|
omit_stops = T/F omits stopwords, default is TRUE \| lemmatize = T/F
transforms raw word to lemmatized form, default is TRUE

### Output of ‘clean_unordered4matrix’ on unordered word list </span>

``` r
#Run clean fn 
MyCleanDat4Matrix <- clean_unordered4matrix(FakeCats, wordcol="word", clean=TRUE, omit_stops=TRUE, lemmatize=TRUE) 
head(MyCleanDat4Matrix, n=8)
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

Computes cosine distance for two models (embedding and experiential)
using a rolling ngram approach consisting of groups of words (ngrams) to
the next word.

<img src="man/figures/RollingNgramIllustrate.png" alt="illustrates how rolling ngrams work on a vector of words by moving a window and contrasting each chunk to each new word" width="40%" />

Remember to call a cleaned/prepped dataframe! Arguments to
‘dist_ngram2word’ are: <br/> \| dat dataframe of a monologue transcript
cleaned and prepped with clean_monologue fn <br/> \| ngram ngram window
size preceding each new content word <br/>

### Output of ‘dist_ngram2word’ ngram-to-word distance on monologue transcript

``` r
MyNgram2WordDists <- dist_ngram2word(MyCleanMonologue, ngram=1) #distance word-to-word
head(MyNgram2WordDists, n=8)
#> # A tibble: 8 × 5
#>   word              id_orig word_clean CosDist_1gram_glo CosDist_1gram_sd15
#>   <chr>             <fct>   <chr>                  <dbl>              <dbl>
#> 1 The dog is blue.  1       ""                    NA                  NA   
#> 2 The dog is blue.  1       "dog"                 NA                  NA   
#> 3 The dog is blue.  1       "blue"                 0.607               1.44
#> 4 Dog               2       "dog"                  0.607               1.44
#> 5 Dog               3       "dog"                  0                   0   
#> 6 Some              4       ""                    NA                  NA   
#> 7 My name is Frank. 5       ""                    NA                  NA   
#> 8 My name is Frank. 5       "name"                NA                  NA
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

### Output of ‘dist_ngram2ngram’ ngram-to-ngram distance on monologue transcript

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

## <span style="color: brown;">2.3: Compute Turn-by-Turn Distance (dist_dialogue_turns)</span>

Averages the semantic vectors for all content words in a turn. Computes
the cosine distance to the average of the semantic vectors of the
content words in the subsequent turn. <br/>

Arguments to ‘dist_dialogue_turns’ are: <br/> \| dat = dataframe w/ a
dialogue sample cleaned and prepped using ‘clean_dialogue’ fn<br/>

### Output of ‘dist_dialogue_turns’ turn-to-turn distance on sample dialogue transcript </span>

``` r
#MyDialogueDists <- dist_dialogue_turns(MyCleanDialogue)
#head(MyDialogueDists, n=15)
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

### Output of ‘dist_2cols’ on 2-column arrayed dataframe

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

### Output of ‘anchor_dist’ on a sample monologue transcript

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

### <span style="color: brown;">2.6: Compute Distance Matrix All Word Pairs (dist_matrix_all)</span>

Returns square matrix where each entry \[i,j\] is the cosine distance
between word i and word j. Matrix contains original words as both row
and column names for reference. User specifies whether to return a
matrix based on embeddings (GLOVE) or experiential norms (SD15). Input a
unordered vector of words cleaned/prepped with ‘clean_unordered4matrix’
function <br/>

Arguments to ‘dist_matrix_all’ are: <br/> \| dat = dataframe cleaned and
prepped using ‘clean_unordered4matrix’ fn<br/> \| dist_type = quoted
argument default is ‘embedding’, other option is “SD15” fn<br/>

### Output of ‘dist_unordered’ on unordered word list

``` r
MyDistMatrix <- dist_matrix_all(MyCleanDat4Matrix)
head(MyDistMatrix)
#>            trumpet  trombone     flute     piano    guitar    cymbal      horn
#> trumpet  0.0000000 0.5717885 0.5138417 0.5558156 0.5520448 0.8515268 0.5426568
#> trombone 0.5717885 0.0000000 0.6698538 0.6488034 0.6219389 0.8934566 0.7856703
#> flute    0.5138417 0.6698538 0.0000000 0.4511922 0.5203509 0.8705058 0.7083871
#> piano    0.5558156 0.6488034 0.4511922 0.0000000 0.2730333 0.9607622 0.6708519
#> guitar   0.5520448 0.6219389 0.5203509 0.2730333 0.0000000 0.9291963 0.6608229
#> cymbal   0.8515268 0.8934566 0.8705058 0.9607622 0.9291963 0.0000000 0.9332137
#>               drum saxophone  clarinet       gun     knife   missile    bullet
#> trumpet  0.6149113 0.5709129 0.5427555 0.8668525 0.8766921 0.9207663 0.8405419
#> trombone 0.7811522 0.6649554 0.6243433 0.9475109 0.8880578 1.0274633 0.9357694
#> flute    0.6104354 0.5973837 0.5602340 0.9288003 0.8349393 0.9453457 0.8365646
#> piano    0.5534039 0.5154477 0.4781244 0.8374068 0.7856145 0.9610571 0.8678741
#> guitar   0.4802157 0.4849726 0.5160797 0.7653835 0.7351402 0.8849044 0.8322209
#> cymbal   0.8134030 0.9342221 0.8573442 1.0227859 0.8829481 0.9698002 0.9566038
#>              spear slingshot    hammer     spike      club     sword     apple
#> trumpet  0.8700478 1.0462993 0.8051553 0.8987646 0.7921973 0.7899880 0.8613004
#> trombone 0.9619708 1.0490071 0.9134879 0.9722551 0.8759932 0.9391996 1.0194700
#> flute    0.8986365 0.9569171 0.8102413 0.9712387 0.8394656 0.8480804 0.9113671
#> piano    0.9531743 0.9992157 0.7361093 0.9000114 0.7190657 0.8395984 0.8508651
#> guitar   0.9239212 0.9620300 0.7308032 0.8226126 0.7294101 0.7903486 0.8293306
#> cymbal   0.9351836 1.0382142 0.9871326 0.9571988 1.0045617 0.9409464 1.0194576
#>             banana    potato    tomato      kiwi      pear strawberry blueberry
#> trumpet  0.9392574 0.9105490 0.8830221 0.8478773 0.8618217  0.8767784 0.9645774
#> trombone 1.0000095 0.9274395 0.9674734 0.8688863 0.9791594  0.9238828 0.9729520
#> flute    0.9885272 0.8556761 0.8531540 0.9460171 0.8875153  0.8993427 0.9281152
#> piano    0.9084053 0.8730102 0.9341004 1.0368087 0.9692899  0.8735781 0.9579473
#> guitar   0.8967875 0.8661847 0.9517537 0.9811987 0.9965683  0.9066593 0.9739581
#> cymbal   0.9559512 0.9462551 0.9143732 0.9915347 0.9253868  0.9249834 0.9466407
#>                sad     happy     angry melancholy    joyful   hateful   content
#> trumpet  0.8666898 0.8488735 0.8308108  0.7873357 0.8519420 0.9333320 0.9868393
#> trombone 0.9464790 1.0493566 0.9779906  0.8594294 0.9773888 1.0456382 1.0586970
#> flute    0.9357723 0.9155405 0.9273802  0.8317150 0.9153496 1.0464467 0.9827075
#> piano    0.7859402 0.7222168 0.8875885  0.7012845 0.8191960 1.0742481 0.8789366
#> guitar   0.7650799 0.7498851 0.8490875  0.6950909 0.8167364 0.9957878 0.8351338
#> cymbal   1.0602806 1.0185100 1.0254275  0.9961827 0.9754140 1.0062601 1.0907118
#>           peaceful     scare   fearful alligator  elephant       rat     mouse
#> trumpet  0.9975748 0.9715591 0.9653837 0.8851451 0.8407929 0.9699536 0.9220590
#> trombone 1.1301653 1.0112355 0.9803312 0.9181429 0.9448770 0.9000255 0.9234132
#> flute    0.9953972 1.0093566 1.0574564 0.8972824 0.8781440 0.9269048 0.8267300
#> piano    0.8897098 1.0114782 1.0478673 0.9309292 0.8870312 0.9866920 0.8235185
#> guitar   0.9433049 0.9376936 1.0143360 0.8359544 0.8739370 0.9203031 0.8490496
#> cymbal   1.0507631 1.1156529 0.9887600 0.9749106 0.9424991 0.9912280 0.9568465
#>                dog      wolf    parrot     eagle   dolphin     shark
#> trumpet  0.8409885 0.9009243 0.8671039 0.8056629 0.8717605 0.9077489
#> trombone 0.9260945 0.9442231 0.9553378 0.9744114 0.9286902 0.9399655
#> flute    0.9037216 0.9617292 0.8961243 0.9114045 0.9250934 0.8988152
#> piano    0.8010806 0.9438895 0.9130158 0.8946121 0.9109896 0.9708619
#> guitar   0.7239519 0.8606558 0.9217278 0.8542731 0.9197273 0.9291874
#> cymbal   0.9942344 1.0316744 0.9467443 0.9377037 0.9532934 0.9520321
```

<br/> <br/>

# <span style="color: darkred;">—Step 3: Data Visualization Options—</span>

## Monologue Time Series: ngram2word

Plots id_orig (as x-axis time) by distance measure (facetted GLO and
SD15). Add red line annotation if semantic distance jump is z\>3 based
on the distribution of that time series

``` r
#Select id_orig, "CosDist_Glo", "CosDist_SD15", pivot_longer
#add smoothing options
#Argument annotate=T, adds red line whenever semantic distance jump is z>3
#linear interpolation using zoo, necessary for geom_path to complete
#pivots on any/all cos_dist columns
#facets on any/all cos_dist columns
#scale axis 0 to 1.5
```

## Monologue Time Series: anchor2word

``` r
#TBA
```

## Time series plot for dialogues

Color point by talker

``` r
#TBA
```

\#Animate Time Series

``` r
#TBA
```
