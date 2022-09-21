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

# Known pretrained models ------------------------------------------------------

#' BERT Model Parameters
#'
#' Several parameters define a BERT model. This function can be used to easily
#' load them.
#'
#' @param bert_type Character scalar; the name of a known BERT model.
#' @param parameter Character scalar; the desired parameter.
#'
#' @return Integer scalar; the value of that parameter for that model.
#' @export
#'
#' @examples
#' config_bert("bert_medium_uncased", "n_head")
config_bert <- function(bert_type,
                        parameter = c(
                          "embedding_size",
                          "n_layer",
                          "n_head",
                          "max_tokens",
                          "vocab_size",
                          "tokenizer_scheme"
                        )) {
  if (length(bert_type) > 1) {
    rlang::abort(
      message = "Please provide a single model name.",
      class = "bad_bert_type"
    )
  }

  if (!(bert_type %in% available_berts())) {
    rlang::abort(
      message = paste(
        "bert_type must be one of",
        paste(available_berts(), collapse = ", ")
      ),
      class = "bad_bert_type"
    )
  }

  parameter <- match.arg(parameter)
  bert_configs[bert_configs$bert_type == bert_type,][[parameter]]
}

#' Available BERT Models
#'
#' List the BERT models that are defined for this package.
#'
#' Note that some of the models listed here are actually repeats, listed under
#' different names. For example, "bert_L2H128_uncased" and "bert_tiny_uncased"
#' point to the same underlying weights. In general, models with the same values
#' of hyperparameters (accessed by `config_bert`) are identical. However, there
#' is one exception to this: the "bert_base_uncased" and "bert_L12H768_uncased"
#' models have the same hyperparameters and training regime, but are actually
#' distinct models with different actual weights. Any differences between the
#' models are presumably attributable to different random seeds.
#'
#' @return A character vector of BERT types.
#' @export
#'
#' @examples
#' available_berts()
available_berts <- function() {
  return(bert_configs$bert_type)
}


# Check tokenization -----------------------------------------------------------

.check_tokenization <- function(data, model, n_tokens) {
  UseMethod(".check_tokenization")
}

#' @export
.check_tokenization.default <- function(data, model, n_tokens) {
  cli::cli_abort(
    "Tokenization is not implemented for class {class(data)[[1]]}."
  )
}

#' @export
.check_tokenization.dataloader <- function(data, model, n_tokens) {
  .check_tokenization(data$dataset, model, n_tokens)
}

#' @export
.check_tokenization.bert_pretrained_dataset <- function(data, model, n_tokens) {
  data$.tokenize_for_model(model, n_tokens)
}

#' @export
.check_tokenization.dataset <- function(data, model, n_tokens) {
  if (!is.null(data$dataset)) {
    # This is a subset, move on to the next layer.
    .check_tokenization(data$dataset, model, n_tokens)
  } else {
    cli::cli_abort(
      "Datasets for `model_bert_pretrained()` must be prepared using `dataset_bert_pretrained()`."
    )
  }
}


# Look up tokenizer and vocab --------------------------------------------------

#' Look Up Tokenizer Name
#'
#' @param tokenizer_scheme A character scalar indicating the tokenizer scheme,
#'   which is a name for a tokenizer plus a vocabulary.
#'
#' @return A character scalar tokenizer name.
#' @keywords internal
.get_tokenizer_name <- function(tokenizer_scheme) {
  # Really this always returns "wordpiece" right now in real contexts, because
  # we won't call this unless the scheme is already validated, and we only have
  # schemes that use wordpiece.
  switch(
    tokenizer_scheme,
    "bert_en_uncased" = return("wordpiece"),
    "bert_en_cased" = return("wordpiece"),
    .validate_tokenizer_scheme(tokenizer_scheme, FALSE)
  )
}

#' Look Up Vocabulary Name
#'
#' @inheritParams .get_tokenizer_name
#'
#' @return A character scalar vocab name.
#' @keywords internal
.get_vocab_name <- function(tokenizer_scheme) {
  # Right now our tokenizer_schemes and vocab_names exactly match.
  return(tokenizer_scheme)
}

#' Look Up Tokenizer Function
#'
#' Given a string representing the name of a tokenization algorithm, return the
#' corresponding tokenization function.
#'
#' @param tokenizer_name Character; the name of the tokenization algorithm.
#'
#' @return The function implementing the specified algorithm.
#' @keywords internal
.get_tokenizer <- function(tokenizer_name) {
  switch(
    tokenizer_name,
    "wordpiece" = return(wordpiece::wordpiece_tokenize),
    "morphemepiece" = stop("morphemepiece tokenizer not yet supported"),
    "sentencepiece" = stop("sentencepiece tokenizer not yet supported"),
    stop("unrecognized tokenizer: ", tokenizer_name)
  )
}

#' Look Up Token Vocabulary
#'
#' Given a string representing the name of a token vocabulary, return the
#' vocabulary.
#'
#' @param vocab_name Character; the name of the vocabulary.
#'
#' @return The specified token vocabulary.
#' @keywords internal
.get_token_vocab <- function(vocab_name) {
  switch(
    vocab_name,
    "bert_en_uncased" = return(wordpiece.data::wordpiece_vocab(cased = FALSE)),
    "bert_en_cased" = return(wordpiece.data::wordpiece_vocab(cased = TRUE)),
    stop("unrecognized vocabulary: ", vocab_name)
  )
}


# Weights ----------------------------------------------------------------------

#' Download and Cache Weights
#'
#' Download weights for this model to the torchtransformers cache, or load them
#' if they're already downloaded.
#'
#' @inheritParams model_bert_pretrained
#' @param redownload Logical; should the weights be downloaded fresh even if
#'   they're cached?
#'
#' @return The parsed weights as a named list.
#' @keywords internal
.download_weights <- function(bert_type = "bert_tiny_uncased",
                              redownload = FALSE) {
  url <- weights_url_map[bert_type]

  return(
    dlr::read_or_cache(
      source_path = url,
      appname = "torchtransformers",
      process_f = .process_downloaded_weights,
      read_f = torch::torch_load,
      write_f = torch::torch_save,
      force_process = redownload
    )
  )
}

#' Process Downloaded Weights
#'
#' @param temp_file The path to the raw downloaded weights.
#'
#' @return The processed weights.
#' @keywords internal
.process_downloaded_weights <- function(temp_file) {
  # The components of this are tested, but this function itself requires
  # downloading from the internet, so we skip it.

  # nocov start
  state_dict <- torch::load_state_dict(temp_file)
  # I think we always want to do the concatenation and name fixing, so just do
  # that here.
  state_dict <- .concatenate_qkv_weights(state_dict)
  state_dict <- .rename_state_dict_variables(state_dict)
  return(state_dict)
  # nocov end
}

#' Concatenate Attention Weights
#'
#' Concatenate weights to format attention parameters appropriately for loading
#' into BERT models. The torch attention module puts the weight/bias values for
#' the q,k,v tensors into a single tensor, rather than three separate ones. We
#' do the concatenation so that we can load into our models.
#'
#' @param state_dict A state_dict of pretrained weights, probably loaded from a
#'  file.
#'
#' @return The state_dict with query, key, value weights concatenated.
#' @keywords internal
.concatenate_qkv_weights <- function(state_dict) {
  w_names <- names(state_dict)
  # Find parameters with "query" in the name. *Assume* there will be
  # corresponding "key" and "value" parameters. *Construct* corresponding
  # "in_proj" variable.
  trigger_pattern <- "query\\."
  query_names <- w_names[stringr::str_detect(
    string = w_names,
    pattern = trigger_pattern
  )]

  for (qn in query_names) {
    kn <- stringr::str_replace(
      string = qn,
      pattern = trigger_pattern,
      replacement = "key."
    )
    vn <- stringr::str_replace(
      string = qn,
      pattern = trigger_pattern,
      replacement = "value."
    )
    ipn <- stringr::str_replace(
      string = qn,
      pattern = trigger_pattern,
      replacement = "in_proj_"
    )
    combined <- torch::torch_cat(list(
      state_dict[[qn]],
      state_dict[[kn]],
      state_dict[[vn]]
    ))
    state_dict[[ipn]] <- combined
    state_dict[[qn]] <- NULL
    state_dict[[kn]] <- NULL
    state_dict[[vn]] <- NULL
  }
  return(state_dict)
}

#' Clean up Parameter Names
#'
#' There are some hard-to-avoid differences between the variable names in BERT
#' models constructed using this package and the standard variable names used in
#' the Huggingface saved weights. This function changes the names from the
#' Huggingface saves to match package usage.
#'
#' @param state_dict A state_dict of pretrained weights, probably loaded from a
#'  file.
#'
#' @return The state_dict with the names normalized.
#' @keywords internal
.rename_state_dict_variables <- function(state_dict) {
  rep_rules <- variable_names_replacement_rules
  w_names <- names(state_dict)
  w_names <- stringr::str_replace_all(
    string = w_names,
    pattern = stringr::fixed(rep_rules)
  )
  names(state_dict) <- w_names
  return(state_dict)
}
