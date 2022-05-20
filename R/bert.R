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

#' BERT Model
#'
#' Construct a BERT model.
#'
#' @param embedding_size Integer; the dimension of the embedding vectors.
#' @param intermediate_size Integer; size of dense layers applied after
#'   attention mechanism.
#' @param n_layer Integer; the number of attention layers.
#' @param n_head Integer; the number of attention heads per layer.
#' @param hidden_dropout Numeric; the dropout probability to apply to dense
#'   layers.
#' @param attention_dropout Numeric; the dropout probability to apply in
#'   attention.
#' @param max_position_embeddings Integer; maximum number of tokens in each
#'   input sequence.
#' @param vocab_size Integer; number of tokens in vocabulary.
#' @param token_type_vocab_size Integer; number of input segments that the model
#'   will recognize. (Two for BERT models.)
#'
#' @section Shape:
#'
#'   Inputs:
#'
#'   With `sequence_length` <= `max_position_embeddings`:
#'
#'   - token_ids: \eqn{(*, sequence_length)}
#'
#'   - token_type_ids: \eqn{(*, sequence_length)}
#'
#'   Output:
#'
#'   - initial_embeddings: \eqn{(*, sequence_length, embedding_size)}
#'
#'   - output_embeddings: list of \eqn{(*, sequence_length, embedding_size)} for
#'   each transformer layer.
#'
#'   - attention_weights: list of \eqn{(*, n_head, sequence_length,
#'   sequence_length)} for each transformer layer.
#'
#' @examples
#' emb_size <- 128L
#' mpe <- 512L
#' n_head <- 4L
#' n_layer <- 6L
#' vocab_size <- 30522L
#' model <- model_bert(
#'   embedding_size = emb_size,
#'   n_layer = n_layer,
#'   n_head = n_head,
#'   max_position_embeddings = mpe,
#'   vocab_size = vocab_size
#' )
#'
#' n_inputs <- 2
#' n_token_max <- 128L
#' # get random "ids" for input
#' t_ids <- matrix(
#'   sample(
#'     2:vocab_size,
#'     size = n_token_max * n_inputs,
#'     replace = TRUE
#'   ),
#'   nrow = n_inputs, ncol = n_token_max
#' )
#' ttype_ids <- matrix(
#'   rep(1L, n_token_max * n_inputs),
#'   nrow = n_inputs, ncol = n_token_max
#' )
#' model(
#'   torch::torch_tensor(t_ids),
#'   torch::torch_tensor(ttype_ids)
#' )
#' @export
model_bert <- torch::nn_module(
  "BERT",
  initialize = function(embedding_size,
                        intermediate_size = 4 * embedding_size,
                        n_layer,
                        n_head,
                        hidden_dropout = 0.1,
                        attention_dropout = 0.1,
                        max_position_embeddings,
                        vocab_size,
                        token_type_vocab_size = 2L) {
    self$embeddings <- embeddings_bert(
      embedding_size = embedding_size,
      max_position_embeddings = max_position_embeddings,
      vocab_size = vocab_size,
      token_type_vocab_size = token_type_vocab_size,
      hidden_dropout = hidden_dropout
    )

    self$encoder <- transformer_encoder_bert(
      embedding_size = embedding_size,
      intermediate_size = intermediate_size,
      n_layer = n_layer,
      n_head = n_head,
      hidden_dropout = hidden_dropout,
      attention_dropout = attention_dropout
    )
  },
  forward = function(token_ids, token_type_ids) {
    mask <- token_ids == 1

    emb_out <- self$embeddings(token_ids, token_type_ids)
    output <- self$encoder(emb_out, mask)

    return(list(
      "initial_embeddings" = emb_out,
      "output_embeddings" = output$embeddings,
      "attention_weights" = output$weights
    ))
  }
)

#' BERT Model Parameters
#'
#' Several parameters define a BERT model. This function can be used to easily
#' load them.
#'
#' @param bert_model Character scalar; the name of a known BERT model.
#' @param parameter Chararcter scalar; the desired parameter.
#'
#' @return Integer scalar; the value of that parameter for that model.
#' @export
#'
#' @examples
#' config_bert("bert_medium_uncased", "n_head")
config_bert <- function(bert_model,
                        parameter = c(
                          "embedding_size",
                          "n_layer",
                          "n_head",
                          "max_tokens",
                          "vocab_size"
                        )) {
  stopifnot(
    length(bert_model) == 1,
    bert_model %in% bert_configs$model_name
  )
  parameter <- match.arg(parameter)
  bert_configs[bert_configs$model_name == bert_model,][[parameter]]
}
