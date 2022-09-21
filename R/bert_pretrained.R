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

# model_bert_pretrained ------------------------------------------------------

#' Construct a Pretrained BERT Model
#'
#' Construct a BERT model (using [model_bert()]) and load pretrained weights.
#'
#' @param bert_type Character; which flavor of BERT to use. See
#'   [available_berts()] for known models.
#' @inheritParams .download_weights
#'
#' @return The model with pretrained weights loaded.
#' @export
model_bert_pretrained <- torch::nn_module(
  "BERT_pretrained",

  ## private -------------------------------------------------------------------
  private = list(
    bert_type = character(0),
    tokenizer_metadata = list(
      tokenizer_scheme = character(0),
      max_tokens = integer(0)
    )
  ),

  ## methods -------------------------------------------------------------------
  #' @section Methods:
  #' \describe{

  ### initialize ---------------------------------------------------------------
  #' \item{`initialize`}{Initialize this model. This method is called when the
  #' model is first created.}
  initialize = function(bert_type = "bert_tiny_uncased", redownload = FALSE) {
    if (!bert_type %in% available_berts()) {
      cli::cli_abort(
        "Unknown BERT model. `bert_type` must be one of:",
        i = paste0(available_berts(), collapse = ", ")
      )
    }
    params <- bert_configs[bert_configs$bert_type == bert_type, ]

    # This feels incorrect, trying it out for now.
    model_base <- model_bert(
      embedding_size = params$embedding_size,
      n_layer = params$n_layer,
      n_head = params$n_head,
      max_position_embeddings = params$max_tokens,
      vocab_size = params$vocab_size
    )
    self$embeddings <- model_base$embeddings
    self$encoder <- model_base$encoder
    self$.bert_forward <- model_base$forward

    # Put these properties in private so users can't accidentally break things
    # by changing them.
    private$bert_type <- bert_type
    private$tokenizer_metadata <- list(
      tokenizer_scheme = params$tokenizer_scheme,
      max_tokens = params$max_tokens
    )

    # Now load this model's weights.
    self$.load_weights(redownload = redownload)
  },

  ### forward ------------------------------------------------------------------
  #' \item{`forward`}{Use this model. This method is called during training, and
  #' also during prediction. `x` is a list of [torch::torch_tensor()] values for
  #' `token_ids` and `token_type_ids`.}
  forward = function(x) {
    # Pass the data through to BERT.
    self$.bert_forward(x$token_ids, x$token_type_ids)
  },

  # TODO: Build in a loss function.

  ### .get_tokenizer_metadata --------------------------------------------------
  #' \item{`.get_tokenizer_metadata`}{Look up the tokenizer metadata for this
  #' model. This method is called automatically when
  #' [luz_callback_bert_tokenize()] validates that a dataset is tokenized
  #' properly for this model.}
  .get_tokenizer_metadata = function() {
    return(private$tokenizer_metadata)
  },

  ### .load_weights ------------------------------------------------------------
  #' \item{`.load_weights`}{Load the pretrained weights for this model. This
  #' method is called automatically during initialization of this model.}
  .load_weights = function(redownload) {
    # This will usually just fetch from the cache
    saved_state_dict <- .download_weights(
      bert_type = private$bert_type, redownload = redownload
    )
    my_weight_names <- names(self$state_dict())
    saved_weight_names <- names(saved_state_dict)
    names_in_common <- intersect(my_weight_names, saved_weight_names)
    if (length(names_in_common) > 0) {
      self$load_state_dict(saved_state_dict[names_in_common])
    } else {
      stop("No matching weight names found.") # nocov
    }
  }

  #' }

)
