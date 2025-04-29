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
  # Check and install required packages
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
    # Convert to lowercase first
    x <- tolower(x)

    # Remove stopwords if requested (now before cleaning)
    if (omit_stops) {
      x <- tm::removeWords(x, reillylab_stopwords25$word)
    }

    if (clean_flag) {
      # Apply cleaning pipeline
      x <- gsub("`", "'", x)
      x <- gsub("[^a-zA-Z']", " ", x) # omit non-alphabetic chars (keeping apostrophes)
      x <- gsub("\\b[a-z]\\b", "", x) # remove single letters

      # Lemmatize if requested
      if (lemmatize) {
        x <- textstem::lemmatize_strings(x)
      }

      # Final cleanup
      x <- gsub("\\s+", " ", x) # collapse multiple spaces
      x <- trimws(x) # trim whitespace

      # Return NA if empty or multiple words
      if (x == "" || length(unlist(strsplit(x, "\\s+"))) > 1) {
        return(NA_character_)
      }
    }

    return(x)
  }

  # Apply processing to both columns
  df[[paste0(col1, "_clean")]] <- sapply(df[[col1]], clean_text, clean_flag = clean)
  df[[paste0(col2, "_clean")]] <- sapply(df[[col2]], clean_text, clean_flag = clean)

  return(df)
}
