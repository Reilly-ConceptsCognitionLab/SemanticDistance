#' clean_unordered4matrix
#'
#' Cleans and formats text. User specifies the dataframe and column name where target text is stored. Word order does not matter (all words shuffled later). Cleaning takes only first instance of word.
#'
#' @name clean_unordered4matrix
#' @param df a dataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param clean apply cleaning functions (lowercase etc) default is TRUE
#' @param omit_stops option for omitting stopwords default is TRUE
#' @param lemmatize option for lemmatizing strings default is TRUE
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom tm removeWords
#' @importFrom dplyr ungroup
#' @importFrom dplyr distinct
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @importFrom utils install.packages
#' @export clean_unordered4matrix

clean_unordered4matrix <- function(df, wordcol, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE) {
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
  if (!requireNamespace("magrittr", quietly = TRUE)) {
    install.packages("magrittr")
  }
  # Create unique numeric ID for each original row
  df$id_orig <- seq_len(nrow(df))

  # Initialize word_clean with original values
  df$word_clean <- df[[wordcol]]

  # Obligatorily transform to lowercase first
  df$word_clean <- tolower(df$word_clean)

  # Apply stopword omission BEFORE cleaning (if requested)
  if (omit_stops) {
    omissions <- reillylab_stopwords25  # Load stopwords
    df$word_clean <- tm::removeWords(df$word_clean, omissions$word)
  }

  # Apply cleaning pipeline only if clean=TRUE
  if (clean) {
    x <- df$word_clean  # Start with the lowercase (and potentially stopword-free) version
    x <- gsub("`", "'", x)
    x <- gsub("[^a-zA-Z']", " ", x) # omit non-alphabetic chars (keeping apostrophes)
    x <- gsub("\\b[a-z]\\b", "", x)

    # Apply lemmatization if requested
    if (lemmatize) {
      x <- textstem::lemmatize_strings(x)
    }

    df$word_clean <- x
  }

  # Split multi-word strings into separate rows while maintaining ID_Orig and talker
  df <- tidyr::separate_rows(df, word_clean, sep = "\\s+")

  # Remove any empty strings that might have been created
  df <- df[df$word_clean != "", ]

  # Split into one word per row while preserving id_orig
  df <- tidyr::separate_rows(df, word_clean, sep = "\\s+")

  # Remove empty strings and trim whitespace
  df <- df[trimws(df$word_clean) != "", ]

  # Apply distinct only to word_clean within each id_orig group
  df <- df %>% dplyr::group_by(id_orig) %>%
    dplyr::distinct(word_clean, .keep_all = TRUE) %>% dplyr::ungroup()

  return(df)
}
