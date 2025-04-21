#' clean_monologue
#'
#' Cleans and formats text. User specifies the dataframe and column name where target text is stored as arguments to the function. Default option is to lemmatize strings. Function splits and unlists text so that the output is in a one-row-per-word format marked by a unique numeric identifier (i.e., 'id_orig')
#'
#' @name clean_monologue
#' @param df a dataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param omit_stops option for omitting stopwords default is TRUE
#' @param lemmatize option for lemmatizing strings default is TRUE
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom textclean replace_contraction
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @export clean_monologue

clean_monologue <- function(df, wordcol, omit_stops=TRUE, lemmatize = TRUE) {
  data(reillylab_stopwords25)
  omissions <- reillylab_stopwords25
  df$id_orig <- factor(seq_len(nrow(df))) # Create ID_Orig as factor variable
  x <- df[[wordcol]]
  # Apply cleaning operations
  x <- tolower(x) # to lower
  x <- gsub("`", "'", x)  # replaces tick marks with apostrophe for contractions
  x <- gsub("can't", "can not", x)
  x <- gsub("won't", "will not", x)
  x <- gsub("gonna", "going to", x)
  x <- gsub("there'd", "there would", x)
  x <- gsub("don't", "do not", x)
  x <- textclean::replace_contraction(x) # replace contractions
  x <- gsub("-", " ", x) # replace all hyphens with spaces
  x <- gsub("[^a-zA-Z]", " ", x) # omit non-alphabetic characters

  # Apply lemmatization if TRUE
  if (lemmatize) {
    x <- textstem::lemmatize_strings(x)
  }

  # Omit stopwords default is TRUE
  if (omit_stops) {
    x <- tm::removeWords(x, omissions$word) # removes stopwords indexing custom list
  }

  # Add cleaned text to new column
  df$word_clean <- x

  # Split multi-word strings into separate rows while maintaining ID_Orig
  df <- tidyr::separate_rows(df, word_clean, sep = "\\s+")
  return(df)
}
