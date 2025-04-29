#' clean_monologue
#'
#' Cleans and formats text. User specifies the dataframe and column name where target text is stored as arguments to the function. Default option is to lemmatize strings. Function splits and unlists text so that the output is in a one-row-per-word format marked by a unique numeric identifier (i.e., 'id_orig')
#'
#' @name clean_monologue
#' @param df a dataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param clean apply cleaning functions (lowercase etc) default is TRUE
#' @param omit_stops option for omitting stopwords default is TRUE
#' @param lemmatize option for lemmatizing strings default is TRUE
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @importFrom utils install.packages
#' @export clean_monologue

clean_monologue <- function(df, wordcol, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE) {
  if (!requireNamespace("tm", quietly = TRUE)) {
    install.packages("tm")
  }
  if (!requireNamespace("textstem", quietly = TRUE)) {
    install.packages("tm")
  }
  if (!requireNamespace("tidyr", quietly = TRUE)) {
    install.packages("tm")
  }
  if (!requireNamespace("textclean", quietly = TRUE)) {
    install.packages("tm")
  }

  df$id_orig <- factor(seq_len(nrow(df)))
  # Copy original column to word_clean (base case)
  df$word_clean <- df[[wordcol]]

  # Apply cleaning operations only if clean=TRUE
  if (clean) {
    x <- df[[wordcol]]

    # Apply cleaning pipeline
    x <- tolower(x)
    x <- gsub("`", "'", x)

    # Apply lemmatization if requested
    if (lemmatize) {
      x <- textstem::lemmatize_strings(x)
    }

    # Remove stopwords if requested
    if (omit_stops) {
      omissions <- reillylab_stopwords25  # Load stopwords only when needed
      x <- tm::removeWords(x, omissions$word)
    }

    x <- gsub("[^a-zA-Z]", " ", x) #omit non-alphabetic chars
    df$word_clean <- x
  }

  # Split multi-word strings into separate rows while maintaining ID_Orig and talker
  df <- tidyr::separate_rows(df, word_clean, sep = "\\s+")

  return(df)
}
