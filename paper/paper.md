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
    orcid: 0000-0000-0000-0000
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

date: " 2 September 2025"
bibliography: paper.bib
correspondence: jamie_reilly@temple.edu
abstract: |
 `SemanticDistance` is an R package that computes pairwise distance between constituents (e.g., word-to-word, ngram-to-word, turn-to-turn) in both structured language samples and unstructured word lists. `SemanticDistance` has cleaning and formatting options including stopword removal and lemmatization. The package computes two complementary cosine distance indices for each pairwise contrast of interest. `SemanticDistance` can also be used to examine clustering properties within unstructured word lists, generating dendrograms and simple igraph network plots illustrating relations among target words.  
keywords: |
  conversation analysis; discourse; language processing; alignment
authorcontributions: |
  JR, HM, EM, and JP conceived the software. All authors drafted and edited the paper.
funding: |
   This work was supported in part by grants R01 DC013063, R01 DC013064, and R01 DC019507 from the US National Institutes of Health. 
conflictsofinterest: |
  We have no known conflicts of interest.
output: rticles::joss_article 
keep_tex: true
csl: apa-single-spaced.csl
journal: JOSS
---




# Statment of Need
Although numerous R and Python packages process word embeddings, none to our knowledge is capable of computing distance metrics within running naturalistic language samples (e.g., one word to the next word in a dialogue or story). A deeper understanding of how the brain processes semantic relationships at different levels of granularity (e.g., word-to-word, sentence-to-word) may be critical for understanding integrative conceptual and linguistic processing. `SemanticDistance` will aid in these efforts by bundling text cleaning, distance computations, and simple network modeling within a single user-friendly resource. 

# Description
There are many ways to assess similarity between two concepts (represented as words) [@malt_words_2020]. Consider, for example, the case of a wildlife biologist interested in quantifying the distance between *wolf* and *dog* in terms of perceived threat to humans. How might she quantify this distance? One common approach might involve querying a representative sample of people and asking them to rate perceived threat of dogs and wolves via a Likert scale. The absolute value of the difference in threat ratings between dog vs wolf represents its distance within a one-dimensional semantic space constrained by threat. Although the true dimensionality of human semantic memory is unknowable, most contemporary approaches to modeling word meaning use high dimensional semantic spaces [@Landauer_LSA_1997,  @reilly_what_2025, @Pennington2014]. <br>

`SemanticDistance` computes two complementary (but different) distance metrics between pairs of constituents (e.g., words, ngrams, turns) as delineated by the user in optional arguments to the package's functions. These distance values are derived from two large databases containing  semantic vectors for >70k English words. `CosDist_Glo` reflects cosine distance between vectors derived from training a GLOVE word embedding model (300 hyperparameters per word) [@Pennington2014]. `CodDist_SD15` refects cosine distances derived from 15 dimension space reflecting meaningful salience across different sensorimotor and affective properties (e.g., How colorful is this?, How pleasant is this?, How loud is this?) [@Reilly2023]. Before using `SemanticDistance`, we recommend that doing some background research on what the distance metrics mean and how the functions should be optimized to produce the desired outcome. `SemanticDistance` processes distance relationships between lexical constituents within the following text formats: \newline

1: **monologues**: stories, narratives, and structured text where order matters. \newline
2: **dialogues**: two-person conversation transcripts. \newline
3: **word pairs in columns**: dog and leash arrayed in two columns. \newline
4: **unordered lists**: bags-of-words where order is irrelevant.  \newline

One advantage of the `SemanticDistance` package is that it bundles text cleaning and formatting options (e.g., stopword removal, lemmatization) with distance and network visualization options. Another useful feature of `SemanticDistance` is that it generates rolling measures of semantic distance within structured text. In structured texts like monologues (stories, narratives) and dialogues (two-person conversation transcripts), word order matters.  In contrast, unordered word lists can be thought of as non-continuous bags-of-words (e.g., a grocery list). `SemanticDistance` can run distance metrics on both of these formats with options for chunk size guided by the user. These various options are illustrated in the section to follow. \newline


# Examples of Distance Functions and Possible Applications
`SemanticDistance` features some of the following core functions. \newline

# Ngram-to-Word Distance 
Computes a rolling measure of semantic distance ngram-to-word across an ordered language sample (e.g.,monologues, stories, continuous structured language) (see Figure 1). This metric may be used to iteratively examine larger integrative chunks from each word to its prior local or global context. We recently used this measure to examine brain sensitivity to distance jumps during real-time narrative comprehension using fMRI [@mechtenberg_measuring_2025]. \newline

![Figure 1: Rolling ngram-to-word distance\label{fig:demo}](ngram-word.png){width=70%}
\vspace*{-0.5cm}
\newline

# Ngram-to-Ngram Distance (monologues, stories, continuous structured language) 
Computes a rolling measure of semantic distance ngram-to-ngram across an ordered language sample (see Figure 2). This metric may be used to examine semantic cohesion between smaller vs. larger chunks of words within linear narrative discourse. 
\newline

![Figure 2. Rolling ngram-to-ngram distance\label{fig:demo}](ngram-ngram.png){width=70%}
\vspace*{-0.5cm}
\newline

# Anchored Distance (monologues, stories, continuous structured language) 
Computes semantic distance iteratively for each new word in an ordered language sample (e.g., story, narrative) relative to the initial block of *n* content words (see Figure 3). Anchored distance can provide an empirical measure of semantic drift or topic variability over the course of a sample (e.g., started with sports, jumped to baking, then to politics). 
\newline


![Figure 3. Anchored distance first chunk to each new word or ngram\label{fig:demo}](anchor.png){width=70%}
\vspace*{-0.5cm}
\newline

# Turn-by-Turn Distance (2-person Dyads, Conversation Tramscripts)
Computes a rolling measure of semantic distance turn-to-turn in a conversation/dialogue transcript. Semantic vectors for all content words within one turn are averaged and grouped by speaker identity. The function then computes cosine distance between each speaker at each turn, yielding a fluctuating time series of distance changes by speaker. This measure could be used to assess lexical-semantic comprehension and alignment in naturalistic conversations.
\newline

# Word Pair Distance (user arrayed word pairs in columns)
Computes pairwise distance metrics row-wise between two specified target columns in a dataframe, This function is useful for stimulus norming or deriving distances for a specified set of non-continuous word pairs. 
\newline

# Finding structure in the chaos of an unstructured word list
`SemanticDistance` also includes several visualization options designed to elucidate structure within unstructured lists. The `wordlist_to_network` function takes a word list as an argument and derives cluster dendrograms (see Figure 4) or network plots (see Figure 5). For example, here's how it uses a simple machine learning algorithm to compute distances and cluster an unordered list of words. <br>
\newline

![Figure 4. Dendrogram from unordered list\label{fig:demo}](dendro.png){width=90%} 
\vspace*{-0.5cm}
\newline

![Figure 5. Semantic network of word list\label{fig:demo}](cluster.png){width=100%}
\vspace*{-0.5cm}
\newline

# References

