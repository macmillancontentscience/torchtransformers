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
      text = as.list(to_tokenize),
      n_tokens = 6
    )
  )
  expect_snapshot(
    tokenize_bert(
      text = to_tokenize,
      n_tokens = 6,
      increment_index = FALSE
    )
  )
})

test_that("tokenizing works for 2-segment sequences", {
  to_tokenize <- c(
    "This is a sample sentence.",
    "This is another, longer sample sentence."
  )

  # 6 tokens, 8 tokens.

  expect_snapshot(
    tokenize_bert(
      to_tokenize,
      to_tokenize
    )
  )
  expect_snapshot(
    tokenize_bert(
      to_tokenize,
      to_tokenize,
      n_tokens = 11
    )
  )
  expect_snapshot(
    tokenize_bert(
      to_tokenize,
      to_tokenize,
      n_tokens = 10
    )
  )
  expect_snapshot(
    tokenize_bert(
      to_tokenize,
      rev(to_tokenize),
      n_tokens = 10
    )
  )
  expect_snapshot(
    tokenize_bert(
      to_tokenize,
      rev(to_tokenize),
      n_tokens = 11
    )
  )
})

test_that("tokenizing bad things doesn't work", {
  expect_error(
    tokenize_bert(1:5),
    class = "bad_text_to_tokenize"
  )

  expect_error(
    tokenize_bert(
      list(a = letters, b = letters)
    ),
    class = "tokenize_list_of_sequences"
  )

  to_tokenize <- c(
    "An example with quite a few tokens.",
    "A short example.",
    "Another one."
  )

  expect_error(
    tokenize_bert(
      to_tokenize,
      pad_token = "BADTOKEN"
    ),
    regexp = "must be in vocab"
  )
  expect_error(
    tokenize_bert(
      to_tokenize,
      cls_token = "BADTOKEN"
    ),
    regexp = "must be in vocab"
  )
  expect_error(
    tokenize_bert(
      to_tokenize,
      pad_token = "BADTOKEN"
    ),
    regexp = "must be in vocab"
  )

  expect_error(
    tokenize_bert(
      to_tokenize,
      to_tokenize,
      to_tokenize
    ),
    regexp = "at most 2 segments"
  )

  expect_error(

  )
})
