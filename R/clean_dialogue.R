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
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @importFrom utils install.packages
#' @export clean_dialogue

clean_dialogue <- function(df, wordcol, whotalks, clean=TRUE, omit_stops=TRUE, lemmatize = TRUE) {
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
    install.packages("tm")
  }

  omissions <- reillylab_stopwords25
  df$id_orig <- factor(seq_len(nrow(df)))

  # Create talker factor variable from whotalks column
  df$talker <- factor(df[[whotalks]])

  # Extract the specified text column
  x <- df[[wordcol]]

  if (clean) {
    # Apply cleaning operations only if clean=TRUE
    x <- tolower(x)
    x <- gsub("`", "'", x)

    # Apply lemmatization if requested
    if (lemmatize) {
      x <- textstem::lemmatize_strings(x)
    }

    # Omit stopwords default is TRUE
    if (omit_stops) {
      x <- tm::removeWords(x, omissions$word) # removes stopwords indexing custom list
    }
  }
  x <- gsub("[^a-zA-Z]", " ", x)
  df$word_clean <- x

  # Split multi-word strings into separate rows while maintaining ID_Orig and talker
  df <- tidyr::separate_rows(df, word_clean, sep = "\\s+")

  # Create turncount variable when talker level changes
  df$turn_count <- cumsum(c(1, diff(as.numeric(df$talker)) != 0))
  rownames(df) <- NULL
  return(df)
}
