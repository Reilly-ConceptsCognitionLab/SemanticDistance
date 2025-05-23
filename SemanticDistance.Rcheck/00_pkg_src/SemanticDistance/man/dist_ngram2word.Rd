% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dist_ngram2word.R
\name{dist_ngram2word}
\alias{dist_ngram2word}
\title{dist_ngram2word}
\usage{
dist_ngram2word(dat, ngram)
}
\arguments{
\item{dat}{a dataframe prepped using 'clean_monologue' fn}

\item{ngram}{an integer specifying the window size of words for computing distance to a target word will go back skipping NAs until content words equals the ngram window}
}
\value{
a dataframe
}
\description{
Function takes dataframe cleaned using 'clean_monologue', computes two metrics of semantic distance for each word relative to the average of the semantic vectors within an n-word window appearing before each word. User specifies the window (ngram) size. The window 'rolls' across the language sample providing distance metrics
}
