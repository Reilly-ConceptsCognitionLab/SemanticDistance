#' clean_2columns
#'
#' Cleans a transcript where there are two or more talkers. User specifies the dataframe and column name where target text is stored as arguments to the function. Default option is to lemmatize strings. Function splits and unlists text so that the output is in a one-row-per-word format marked by a unique numeric identifier (i.e., 'id_orig')
#'
#' @name clean_2columns
#' @param df a dataframe with two columns of words you want pairwise distance for
#' @param col1 quoted column name storing the first string for comparison
#' @param col2 quoted column name storing the second string for comparison
#' @param clean T/F default is T specifies whether to apply cleaning transformations or leave data alone
#' @param omit_stops T/F user wishes to remove stopwords (default is TRUE)
#' @param lemmatize T/F user wishes to lemmatize each string (default is TRUE)
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom textclean replace_contraction
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @export clean_2columns

clean_2columns <- function(df, col1, col2, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE) {
  if (!requireNamespace("textclean", quietly = TRUE)) {
    install.packages("textclean")
  }
  if (!requireNamespace("textstem", quietly = TRUE)) {
    install.packages("textstem")
  }
  if (!requireNamespace("tm", quietly = TRUE)) {
    install.packages("tm")
  }

  # Create ID column
  df$id_orig <- factor(seq_len(nrow(df)))

  # Define cleaning operations function
  clean_text <- function(text, clean_flag = TRUE) {
    if (clean_flag) {
      # Check for multiple words
      if (length(unlist(strsplit(text, "\\s+"))) > 1) {
        return(NA_character_)
      }

      # Apply cleaning pipeline
      text <- tolower(text)
      text <- gsub("`", "'", text)
      text <- gsub("can't", "can not", text)
      text <- gsub("won't", "will not", text)
      text <- gsub("gonna", "going to", text)
      text <- gsub("there'd", "there would", text)
      text <- gsub("don't", "do not", text)
      text <- textclean::replace_contraction(text)
      text <- gsub("-", " ", text)
      text <- gsub("[^a-zA-Z]", " ", text)

      # Lemmatize if requested
      if (lemmatize) {
        text <- textstem::lemmatize_strings(text)
      }

      # Remove stopwords if requested
      if (omit_stops) {
        text <- tm::removeWords(text, reillylab_stopwords25$word)
      }

      # Trim whitespace and ensure single word
      text <- trimws(text)
      if (text == "" || length(unlist(strsplit(text, "\\s+"))) > 1) {
        return(NA_character_)
      }
    }
    return(text)
  }

  # Apply processing to both columns
  df[[paste0(col1, "_clean1")]] <- sapply(df[[col1]], clean_text, clean_flag = clean)
  df[[paste0(col2, "_clean2")]] <- sapply(df[[col2]], clean_text, clean_flag = clean)

  return(df)
}
