test_that("the model_bert module works", {

  emb_size <- 64
  mpe <- 512
  n_head <- 4L
  n_layer <- 6L
  vocab_size <- 30522L
  test_model <- model_bert(embedding_size = emb_size,
                           n_layer = n_layer,
                           n_head = n_head,
                           max_position_embeddings = mpe,
                           vocab_size = vocab_size)

  n_inputs <- 2L
  n_token_max <- 128L
  # get random "ids" for input
  t_ids <- matrix(sample(2:vocab_size, size = n_token_max * n_inputs,
                         replace = TRUE),
                  nrow = n_token_max, ncol = n_inputs)
  ttype_ids <- matrix(rep(1L, n_token_max * n_inputs),
                      nrow = n_token_max, ncol = n_inputs)
  test_results <- test_model(torch::torch_tensor(t_ids),
        torch::torch_tensor(ttype_ids))

  # for now, just testing that the output has the right shape
  testthat::expect_equal(length(test_results), 3L)
  testthat::expect_equal(dim(test_results[[1]]),
                         c(n_token_max, n_inputs, emb_size))
  testthat::expect_equal(length(test_results[[2]]), n_layer)
  testthat::expect_equal(dim(test_results[[2]][[1]]),
                         c(n_token_max, n_inputs, emb_size))

  testthat::expect_equal(length(test_results[[3]]), n_layer)
  testthat::expect_equal(dim(test_results[[3]][[1]]),
                         c(n_inputs, n_head, n_token_max, n_token_max))

})
