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

test_that("dataset_bert_pretrained fails with bad input.", {
  original_data <- data.frame(
    x1 = c("Some text", "More text"),
    x2 = c("Still more", "Also another"),
    result = factor(c("a", "b"))
  )
  predictors <- dplyr::select(original_data, x1, x2)
  outcome <- dplyr::select(original_data, result)

  # Bad input data.
  expect_error(
    dataset_bert_pretrained(
      x = data.frame(a = 1:10, b = 1:10),
      y = outcome$result
    ),
    "is not TRUE"
  )
  expect_error(
    dataset_bert_pretrained(predictors, as.character(outcome$result)),
    class = "bad_outcome"
  )
})

test_that("dataset_bert_pretrained can tokenize after initialization.", {
  original_data <- data.frame(
    x1 = c("Some text", "More text"),
    x2 = c("Still more", "Also another"),
    result = factor(c("a", "b"))
  )
  predictors <- dplyr::select(original_data, x1, x2)
  outcome <- dplyr::select(original_data, result)

  data_separate <- dataset_bert_pretrained(predictors, outcome)
  expect_length(data_separate, 2)
  expect_error(
    data_separate$.getitem(1),
    "To tokenize, we need both `tokenizer_scheme` and `n_tokens`"
  )

  # Tokenization errors.
  expect_error(
    data_separate$tokenize("bad_scheme"),
    "Unsupported tokenizer_scheme: bad_scheme"
  )
  expect_error(
    data_separate$tokenize("bert_en_uncased"),
    "n_tokens is missing"
  )
  expect_error(
    data_separate$tokenize(1L),
    "`tokenizer_scheme` must be a length-1 character"
  )
  expect_error(
    data_separate$tokenize("bert_en_uncased", 10000),
    "10000 > "
  )
  expect_error(
    data_separate$tokenize("bert_en_uncased", 1.1),
    "`n_tokens` should be a length-1 integer"
  )
  expect_error(
    data_separate$tokenize("bert_en_uncased", NULL),
    "`n_tokens` cannot be NULL"
  )
  expect_error(
    data_separate$tokenize(NULL, 10),
    "`tokenizer_scheme` cannot be NULL"
  )

  expect_true(data_separate$tokenize("bert_en_uncased", 10L))

  # And it should be true if we retry, too.
  expect_true(data_separate$tokenize("bert_en_uncased", 10L))

  # And then it will fail for different settings.
  expect_error(
    data_separate$tokenize("bert_en_cased", 10L),
    "bert_en_uncased, not bert_en_cased"
  )
  expect_error(
    data_separate$tokenize("bert_en_uncased", 100L),
    "10, not 100"
  )

  # Do snapshots at the end to avoid confusing coverage.
  expect_snapshot(data_separate)
  expect_snapshot(data_separate$.getitem(1))
})

test_that("dataset_bert_pretrained can partially set tokenization info.", {
  original_data <- data.frame(
    x1 = c("Some text", "More text"),
    x2 = c("Still more", "Also another"),
    result = factor(c("a", "b"))
  )
  predictors <- dplyr::select(original_data, x1, x2)
  outcome <- dplyr::select(original_data, result)

  data_with_scheme <- dataset_bert_pretrained(
    predictors,
    outcome,
    tokenizer_scheme = "bert_en_uncased"
  )
  expect_length(data_with_scheme, 2)
  expect_error(
    data_with_scheme$.getitem(1),
    "To tokenize, we need both `tokenizer_scheme` and `n_tokens`"
  )

  # Tokenization errors.
  expect_error(
    data_with_scheme$tokenize("bert_en_uncased"),
    "n_tokens is missing"
  )

  # Note that it actually changes the tokenization scheme.
  expect_true(data_with_scheme$tokenize("bert_en_cased", 10L))

  # And still returns TRUE on a second run.
  expect_true(data_with_scheme$tokenize("bert_en_cased", 10L))

  # And then it will fail for different settings.
  expect_error(
    data_with_scheme$tokenize("bert_en_uncased", 10L),
    "bert_en_cased, not bert_en_uncased"
  )
  expect_error(
    data_with_scheme$tokenize("bert_en_cased", 100L),
    "10, not 100"
  )

  # Do snapshots at the end to avoid confusing coverage.
  expect_snapshot(data_with_scheme)
  expect_snapshot(data_with_scheme$.getitem(1))
})

test_that("dataset_bert_pretrained can do it all in one go.", {
  original_data <- data.frame(
    x1 = c("Some text", "More text"),
    x2 = c("Still more", "Also another"),
    result = factor(c("a", "b"))
  )
  predictors <- dplyr::select(original_data, x1, x2)
  outcome <- dplyr::select(original_data, result)

  data_tokenized <- dataset_bert_pretrained(
    predictors,
    outcome,
    tokenizer_scheme = "bert_en_uncased",
    n_tokens = 10L
  )

  expect_length(data_tokenized, 2)
  expect_error(
    data_tokenized$.getitem(1),
    NA
  )

  # And then it will fail for different settings.
  expect_error(
    data_tokenized$tokenize("bert_en_cased", 10L),
    "bert_en_uncased, not bert_en_cased"
  )
  expect_error(
    data_tokenized$tokenize("bert_en_uncased", 100L),
    "10, not 100"
  )

  # Do snapshots at the end to avoid confusing coverage.
  expect_snapshot(data_tokenized)
  expect_snapshot(data_tokenized$.getitem(1))
})
