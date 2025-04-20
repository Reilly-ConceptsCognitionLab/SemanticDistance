#' clean_dialogue
#'
#' Cleans a transcript where there are two or more talkers. User specifies the dataframe and column name where target text is stored as arguments to the function. Default option is to lemmatize strings. Function splits and unlists text so that the output is in a one-row-per-word format marked by a unique numeric identifier (i.e., 'id_orig')
#'
#' @name clean_dialogue
#' @param df a dataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param whotalks quoted column name with speaker/talker identities will be factorized
#' @param omit_stops T/F user wishes to remove stopwords (default is TRUE)
#' @param lemmatize T/F user wishes to lemmatize each string (default is TRUE)
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom textclean replace_contraction
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @export clean_dialogue

clean_dialogue <- function(df, wordcol, whotalks, omit_stops=TRUE, lemmatize = TRUE) {
  omissions <- reillylab_stopwords25

  # Create ID_Orig as factor variable
  df$ID_Orig <- factor(seq_len(nrow(df)))

  # Create talker factor variable from whotalks column
  df$talker <- factor(df[[whotalks]])

  # Extract the specified text column
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
  x <- tm::removeWords(x, omissions$word) # removes stopwords indexing custom list
  x <- textstem::lemmatize_strings(x)

  # Apply lemmatization if requested
  if (lemmatize) {
    x <- textstem::lemmatize_strings(x)
  }

  # Omit stopwords default is TRUE
  if (omit_stops) {
    x <- tm::removeWords(x, omissions$word) # removes stopwords indexing custom list
  }

  df$word_clean <- x

  # Split multi-word strings into separate rows while maintaining ID_Orig and talker
  df <- tidyr::separate_rows(df, word_clean, sep = "\\s+")

  #Create turncount variable when talker level changes, increment the turn count, as.numeric converts talker to numeric 0 or 1, diff computes difference between consecutive elements in the vector so if 0=0 then cumsum does not increment by one, c(1) - starts at 1
  df$turn_count <- cumsum(c(1, diff(as.numeric(df$talker)) != 0))
  rownames(df) <- NULL
  return(df)
}
