---
title: 'SemanticDistance: An R package for Computing Semantic Distance in Structured Texts and Visualizing Clustering Properties in Unstructured Word Lists'

tags:
  - R
  - psychology
  - semantic memory
  - natural language processing
  - linguistics
  
authors:
  - name: Jamie Reilly
    orcid: 0000-0002-0891-438X
    equal-contrib: false
    corresponding: true
    affiliation: "1, 2"
    
  - name: Emily B. Myers
    orcid: 0000-0002-9475-764X
    equal-contrib: false
    corresponding: false
    affiliation: "3, 4"
    
  - name: Hannah Mechtenberg
    orcid: 0000-0003-1436-1846
    equal-contrib: false
    corresponding: false
    affiliation: 4
    
  - name: Jonathan E. Peelle
    orcid: 0000-0001-9194-854X
    equal-contrib: false
    corresponding: false
    affiliation: "5, 6, 7" # (Multiple affiliations must be quoted)
    
affiliations:
  - name: Department of Communication Sciences and Disorders, Temple University, United States
    index: 1
    
  - name: Department of Psychology and Neuroscience, Temple University, United States
    index: 2
    
  - name: Department of Speech, Language, and Hearing Sciences, University of Connecticut, United States
    index: 3
    
  - name: Department of Psychological Sciences, University of Connecticut, United States
    index: 4
    
  - name: Institute for Cognitive and Brain Health, Northeastern University, United States
    index: 5
    
  - name: Department of Communication Sciences and Disorders, Northeastern University, United States
    index: 6
    
  - name: Department of Psychology, Northeastern University, United States
    index: 7

date: "16 January 2026"
bibliography: paper.bib
funding: |
  R01 DC013063, R01 DC013064, R01 DC019507 from the US National Institutes of Health
output: rticles::joss_article 
---




# Summary
 `SemanticDistance` computes pairwise distance between units of language (e.g., word-to-word, ngram-to-word, turn-to-turn) in both structured language samples and unstructured word lists. `SemanticDistance` has cleaning and formatting options including stopword removal and lemmatization. The package computes two complementary cosine distance indices for each pairwise contrast of interest. `SemanticDistance` can also be used to examine clustering properties within unstructured word lists, generating dendrograms and simple igraph network plots.  
 
# Software Design
 `SemanticDistance` was is an open-source R package designed to accommodate a wide range of user expertise (e.g., neuroscience, linguistics, computer science). The software does not leverage artificial intelligence or use any proprietary dependencies. The package instead indexes an internal lookup database containing publicly available lexical norms.

# Statment of need
`SemanticDistance` is unique in its capacity to compute semantic distance metrics within running language samples (e.g., word-to-word, bigram-to-word) and to produce semantic network visualizations. The package also provides complementary (but different) semantic distance metrics (experiential vs. embedding) computed over the same stimuli. This package will support novel insights into the flow of meaning within naturalistic language samples.

# Research Impact Statement
 `SemanticDistance` has supported one peer-reviewed publication to date in the journal, `Cortex` [@Mechtenberg:2026] along with one refereed conference presentation at the annual conference of the Society for the Neurobiology of Language. The software is new, and broader impacts have yet to be realized.
 
# Description
`SemanticDistance` computes two complementary distance metrics between pairs of language chunks (e.g., words, ngrams, turns). Distance values are derived from two custom lookup databases containing semantic vectors for many English words.  \newline

`SemanticDistance` bundles text cleaning and formatting options (e.g., stopword removal, lemmatization) with distance and network visualization options. `SemanticDistance` is capable of generating rolling measures of semantic distance within stories or narratives where word order is conserved. The package is also capable of computing semantic distance turn-by-turn across speaker shifts within dyadic conversation transcripts. In addition to these ordered language formats, `SemanticDistance` is capable of producing distance metrics between word pairs arrayed in columns or between all pairs of words in an undifferentiated list. The package offers network visualization options (e.g., cluster dendrograms, igraph networks) that may prove useful in evaluating the structure and integrity of semantic networks as revealed by language  \newline

# AI Usage
`SemanticDistance` uses an internal database composed of many words with a fixed set of embeddings. The software does not use AI or rely on proprietary package dependencies. We did use GPT-4.0 (OpenAI) to troubleshoot R coding errors and assist with generating complex regular expressions (regex) used for cleaning text data. 

# References

