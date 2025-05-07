#' Messy Dialogue Transcript
#'
#' A sample dyadic conversation transcript where two people are taslking; Messy string data in a conversation tramscript, mulyiple lines per person per turn, missing observations, fragments, punctuations interspersed with single words. Two people talking to each other.
#'
#' @format ## "Dialogue_Messy"
#' A data frame with 75 rows and 2 columns:
#' \describe{
#'   \item{word}{text from a language transcript}
#'   \item{speaker}{Mary or Peter: fictional speaker identities}
#'   ...
#' }
"Dialogue_Messy"



#' Dialogue Transcript Perfectly Formatted
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




#' A Sample Messy Monologue Transcript
#'
#' No talker delineated. Messy string data composed of missing observations, fragments, punctuations interspersed with single words.
#'
#' @format ## "Monologue_Messy"
#' A data.frame with 74 obs and 1 var
#' \describe{
#'   \item{mytext}{text from a hypothetical language transcript}
#'   ...
#' }
"Monologue_Messy"



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



#' Column Arrayed Word Pairs for Pairwise Distance
#'
#' first target word for computing distance in one column, second word in another column.
#'
#' @format ## "Word_Pairs"
#' A data frame with 27 rows and 2 columns:
#' \describe{
#'   \item{word1}{text corresponding to the first word in a pair to contrast}
#'   \item{word2}{text corresponding to the second word in a pair to contrast}
#'   ...
#' }
"Word_Pairs"




#' Simulated Semantic Category Fluency Data: Word List Blocked by Semantic Category
#'
#' No talker delineated. Vector of 20 words, 5 from each of 4 categories, Good for examining clustering
#'
#'
#' @format ## "Semantic_Clusters"
#' A data frame with 20 rows and 3 columns:
#' \describe{
#'   \item{ID_JR}{a sequential numeric identifier}
#'   \item{word}{target text}
#'   \item{category}{semantic category of the target word}
#'   ...
#' }
'Semantic_Clusters'





#' The Grandfather Passage: A Standardized Reading Passage
#'
#' A monologue discourse sample. Grandfather Passage is a well-known test of reading aloud.
#'
#'
#' @format ## "Grandfather_Passage"
#' A data frame with 1 observation of 1 variable:
#' \describe{
#'   \item{mytext}{text from the Grandfather Passage unsplit}
#'   ...
#' }
'Grandfather_Passage'




