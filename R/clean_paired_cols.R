#' clean_paired_cols
#'
#' Cleans a transcript where word pairs are arrayed in two columns.
#'
#' @name clean_paired_cols
#' @param dat a dataframe with two columns of words you want pairwise distance for
#' @param wordcol1 quoted column name storing the first string for comparison
#' @param wordcol2 quoted column name storing the second string for comparison
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
#' @export clean_paired_cols

clean_paired_cols <- function(dat, wordcol1, wordcol2, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE) {
  # Load required packages
  required_packages <- c("dplyr", "magrittr", "stringi", "textstem", "tm", "textclean", "utils")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  }

  # Create ID column
  dat$id_row_orig <- factor(seq_len(nrow(dat)))

  # Text cleaning function - MODIFIED to lowercase first
  clean_text <- function(x, clean_flag = TRUE, omit_stops_flag = TRUE, lemmatize_flag = TRUE) {
    # Convert to lowercase FIRST before any processing
    x <- tolower(as.character(x))

    if (clean_flag) {
      # Convert backticks to apostrophes
      x <- stringi::stri_replace_all_fixed(x, "`", "'")
      # Keep apostrophes and letters (remove other punctuation)
      x <- stringi::stri_replace_all_regex(x, "[^a-z']", " ")  # Changed to lowercase pattern
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
      if (!exists("replacements_25") || !exists("Temple_Stopwords25")) {
        warning("Stopword data not found. Skipping stopword removal.")
      } else {
        # Safe encoding conversion for stopwords
        safe_convert <- function(x) {
          tryCatch(
            stringi::stri_enc_toutf8(tolower(as.character(x))),  # Ensure stopwords are lowercase
            error = function(e) stringi::stri_encode(tolower(as.character(x)), to = "UTF-8")
          )
        }

        # Process stopwords with encoding protection
        valid_stopwords <- Temple_Stopwords25 %>%
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
  dat[[paste0(wordcol1, "_clean1")]] <- sapply(dat[[wordcol1]], clean_text,
                                               clean_flag = clean,
                                               omit_stops_flag = omit_stops,
                                               lemmatize_flag = lemmatize)

  dat[[paste0(wordcol2, "_clean2")]] <- sapply(dat[[wordcol2]], clean_text,
                                               clean_flag = clean,
                                               omit_stops_flag = omit_stops,
                                               lemmatize_flag = lemmatize)

  return(dat)
}
