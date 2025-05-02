#' clean_dialogue
#'
#' Cleans a transcript where there are two or more talkers. User specifies the dataframe and column name where target text is stored as arguments to the function. Default option is to lemmatize strings. Function splits and unlists text so that the output is in a one-row-per-word format marked by a unique numeric identifier (i.e., 'id_orig')
#'
#' @name clean_dialogue
#' @param df a dataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param whotalks quoted column name with speaker/talker identities will be factorized
#' @param clean T/F apply cleaning transformations (default is TRUE)
#' @param omit_stops T/F user wishes to remove stopwords (default is TRUE)
#' @param lemmatize T/F user wishes to lemmatize each string (default is TRUE)
#' @param split_strings option T/F (default T) split multiword contractions into separate rows
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @importFrom utils install.packages
#' @export clean_dialogue

clean_dialogue <- function(df, wordcol, whotalks, clean=TRUE, omit_stops=TRUE, lemmatize = TRUE, split_strings=TRUE) {
  if (!requireNamespace("textclean", quietly = TRUE)) {
    install.packages("textclean")
  }
  if (!requireNamespace("textstem", quietly = TRUE)) {
    install.packages("textstem")
  }
  if (!requireNamespace("tm", quietly = TRUE)) {
    install.packages("tm")
  }
  if (!requireNamespace("tidyr", quietly = TRUE)) {
    install.packages("tidyr")
  }
  if (!requireNamespace("magrittr", quietly = TRUE)) {
    install.packages("magrittr")
  }

  omissions <- reillylab_stopwords25
  df$id_orig <- factor(seq_len(nrow(df)))
  df$word_clean <- tolower(df[[wordcol]])  # Fixed: using wordcol parameter

  # Create talker factor variable from whotalks column
  df$talker <- factor(df[[whotalks]])
  x <- df[[wordcol]]

  # Apply stopword omission BEFORE cleaning (if requested)
  if (omit_stops) {
    omissions <- reillylab_stopwords25  # Load stopwords
    df$word_clean <- tm::removeWords(df$word_clean, omissions$word)
  }

  # Apply cleaning operations only if clean=TRUE
  if (clean) {
    x <- df$word_clean  # Start with the lowercase (and potentially stopword-free) version

    # Apply cleaning pipeline
    x <- gsub("`", "'", x)
    x <- gsub("[^a-zA-Z']", " ", x) # omit non-alphabetic chars (keeping apostrophes)
    x <- gsub("\\b[a-z]\\b", "", x) # omit stray singleton letters

    # Apply lemmatization if requested
    if (lemmatize) {
      x <- textstem::lemmatize_strings(x)
    }

    df$word_clean <- x
  }

  # Split multi-word strings into separate rows while maintaining ID_Orig and talker
  if (split_strings) {
    df <- tidyr::separate_rows(df, word_clean, sep = "\\s+")
  }

  # Create turncount variable when talker level changes
  df$turn_count <- cumsum(c(1, diff(as.numeric(df$talker)) != 0))
  rownames(df) <- NULL
  return(df)
}
