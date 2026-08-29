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

  # Create working copy and perform initial split
  dat_prep <- dat %>%
    dplyr::mutate(
      id_row_orig = factor(seq_len(nrow(dat))),
      text_initialsplit = tryCatch(
        stringi::stri_enc_toutf8(as.character(.[[wordcol]]),
                                 is_unknown_8bit = TRUE,
                                 validate = TRUE),
        error = function(e) stringi::stri_encode(as.character(.[[wordcol]]), to = "UTF-8")
      ) %>%
        tolower()
    )

  # Standardize apostrophes in original text
  dat_prep <- dat_prep %>%
    dplyr::mutate(
      text_initialsplit = ifelse(
        is.na(text_initialsplit),
        NA_character_,
        stringi::stri_replace_all_regex(
          text_initialsplit,
          "[\u2018\u2019\u02BC\u201B\uFF07\u0092\u0091\u0060\u00B4\u2032\u2035]",
          "'"
        )
      )
    )

  # Perform initial split into words (retains contractions)
  dat_prep <- dat_prep %>%
    tidyr::separate_rows(text_initialsplit, sep = "[[:space:]]+") %>%
    dplyr::mutate(
      text_initialsplit = ifelse(
        is.na(text_initialsplit) | stringi::stri_isempty(text_initialsplit),
        NA_character_,
        text_initialsplit
      )
    ) %>%
    # Remove original column
    dplyr::select(-all_of(wordcol))

  # Initialize cleaning column with actual cleaned text
  dat_prep <- dat_prep %>%
    dplyr::mutate(
      word_clean = text_initialsplit,
      # Remove non-alphabetic characters except apostrophes
      word_clean = ifelse(
        is.na(word_clean),
        NA_character_,
        stringi::stri_replace_all_regex(word_clean, "[^a-zA-Z']", " ")
      ),
      # Squish whitespace
      word_clean = ifelse(
        is.na(word_clean),
        NA_character_,
        stringr::str_squish(word_clean)
      ),
      word_clean = ifelse(
        is.na(word_clean),
        NA_character_,
        stringi::stri_replace_all_regex(word_clean, "[^a-z']", "")
      ),
      word_clean = ifelse(
        is.na(word_clean),
        NA_character_,
        stringi::stri_replace_all_regex(word_clean, "[^[:alnum:]']", "")
      )
    )

  # Apply contractions replacement (only for non-NA values)
  dat_prep <- replacements_25(dat = dat_prep, wordcol = word_clean)

  # Perform additional splitting after replacements (keeping NAs)
  dat_prep <- dat_prep %>%
    tidyr::separate_rows(word_clean, sep = "[[:space:]]+", convert = TRUE) %>%
    dplyr::mutate(
      word_clean = ifelse(
        is.na(word_clean) | stringi::stri_isempty(word_clean),
        NA_character_,
        word_clean
      ),
      id_row_postsplit = factor(seq_len(dplyr::n()))
    )

  # Lemmatization if requested (only for non-NA values)
  if (lemmatize) {
    dat_prep <- dat_prep %>%
      dplyr::mutate(
        word_clean = ifelse(
          is.na(word_clean),
          NA_character_,
          textstem::lemmatize_strings(word_clean)
        )
      )
  }

  # Stopword removal if requested (now keeps NAs)
  if (omit_stops) {
    stopwords <- tolower(Temple_stops25$word)
    dat_prep <- dat_prep %>%
      dplyr::mutate(
        is_stopword = ifelse(
          is.na(word_clean),
          NA,
          word_clean %in% stopwords
        ),
        word_clean = ifelse(is_stopword, NA_character_, word_clean)
      ) %>%
      dplyr::select(-is_stopword)  # Remove the is_stopword column
  }

  return(dat_prep)
}
