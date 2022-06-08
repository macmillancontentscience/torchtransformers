test_that("dataset_bert works", {
  original_data <- data.frame(
    x1 = c("Some text", "More text"),
    x2 = c("Still more", "Also another"),
    result = factor(c("a", "b"))
  )
  # For the moment we're strict about the input; we deal with lots of different
  # input formats in tidybert.
  predictors <- dplyr::select(original_data, x1, x2)
  outcome <- dplyr::select(original_data, result)
  test_result <- dataset_bert(predictors, outcome)
  expect_snapshot(test_result)
  expect_snapshot(test_result$token_types)
  expect_snapshot(test_result$tokenized_text)
  expect_snapshot(test_result$y)

  test_result <- dataset_bert(predictors, outcome$result)
  expect_snapshot(test_result)
  expect_snapshot(test_result$token_types)
  expect_snapshot(test_result$tokenized_text)
  expect_snapshot(test_result$y)

  test_result <- dataset_bert(predictors, NULL)
  expect_snapshot(test_result)
  expect_snapshot(test_result$token_types)
  expect_snapshot(test_result$tokenized_text)
  expect_snapshot(test_result$y)

  test_result <- dataset_bert(predictors, outcome, n_tokens = 32)
  expect_snapshot(test_result)
  expect_snapshot(test_result$token_types)
  expect_snapshot(test_result$tokenized_text)
  expect_snapshot(test_result$y)
})
