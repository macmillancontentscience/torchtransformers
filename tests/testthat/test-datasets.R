test_that("dataset_bert implementation works", {
  # Include these as separate tests mostly to make sure coverage checks see that
  # we test them. It's also theoretically useful to separate these out to avoid
  # debugging issues with torch.
  original_data <- data.frame(
    x1 = c("Some text", "More text"),
    x2 = c("Still more", "Also another"),
    result = factor(c("a", "b"))
  )
  predictors <- dplyr::select(original_data, x1, x2)
  outcome <- dplyr::select(original_data, result)

  expect_error(
    .standardize_bert_dataset_outcome(as.character(outcome$result)),
    class = "bad_outcome"
  )

  test_result_df <- .standardize_bert_dataset_outcome(outcome)
  expect_identical(test_result_df, outcome$result)

  test_result_factor <- .standardize_bert_dataset_outcome(outcome$result)
  expect_identical(test_result_factor, outcome$result)

  test_result_null <- .standardize_bert_dataset_outcome(NULL)
  expect_null(test_result_null)
})

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

  expect_error(
    dataset_bert(predictors, as.character(outcome$result)),
    class = "bad_outcome"
  )

  test_result_df <- dataset_bert(predictors, outcome)
  expect_snapshot(test_result_df)
  expect_snapshot(test_result_df$token_types)
  expect_snapshot(test_result_df$tokenized_text)
  expect_snapshot(test_result_df$y)

  test_result_factor <- dataset_bert(predictors, outcome$result)
  expect_snapshot(test_result_factor)
  expect_snapshot(test_result_factor$token_types)
  expect_snapshot(test_result_factor$tokenized_text)
  expect_snapshot(test_result_factor$y)

  test_result_null <- dataset_bert(predictors, NULL)
  expect_snapshot(test_result_null)
  expect_snapshot(test_result_null$token_types)
  expect_snapshot(test_result_null$tokenized_text)
  expect_snapshot(test_result_null$y)

  test_result_tokens <- dataset_bert(predictors, outcome, n_tokens = 32)
  expect_snapshot(test_result_tokens)
  expect_snapshot(test_result_tokens$token_types)
  expect_snapshot(test_result_tokens$tokenized_text)
  expect_snapshot(test_result_tokens$y)
})
