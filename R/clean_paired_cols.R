#' clean_paired_cols
#'
#' Cleans a transcript where word pairs are arrayed in two columns.
#'
#' @name clean_paired_cols
#' @param dat a dataframe with two columns of words you want pairwise distance for
#' @param wordcol1 quoted column name storing the first string for comparison
#' @param wordcol2 quoted column name storing the second string for comparison
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
#' @importFrom stringr str_squish
#' @importFrom textstem lemmatize_strings
#' @importFrom tm removeWords
#' @importFrom textclean replace_white
#' @importFrom utils install.packages
#' @export

clean_paired_cols <- function(dat, wordcol1, wordcol2, lemmatize = TRUE) {
  # Create new column names by appending "_clean1" and "_clean2"
  wordcol1_clean1 <- paste0(wordcol1, "_clean1")
  wordcol2_clean2 <- paste0(wordcol2, "_clean2")

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
      !!sym(wordcol1_clean1) := tryCatch(
        stringi::stri_enc_toutf8(as.character(.[[wordcol1]]),
                                 is_unknown_8bit = TRUE,
                                 validate = TRUE),
        error = function(e) stringi::stri_encode(as.character(.[[wordcol1]]),
                                                 to = "UTF-8")
      ),
      # Process second column
      !!sym(wordcol2_clean2) := tryCatch(
        stringi::stri_enc_toutf8(as.character(.[[wordcol2]]),
                                 is_unknown_8bit = TRUE,
                                 validate = TRUE),
        error = function(e) stringi::stri_encode(as.character(.[[wordcol2]]),
                                                 to = "UTF-8")
      )
    ) %>%
    dplyr::mutate(
      !!sym(wordcol1_clean1) := tolower(!!sym(wordcol1_clean1)),
      !!sym(wordcol2_clean2) := tolower(!!sym(wordcol2_clean2))
    )

  # Define cleaning steps for a column
  clean_column <- function(dat, col_clean, lemmatize) {
    # Apply all cleaning steps
    dat <- dat %>%
      # Remove non-alphabetic characters
      mutate(!!sym(col_clean) := stringi::stri_replace_all_regex(
        !!sym(col_clean), "[^a-zA-Z]", " ")) %>%
      # Clean whitespace
      mutate(!!sym(col_clean) := stringr::str_squish(
        gsub("\\s+", " ", !!sym(col_clean)))) %>%
      # Clean text
      mutate(!!sym(col_clean) := stringi::stri_replace_all_regex(
        !!sym(col_clean), "[^a-z']", "")) %>%
      # ASCII conversion
      mutate(
        !!sym(col_clean) := iconv(!!sym(col_clean), to = "ASCII//TRANSLIT", sub = ""),
        !!sym(col_clean) := stringi::stri_replace_all_regex(
          !!sym(col_clean), "[^[:alnum:]']", "")
      )

    # Lemmatization if requested
    if (lemmatize) {
      dat <- dat %>%
        mutate(!!sym(col_clean) := textstem::lemmatize_strings(!!sym(col_clean)))
    }

    return(dat)
  }

  # Apply cleaning to both columns
  dat_prep <- clean_column(dat_prep, wordcol1_clean1, lemmatize)
  dat_prep <- clean_column(dat_prep, wordcol2_clean2, lemmatize)

  # Rename columns to match input column names
  dat_prep <- dat_prep %>%
    rename(
      !!paste0(wordcol1, "_clean") := !!sym(wordcol1_clean1),
      !!paste0(wordcol2, "_clean") := !!sym(wordcol2_clean2)
    )

  # Retain all rows, including those with NAs
  return(dat_prep)
}
