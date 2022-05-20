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

test_that("attention module works", {
  emb_size <- 4L
  seq_len <- 3L
  n_head <- 2L

  test_model <- attention_bert(
    embedding_size = emb_size,
    n_head = n_head
  )

  batch_size <- 1L

  # get "random" values for input and weights
  RNGkind(kind = "Mersenne-Twister")
  set.seed(23)
  test_input <- array(
    sample(
      -10:10,
      size = batch_size * seq_len * emb_size,
      replace = TRUE
    ) / 10,
    dim = c(seq_len, batch_size, emb_size)
  )
  aipw <- array(
    sample(-10:10,
           size = 3 * emb_size * emb_size,
           replace = TRUE
    ) / 10,
    dim = c(3 * emb_size, emb_size)
  )
  aipb <- array(
    sample(-10:10, size = 3 * emb_size, replace = TRUE) / 10,
    dim = c(3 * emb_size)
  )
  aopw <- array(
    sample(-10:10, size = emb_size * emb_size, replace = TRUE) / 10,
    dim = c(emb_size, emb_size)
  )
  aopb <- array(sample(-10:10, size = emb_size, replace = TRUE) / 10,
    dim = c(emb_size)
  )
  lnw <- array(
    sample(-10:10, size = emb_size, replace = TRUE) / 10,
    dim = c(emb_size)
  )
  lnb <- array(
    sample(-10:10, size = emb_size, replace = TRUE) / 10,
    dim = c(emb_size)
  )

  wts <- test_model$state_dict()

  wts$self.in_proj_weight <- torch::torch_tensor(aipw)
  wts$self.in_proj_bias <- torch::torch_tensor(aipb)
  wts$self.out_proj.weight <- torch::torch_tensor(aopw)
  wts$self.out_proj.bias <- torch::torch_tensor(aopb)
  wts$output.layer_norm.weight <- torch::torch_tensor(lnw)
  wts$output.layer_norm.bias <- torch::torch_tensor(lnb)

  test_model$load_state_dict(wts)
  test_model$eval()

  test_input <- torch::torch_tensor(test_input)
  # Reshape the test_input per the new standard. We should eventually do this
  # above, but I want to leave the original randomly generated thing as the
  # input first to make sure we come up with the same result (other than the
  # shape).
  test_input <- torch::torch_transpose(test_input, 1, 2)


  test_result <- test_model(test_input)

  # preliminary test results. Verify with full model eventually.
  expected_result_output <- array(
    c(
      -1.03503084, -0.97248346, -1.01456141,
      2.34950972, 2.42966652, 2.45326734,
      0.11602651, 0.32275218, 0.49853998,
      0.13793895, 0.12826201, 0.08730511
    ),
    dim = c(1, 3, 4)
  )
  expect_equal(
    torch::as_array(test_result[[1]]),
    expected_result_output,
    tolerance = 0.0001
  )

  expected_result_attn <- array(
    c(
      0.3616562, 0.3253968, 0.3454985,
      0.3781769, 0.4125956, 0.2718856,
      0.3109135, 0.3329849, 0.1953470,
      0.3389427, 0.2031936, 0.3478628,
      0.3274302, 0.3416184, 0.4591545,
      0.2828803, 0.3842109, 0.3802516
    ),
    dim = c(1, 2, 3, 3)
  )
  expect_equal(
    torch::as_array(test_result[[2]]),
    expected_result_attn,
    tolerance = 0.0001
  )
  # maybe add tests with masking later.
})
