#' A Sample Dialogue Transcript
#'
#' Messy string data composed of missing observations, fragments, punctuations interspersed with single words. Two people talking to each other.
#'
#'
#' @format ## "DialogueSample1"
#' A data frame with 75 rows and 2 columns:
#' \describe{
#'   \item{word}{text from a language transcript}
#'   \item{speaker}{Mary or Peter: fictional speaker identities}
#'   ...
#' }
"DialogueSample1"




#' A Sample Monologue Transcript
#'
#' No talker delineated. Messy string data composed of missing observations, fragments, punctuations interspersed with single words.
#'
#'
#' @format ## "MonologueSample1"
#' A data frame with 74 rows and 1 column:
#' \describe{
#'   \item{word}{text from a hypothetical language transcript}
#'   ...
#' }
"MonologueSample1"




#' Sample Transcript Split by Two Columns
#'
#' No talker delineated. User arrays first word in one column, second word in another column of the dataframe.
#'
#'
#' @format ## "ColumnSample"
#' A data frame with 27 rows and 2 columns:
#' \describe{
#'   \item{word1}{text corresponding to the first word in a pair to contrast}
#'   \item{word2}{text corresponding to the second word in a pair to contrast}
#'   ...
#' }
"ColumnSample"




#' Sample Dataframe with Blocks of Words Related by Semantic Category
#'
#' No talker delineated. Vector of 50 words, 10 from each of 5 categories (animals, fruits, weapons..).
#'
#'
#' @format ## "FakeCats"
#' A data frame with 50 rows and 4 columns:
#' \describe{
#'   \item{ID_JR}{a sequential numeric identifier}
#'   \item{word}{target text}
#'   \item{category}{semantic category of the target word}
#'   \item{prediction}{is the target word within category or at a switchpoint between cats}
#'   ...
#' }
"FakeCats"

