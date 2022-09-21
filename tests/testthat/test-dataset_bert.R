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

test_that("dataset_bert works", {
  original_data <- data.frame(
    x1 = c("Some text", "More text"),
    x2 = c("Still more", "Also another"),
    result = factor(c("a", "b"))
  )
  predictors <- dplyr::select(original_data, x1, x2)
  outcome <- dplyr::select(original_data, result)

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
