test_that("position embedding module works", {
  emb_size <- 3L
  mpe <- 2L

  # get "random" values for and weights
  set.seed(23)
  dm <- matrix(sample(1:10, size = mpe * emb_size, replace = TRUE) / 10,
               nrow = emb_size, ncol = mpe)

  test_model <- position_embedding(embedding_size = emb_size,
                                   max_position_embeddings = mpe)

  wts <- test_model$state_dict()

  # set weights
  wts$pos_emb <- torch::torch_tensor(t(dm))

  test_model$load_state_dict(wts)
  test_model$eval()

  test_result <- test_model(1)
  expected_result <- array(c(0.8, 0.3, 0.8), dim = c(1, 1, 3))
  testthat::expect_equal(torch::as_array(test_result),
                         expected_result, tolerance = 0.0001)

  test_result <- test_model()
  expected_result <- array(c(0.8, 0.9, 0.3, 0.7, 0.8, 0.2), dim = c(2, 1, 3))
  testthat::expect_equal(torch::as_array(test_result),
                         expected_result, tolerance = 0.0001)
})


