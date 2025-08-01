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


clean_dialogue <- function(dat, wordcol, whotalks, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE, split_strings = TRUE) {
  # Input validation
  if (!wordcol %in% names(dat)) {
    stop(paste("Column", wordcol, "not found in dataframe"))
  }
  if (!whotalks %in% names(dat)) {
    stop(paste("Column", whotalks, "not found in dataframe"))
  }

  # Create working copy with robust encoding handling
  dat_prep <- dat %>%
    dplyr::mutate(
      id_row_orig = factor(seq_len(nrow(dat))),
      word_clean = tryCatch(
        stringi::stri_enc_toutf8(as.character(.[[wordcol]]), is_unknown_8bit = TRUE, validate = TRUE),
        error = function(e) stringi::stri_encode(as.character(.[[wordcol]]), to = "UTF-8")
      ),
      .before = 1
    ) %>%
    dplyr::mutate(
      word_clean = tolower(word_clean),
      is_stopword = FALSE,  # Initialize stopword flag
      talker = factor(.[[whotalks]]))  # Create talker factor variable

      if (clean) {
        # Standardize apostrophes
        dat_prep <- dat_prep %>%
          mutate(word_clean = stringi::stri_replace_all_regex(word_clean, "[\u2018\u2019\u02BC\u201B\uFF07\u0092\u0091\u0060\u00B4\u2032\u2035]", "'"))

        # Remove non-alphabetic characters except apostrophes
        dat_prep <- dat_prep %>%
          mutate(word_clean = stringi::stri_replace_all_regex(word_clean, "[^a-zA-Z']", " "))

        # Clean whitespace
        dat_prep <- dat_prep %>%
          mutate(word_clean = str_squish(gsub("\\s+", " ", word_clean)))

        # Clean text
        dat_prep <- dat_prep %>%
          mutate(word_clean = stringi::stri_replace_all_regex(word_clean, "[^a-z']", ""))

        # ASCII conversion
        dat_prep <- dat_prep %>%
          mutate(
            word_clean = iconv(word_clean, to = "ASCII//TRANSLIT", sub = ""),
            word_clean = stringi::stri_replace_all_regex(word_clean, "[^[:alnum:]']", "")
          )
      }

      # Apply contractions replacement
      dat_prep <- replacements_25(dat = dat_prep, wordcol = "word_clean")

      # String splitting if requested
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

      # Create turncount variable when talker level changes
      dat_prep <- dat_prep %>%
        group_by(talker) %>%
        mutate(id_turn = cumsum(c(1, diff(as.numeric(talker)) != 0))) %>%
                 ungroup()

               rownames(dat_prep) <- NULL
               return(dat_prep)
}
