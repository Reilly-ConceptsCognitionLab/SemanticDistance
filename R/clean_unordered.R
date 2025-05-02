#' clean_unordered
#'
#' Cleans and formats text. User specifies the dataframe and column name where target text is stored. Word order does not matter (all words shuffled later). Cleaning takes only first instance of word.
#'
#' @name clean_unordered
#' @param df a dataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param clean apply cleaning functions (lowercase etc) default is TRUE
#' @param omit_stops option for omitting stopwords default is TRUE
#' @param lemmatize option for lemmatizing strings default is TRUE
#' @return a dataframe
#' @importFrom dplyr ungroup
#' @importFrom dplyr distinct
#' @importFrom magrittr %>%
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @importFrom utils install.packages
#' @export clean_unordered

clean_unordered <- function(df, wordcol, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE, split_strings = TRUE) {
  my_packages <- c("dplyr", "magrittr", "stringr", "stringi", "textstem", "tm", "tidyr", "textclean", "utils")
  for (pkg in my_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  }

  df <- df %>% dplyr::mutate(
    id_row_orig = factor(seq_len(nrow(df))),
    word_clean = tryCatch(
      stringi::stri_enc_toutf8(as.character(.[[wordcol]]), is_unknown_8bit = TRUE, validate = TRUE),
      error = function(e) stringi::stri_encode(as.character(.[[wordcol]]), to = "UTF-8")
    ),
    .before = 1
  ) %>% dplyr::mutate(
    word_clean = tolower(word_clean),
    is_stopword = FALSE  # Initialize stopword flag
  )

  # Text cleaning pipeline (preserve apostrophes)
  if (clean) {
    df <- df %>% dplyr::mutate(
      # Convert backticks to apostrophes
      word_clean = stringi::stri_replace_all_fixed(word_clean, "`", "'"),
      # Keep apostrophes and letters (remove other punctuation)
      word_clean = stringi::stri_replace_all_regex(word_clean, "[^a-zA-Z']", " "),
      # Remove single letters
      word_clean = stringi::stri_replace_all_regex(word_clean, "\\b[a-z]\\b", ""),
      # Clean whitespace
      word_clean = textclean::replace_white(word_clean),
      # Lemmatization (preserves apostrophes)
      word_clean = if (lemmatize) textstem::lemmatize_strings(word_clean) else word_clean,
      # Mark empty strings as NA
      word_clean = ifelse(stringi::stri_isempty(word_clean), NA, word_clean)
    )
  }

  # Remove apostrophes BEFORE splitting (helps with stopword matching)
  df <- df %>%
    dplyr::mutate(word_clean = stringi::stri_replace_all_fixed(word_clean, "'", ""))

  # String splitting FIRST
  if (split_strings) {
    df <- df %>%
      tidyr::separate_rows(word_clean, sep = "\\s+") %>%
      dplyr::filter(
        !is.na(word_clean) | is_stopword,  # Keep NAs that are stopwords
        !stringi::stri_isempty(word_clean) | is_stopword
      )
  }

  # Stopword removal AFTER splitting (now works on individual words)
  if (omit_stops) {
    if (!exists("replacements_25") || !exists("reillylab_stopwords25")) {
      warning("Stopword data not found. Skipping stopword removal.")
    } else {
      # Safe encoding conversion for stopwords
      safe_convert <- function(x) {
        tryCatch(
          stringi::stri_enc_toutf8(as.character(x), is_unknown_8bit = TRUE, validate = TRUE),
          error = function(e) stringi::stri_encode(as.character(x), to = "UTF-8")
        )
      }

      # Process stopwords with encoding protection
      valid_stopwords <- reillylab_stopwords25 %>%
        dplyr::mutate(word = safe_convert(word)) %>%
        dplyr::filter(
          !is.na(word),
          !stringi::stri_isempty(word),
          stringi::stri_enc_isutf8(word)
        )

      if (nrow(valid_stopwords) > 0) {
        df <- df %>%
          dplyr::mutate(
            is_stopword = word_clean %in% valid_stopwords$word,
            word_clean = ifelse(is_stopword, NA, word_clean)
          )
      }
    }
  }

  # Add post-split ID and clean up
  df <- df %>%
    dplyr::mutate(
      id_row_postsplit = seq_len(nrow(df)),
      is_stopword = NULL  # Remove the temporary stopword flag
    )

  # Retain only first instance of each unique cleaned string
  df <- df %>%
    dplyr::group_by(word_clean) %>%
    dplyr::filter(row_number() == 1 | is.na(word_clean)) %>%
    dplyr::ungroup()

  return(df)
}
