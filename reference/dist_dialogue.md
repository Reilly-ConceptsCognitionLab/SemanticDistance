# dist_dialogue

Function takes dataframe cleaned using 'clean_dialogue' and computes two
metrics of semantic distance turn-to-turn indexing a 'talker' column.
Sums all the respective semantic vectors within each tuern, cosine
distance to the next turn's composite vector

## Usage

``` r
dist_dialogue(dat, who_talking)
```

## Arguments

- dat:

  a dataframe prepped using 'clean_dialogue' fn with talker data and
  turncount appended

- who_talking:

  factor variable with two levels specifying an ID for the person
  producing the text in \`word_clean\`

## Value

a dataframe
