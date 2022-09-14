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

#' BERT Tokenization Callback
#'
#' Data used in pretrained BERT models must be tokenized in the way the model
#' expects. This `luz_callback` checks that the incoming data is tokenized
#' properly, and triggers tokenization if necessary.
#'
#' @param submodel_name An optional character scalar identifying a model inside
#'   the main [torch::nn_module()] that was built using
#'   [model_bert_pretrained()].
#' @param n_tokens An optional integer scalar indicating the number of tokens to
#'   which the data should be tokenized. If present it must be equal to or less
#'   than the `max_tokens` allowed by the pretrained model.
#' @param verbose A logical scalar indicating whether the callback should report
#'   its progress (default `TRUE`).
#'
#' @examples
#' if (rlang::is_installed("luz")) {
#'   luz_callback_bert_tokenize()
#'   luz_callback_bert_tokenize(n_tokens = 32L)
#' }
#'
#' @export
luz_callback_bert_tokenize <- function(submodel_name = NULL,
                                       n_tokens = NULL,
                                       verbose = TRUE) {
  rlang::check_installed("luz")

  # Keep this inside of the function so installation doesn't fail if they don't
  # have luz.
  luz_callback_bert_tokenize_generator <- luz::luz_callback(
    "bert_tokenize_callback",
    initialize = function(submodel_name = NULL,
                          n_tokens = NULL,
                          verbose = TRUE) {
      self$submodel_name <- submodel_name
      self$n_tokens <- n_tokens
      self$verbose <- verbose
    },
    on_fit_begin = function() {
      # The ctx object contains everything being used by luz. The specific
      # things we want are model, train_data, and valid_data. Make sure that
      # those datasets are tokenized to match this model.
      model <- ctx$model
      if (!is.null(self$submodel_name)) {
        model <- model[[self$submodel_name]]
      }

      .maybe_alert(self$verbose, "Confirming train_data tokenization.")

      .check_tokenization(ctx$train_data, model, self$n_tokens)

      if(length(ctx$valid_data)) { # nocov start
        .maybe_alert(self$verbose, "Confirming valid_data tokenization.")
        .check_tokenization(ctx$valid_data, model, self$n_tokens)
      } # nocov end
    },
    on_predict_begin = function() {
      # TODO: Theoretically this should check how the training data was
      # tokenized to make sure it matches THAT, in case they used a different
      # n_tokens. Technically you don't HAVE to match, though, so maybe not?

      # The ctx object contains everything being used by luz. The specific
      # things we want are model and data in this case. Make sure that that
      # dataset is tokenized to match this model.
      model <- ctx$model
      if (!is.null(self$submodel_name)) {
        model <- model[[self$submodel_name]]
      }

      .maybe_alert(self$verbose, "Confirming prediction data tokenization.")
      .check_tokenization(ctx$data, model, self$n_tokens)
    }
  )

  return(
    luz_callback_bert_tokenize_generator(
      submodel_name,
      n_tokens,
      verbose
    )
  )
}
