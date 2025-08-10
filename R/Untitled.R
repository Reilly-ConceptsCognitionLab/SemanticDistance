#' clean_monologue_or_list
#'
#' Cleans and formats text. User specifies the dataframe and column name where target text is stored as arguments to the function. Default option is to lemmatize strings. Function splits and unlists text so that the output is in a one-row-per-word format marked by a unique numeric identifier (i.e., 'id_orig')
#'
#' @name clean_monologue_or_list
#' @param dat a dataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param omit_stops option for omitting stopwords default is TRUE
#' @param lemmatize option for lemmatizing strings default is TRUE
#' @return a dataframe
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr n
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

clean_monologue_or_list <- function(dat, wordcol, omit_stops = TRUE, lemmatize = TRUE) {
  # Input validation
  if (!wordcol %in% names(dat)) {
    stop(paste("Column", wordcol, "not found in dataframe"))
  }

  # Create working copy and perform initial split with punctuation removal
  dat_prep <- dat %>%
    dplyr::mutate(
      id_row_orig = factor(seq_len(nrow(dat))),
      text_initialsplit = tryCatch(
        stringi::stri_enc_toutf8(as.character(.[[wordcol]]),
                                 is_unknown_8bit = TRUE,
                                 validate = TRUE),
        error = function(e) stringi::stri_encode(as.character(.[[wordcol]]), to = "UTF-8")
      ) %>%
        tolower() %>%
        # Remove all punctuation immediately after encoding
        stringi::stri_replace_all_regex("[[:punct:]]", " "),
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
      word_clean = stringi::stri_replace_all_regex(
        stringr::str_squish(
          stringi::stri_replace_all_regex(
            text_initialsplit,
            "[^a-zA-Z']", " "
          )
        ),
        "[^a-z']", ""
      ),
      id_row_postsplit = seq_len(dplyr::n())
    ) %>%
    # ASCII conversion and final cleaning
    dplyr::mutate(
      word_clean = iconv(word_clean, to = "ASCII//TRANSLIT", sub = ""),
      word_clean = stringi::stri_replace_all_regex(word_clean, "[^[:alnum:]']", ""),
      word_clean = stringr::str_squish(word_clean)
    ) %>%
    dplyr::filter(word_clean != "")

  # Apply contractions replacement
  dat_prep <- replacements_25(dat = dat_prep, wordcol = "word_clean")

  # Perform additional splitting after replacements
  dat_prep <- dat_prep %>%
    tidyr::separate_rows(word_clean, sep = "[[:space:]]+") %>%
    dplyr::filter(
      !is.na(word_clean),
      !stringi::stri_isempty(word_clean)
    ) %>%
    dplyr::mutate(id_row_postsplit = seq_len(dplyr::n()))

  # Lemmatization if requested
  if (lemmatize) {
    dat_prep <- dat_prep %>%
      dplyr::mutate(word_clean = textstem::lemmatize_strings(word_clean))
  }

  # Stopword removal if requested
  if (omit_stops) {
    stopwords <- tolower(Temple_stops25$word)
    dat_prep <- dat_prep %>%
      dplyr::mutate(
        is_stopword = word_clean %in% stopwords,
        word_clean = ifelse(is_stopword, NA_character_, word_clean)
      ) %>%
      dplyr::filter(!is.na(word_clean), word_clean != "")
  }

  # Final cleanup and return
  dat_prep %>%
    dplyr::select(-is_stopword) %>%
    dplyr::filter(!is.na(word_clean), word_clean != "")
}
