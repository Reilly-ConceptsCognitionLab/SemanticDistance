#' clean_dialogue
#'
#' Cleans a transcript where there are two or more talkers. User specifies the dataframe and
#' column name where target text is stored in addition a factor variable corresponding to the
#' identity of the person producing corresponding text. Users also specify cleaning parameters
#' for stopword removal and lemmatization (both defaulting to TRUE). Function splits and unlists text
#' so that the output is in a one-row-per-word format marked by a unique numeric identifier (i.e., 'id_orig').
#' Function appends a turn_count sequence used for aggregating all the words within each turn.
#' If a speaker generates no complete observations because of stopword removal, the turn counter
#' will not increment until a talker switch AND a complete observation is observed.
#'
#' @name clean_dialogue
#' @param dat a datataframe with at least one target column of string data
#' @param wordcol quoted column name storing the strings that will be cleaned and split
#' @param who_talking quoted column name with speaker/talker identities will be factorized
#' @param omit_stops T/F user wishes to remove stopwords (default is TRUE)
#' @param lemmatize T/F user wishes to lemmatize each string (default is TRUE)
#' @return a dataframe
#' @importFrom dplyr filter
#' @importFrom dplyr mutate
#' @importFrom dplyr ungroup
#' @importFrom magrittr %>%
#' @importFrom stringi stri_enc_toutf8
#' @importFrom stringi stri_encode
#' @importFrom stringi stri_replace_all_regex
#' @importFrom stringi stri_isempty
#' @importFrom stringr str_squish
#' @importFrom tm removeWords
#' @importFrom textstem lemmatize_strings
#' @importFrom tidyr separate_rows
#' @importFrom tidyselect all_of
#' @importFrom utils install.packages
#' @export

clean_dialogue <- function(dat, wordcol, who_talking, omit_stops = TRUE, lemmatize = TRUE) {
  # Input validation
  if (!wordcol %in% names(dat)) {
    stop(paste("Column", wordcol, "not found in dataframe"))
  }
  if (!who_talking %in% names(dat)) {
    stop(paste("Column", who_talking, "not found in dataframe"))
  }

  # Create working copy
  dat_prep <- dat %>%
    dplyr::mutate(
      id_row_orig = factor(seq_len(nrow(dat))),
      !!who_talking := factor(.[[who_talking]]),
      text_initialsplit = tryCatch(
        stringi::stri_enc_toutf8(as.character(.[[wordcol]]),
                                 is_unknown_8bit = TRUE,
                                 validate = TRUE),
        error = function(e) stringi::stri_encode(as.character(.[[wordcol]]), to = "UTF-8")
      ) %>% tolower(),
      .before = 1
    )

  # Standardize apostrophes
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

  # Perform initial split into words
  dat_prep <- dat_prep %>%
    tidyr::separate_rows(text_initialsplit, sep = "[[:space:]]+") %>%
    dplyr::mutate(
      text_initialsplit = ifelse(
        is.na(text_initialsplit) | stringi::stri_isempty(text_initialsplit),
        NA_character_,
        text_initialsplit
      )
    ) %>%
    dplyr::select(-all_of(wordcol))

  # Initialize cleaning column
  dat_prep <- dat_prep %>%
    dplyr::mutate(
      word_clean = text_initialsplit,
      word_clean = ifelse(
        is.na(word_clean),
        NA_character_,
        stringi::stri_replace_all_regex(word_clean, "[^a-zA-Z']", " ")
      ),
      word_clean = ifelse(
        is.na(word_clean),
        NA_character_,
        stringr::str_squish(word_clean)
      ),
      word_clean = ifelse(
        is.na(word_clean),
        NA_character_,
        stringi::stri_replace_all_regex(word_clean, "[^a-z']", "")
      )
    )

  # Apply contractions replacement
  dat_prep <- replacements_25(dat = dat_prep, wordcol = word_clean)

  # Perform additional splitting
  dat_prep <- dat_prep %>%
    tidyr::separate_rows(word_clean, sep = "[[:space:]]+", convert = TRUE) %>%
    dplyr::mutate(
      word_clean = ifelse(
        is.na(word_clean) | stringi::stri_isempty(word_clean),
        NA_character_,
        word_clean
      ),
      id_row_postsplit = seq_len(dplyr::n())
    )

  # Lemmatization if requested
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

  # Stopword removal if requested
  if (omit_stops) {
    stopwords <- tolower(Temple_stops25$word)
    dat_prep <- dat_prep %>%
      dplyr::mutate(
        word_clean = ifelse(word_clean %in% stopwords, NA_character_, word_clean)
      )
  }

  # FINAL PUNCTUATION REMOVAL
  dat_prep <- dat_prep %>%
    dplyr::mutate(
      text_initialsplit = ifelse(
        is.na(text_initialsplit),
        NA_character_,
        stringi::stri_replace_all_regex(text_initialsplit, "[[:punct:]]", "")
      ),
      word_clean = ifelse(
        is.na(word_clean),
        NA_character_,
        stringi::stri_replace_all_regex(word_clean, "[[:punct:]]", "")
      )
    )

  # Convert empty strings to NA in word_clean
  dat_prep <- dat_prep %>%
    dplyr::mutate(
      word_clean = ifelse(is.na(word_clean) | stringi::stri_isempty(word_clean),
                          NA_character_,
                          word_clean)
    )

  # SIMPLIFIED TURN COUNT SECTION
  dat_prep <- dat_prep %>%
    dplyr::arrange(id_row_orig, id_row_postsplit) %>%
    dplyr::mutate(
      # Handle speaker changes (including NA values)
      speaker_changed = (!!rlang::sym(who_talking)) != dplyr::lag(!!rlang::sym(who_talking)),
      # First row always starts new turn
      speaker_changed = ifelse(dplyr::row_number() == 1, TRUE, speaker_changed),
      # Increment turn count on speaker change
      turn_count = cumsum(as.integer(speaker_changed))
    ) %>%
    dplyr::select(-speaker_changed)

  rownames(dat_prep) <- NULL
  return(dat_prep)
}
