#' clean_4clustering
#'
#' Cleans and formats text. User specifies the dataframe and column name where target text is stored. Word order does not matter (all words shuffled later). Cleaning takes only first instance of word.
#'
#' @name clean_4clustering
#' @param df a dataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param clean apply cleaning functions (lowercase etc) default is TRUE
#' @param omit_stops option for omitting stopwords default is TRUE
#' @param lemmatize option for lemmatizing strings default is TRUE
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom textclean replace_contraction
#' @importFrom tm removeWords
#' @importFrom dplyr ungroup
#' @importFrom dplyr distinct
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @export clean_4clustering

clean_4clustering <- function(df, wordcol, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE) {
  if (!requireNamespace("textclean", quietly = TRUE)) {
    install.packages("textclean")
  }
  if (!requireNamespace("textstem", quietly = TRUE)) {
    install.packages("textstem")
  }
  if (!requireNamespace("tm", quietly = TRUE)) {
    install.packages("tm")
  }
  if (!requireNamespace("dplyr", quietly = TRUE)) {
    install.packages("tm")
  }
  # Create unique numeric ID for each original row
  df$id_orig <- seq_len(nrow(df))

  # Initialize word_clean with original values
  df$word_clean <- df[[wordcol]]

  # Only perform cleaning if clean=TRUE
  if (clean) {
    x <- df[[wordcol]]

    # Apply cleaning pipeline
    x <- tolower(x)
    x <- gsub("`", "'", x)
    x <- gsub("can't", "can not", x)
    x <- gsub("won't", "will not", x)
    x <- gsub("gonna", "going to", x)
    x <- gsub("there'd", "there would", x)
    x <- gsub("don't", "do not", x)
    x <- textclean::replace_contraction(x)
    x <- gsub("-", " ", x)
    x <- gsub("[^a-zA-Z]", " ", x)

    # Apply lemmatization if requested
    if (lemmatize) {
      x <- textstem::lemmatize_strings(x)
    }

    # Remove stopwords if requested
    if (omit_stops) {
      omissions <- reillylab_stopwords25
      x <- tm::removeWords(x, omissions$word)
    }

    # Update cleaned text
    df$word_clean <- x
  }

  # Split into one word per row while preserving id_orig
  df <- tidyr::separate_rows(df, word_clean, sep = "\\s+")

  # Remove empty strings and trim whitespace
  df <- df[trimws(df$word_clean) != "", ]

  # Apply distinct only to word_clean within each id_orig group
  df <- df %>% dplyr::group_by(id_orig) %>%
    dplyr::distinct(word_clean, .keep_all = TRUE) %>% dplyr::ungroup()

  return(df)
}
