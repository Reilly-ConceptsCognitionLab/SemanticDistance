# clean_dialogue

Cleans a transcript where there are two or more talkers. User specifies
the dataframe and column name where target text is stored in addition a
factor variable corresponding to the identity of the person producing
corresponding text. Users also specify cleaning parameters for stopword
removal and lemmatization (both defaulting to TRUE). Function splits and
unlists text so that the output is in a one-row-per-word format marked
by a unique numeric identifier (i.e., 'id_orig'). Function appends a
turn_count sequence used for aggregating all the words within each turn.
If a speaker generates no complete observations because of stopword
removal, the turn counter will not increment until a talker switch AND a
complete observation is observed.

## Usage

``` r
clean_dialogue(dat, wordcol, who_talking, omit_stops = TRUE, lemmatize = TRUE)
```

## Arguments

- dat:

  a datataframe with at least one target column of string data

- wordcol:

  quoted column name storing the strings that will be cleaned and split

- who_talking:

  quoted column name with speaker/talker identities will be factorized

- omit_stops:

  T/F user wishes to remove stopwords (default is TRUE)

- lemmatize:

  T/F user wishes to lemmatize each string (default is TRUE)

## Value

a dataframe
