#' clean_2cols
#'
#' Cleans a transcript where word pairs are arrayed in two columns.
#'
#' @name clean_2cols
#' @param df a dataframe with two columns of words you want pairwise distance for
#' @param col1 quoted column name storing the first string for comparison
#' @param col2 quoted column name storing the second string for comparison
#' @param clean T/F default is T specifies whether to apply cleaning transformations or leave data alone
#' @param omit_stops T/F user wishes to remove stopwords (default is TRUE)
#' @param lemmatize T/F user wishes to lemmatize each string (default is TRUE)
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @importFrom utils install.packages
#' @export clean_2cols

clean_2cols <- function(df, col1, col2, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE) {
  if (!requireNamespace("textclean", quietly = TRUE)) {
    install.packages("textclean")
  }
  if (!requireNamespace("textstem", quietly = TRUE)) {
    install.packages("textstem")
  }
  if (!requireNamespace("tm", quietly = TRUE)) {
    install.packages("tm")
  }
  if (!requireNamespace("magrittr", quietly = TRUE)) {
    install.packages("magrittr")
  }

  # Create ID column
  df$id_orig <- factor(seq_len(nrow(df)))

  # Define cleaning operations function
  clean_text <- function(x, clean_flag = TRUE) {
    if (clean_flag) {
      # Check for multiple words
      if (length(unlist(strsplit(x, "\\s+"))) > 1) {
        return(NA_character_)
      }

      # Apply cleaning pipeline
      x <- tolower(x)
      x <- gsub("`", "'", x)
      x <- gsub("'s", "", x)
      x <- gsub("-", " ", x)
      x <- gsub("[^a-zA-Z]", " ", x)


      # Lemmatize if requested
      if (lemmatize) {
        text <- textstem::lemmatize_strings(x)
      }

      # Remove stopwords if requested
      if (omit_stops) {
        text <- tm::removeWords(x, reillylab_stopwords25$word)
      }

      # Trim whitespace and ensure single word
      text <- trimws(x)
      if (text == "" || length(unlist(strsplit(x, "\\s+"))) > 1) {
        return(NA_character_)
      }
    }
    return(x)
  }

  # Apply processing to both columns
  df[[paste0(col1, "_clean1")]] <- sapply(df[[col1]], clean_text, clean_flag = clean)
  df[[paste0(col2, "_clean2")]] <- sapply(df[[col2]], clean_text, clean_flag = clean)

  return(df)
}
