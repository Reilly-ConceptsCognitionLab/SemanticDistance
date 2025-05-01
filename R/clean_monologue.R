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
#' @param split_strings option T/F (default T) will split multiword utterances into separate rows
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @importFrom utils install.packages
#' @importFrom stringr str_replace_all
#' @export clean_monologue

clean_monologue <- function(df, wordcol, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE, split_strings = TRUE) {
  if (!requireNamespace("tm", quietly = TRUE)) {
    install.packages("tm")
  }
  if (!requireNamespace("textstem", quietly = TRUE)) {
    install.packages("textstem")
  }
  if (!requireNamespace("tidyr", quietly = TRUE)) {
    install.packages("tidyr")
  }
  if (!requireNamespace("textclean", quietly = TRUE)) {
    install.packages("textclean")
  }
  if (!requireNamespace("magrittr", quietly = TRUE)) {
    install.packages("magrittr")
  }

  df$id_row_orig <- factor(seq_len(nrow(df)))
  df$word_clean <- df[[wordcol]]

  # Obligatorily transform to lowercase first
  df$word_clean <- tolower(df$word_clean)

  # Apply stopword omission BEFORE cleaning (if requested)
  if (omit_stops) {
    replacement_lookup <- setNames(replacements_25$replacement,
                                   replacements_25$target)
    df$word_clean <- stringr::str_replace_all(df$word_clean, replacement_lookup)
    df$word_clean <- tm::removeWords(df$word_clean, reillylab_stopwords25$word)
  }

  # Apply cleaning operations only if clean=TRUE
  if (clean) {
    x <- df$word_clean  # Start with the lowercase (and potentially stopword-free) version
    x <- gsub("`", "'", x)
    x <- gsub("[^a-zA-Z']", " ", x) # omit non-alphabetic chars (keeping apostrophes)
    x <- gsub("\\b[a-z]\\b", "", x)  # Remove singleton letters

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

  #squish any multiword rows into one string
  df$word_clean <- textclean::replace_white(df$word_clean)

  # Replace empty strings with NA instead of removing rows
  df$word_clean[df$word_clean == ""] <- NA

  #append unique ID by row after splitting the dataframe
  # Prepare working data and create unique row IDs
  df <- df %>% dplyr::mutate(
      id_row_postsplit = seq_len(nrow(df)))  # unique row identifier after splitting

  return(df)
}
