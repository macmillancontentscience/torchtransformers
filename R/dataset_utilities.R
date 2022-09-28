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

#' Choose Tokenizer Metadata
#'
#' @param bert_type A bert_type from [available_berts()] to use to choose the
#'   other properties. If `bert_type` and `n_tokens` are set, they overrule this
#'   setting.
#' @inheritParams .validate_tokenizer_scheme
#' @inheritParams .validate_n_tokens
#'
#' @return A list with elements `tokenizer_scheme` and `n_tokens`.
#' @keywords internal
.validate_tokenizer_metadata <- function(bert_type = NULL,
                                         tokenizer_scheme = NULL,
                                         n_tokens = NULL,
                                         allow_null = TRUE) {
  type_scheme <- NULL
  type_tokens <- NULL

  if (!is.null(bert_type)) {
    type_scheme <- config_bert(bert_type, "tokenizer_scheme")
    type_tokens <- config_bert(bert_type, "max_tokens")
  }

  # For now we'll use the specific over the general.
  tokenizer_scheme <- tokenizer_scheme %||% type_scheme
  n_tokens <- n_tokens %||% type_tokens
  tokenizer_scheme <- .validate_tokenizer_scheme(tokenizer_scheme, allow_null)
  n_tokens <- .validate_n_tokens(n_tokens, allow_null)
  return(
    list(
      tokenizer_scheme = tokenizer_scheme,
      n_tokens = n_tokens
    )
  )
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

#' Standardize BERT Dataset Predictors
#'
#' The predictors are coerced to a data.frame of character columns, if possible.
#'
#' @param x The input to standardize.
#'
#' @return A data.frame with one or more character columns.
#' @keywords internal
.standardize_bert_dataset_predictors <- function(x) {
  # Validate x and cast to a df via methods.
  UseMethod(".standardize_bert_dataset_predictors")
}

#' @export
.standardize_bert_dataset_predictors.default <- function(x) {
  classname <- class(x)[[1]]
  msg <- c(
    "Unsupported predictor class.",
    i = paste(
      "The predictors must be a list of character vectors,",
      "a data.frame of character columns,",
      "or a matrix of character columns."
    ),
    x = glue::glue(
      "`x` is a(n) {classname}"
    )
  )
  cli::cli_abort(
    msg,
    class = "bad_predictors",
    call = rlang::caller_env()
  )
}

#' @export
.standardize_bert_dataset_predictors.data.frame <- function(x) {
  # Make sure it only has character columns.
  # TODO: Make this prettier.
  stopifnot(all(purrr::map_lgl(x, is.character)))
  return(as.data.frame(x))
}

#' @export
.standardize_bert_dataset_predictors.list <- function(x) {
  # Make sure it only has character elements.
  # TODO: Make this prettier.
  stopifnot(all(purrr::map_lgl(x, is.character)))
  return(as.data.frame(x))
}

#' @export
.standardize_bert_dataset_predictors.matrix <- function(x) {
  # Make sure it only has character columns.
  # TODO: Make this prettier.
  stopifnot(all(purrr::map_lgl(x, is.character)))
  return(as.data.frame(x))
}

#' @export
.standardize_bert_dataset_predictors.character <- function(x) {
  return(as.data.frame(x))
}

#' Standardize BERT Dataset Outcome
#'
#' @param y A potential outcome variable. Should be a numeric vector, a factor,
#'   a data.frame with a single compatible column, or NULL.
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
      "a numeric vector,",
      "or a data.frame with a single compatible column."
    ),
    x = glue::glue(
      "`y` is a(n) {classname}"
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
.standardize_bert_dataset_outcome.numeric <- function(y) {
  return(y)
}

#' @export
.standardize_bert_dataset_outcome.data.frame <- function(y) {
  stopifnot(
    ncol(y) == 1,
    is.factor(y[[1]]) | is.numeric(y[[1]])
  )
  return(y[[1]])
}
