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

test_that("proj_add_norm module works", {
  n_in <- 5L
  n_out <- 3L

  # get "random" values for inputs and weights
  RNGkind(kind = "Mersenne-Twister")
  set.seed(23)
  inv1 <- matrix(sample(1:10, size = n_in, replace = TRUE) / 10,
    nrow = 1, ncol = n_in
  )
  inv2 <- matrix(sample(1:10, size = n_out, replace = TRUE) / 10,
    nrow = 1, ncol = n_out
  )

  dm <- matrix(sample(1:10, size = n_in * n_out, replace = TRUE) / 10,
    nrow = n_in, ncol = n_out
  )
  bias <- array(sample(1:10, size = n_out, replace = TRUE) / 10, dim = n_out)
  gamma <- array(sample(1:10, size = n_out, replace = TRUE) / 10, dim = n_out)
  beta <- array(sample(1:10, size = n_out, replace = TRUE) / 10, dim = n_out)

  test_model <- proj_add_norm(input_size = n_in, output_size = n_out)
  wts <- test_model$state_dict()
  in1 <- torch::torch_tensor(inv1)
  in2 <- torch::torch_tensor(inv2)

  # set weights
  wts$dense.weight <- torch::torch_tensor(t(dm))
  wts$dense.bias <- torch::torch_tensor(bias)
  wts$layer_norm.weight <- torch::torch_tensor(gamma)
  wts$layer_norm.bias <- torch::torch_tensor(beta)

  test_model$load_state_dict(wts)
  test_model$eval()

  test_result <- test_model(in1, in2)
  # these results were validated using RBERT/tf2
  expected_result <- array(c(-0.2365, 0.7227, 0.3705), dim = c(1, 3))

  testthat::expect_equal(torch::as_array(test_result),
    expected_result,
    tolerance = 0.0001
  )
})
