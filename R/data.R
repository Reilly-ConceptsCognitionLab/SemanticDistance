#' A Typical Dialogue Transcript
#'
#' A sample dyadic conversation transcript where two people are conversing.
#'
#' @format ## "Dialogue_Typical"
#' A data frame with 5 rows and 2 columns:
#' \describe{
#'   \item{word}{fictional text from a language transcript}
#'   \item{speaker}{Mary or Peter: fictional speaker identities}
#'   ...
#' }
"Dialogue_Typical"



#' A Typical Monologue Transcript
#'
#' Dataframe with ordered text squashed into a single cell.
#'
#' @format ## "Monologue_Typical"
#' A data frame with 1 row and 1 column
#' \describe{
#'   \item{mytext}{text from a language transcript}
#'   ...
#' }
"Monologue_Typical"



#'  Word Pairs in Columns
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



#' Unordered_List
#'
#' No talker delineated. List of 17 words spanning 4 semantic categories, Good for examining clustering
#'
#'
#' @format ## "Unordered_List"
#' A data frame with 1 rows and 1 columns:
#' \describe{
#'   \item{mytext}{unsplit list of words containing musical instruments, weapongs, fruits, emotions}
#' }
'Unordered_List'



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


#' Glove Semantic Embeddings
#'
#' Word embeddings (300 hyperparameter dimensions, 59061 words). Each word is one row.
#'
#' @format ## "glowca_25"
#' A data frame with 59061 observations of 301 variables
#' \describe{
#'   \item{word}{word characterized across embeddings}
#'   \item{Param_1}{hyperparameter number 1}
#'   \item{Param_300}{hyperparameter number 300}
#'   ...
#' }
'glowca_25'



#' SD15_2025_complete Experiential Semantic Distance Values
#'
#' Word embeddings (300 dimensions, 59061 words). Each word is one row.
#'
#' @format ## "SD15_2025_complete"
#' A data frame with 25,050 observations of 16 variables
#' \describe{
#'   \item{word}{word characterized across 15 ratings}
#'   \item{Param_auditory_z}{z-score of auditory salience from Lancaster Sensorimotor Norms}
#'   \item{Param_gustatory_z}{z-score of gustatory salience from Lancaster Sensorimotor Norms}
#'   \item{Param_haptic_z}{z-score of haptic salience from Lancaster Sensorimotor Norms}
#'   \item{Param_interoceptive_z}{z-score of interoceptive salience from Lancaster Sensorimotor Norms}
#'   \item{Param_visual_z}{z-score of visual salience from Lancaster Sensorimotor Norms}
#'   \item{Param_olfactory_z}{z-score of olfactory salience from Lancaster Sensorimotor Norms}
#'   \item{Param_handarm_z}{z-score of handarm motor salience from Lancaster Sensorimotor Norms}
#'   \item{Param_excitement_z}{z-score of excitement salience from affectvec}
#'   \item{Param_surprised_z}{z-score of surprise salience from affectvec}
#'   \item{Param_fear_z}{z-score of fear salience from affectvec}
#'   \item{Param_anger_z}{z-score of anger salience from affectvec}
#'   \item{Param_disgust_z}{z-score of disgust salience from affectvec}
#'   \item{Param_sadness_z}{z-score of sadness salience from affectvec}
#'   \item{Param_happiness_z}{z-score of happiness salience from affectvec}
#'   \item{Param_contempr_z}{z-score of contempt salience from affectvec}
#'   ...
#' }
'SD15_2025_complete'


#' Stopword List
#'
#' List of stopwords
#'
#' @format ## "Temple_stops25"
#' A data frame with 829 observations of 4 variables
#' \describe{
#'   \item{id_orig}{numeric identifier}
#'   \item{word}{stopword target}
#'   \item{length}{length in words}
#'   \item{pos}{universal part-of-speech tag}
#'   ...
#' }
'Temple_stops25'

