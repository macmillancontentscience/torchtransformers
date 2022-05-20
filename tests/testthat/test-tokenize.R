test_that("simplify_bert_token_list returns expected dimensions", {
  test_result <- simplify_bert_token_list(
    list(
      1:3,
      2:4
    )
  )

  # Directly test dimensions to get a clean report if that's the issue.
  expect_identical(dim(test_result), c(2L, 3L))

  # Also include a snapshot in case anything unexpected is happening.
  expect_snapshot(test_result)
})

test_that("increment_list_index does what it says", {
  # This one shouldn't require that things already be padded.
  expect_snapshot(
    increment_list_index(
      list(
        1:3,
        2:6
      )
    )
  )
})

test_that("tokenize_bert returns data in the expected shapes", {
  to_tokenize <- c(
    "An example with quite a few tokens.",
    "A short example.",
    "Another one."
  )
  expect_snapshot(
    tokenize_bert(
      text = to_tokenize,
      n_tokens = 6
    )
  )
  expect_snapshot(
    tokenize_bert(
      text = to_tokenize,
      n_tokens = 6,
      simplify = FALSE
    )
  )
  expect_snapshot(
    tokenize_bert(
      text = to_tokenize,
      n_tokens = 6,
      increment_index = FALSE
    )
  )
  expect_snapshot(
    tokenize_bert(
      text = to_tokenize,
      n_tokens = 6,
      simplify = FALSE,
      increment_index = FALSE
    )
  )
})
