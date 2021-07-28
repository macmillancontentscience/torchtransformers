test_that("pre-trained bert works", {
  tiny_bert_model <- make_and_load_bert("bert_tiny_uncased")

  n_inputs <- 1
  n_token_max <- 128L

  RNGkind(kind = "Mersenne-Twister")
  set.seed(23)

  # generate some "random" input, including [PAD] tokens.
  token_ids <- matrix(c(sample(2:10, size = n_token_max - 100, replace = TRUE),
                        rep(1L, 100)),
                      nrow = n_token_max, ncol = 1)
  token_type_ids <- matrix(rep(1L, n_token_max), nrow = n_token_max, ncol = 1)


  tiny_bert_model$eval()
  test_results <- tiny_bert_model(torch::torch_tensor(token_ids),
                                  torch::torch_tensor(token_type_ids))

  # check initial embeddings
  test_init_emb <- test_results$initial_embeddings[1:3, 1, 1:3]
  # these results were validated using RBERT/tf2
  expected_result <- t(array(c(0.5446903, 0.07125717, -5.4782972,
                             -0.8838950, -0.36615837, -0.6784807,
                             -1.3416783, -0.01943891, -0.2987145),
                           dim = c(3, 3)))

  testthat::expect_equal(torch::as_array(test_init_emb),
                         expected_result, tolerance = 0.0001)

  # check final embeddings
  test_final_emb <- test_results$output_embeddings[[2]][1:3, 1, 1:3]
  # these results were validated using RBERT/tf2
  expected_result <- t(array(c(-0.7875152, -0.1695986, -2.8418319,
                               -1.6072146, -0.1021989, -0.7384009,
                               -1.4035270, -0.4185355, -0.7933679),
                             dim = c(3, 3)))

  testthat::expect_equal(torch::as_array(test_final_emb),
                         expected_result, tolerance = 0.0001)

  # check attention weights
  test_att_wts <- test_results$attention_weights[[2]][1, 1, 1:3, 1:3]
  # these results were validated using RBERT/tf2
  expected_result <- t(array(c(0.04766777, 0.0387264, 0.02898057,
                               0.06037212, 0.4090807, 0.03938726,
                               0.03232013, 0.4658996, 0.28688604),
                             dim = c(3, 3)))

  testthat::expect_equal(torch::as_array(test_att_wts),
                         expected_result, tolerance = 0.0001)

})
