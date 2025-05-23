% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dist_anchor.R
\name{dist_anchor}
\alias{dist_anchor}
\title{dist_anchor}
\usage{
dist_anchor(dat, anchor_size = 10)
}
\arguments{
\item{dat}{a dataframe prepped using 'clean_monologue' fn}

\item{anchor_size}{an integer specifying the number of words in the initial chunk for comparison to new words as the sample unfolds}
}
\value{
a dataframe
}
\description{
Function takes dataframe cleaned using 'clean_monologue', computes rolling chunk-to-chunk distance between user-specified ngram size (e.g., 2-word chunks)
}
