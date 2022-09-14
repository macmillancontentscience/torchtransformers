test_that("Tokenization checker works.", {
  predictors <- data.frame(
    x1 = c("Some text", "More text"),
    x2 = c("Still more", "Also another")
  )
  outcome <- factor(c("a", "b"))

  expect_error(
    .check_tokenization(predictors),
    "Tokenization is not implemented for class data\\.frame"
  )

  data_tokenized <- dataset_bert_pretrained(
    predictors,
    outcome,
    tokenizer_scheme = "bert_en_uncased",
    n_tokens = 10L
  )
  tiny_bert_model <- model_bert_pretrained("bert_tiny_uncased")
  expect_true(.check_tokenization(data_tokenized, tiny_bert_model))

  data_tokenized_dl <- torch::dataloader(data_tokenized, batch_size = 2)
  expect_true(.check_tokenization(data_tokenized_dl, tiny_bert_model))

  data_tokenized_subset <- torch::dataset_subset(data_tokenized, 2)
  expect_true(.check_tokenization(data_tokenized_subset, tiny_bert_model))

  vanilla_constructor <- torch::dataset(
    "minimal",
    initialize = function() {
      self$data <- torch::torch_tensor(1:5)
    },
    .length = function() {
      self$data$size()[[1]]
    }
  )
  vanilla_ds <- vanilla_constructor()
  expect_error(
    .check_tokenization(vanilla_ds, tiny_bert_model),
    "must be prepared using"
  )

  data_tokenized_bad <- dataset_bert_pretrained(
    predictors,
    outcome,
    tokenizer_scheme = "bert_en_cased",
    n_tokens = 10L
  )

  expect_error(
    .check_tokenization(data_tokenized_bad, tiny_bert_model),
    "bert_en_cased, not bert_en_uncased"
  )
})

test_that("config_bert works as expected", {
  expect_error(
    config_bert("not_a_model", "embedding_size"),
    class = "bad_bert_type"
  )
  expect_error(
    config_bert(letters, "embedding_size"),
    class = "bad_bert_type"
  )

  expect_identical(
    config_bert("bert_tiny_uncased", "n_head"),
    2L
  )
  expect_identical(
    config_bert("bert_medium_uncased", "max_tokens"),
    512L
  )
})

test_that("Pretrained lookup functions error as expected.", {
  expect_error(
    .get_token_vocab("fake"),
    "unrecognized vocabulary: fake"
  )
  expect_error(
    .get_tokenizer("morphemepiece"),
    "morphemepiece tokenizer not yet supported"
  )
  expect_error(
    .get_tokenizer("sentencepiece"),
    "sentencepiece tokenizer not yet supported"
  )
  expect_error(
    .get_tokenizer("other"),
    "unrecognized tokenizer: other"
  )
  expect_error(
    .get_tokenizer_name("fake"),
    "Unsupported tokenizer_scheme: fake"
  )
})

test_that("Weights process as expected.", {
  # I constructed the dataset for this by downloading the raw bert-tiny-uncased
  # weights and choping most things out to get a minimal file to start from. For
  # simplicity we still start *after* the python weights are already loaded, so
  # we skip the actual processing function.
  state_dict <- torch::torch_load(
    testthat::test_path("minimal_sd.rds")
  )
  expect_snapshot(.concatenate_qkv_weights(state_dict))
  expect_snapshot(.rename_state_dict_variables(state_dict))
})
