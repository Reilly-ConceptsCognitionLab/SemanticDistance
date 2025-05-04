#' clean_dialogue
#'
#' Cleans a transcript where there are two or more talkers. User specifies the dataframe and column name where target text is stored as arguments to the function. Default option is to lemmatize strings. Function splits and unlists text so that the output is in a one-row-per-word format marked by a unique numeric identifier (i.e., 'id_orig')
#'
#' @name clean_dialogue
#' @param dat a datataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param whotalks quoted column name with speaker/talker identities will be factorized
#' @param clean T/F apply cleaning transformations (default is TRUE)
#' @param omit_stops T/F user wishes to remove stopwords (default is TRUE)
#' @param lemmatize T/F user wishes to lemmatize each string (default is TRUE)
#' @param split_strings option T/F (default T) split multiword contractions into separate rows
#' @return a dataframe
#' @importFrom magrittr %>%
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @importFrom utils install.packages
#' @export clean_dialogue


clean_dialogue <- function(dat, wordcol, whotalks, clean=TRUE, omit_stops=TRUE, lemmatize = TRUE, split_strings=TRUE) {
  required_packages <- c("tm", "textstem", "tidyr", "textclean", "magrittr", "stringr", "dplyr", "stringi", "utils")
  for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
      install.packages(pkg)
    }
    library(pkg, character.only = TRUE)
  }

  # Create working copy with robust encoding handling
  dat <- dat %>%
    dplyr::mutate(id_row_orig = factor(seq_len(nrow(dat))),
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

  # Create talker factor variable from whotalks column
  dat$talker <- factor(dat[[whotalks]])
  x <- dat[[wordcol]]

  # Text cleaning pipeline (preserve apostrophes)
  if (clean) {
    dat <- dat %>%
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
  dat <- dat %>%
    dplyr::mutate(
      word_clean = stringi::stri_replace_all_fixed(word_clean, "'", "")
    )

  # String splitting - only if split_strings=TRUE
  if (isTRUE(split_strings)) {
    dat <- dat %>%
      tidyr::separate_rows(word_clean, sep = "\\s+") %>%
      dplyr::filter(
        !is.na(word_clean) | is_stopword,  # Keep NAs that are stopwords
        !stringi::stri_isempty(word_clean) | is_stopword
      )
  }

  # Stopword removal (works whether strings are split or not)
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
        dplyr::filter(!is.na(word),
          !stringi::stri_isempty(word),
          stringi::stri_enc_isutf8(word)
        )

      if (nrow(valid_stopwords) > 0) {
        dat <- dat %>%
          dplyr::mutate(
            is_stopword = word_clean %in% valid_stopwords$word,
            word_clean = ifelse(is_stopword, NA, word_clean)
          )
      }
    }
  }

  # Add post-split ID and clean up
  dat <- dat %>%
    dplyr::mutate(
      id_row_postsplit = seq_len(nrow(dat)),
      is_stopword = NULL  # Remove the temporary stopword flag
    )

  # Create turncount variable when talker level changes
  dat$id_turn <- cumsum(c(1, diff(as.numeric(dat$talker)) != 0))
  rownames(dat) <- NULL
  return(dat)
}
