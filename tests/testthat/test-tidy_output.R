# Copyright 2021 Bedford Freeman & Worth Pub Grp LLC DBA Macmillan Learning.
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

test_that("output tidiers work", {
  # once we have tokenizers living somewhere, we won't have to define manually
  tokenized_text <- list(
    c("[CLS]" = 102, "input" = 7954, "one" = 2029, "[SEP]" = 103, "[PAD]" = 1),
    c("[CLS]" = 102, "input" = 7954, "two" = 2049, "[SEP]" = 103, "[PAD]" = 1)
  )

  token_input <- torch::torch_tensor(array(unlist(tokenized_text),
                                           dim = c(5,2)),
                                     dtype = torch::torch_int())
  tt <- torch::torch_tensor(array(1, dim = c(5,2)), dtype = torch::torch_int())

  tiny_bert_model <- make_and_load_bert("bert_tiny_uncased")

  tiny_bert_model$eval()
  test_results <- tiny_bert_model(token_input, tt)

  tidy_attention <- tidy_attention_output(test_results, tokenized_text)
  tidy_embeddings <- tidy_embeddings_output(test_results, tokenized_text)

  # Results have been manually verified against RBERT. Note that there are
  # slight numerical differences (presumably due to rounding) that can
  # accumulate. Attention weights agree to ~6 decimal places in the first layer,
  # but only to ~3 places by the 12th layer. This is probably not a problem for
  # most applications, but it may become significant when comparing larger
  # models. I am not sure how much of the discrepancy is due to torch/TF
  # libraries, and how much is due to model/layer implementation in
  # torchtransformers.

  # we'll check numbers at the beginning and end of each data frame.
  test_head <- head(tidy_attention$attention_weight)
  expected_head <- c(0.539674, 0.337973, 0.046812, 0.075540, 0.004252, 0.988340)
  testthat::expect_equal(test_head, expected_head, tolerance = 0.0001)

  test_tail <- tail(tidy_attention$attention_weight)
  expected_tail <- c(0.127517, 0.568830, 0.209703, 0.003901, 0.137183, 0.649210)
  testthat::expect_equal(test_tail, expected_tail, tolerance = 0.0001)

  test_head <- head(tidy_embeddings$V1)
  expected_head <- c(0.79733, -1.63882, -1.33924, -2.96737, -0.23281, -2.83020)
  testthat::expect_equal(test_head, expected_head, tolerance = 0.0001)

  test_tail <- tail(tidy_embeddings$V1)
  expected_tail <- c(-0.47954, -2.73564, -0.60780, -1.86034, -0.76254, -2.08767)
  testthat::expect_equal(test_tail, expected_tail, tolerance = 0.0001)
})
