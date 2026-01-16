# clean_monologue_or_list

Cleans and formats text. User specifies the dataframe and column name
where target text is stored as arguments to the function. Default option
is to lemmatize strings. Function splits and unlists text so that the
output is in a one-row-per-word format marked by a unique numeric
identifier (i.e., 'id_orig')

Cleans and formats text. User specifies the dataframe and column name
where target text is stored as arguments to the function. Default option
is to lemmatize strings. Function splits and unlists text so that the
output is in a one-row-per-word format marked by a unique numeric
identifier (i.e., 'id_orig')

## Usage

``` r
clean_monologue_or_list(dat, wordcol, omit_stops = TRUE, lemmatize = TRUE)

clean_monologue_or_list(dat, wordcol, omit_stops = TRUE, lemmatize = TRUE)
```

## Arguments

- dat:

  a dataframe with at least one target column of string data

- wordcol:

  quoted column name storing the strings that will be cleaned and split

- omit_stops:

  option for omitting stopwords default is TRUE

- lemmatize:

  option for lemmatizing strings default is TRUE

## Value

a dataframe

a dataframe
