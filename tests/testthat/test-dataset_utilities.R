# Copyright 2022 Bedford Freeman & Worth Pub Grp LLC DBA Macmillan Learning.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

test_that("dataset predictor standardization works.", {
  x1 <- c("Some text", "More text")
  x2 <- c("Still more", "Also another")
  pred_df1 <- data.frame(x = x1)
  pred_df2 <- data.frame(
    x1 = x1,
    x2 = x2
  )
  pred_list <- list(
    x1 = x1,
    x2 = x2
  )
  pred_matrix <- as.matrix(pred_df2)

  expect_identical(
    .standardize_bert_dataset_predictors(pred_df2),
    pred_df2
  )
  expect_identical(
    .standardize_bert_dataset_predictors(pred_list),
    pred_df2
  )
  expect_identical(
    .standardize_bert_dataset_predictors(pred_matrix),
    pred_df2
  )

  expect_identical(
    .standardize_bert_dataset_predictors(x1),
    pred_df1
  )

  expect_error(
    .standardize_bert_dataset_predictors(1:10),
    "integer",
    class = "bad_predictors"
  )
  expect_error(
    .standardize_bert_dataset_predictors(NULL),
    "NULL",
    class = "bad_predictors"
  )
  expect_error(
    .standardize_bert_dataset_predictors(1.1),
    "numeric",
    class = "bad_predictors"
  )
})

test_that("dataset outcome standardization works.", {
  outcome <- factor(c("a", "b"))
  outcome_df <- data.frame(result = factor(c("a", "b")))

  expect_identical(
    .standardize_bert_dataset_outcome(outcome),
    outcome
  )
  expect_identical(
    .standardize_bert_dataset_outcome(outcome_df),
    outcome
  )
  expect_identical(
    .standardize_bert_dataset_outcome(outcome_df$result),
    outcome
  )

  outcome <- 1:10
  outcome_df <- data.frame(result = outcome)

  expect_identical(
    .standardize_bert_dataset_outcome(outcome),
    outcome
  )
  expect_identical(
    .standardize_bert_dataset_outcome(outcome_df),
    outcome
  )

  expect_null(
    .standardize_bert_dataset_outcome(NULL)
  )

  expect_error(
    .standardize_bert_dataset_outcome(as.character(outcome)),
    class = "bad_outcome"
  )
})

test_that("Tokenizer validations functions work.", {
  expect_identical(
    .validate_tokenizer_metadata("bert_tiny_uncased"),
    list(tokenizer_scheme = "bert_en_uncased", n_tokens = 512L)
  )
})

