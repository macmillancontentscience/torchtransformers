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

# Pretrained Dataset -----------------------------------------------------------

# Because of the way our datasets are defined, via direct torch::dataset calls,
# the definitions of sub-functions have to be BEFORE the definitions of any
# associated datasets.

utils::globalVariables("self")
utils::globalVariables("private")

#' Tokenize Pretrained Bert Datasets
#'
#' This is really a method of dataset_bert_pretrained.
#'
#' @inheritParams .validate_tokenizer_scheme
#' @inheritParams .validate_n_tokens
#'
#' @return TRUE invisibly.
#' @keywords internal
.tokenize_dataset_bert_pretrained <- function(tokenizer_scheme,
                                              n_tokens) {
  # I actually DO test this, but it's in the context of the R6, and I think that
  # confuses covr.

  # nocov start

  # Sort out what new information they're giving us.
  if (!missing(tokenizer_scheme)) {
    tokenizer_scheme <- .validate_tokenizer_scheme(tokenizer_scheme, FALSE)
    if (private$tokenized) {
      .error_on_tokenizer_mismatch(
        tokenizer_scheme,
        private$tokenizer$tokenizer_scheme
      )
    } else {
      private$tokenizer$tokenizer_scheme <- tokenizer_scheme
    }
  }
  if (!missing(n_tokens)) {
    n_tokens <- .validate_n_tokens(n_tokens, FALSE)
    if (private$tokenized) {
      .error_on_tokenizer_mismatch(n_tokens, private$tokenizer$n_tokens)
    } else {
      private$tokenizer$n_tokens <- n_tokens
    }
  }

  # If they made it through that, they didn't conflict with existing
  # tokenization.
  if (private$tokenized) {
    return(invisible(TRUE))
  }

  # Make sure everything is set now.
  tokenizer_settings_missing <- c(
    is.null(private$tokenizer$tokenizer_scheme),
    is.null(private$tokenizer$n_tokens)
  )

  if (any(tokenizer_settings_missing)) {
    tokenizer_settings <- purrr::map_chr(
      private$tokenizer,
      ~.x %||% "missing"
    )
    tokenizer_settings_names <- names(private$tokenizer)
    msg <- glue::glue("{tokenizer_settings_names} is {tokenizer_settings}")
    names(msg)[tokenizer_settings_missing] <- "x"
    names(msg)[!tokenizer_settings_missing] <- "v"
    cli::cli_abort(
      c("To tokenize, we need both `tokenizer_scheme` and `n_tokens`.", msg)
    )
  }

  # At this point we have the values and things aren't already tokenized, so
  # actually perform the tokenization.
  tokenizer <- .get_tokenizer(
    .get_tokenizer_name(private$tokenizer$tokenizer_scheme)
  )
  vocab <- .get_token_vocab(
    .get_vocab_name(private$tokenizer$tokenizer_scheme)
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
  private$processed_data$x <- tokenized

  private$torch_data$x <- list(
    token_ids = torch::torch_tensor(tokenized$token_ids),
    token_type_ids = torch::torch_tensor(tokenized$token_type_ids)
  )

  private$tokenized <- TRUE

  # I test that I'm getting TRUE out but for some reason gp doesn't acknowledge
  # that test.
  return(invisible(TRUE))
  # nocov end
}

#' Make Sure Tokenizer Schemes are Recognized
#'
#' @param tokenizer_scheme A character scalar that indicates vocabulary +
#'   tokenizer.
#' @param allow_null A logical scalar indicating whether the scheme can be NULL.
#'
#' @return The scheme, validated.
#' @keywords internal
.validate_tokenizer_scheme <- function(tokenizer_scheme, allow_null = TRUE) {
  if (is.null(tokenizer_scheme)) {
    if (allow_null) {
      return(NULL)
    } else {
      cli::cli_abort("`tokenizer_scheme` cannot be NULL.")
    }
  }

  if (length(tokenizer_scheme) > 1 || !is.character(tokenizer_scheme)) {
    cli::cli_abort(
      "`tokenizer_scheme` must be a length-1 character."
    )
  }

  switch(
    tolower(tokenizer_scheme),
    "bert_en_cased" = return(invisible("bert_en_cased")),
    "bert_en_uncased" = return(invisible("bert_en_uncased")),
    cli::cli_abort(
      c(
        "We only support the bert_en_cased and bert_en_uncased schemes.",
        x = glue::glue("Unsupported tokenizer_scheme: {tokenizer_scheme}")
      )
    )
  )
}

#' Make Sure the Number of Tokens Makes Sense
#'
#' @param n_tokens An integer scalar indicating the number of tokens in the
#'   output.
#' @param allow_null A logical scalar indicating whether n_tokens can be NULL.
#'
#' @return n_tokens, validated.
#' @keywords internal
.validate_n_tokens <- function(n_tokens, allow_null = TRUE) {
  if (is.null(n_tokens)) {
    if (allow_null) {
      return(NULL)
    } else {
      cli::cli_abort("`n_tokens` cannot be NULL.")
    }
  }

  if (as.integer(n_tokens) != n_tokens || length(n_tokens) != 1) {
    cli::cli_abort(
      "`n_tokens` should be a length-1 integer."
    )
  }

  maxest_tokens <- max(bert_configs$max_tokens)
  if (n_tokens > maxest_tokens) {
    cli::cli_abort(
      c(
        "`n_tokens` too large",
        x = glue::glue("{n_tokens} > {maxest_tokens}")
      )
    )
  }

  return(as.integer(n_tokens))
}

#' Error Helper Function for Mismatches
#'
#' @param new The new value.
#' @param old The old value.
#'
#' @return TRUE invisibly.
#' @keywords internal
.error_on_tokenizer_mismatch <- function(new, old) {
  if (!identical(new, old)) {
    cli::cli_abort(
      c(
        "This dataset is already tokenized with a different setting:",
        x = glue::glue("{old}, not {new}")
      )
    )
  }
  return(invisible(TRUE))
}

#' BERT Pretrained Dataset
#'
#' Prepare a dataset for pretrained BERT models.
#'
#' @param x A data.frame with one or more character predictor columns.
#' @param y A factor of outcomes, or a data.frame with a single factor column.
#'   Can be NULL (default).
#' @inheritParams .tokenize_dataset_bert_pretrained
#'
#' @return An initialized [torch::dataset()]. If it is not yet tokenized, the
#'   `tokenize()` method must be called before the dataset will be usable.
#'
#' @export
dataset_bert_pretrained <- torch::dataset(
  name = "bert_pretrained_dataset",
  private = list(
    input_data = list(),
    processed_data = list(
      x = list(
        token_ids = integer(0),
        token_type_ids = integer(0)
      ),
      y = integer(0)
    ),
    torch_data = list(
      x = list(
        token_ids = torch::torch_tensor(integer(0)),
        token_type_ids = torch::torch_tensor(integer(0))
      ),
      y = torch::torch_tensor(integer(0))
    ),
    tokenizer = list(),
    tokenized = FALSE
  ),
  initialize = function(x,
                        y = NULL,
                        tokenizer_scheme = NULL,
                        n_tokens = NULL) {
    # TODO: Cast x to a df here.
    # Make sure the input x is just text columns.
    stopifnot(all(purrr::map_lgl(x, is.character)))

    # Cast y to a factor (or NULL)
    y <- .standardize_bert_dataset_outcome(y)

    # Put what we can into the private fields.
    private$input_data <- list(
      x = x,
      y = y
    )
    private$processed_data$y <- as.integer(private$input_data$y)
    private$torch_data$y <- torch::torch_tensor(private$processed_data$y)

    # Log the tokenizer info if known.
    tokenizer_scheme <- .validate_tokenizer_scheme(tokenizer_scheme)
    n_tokens <- .validate_n_tokens(n_tokens)

    private$tokenizer <- list(
      tokenizer_scheme = tokenizer_scheme,
      n_tokens = n_tokens
    )

    if (!is.null(tokenizer_scheme) && !is.null(n_tokens)) {
      self$tokenize(tokenizer_scheme, n_tokens)
    }
  },
  tokenize = .tokenize_dataset_bert_pretrained,
  .getitem = function(index) {
    if (length(private$torch_data$y)) {
      target <- private$torch_data$y[index]
    } else {
      target <- list()
    }

    if (!private$tokenized) {
      # This will fail, but we deal with error messaging there.
      self$tokenize()
    }

    list(
      list(
        token_ids = private$torch_data$x$token_ids[index, ],
        token_type_ids = private$torch_data$x$token_type_ids[index, ]
      ),
      target
    )
  },
  .length = function() {
    nrow(private$input_data$x)
  }
)


# More general BERT dataset ----------------------------------------------------


#' BERT Dataset
#'
#' Prepare a dataset for BERT-like models.
#'
#' @param x A data.frame with one or more character predictor columns.
#' @param y A factor of outcomes, or a data.frame with a single factor column.
#'   Can be NULL (default).
#' @param tokenizer A tokenization function (signature compatible with
#'   `tokenize_bert`).
#' @inheritParams tokenize_bert
#'
#' @return An initialized \code{\link[torch]{dataset}}.
#'
#' @export
dataset_bert <- torch::dataset(
  name = "bert_dataset",
  initialize = function(x,
                        y = NULL,
                        # TODO: Because tokenize_bert is defined later, R CMD
                        # check doesn't like this, but then it runs fine. To fix
                        # before CRAN attempts.
                        tokenizer = tokenize_bert,
                        n_tokens = 128L) {
    # Eventually this should be exported somewhere. It's a super quick version
    # of something I'm also implementing in tidybert.
    stopifnot(all(purrr::map_lgl(x, is.character)))

    tokenized_text <- do.call(
      tokenizer,
      c(
        x,
        list(n_tokens = n_tokens)
      )
    )

    y <- .standardize_bert_dataset_outcome(y)

    # We supply the data as tensors.
    self$tokenized_text <- torch::torch_tensor(tokenized_text$token_ids)
    self$token_types <- torch::torch_tensor(tokenized_text$token_type_ids)

    # Also supply the labels as tensors.
    self$y <- torch::torch_tensor(as.integer(y))
  },
  # We extract subsets of this data using an index.
  .getitem = function(index) {
    if (length(self$y)) {
      target <- self$y[index]
    } else {
      target <- list()
    }

    list(
      list(
        token_ids = self$tokenized_text[index, ],
        token_type_ids = self$token_types[index, ]
      ),
      target
    )
  },
  .length = function() {
    dim(self$tokenized_text)[[1]]
  }
)

#' Standardize BERT Dataset Outcome
#'
#' @param y A potential outcome variable. Should be a factor, a data.frame with
#'   a single factor column, or NULL.
#'
#' @return A factor or NULL.
#' @keywords internal
.standardize_bert_dataset_outcome <- function(y) {
  UseMethod(".standardize_bert_dataset_outcome")
}

#' @export
.standardize_bert_dataset_outcome.default <- function(y) {
  classname <- class(y)[[1]]
  msg <- c(
    "Unsupported outcome type.",
    i = paste(
      "The outcome must be NULL,",
      "a factor,",
      "or a data.frame with a single factor column."
    ),
    x = glue::glue(
      "`y` is a {classname}"
    )
  )
  cli::cli_abort(
    msg,
    class = "bad_outcome",
    call = rlang::caller_env()
  )
}

#' @export
.standardize_bert_dataset_outcome.NULL <- function(y) {
  return(y)
}

#' @export
.standardize_bert_dataset_outcome.factor <- function(y) {
  return(y)
}

#' @export
.standardize_bert_dataset_outcome.data.frame <- function(y) {
  stopifnot(
    ncol(y) == 1,
    is.factor(y[[1]])
  )
  return(y[[1]])
}
