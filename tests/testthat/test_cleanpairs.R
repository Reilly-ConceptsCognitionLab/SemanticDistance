test_that("clean_paired_cols produces 'word1_clean' column", {
  # Apply cleaning function (ensure Monologue_Typical exists in environment)
  cleaned_data <- clean_paired_cols(Word_Pairs, wordcol1='word1', wordcol2='word2')

  # Test 1: Check column exists
  expect_true("word1_clean" %in% names(cleaned_data))

  # Test 2: Verify result is still a data frame
  expect_s3_class(cleaned_data, "data.frame")

})
