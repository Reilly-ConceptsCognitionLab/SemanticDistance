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
  # Load required packages
  required_packages <- c("tm", "textstem", "tidyr", "textclean", "magrittr", "stringr", "dplyr", "stringi")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  }

  # Input validation
  if (nrow(df) == 0) {
    warning("Input dataframe is empty")
    return(df)
  }

  if (!wordcol %in% names(df)) {
    stop(paste("Column", wordcol, "not found in dataframe"))
  }

  # Create working copy with robust encoding handling
  df <- df %>%
    dplyr::mutate(
      id_row_orig = factor(seq_len(nrow(df))),
      word_clean = tryCatch(
        stringi::stri_enc_toutf8(as.character(.[[wordcol]]), is_unknown_8bit = TRUE, validate = TRUE),
        error = function(e) stringi::stri_encode(as.character(.[[wordcol]]), to = "UTF-8")
      ),
      .before = 1
    ) %>%
    dplyr::mutate(
      word_clean = tolower(word_clean),
      is_stopword = FALSE  # Initialize stopword flag
    )

  # Text cleaning pipeline (preserve apostrophes)
  if (clean) {
    df <- df %>%
      dplyr::mutate(
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
    dplyr::mutate(
      word_clean = stringi::stri_replace_all_fixed(word_clean, "'", "")
    )

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

  return(df)
}
