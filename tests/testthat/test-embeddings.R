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

test_that("position embedding module works", {
  emb_size <- 3L
  mpe <- 2L

  # get "random" values for weights
  RNGkind(kind = "Mersenne-Twister")
  set.seed(23)
  dm <- matrix(
    sample(1:10, size = mpe * emb_size, replace = TRUE) / 10,
    nrow = emb_size, ncol = mpe
  )

  test_model <- position_embedding(
    embedding_size = emb_size,
    max_position_embeddings = mpe
  )

  wts <- test_model$state_dict()

  # set weights
  wts$weight <- torch::torch_tensor(t(dm))

  test_model$load_state_dict(wts)
  test_model$eval()

  test_result <- test_model(1)
  expected_result <- array(c(0.8, 0.3, 0.8), dim = c(1, 1, 3))
  expect_equal(
    torch::as_array(test_result),
    expected_result,
    tolerance = 0.0001
  )

  test_result <- test_model()
  expected_result <- array(c(0.8, 0.9, 0.3, 0.7, 0.8, 0.2), dim = c(1, 2, 3))
  expect_equal(
    torch::as_array(test_result),
    expected_result,
    tolerance = 0.0001
  )
})


test_that("embeddings_bert module works", {
  emb_size <- 3L
  mpe <- 5L
  vocabulary_size <- 7L

  n_inputs <- 1L
  # If inputs are smaller than max position embedding, it will cut off the
  # position embedding.
  cutoff <- 3L

  # get "random" values for input and weights
  RNGkind(kind = "Mersenne-Twister")
  set.seed(23)
  t_ids <- matrix(
    sample(2:vocabulary_size, size = cutoff * n_inputs, replace = TRUE),
    nrow = n_inputs, ncol = cutoff
  )
  ttype_ids <- matrix(
    rep(1L, cutoff * n_inputs),
    nrow = n_inputs, ncol = cutoff
  )

  wew <- matrix(
    sample(1:10, size = vocabulary_size * emb_size, replace = TRUE) / 10,
    nrow = emb_size, ncol = vocabulary_size
  )
  ttew <- matrix(
    sample(1:10, size = 2 * emb_size, replace = TRUE) / 10,
    nrow = emb_size, ncol = 2
  )
  pepe <- matrix(
    sample(1:10, size = mpe * emb_size, replace = TRUE) / 10,
    nrow = emb_size, ncol = mpe
  )
  lnw <- array(
    sample(1:10, size = emb_size, replace = TRUE) / 10,
    dim = emb_size
  )
  lnb <- array(
    sample(1:10, size = emb_size, replace = TRUE) / 10,
    dim = emb_size
  )


  test_model <- embeddings_bert(
    embedding_size = emb_size,
    max_position_embeddings = mpe,
    vocab_size = vocabulary_size
  )
  wts <- test_model$state_dict()
  t_ids <- torch::torch_tensor(t_ids)
  ttype_ids <- torch::torch_tensor(ttype_ids)

  # set weights
  wts$word_embeddings.weight <- torch::torch_tensor(t(wew))
  wts$token_type_embeddings.weight <- torch::torch_tensor(t(ttew))
  wts$position_embeddings.weight <- torch::torch_tensor(t(pepe))
  wts$layer_norm.weight <- torch::torch_tensor(lnw)
  wts$layer_norm.bias <- torch::torch_tensor(lnb)

  test_model$load_state_dict(wts)
  test_model$eval()

  test_result <- test_model(
    token_ids = t_ids,
    token_type_ids = ttype_ids
  )

  expected_result <- array(
    c(
      0.11484, -0.09223, 0.84912,
      1.17775, 1.17456, 0.82155,
      0.11484, 0.22155, 0.10388
    ),
    dim = c(1, 3, 3)
  )
  expect_equal(
    torch::as_array(test_result),
    expected_result,
    tolerance = 0.0001
  )
})
