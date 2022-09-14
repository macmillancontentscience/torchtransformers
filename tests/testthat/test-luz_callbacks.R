test_that("luz callback works.", {
  # This actually also tests the full fit procedure for something based on a
  # pretrained bert.
  skip_if_not_installed("luz")

  predictors <- original_data <- data.frame(
    x1 = c("Some text", "More text"),
    x2 = c("Still more", "Also another")
  )
  outcome <- factor(c("a", "b"))

  simple_dataset <- dataset_bert_pretrained(predictors, outcome)

  simplish_model <- torch::nn_module(
    "entailment_classifier",
    initialize = function() {
      bert_type <- "bert_tiny_uncased"
      embedding_size <- config_bert(bert_type, "embedding_size")
      self$bert <- model_bert_pretrained(bert_type)
      # After pooled bert output, do a final dense layer.
      self$linear <- torch::nn_linear(
        in_features = embedding_size,
        out_features = 2L
      )
    },
    forward = function(x) {
      output <- self$bert(x)

      # Take the output embeddings from the last layer.
      output <- output$output_embeddings
      output <- output[[length(output)]]
      # Take the [CLS] token embedding for classification.
      output <- output[ , 1, ]
      # Apply the last dense layer to the pooled output.
      output <- self$linear(output)
      return(output)
    }
  )

  setted <- luz::setup(
    module = simplish_model,
    loss = torch::nn_cross_entropy_loss(),
    optimizer = torch::optim_adam,
    metrics = list(
      luz::luz_metric_accuracy()
    )
  )

  # Setting seed twice to see if that impacts the torch bug.
  set.seed(1234L)
  torch::torch_manual_seed(1234L)
  set.seed(1234L)
  torch::torch_manual_seed(1234L)

  expect_message(
    {
      fitted <- luz::fit(
        setted,
        simple_dataset,
        epochs = 1,
        callbacks = list(
          luz_callback_bert_tokenize("bert")
        )
      )
    },
    "Confirming train_data tokenization"
  )

  # Times can change.
  fitted$records$profile <- NULL

  expect_snapshot(fitted)

  expect_message(
    {
      set.seed(1234L)
      torch::torch_manual_seed(1234L)
      predicted <- predict(
        fitted,
        simple_dataset,
        callbacks = list(
          luz_callback_bert_tokenize("bert")
        )
      )
    },
    "Confirming prediction data tokenization"
  )

  predicted <- torch::as_array(predicted$cpu())

  expect_equal(
    predicted,
    matrix(
      c(
        0.440626859664917,
        -0.153290539979935,
        -0.357242047786713,
        -0.288346469402313
      ),
      2, 2
    ),
    tolerance = 0.0001
  )

  expect_snapshot(
    luz_callback_bert_tokenize()
  )
  expect_snapshot(
    luz_callback_bert_tokenize(submodel_name = "bert")
  )
  expect_snapshot(
    luz_callback_bert_tokenize(n_tokens = 32L)
  )
  expect_snapshot(
    luz_callback_bert_tokenize(verbose = FALSE)
  )
})
