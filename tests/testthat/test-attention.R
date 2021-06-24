test_that("attention module works", {
  emb_size <- 4L
  seq_len <- 3L
  n_head <- 2L

  test_model <- bert_attention(embedding_size = emb_size,
                               n_head = n_head)

  batch_size <- 1L

  # get "random" values for input and weights
  RNGkind(kind = "Mersenne-Twister")
  set.seed(23)
  test_input <- array(sample(-10:10,
                             size = batch_size*seq_len*emb_size,
                             replace = TRUE) / 10,
              dim = c(seq_len, batch_size, emb_size))
  aipw <- array(sample(-10:10, size = 3*emb_size*emb_size, replace = TRUE) / 10,
             dim = c(3*emb_size, emb_size))
  aipb <- array(sample(-10:10, size = 3*emb_size, replace = TRUE) / 10,
                dim = c(3*emb_size))
  aopw <- array(sample(-10:10, size = emb_size*emb_size, replace = TRUE) / 10,
                dim = c(emb_size, emb_size))
  aopb <- array(sample(-10:10, size = emb_size, replace = TRUE) / 10,
                   dim = c(emb_size))
  lnw  <- array(sample(-10:10, size = emb_size, replace = TRUE) / 10,
                dim = c(emb_size))
  lnb <- array(sample(-10:10, size = emb_size, replace = TRUE) / 10,
               dim = c(emb_size))

  wts <- test_model$state_dict()

  wts$attention.in_proj_weight <- torch::torch_tensor(aipw)
  wts$attention.in_proj_bias <- torch::torch_tensor(aipb)
  wts$attention.out_proj.weight <- torch::torch_tensor(aopw)
  wts$attention.out_proj.bias <- torch::torch_tensor(aopb)
  wts$layernorm.weight <- torch::torch_tensor(lnw)
  wts$layernorm.bias <- torch::torch_tensor(lnb)

  test_model$load_state_dict(wts)
  test_model$eval()

  test_input <- torch::torch_tensor(test_input)

  test_result <- test_model(test_input)

  as.vector(as.array(test_result[[2]]))
  # preliminary test results. Verify with full model eventually.
  expected_result_output <- array(c(-1.03503084, -0.97248346, -1.01456141,
                                    2.34950972, 2.42966652, 2.45326734,
                                    0.11602651, 0.32275218, 0.49853998,
                                    0.13793895, 0.12826201, 0.08730511),
                                  dim = c(3, 1, 4))
  testthat::expect_equal(torch::as_array(test_result[[1]]),
                         expected_result_output, tolerance = 0.0001)

  expected_result_attn <- array(c(0.3616562, 0.3253968, 0.3454985,
                                  0.3781769, 0.4125956, 0.2718856,
                                  0.3109135, 0.3329849, 0.1953470,
                                  0.3389427, 0.2031936, 0.3478628,
                                  0.3274302, 0.3416184, 0.4591545,
                                  0.2828803, 0.3842109, 0.3802516),
                                  dim = c(1, 2, 3, 3))
  testthat::expect_equal(torch::as_array(test_result[[2]]),
                         expected_result_attn, tolerance = 0.0001)
  # maybe add tests with masking later.

})
