#' clean_monologue
#'
#' Cleans and formats text. User specifies the dataframe and column name where target text is stored as arguments to the function. Default option is to lemmatize strings. Function splits and unlists text so that the output is in a one-row-per-word format marked by a unique numeric identifier (i.e., 'id_orig')
#'
#' @name clean_monologue
#' @param dat a dataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param clean apply cleaning functions (lowercase etc) default is TRUE
#' @param omit_stops option for omitting stopwords default is TRUE
#' @param lemmatize option for lemmatizing strings default is TRUE
#' @param split_strings option T/F (default T) will split multiword utterances into separate rows
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
#' @importFrom tidyr separate_rows
#' @importFrom utils install.packages
#' @export

clean_monologue <- function(dat, wordcol, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE, split_strings = TRUE) {
  # Input validation
  if (!wordcol %in% names(dat)) {
    stop(paste("Column", wordcol, "not found in dataframe"))
  }

  # Create working copy and perform initial split
  dat_prep <- dat %>%
    dplyr::mutate(
      id_row_orig = factor(seq_len(nrow(dat))),
      text_initialsplit = tryCatch(
        stringi::stri_enc_toutf8(as.character(.[[wordcol]]), is_unknown_8bit = TRUE, validate = TRUE),
        error = function(e) stringi::stri_encode(as.character(.[[wordcol]]), to = "UTF-8")
      ),
      .before = 1
    ) %>%
    # Perform initial split into words
    tidyr::separate_rows(text_initialsplit, sep = "[[:space:]]+") %>%
    dplyr::filter(
      !is.na(text_initialsplit),
      !stringi::stri_isempty(text_initialsplit)
    ) %>%
    # Remove original column
    dplyr::select(-all_of(wordcol)) %>%
    # Initialize cleaning column
    dplyr::mutate(
      word_clean = tolower(text_initialsplit),
      is_stopword = FALSE  # Initialize stopword flag
    )

  if (clean) {
    # Standardize apostrophes
    dat_prep <- dat_prep %>%
      mutate(word_clean = stringi::stri_replace_all_regex(word_clean, "[\u2018\u2019\u02BC\u201B\uFF07\u0092\u0091\u0060\u00B4\u2032\u2035]", "'"))

    # Remove non-alphabetic characters except apostrophes
    dat_prep <- dat_prep %>% mutate(word_clean = stringi::stri_replace_all_regex(word_clean, "[^a-zA-Z']", " "))

    # Clean whitespace
    dat_prep <- dat_prep %>% mutate(word_clean = str_squish(gsub("\\s+", " ", word_clean)))

    # Clean text
    dat_prep <- dat_prep %>% mutate(word_clean = stringi::stri_replace_all_regex(word_clean, "[^a-z']", ""))

    # ASCII conversion
    dat_prep <- dat_prep %>% mutate(
      word_clean = iconv(word_clean, to = "ASCII//TRANSLIT", sub = ""),
      word_clean = stringi::stri_replace_all_regex(word_clean, "[^[:alnum:]']", "")
    )
  }

  # Apply contractions replacement
  dat_prep <- replacements_25(dat = dat_prep, wordcol = "word_clean")

  # Additional string splitting if requested (though initial split already did this)
  if (split_strings) {
    dat_prep <- dat_prep %>%
      tidyr::separate_rows(word_clean, sep = "[[:space:]]+") %>%
      dplyr::filter(
        !is.na(word_clean) | is_stopword,
        !stringi::stri_isempty(word_clean) | is_stopword
      )
  }

  # Lemmatization if requested
  if (lemmatize) {
    dat_prep <- dat_prep %>%
      mutate(word_clean = textstem::lemmatize_strings(word_clean))
  }

  # Stopword removal if requested
  if (omit_stops) {
    stopwords <- Temple_stops25$word
    dat_prep <- dat_prep %>%
      mutate(
        is_stopword = word_clean %in% stopwords,
        word_clean = ifelse(is_stopword, NA, word_clean)
      )
  }

  return(dat_prep)
}
