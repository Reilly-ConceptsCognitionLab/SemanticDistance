test_that("clean_dialogue produces 'word_clean' column", {
  # Apply cleaning function (ensure Monologue_Typical exists in environment)
  cleaned_data <- clean_dialogue(Dialogue_Typical, wordcol='mytext')

  # Test 1: Check column exists
  expect_true("word_clean" %in% names(cleaned_data))

  # Test 2: Verify result is still a data frame
  expect_s3_class(cleaned_data, "data.frame")

  # Test 3: Confirm non-empty output (optional safeguard)
  expect_gt(nrow(cleaned_data), 0)
})
