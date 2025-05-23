% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/clean_monologue.R
\name{clean_monologue}
\alias{clean_monologue}
\title{clean_monologue}
\usage{
clean_monologue(
  dat,
  wordcol,
  clean = TRUE,
  omit_stops = TRUE,
  lemmatize = TRUE,
  split_strings = TRUE
)
}
\arguments{
\item{dat}{a dataframe with at least one target column of string data}

\item{wordcol}{quoted column name storing the strings that will be cleaned and split}

\item{clean}{apply cleaning functions (lowercase etc) default is TRUE}

\item{omit_stops}{option for omitting stopwords default is TRUE}

\item{lemmatize}{option for lemmatizing strings default is TRUE}

\item{split_strings}{option T/F (default T) will split multiword utterances into separate rows}
}
\value{
a dataframe
}
\description{
Cleans and formats text. User specifies the dataframe and column name where target text is stored as arguments to the function. Default option is to lemmatize strings. Function splits and unlists text so that the output is in a one-row-per-word format marked by a unique numeric identifier (i.e., 'id_orig')
}
