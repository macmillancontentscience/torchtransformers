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

test_that("the model_bert module works", {
  emb_size <- 64
  mpe <- 512
  n_head <- 4L
  n_layer <- 6L
  vocab_size <- 30522L
  test_model <- model_bert(
    embedding_size = emb_size,
    n_layer = n_layer,
    n_head = n_head,
    max_position_embeddings = mpe,
    vocab_size = vocab_size
  )

  n_inputs <- 2L
  n_token_max <- 128L
  # get random "ids" for input
  t_ids <- matrix(
    sample(
      2:vocab_size,
      size = n_token_max * n_inputs,
      replace = TRUE
    ),
    nrow = n_inputs,
    ncol = n_token_max
  )
  ttype_ids <- matrix(
    rep(1L, n_token_max * n_inputs),
    nrow = n_inputs,
    ncol = n_token_max
  )

  test_results <- test_model(
    torch::torch_tensor(t_ids),
    torch::torch_tensor(ttype_ids)
  )

  # for now, just testing that the output has the right shape
  expect_equal(length(test_results), 3L)
  expect_equal(
    dim(test_results[[1]]),
    c(n_inputs, n_token_max, emb_size)
  )
  expect_equal(length(test_results[[2]]), n_layer)
  expect_equal(
    dim(test_results[[2]][[1]]),
    c(n_inputs, n_token_max, emb_size)
  )

  expect_equal(length(test_results[[3]]), n_layer)
  expect_equal(
    dim(test_results[[3]][[1]]),
    c(n_inputs, n_head, n_token_max, n_token_max)
  )
})

test_that("we can prune head of torchtransformer model", {
  emb_size <- 128L
  mpe <- 512L
  n_head <- 4L
  n_layer <- 6L
  vocab_size <- 30522L
  n_inputs <- 2
  n_token_max <- 128L
  t_ids <- matrix(
    sample(
      2:vocab_size,
      size = n_token_max * n_inputs,
      replace = TRUE
    ),
    nrow = n_token_max, ncol = n_inputs
  )
  ttype_ids <- matrix(
    rep(1L, n_token_max * n_inputs),
    nrow = n_token_max, ncol = n_inputs
  )

  model <- model_bert(
    embedding_size = emb_size,
    n_layer = n_layer,
    n_head = n_head,
    max_position_embeddings = mpe,
    vocab_size = vocab_size
  )
  expect_error(prune <- torch::nn_prune_head(model), NA)
  output  <-  prune(
    torch::torch_tensor(t_ids),
    torch::torch_tensor(ttype_ids)

  )
  expect_equal(output$shape, c(128, 2, 128))

})

