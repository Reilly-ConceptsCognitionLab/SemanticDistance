#' Dialogue 'Dirty' Transcript
#'
#' A sample dyadic conversation transcript where two people are taslking; Messy string data in a conversation tramscript, mulyiple lines per person per turn, missing observations, fragments, punctuations interspersed with single words. Two people talking to each other.
#'
#' @format ## "Dialogue_Dirty"
#' A data frame with 75 rows and 2 columns:
#' \describe{
#'   \item{word}{text from a language transcript}
#'   \item{speaker}{Mary or Peter: fictional speaker identities}
#'   ...
#' }
"Dialogue_Dirty"



#' Dialogue Structured/Ideal Formatted Transcript
#'
#' Perfectly pre-fomrmatted data in a structure where 2 people are coversing in 1-word utterances back and forth.
#'
#' @format ## "Dialogue_Structured"
#' A data frame with 50 rows and 2 vars:
#' \describe{
#'   \item{mytext}{text from a language transcript}
#'   \item{speaker}{P1 or P2 fictional interlocutor identities}
#'   ...
#' }
"Dialogue_Structured"




#' A Sample 'Dirty' Monologue Transcript
#'
#' No talker delineated. Messy string data composed of missing observations, fragments, punctuations interspersed with single words.
#'
#'
#' @format ## "Monologue_Dirty"
#' A data.frame with 74 obs and 1 var
#' \describe{
#'   \item{mytext}{text from a hypothetical language transcript}
#'   ...
#' }
"Monologue_Dirty"



#' A Sample Structured Monologue Transcript
#'
#' No talker delineated. Idealized/structured transcript no missing observations, fragments, no multiword utterances, already split to one-word-per-row
#'
#' @format ## "Monologue_Structured"
#' A data.frame with 25 obs, 2 vars:
#' \describe{
#'   \item{mytext}{text from a hypothetical 'ideal' language transcript}
#'    \item{timestamp}{simulated metadata as a timestamp}
#'   ...
#' }
"Monologue_Structured"





#' Sample Transcript Split by Two Columns for Pairwise Distance
#'
#' No talker delineated. User arrays first word in one column, second word in another column of the dataframe.
#'
#'
#' @format ## "WordList_Columns"
#' A data frame with 27 rows and 2 columns:
#' \describe{
#'   \item{word1}{text corresponding to the first word in a pair to contrast}
#'   \item{word2}{text corresponding to the second word in a pair to contrast}
#'   ...
#' }
"WordList_Columns"




#' Sample Dataframe with Blocks of Words Related by Semantic Category (unordered text) for evaluating hierachical clustering
#'
#' No talker delineated. Vector of 50 words, 10 from each of 5 categories (animals, fruits, weapons..).
#'
#'
#' @format ## "WordList_TestClustering"
#' A data frame with 50 rows and 4 columns:
#' \describe{
#'   \item{ID_JR}{a sequential numeric identifier}
#'   \item{word}{target text}
#'   \item{category}{semantic category of the target word}
#'   \item{prediction}{is the target word within category or at a switchpoint between cats}
#'   ...
#' }
WordList_TestClustering

