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

# dataset_bert_pretrained ------------------------------------------------------

#' BERT Pretrained Dataset
#'
#' Prepare a dataset for pretrained BERT models.
#'
#' @param x A data.frame with one or more character predictor columns, or a
#'   list, matrix, or character vector that can be coerced to such a data.frame.
#' @param y A factor of outcomes, or a data.frame with a single factor column.
#'   Can be NULL (default).
#' @inheritParams .validate_tokenizer_metadata
#'
#' @return An initialized [torch::dataset()]. If it is not yet tokenized, the
#'   `tokenize()` method must be called before the dataset will be usable.
#'
#' @export
dataset_bert_pretrained <- torch::dataset(
  name = "bert_pretrained_dataset",

  ## private -------------------------------------------------------------------
  private = list(
    #' @field input_data `(private)` The input predictors (`x`) standardized to
    #'   a data.frame of character columns, and outcome (`y`) standardized to a
    #'   factor or `NULL`.
    input_data = list(),

    #' @field tokenizer_metadata `(private)` A list indicating the
    #'   `tokenizer_scheme` and `n_tokens` that have been or will be used to
    #'   tokenize the predictors (`x`).
    tokenizer_metadata = list(),
    #' @field tokenized `(private)` A single logical value indicating whether
    #'   the data has been tokenized.
    tokenized = FALSE
  ),

  ## methods -------------------------------------------------------------------
  #' @section Methods:
  #' \describe{

  ### initialize ---------------------------------------------------------------
  #' \item{`initialize`}{Initialize this dataset. This method is called when the
  #' dataset is first created.}
  initialize = function(x,
                        y = NULL,
                        bert_type = NULL,
                        tokenizer_scheme = NULL,
                        n_tokens = NULL) {
    # Check the predictors.
    x <- .standardize_bert_dataset_predictors(x)

    # Cast y to a factor (or NULL)
    y <- .standardize_bert_dataset_outcome(y)

    # TODO: Make sure y is the same length as x if it exists (maybe within the
    # standardize function).

    # Put what we can into the private fields.
    private$input_data <- list(
      x = x,
      y = y
    )

    # I think putting this in private caused issues. I still want to initialize
    # it so it's the same shape no matter where we go after this.
    self$torch_data <- list(
      x = list(
        token_ids = torch::torch_tensor(integer(0)),
        token_type_ids = torch::torch_tensor(integer(0))
      ),
      y = torch::torch_tensor(integer(0))
    )

    self$torch_data$y <- torch::torch_tensor(private$input_data$y)

    # Log the tokenizer info if known.
    private$tokenizer_metadata <- .validate_tokenizer_metadata(
      bert_type, tokenizer_scheme, n_tokens
    )

    # If we know the tokenizer info, tokenize.
    if (
      !is.null(private$tokenizer_metadata$tokenizer_scheme) &&
      !is.null(private$tokenizer_metadata$n_tokens)
    ) {
      self$tokenize(
        private$tokenizer_metadata$tokenizer_scheme,
        private$tokenizer_metadata$n_tokens
      )
    }
  },

  ### tokenize -----------------------------------------------------------------
  #' \item{`tokenize`}{Tokenize this dataset.}
  tokenize = function(tokenizer_scheme,
                      n_tokens) {
    # Sort out what new information they're giving us.
    if (!missing(tokenizer_scheme)) {
      tokenizer_scheme <- .validate_tokenizer_scheme(tokenizer_scheme, FALSE)
      if (private$tokenized) {
        .error_on_tokenizer_mismatch(
          tokenizer_scheme,
          private$tokenizer_metadata$tokenizer_scheme
        )
      } else {
        private$tokenizer_metadata$tokenizer_scheme <- tokenizer_scheme
      }
    }
    if (!missing(n_tokens)) {
      n_tokens <- .validate_n_tokens(n_tokens, FALSE)
      if (private$tokenized) {
        .error_on_tokenizer_mismatch(
          n_tokens,
          private$tokenizer_metadata$n_tokens
        )
      } else {
        private$tokenizer_metadata$n_tokens <- n_tokens
      }
    }

    # If they made it through that, they didn't conflict with existing
    # tokenization.
    if (private$tokenized) {
      return(invisible(TRUE))
    }

    # Make sure everything is set now.
    tokenizer_settings_missing <- c(
      is.null(private$tokenizer_metadata$tokenizer_scheme),
      is.null(private$tokenizer_metadata$n_tokens)
    )

    if (any(tokenizer_settings_missing)) {
      tokenizer_settings <- purrr::map_chr(
        private$tokenizer_metadata,
        ~.x %||% "missing"
      )
      tokenizer_settings_names <- names(private$tokenizer_metadata)
      msg <- glue::glue("{tokenizer_settings_names} is {tokenizer_settings}")
      names(msg)[tokenizer_settings_missing] <- "x"
      names(msg)[!tokenizer_settings_missing] <- "v"
      cli::cli_abort(
        c(
          "To tokenize, we need both `tokenizer_scheme` and `n_tokens`.",
          msg,
          i = "You may need to use `luz_callback_bert_tokenize()`."
        )
      )
    }

    # At this point we have the values and things aren't already tokenized, so
    # actually perform the tokenization.
    tokenizer <- .get_tokenizer(
      .get_tokenizer_name(private$tokenizer_metadata$tokenizer_scheme)
    )
    vocab <- .get_token_vocab(
      .get_vocab_name(private$tokenizer_metadata$tokenizer_scheme)
    )

    # TODO: When/if we add more tokenizers we might have to pass more arguments
    # through to this function. I think we'd go to something like
    # .parse_tokenizer_scheme and do the call from there. I do this as do.call
    # still to deal with data.frames, we should do this more cleanly in
    # tokenize_bert.
    tokenized <- do.call(
      tokenize_bert,
      c(
        private$input_data$x,
        list(
          n_tokens = n_tokens,
          tokenizer = tokenizer,
          vocab = vocab
        )
      )
    )

    # TODO: For the moment we assume that succeeded since tokenize_bert didn't
    # complain.
    self$torch_data$x <- list(
      token_ids = torch::torch_tensor(tokenized$token_ids),
      token_type_ids = torch::torch_tensor(tokenized$token_type_ids)
    )

    private$tokenized <- TRUE

    return(invisible(TRUE))
  },

  ### untokenize ---------------------------------------------------------------
  #' \item{`untokenize`}{Remove any tokenization from this dataset.}
  untokenize = function() {
    private$tokenized <- FALSE
    private$tokenizer_metadata <- list(
      tokenizer_scheme = NULL,
      n_tokens = NULL
    )
    self$torch_data$x <- list(
      token_ids = torch::torch_tensor(integer(0)),
      token_type_ids = torch::torch_tensor(integer(0))
    )
  },

  ### .tokenize_for_model ------------------------------------------------------
  #' \item{`.tokenize_for_model`}{Tokenize this dataset for a particular model.
  #' Generally superseded by instead calling [luz_callback_bert_tokenize()].}
  .tokenize_for_model = function(model, n_tokens) {
    model_tokenizer_metadata <- model$.get_tokenizer_metadata()
    max_tokens <- model_tokenizer_metadata$max_tokens
    set_n_tokens <- private$tokenizer_metadata$n_tokens

    # The model data has *max* tokens, rather than *n* tokens, so do a check
    # here.
    if (is.null(set_n_tokens)) {
      if (!is.null(n_tokens)) {
        if (n_tokens > max_tokens) {
          cli::cli_abort(
            "Tokenization mismatch.",
            x = "The model cannot accept more than {max_tokens} tokens.",
            x = "{n_tokens} > {max_tokens}"
          )
        } else {
          set_n_tokens <- n_tokens
        }
      } else {
        set_n_tokens <- max_tokens
      }
    } else if (set_n_tokens > max_tokens) {
      cli::cli_abort(
        "Tokenization mismatch.",
        x = "The model cannot accept more than {max_tokens} tokens, data is tokenized to {n_tokens} tokens."
      )
    }

    # If the model and this dataset mismatch, we'll throw an error. If
    # tokenization has to happen, it will happen here.
    self$tokenize(
      model_tokenizer_metadata$tokenizer_scheme,
      set_n_tokens
    )
  },

  ### .getitem -----------------------------------------------------------------
  #' \item{`.getitem`}{Fetch an individual predictor (and, if available, the
  #' associated outcome). Generally superseded by instead calling `.getbatch()`
  #' (or by letting the {luz} modeling process fit automatically).}
  .getitem = function(index) {
    if (length(self$torch_data$y)) {
      target <- self$torch_data$y[index]
    } else {
      target <- list()
    }

    if (!private$tokenized) {
      # This will fail, but we deal with error messaging there.
      self$tokenize()
    }

    return(
      list(
        list(
          token_ids = self$torch_data$x$token_ids[index, ],
          token_type_ids = self$torch_data$x$token_type_ids[index, ]
        ),
        target
      )
    )
  },

  ### .getbatch ----------------------------------------------------------------
  #' \item{`.getbatch`}{Fetch specific predictors (and, if available, the
  #' associated outcomes). This function is called automatically by `{luz}`
  #' during the fitting process.}
  .getbatch = function(index) {
    if (length(self$torch_data$y)) {
      target <- self$torch_data$y[index, drop = FALSE]
    } else {
      target <- list()
    }

    if (!private$tokenized) {
      # This will fail, but we deal with error messaging there.
      self$tokenize()
    }

    return(
      list(
        list(
          token_ids = self$torch_data$x$token_ids[drop = FALSE, index, ],
          token_type_ids = self$torch_data$x$token_type_ids[
            drop = FALSE, index,
          ]
        ),
        target
      )
    )
  },

  ### .length ------------------------------------------------------------------
  #' \item{`.length`}{Determine the length of the dataset (the number of rows of
  #' predictors). Generally superseded by instead calling [length()].}
  .length = function() {
    nrow(private$input_data$x)
  }

  #' }

)

