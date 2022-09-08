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
  initialize = function(x, y = NULL, tokenizer, n_tokens = 128L) {
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
  rlang::abort(
    message = paste(
      "The outcome must be NULL,",
      "a factor,",
      "or a data.frame with a single factor column"
    ),
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
