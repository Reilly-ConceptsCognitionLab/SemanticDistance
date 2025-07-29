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
#' @importFrom rlang sym
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

clean_paired_cols <- function(dat, wordcol1, wordcol2, clean = TRUE, omit_stops = TRUE, lemmatize = TRUE, split_strings = TRUE) {
  # Input validation
  if (!wordcol1 %in% names(dat)) {
    stop(paste("Column", wordcol1, "not found in dataframe"))
  }
  if (!wordcol2 %in% names(dat)) {
    stop(paste("Column", wordcol2, "not found in dataframe"))
  }

  # Create working copy with robust encoding handling
  dat_prep <- dat %>%
    dplyr::mutate(
      id_row_orig = factor(seq_len(nrow(dat))),
      # Process first column
      word_clean1 = tryCatch(
        stringi::stri_enc_toutf8(as.character(.[[wordcol1]]), is_unknown_8bit = TRUE, validate = TRUE),
        error = function(e) stringi::stri_encode(as.character(.[[wordcol1]]), to = "UTF-8")
      ),
      # Process second column
      word_clean2 = tryCatch(
        stringi::stri_enc_toutf8(as.character(.[[wordcol2]]), is_unknown_8bit = TRUE, validate = TRUE),
        error = function(e) stringi::stri_encode(as.character(.[[wordcol2]]), to = "UTF-8")
      ),
      .before = 1
    ) %>%
    dplyr::mutate(
      word_clean1 = tolower(word_clean1),
      word_clean2 = tolower(word_clean2),
      is_stopword1 = FALSE,
      is_stopword2 = FALSE
    )

  # Define cleaning steps for a column
  clean_column <- function(dat, colname, clean, omit_stops, lemmatize, split_strings) {
    col_clean <- paste0(colname, "_clean")
    col_stop <- paste0("is_stopword", substr(colname, nchar(colname), nchar(colname)))

    if (clean) {
      dat <- dat %>%
        # Standardize apostrophes
        mutate(!!sym(col_clean) := stringi::stri_replace_all_regex(!!sym(col_clean),
                                                                   "[\u2018\u2019\u02BC\u201B\uFF07\u0092\u0091\u0060\u00B4\u2032\u2035]", "'")) %>%
        # Remove non-alphabetic characters except apostrophes
        mutate(!!sym(col_clean) := stringi::stri_replace_all_regex(!!sym(col_clean), "[^a-zA-Z']", " ")) %>%

        # Clean whitespace
        mutate(!!sym(col_clean) := str_squish(gsub("\\s+", " ", !!sym(col_clean)))) %>%

  # Clean text
  mutate(!!sym(col_clean) := stringi::stri_replace_all_regex(!!sym(col_clean), "[^a-z']", "")) %>%
  # ASCII conversion
  mutate(
    !!sym(col_clean) := iconv(!!sym(col_clean), to = "ASCII//TRANSLIT", sub = ""),
    !!sym(col_clean) := stringi::stri_replace_all_regex(!!sym(col_clean), "[^[:alnum:]']", "")
  )
    }

    # Apply contractions replacement
    dat <- replacements_25(dat = dat, wordcol = col_clean)

    # String splitting if requested
    if (split_strings) {
      dat <- dat %>%
        tidyr::separate_rows(!!sym(col_clean), sep = "[[:space:]]+") %>%
        dplyr::filter(
          !is.na(!!sym(col_clean)) | !!sym(col_stop),
          !stringi::stri_isempty(!!sym(col_clean)) | !!sym(col_stop)
        )
    }

    # Lemmatization if requested
    if (lemmatize) {
      dat <- dat %>%
        mutate(!!sym(col_clean) := textstem::lemmatize_strings(!!sym(col_clean)))
    }

    # Stopword removal if requested
    if (omit_stops) {
      stopwords <- Temple_stops25$word
      dat <- dat %>%
        mutate(
          !!sym(col_stop) := !!sym(col_clean) %in% stopwords,
          !!sym(col_clean) := ifelse(!!sym(col_stop), NA, !!sym(col_clean))
        )
    }

    return(dat)
  }

  # Apply cleaning to both columns
  dat_prep <- clean_column(dat_prep, "word1", clean, omit_stops, lemmatize, split_strings)
  dat_prep <- clean_column(dat_prep, "word2", clean, omit_stops, lemmatize, split_strings)

  # Rename columns to match input column names
  dat_prep <- dat_prep %>%
    rename(
      !!paste0(wordcol1, "_clean") := word_clean1,
      !!paste0(wordcol2, "_clean") := word_clean2
    ) %>%
    select(-is_stopword1, -is_stopword2)

  return(dat_prep)
}
