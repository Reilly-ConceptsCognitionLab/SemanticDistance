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
#' @importFrom dplyr mutate
#' @importFrom magrittr %>%
#' @importFrom stringi stri_isempty
#' @importFrom stringi stri_enc_toutf8
#' @importFrom stringi stri_encode
#' @importFrom stringi stri_enc_isutf8
#' @importFrom stringi stri_replace_all_fixed
#' @importFrom stringi stri_replace_all_regex
#' @importFrom textstem lemmatize_strings
#' @importFrom tm removeWords
#' @importFrom textclean replace_white
#' @importFrom utils install.packages
#' @export clean_2cols

clean_2cols <- function(df, col1, col2, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE) {
  # Load required packages
  required_packages <- c("dplyr", "magrittr", "stringi", "textstem", "tm", "textclean", "utils")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  }

  # Convert specified columns to lowercase first
  df <- df %>%
    dplyr::mutate(
      !!col1 := tolower(.[[col1]]),
      !!col2 := tolower(.[[col2]])
    )

  # Create ID column
  df$id_row_orig <- factor(seq_len(nrow(df)))

  # Text cleaning function
  clean_text <- function(x, clean_flag = TRUE, omit_stops_flag = TRUE, lemmatize_flag = TRUE) {
    if (clean_flag) {
      # Convert backticks to apostrophes
      x <- stringi::stri_replace_all_fixed(x, "`", "'")
      # Keep apostrophes and letters (remove other punctuation)
      x <- stringi::stri_replace_all_regex(x, "[^a-zA-Z']", " ")
      # Remove single letters
      x <- stringi::stri_replace_all_regex(x, "\\b[a-z]\\b", "")
      # Clean whitespace
      x <- textclean::replace_white(x)
      # Lemmatization (preserves apostrophes)
      x <- if (lemmatize_flag) textstem::lemmatize_strings(x) else x
      # Remove apostrophes
      x <- stringi::stri_replace_all_fixed(x, "'", "")
      # Mark empty strings as NA
      x <- ifelse(stringi::stri_isempty(x), NA, x)
    }

    # Stopword removal
    if (omit_stops_flag) {
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
          x <- ifelse(x %in% valid_stopwords$word, NA, x)
        }
      }
    }

    return(x)
  }

  # Apply processing to both columns with different suffixes
  df[[paste0(col1, "_clean1")]] <- sapply(df[[col1]], clean_text,
                                          clean_flag = clean,
                                          omit_stops_flag = omit_stops,
                                          lemmatize_flag = lemmatize)

  df[[paste0(col2, "_clean2")]] <- sapply(df[[col2]], clean_text,
                                          clean_flag = clean,
                                          omit_stops_flag = omit_stops,
                                          lemmatize_flag = lemmatize)

  return(df)
}
