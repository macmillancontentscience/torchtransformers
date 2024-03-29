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

# position embeddings -----------------------------------------------------


#' Create Position Embeddings
#'
#' Position embeddings are how BERT-like language models represent the order of
#' input tokens. Each token gets a position embedding vector which is completely
#' determined by its position index. Because these embeddings don't depend on
#' the actual input, it is implemented by simply initializing a matrix of
#' weights.
#'
#' @inheritParams model_bert
#'
#' @section Shape:
#'
#'   Inputs:
#'
#'   No input tensors. Optional input parameter to limit number of positions
#'   (tokens) considered.
#'
#'   Output:
#'
#'   - \eqn{(*, max_position_embeddings, embedding_size)}
#'
#' @examples
#' emb_size <- 3L
#' mpe <- 2L
#' model <- position_embedding(
#'   embedding_size = emb_size,
#'   max_position_embeddings = mpe
#' )
#' model(seq_len_cap = 1)
#' model()
#' @export
position_embedding <- torch::nn_module(
  "position_embedding",
  initialize = function(embedding_size, max_position_embeddings) {
    # Maybe eventually promote this to proper param.
    std <- 0.02
    # todo on GPU: check that device is set properly!
    self$pos_emb0 <- torch::torch_empty(
      max_position_embeddings,
      embedding_size
    )
    torch::nn_init_trunc_normal_(self$pos_emb0,
      std = std,
      a = -2 * std, b = 2 * std
    )
    # model variable name!
    self$weight <- torch::nn_parameter(self$pos_emb0)
  },
  forward = function(seq_len_cap = NULL) {
    # When the embedding layer is actually called, we can restrict number of
    # positions to be smaller than the initialized size. (e.g. if you know you
    # only need length-20 sequences, you can save a lot of time.)
    pe <- self$weight

    if (!is.null(seq_len_cap)) {
      mpe <- self$weight$shape[[1]]
      if (seq_len_cap <= mpe) {
        pe <- self$weight[1:seq_len_cap, ]
      } else {
        message(
          "seq_len_cap (", seq_len_cap,
          ") is bigger than max_position_embeddings (",
          max_position_embeddings, "), and will be ignored."
        )
      }
    }

    # We'll need to broadcast the embeddings to every example in the batch, so
    # unsqueeze the batch dimension.
    return(pe$unsqueeze(1))
  }
)


# bert embeddings ---------------------------------------------------------

#' Create BERT Embeddings
#'
#' There are three components which are added together to give the input
#' embeddings in a BERT model: the embedding of the tokens themselves, the
#' segment ("token type") embedding, and the position (token index) embedding.
#' This function sets up the embedding layer for all three of these.
#'
#' @inheritParams model_bert
#'
#' @section Shape:
#'
#' With `sequence_length` <= `max_position_embeddings`:
#'
#'   Inputs:
#'
#'   - token_ids: \eqn{(*, sequence_length)}
#'
#'   - token_type_ids: \eqn{(*, sequence_length)}
#'
#'
#'   Output:
#'
#'   - \eqn{(*, sequence_length, embedding_size)}
#'
#' @examples
#' emb_size <- 3L
#' mpe <- 5L
#' vs <- 7L
#' n_inputs <- 2L
#' # get random "ids" for input
#' t_ids <- matrix(sample(2:vs, size = mpe * n_inputs, replace = TRUE),
#'   nrow = n_inputs, ncol = mpe
#' )
#' ttype_ids <- matrix(rep(1L, mpe * n_inputs), nrow = n_inputs, ncol = mpe)
#'
#' model <- embeddings_bert(
#'   embedding_size = emb_size,
#'   max_position_embeddings = mpe,
#'   vocab_size = vs
#' )
#' model(
#'   torch::torch_tensor(t_ids),
#'   torch::torch_tensor(ttype_ids)
#' )
#' @export
embeddings_bert <- torch::nn_module(
  "embeddings_bert",
  initialize = function(embedding_size,
                        max_position_embeddings,
                        vocab_size,
                        token_type_vocab_size = 2L,
                        hidden_dropout = 0.1) {
    self$word_embeddings <- torch::nn_embedding(
      num_embeddings = vocab_size,
      embedding_dim = embedding_size
    )

    self$token_type_embeddings <- torch::nn_embedding(
      num_embeddings = token_type_vocab_size,
      embedding_dim = embedding_size
    )

    self$position_embeddings <- position_embedding(
      embedding_size = embedding_size,
      max_position_embeddings = max_position_embeddings
    )

    self$layer_norm <- torch::nn_layer_norm(
      normalized_shape = embedding_size,
      eps = 1e-12 # cf BERT
    )

    self$dropout <- torch::nn_dropout(p = hidden_dropout)
  },
  forward = function(token_ids, token_type_ids) {
    token_shape <- token_ids$shape
    token_type_shape <- token_type_ids$shape

    # number of tokens in input is always the last dimension (which might be the
    # only dimension if the batch d is dropped). I think this is actually
    # over-engineered now but this way we protect against accidentally calling a
    # non-existant dimension.
    input_length <- token_shape[[length(token_shape)]]

    # ...should match!
    input_length2 <- token_type_shape[[length(token_type_shape)]]

    # at most. This is the max_position_embeddings, ie the longest allowed
    # sequence.
    input_length3 <- self$position_embeddings$weight$shape[[1]]

    if (input_length != input_length2) {
      stop("Shape of token_ids should match shape of token_type_ids.")
    }
    if (input_length <= input_length3) {
      seq_len_cap <- input_length # truncate to actual input sequence length
    } else {
      stop("Length of input exceeds maximum.")
      # If truncation should be ok, it should happen before here.
    }

    word_emb_output <- self$word_embeddings(token_ids)
    tt_emb_output <- self$token_type_embeddings(token_type_ids)
    pos_emb_output <- self$position_embeddings(seq_len_cap)

    embedding_output <- word_emb_output + tt_emb_output + pos_emb_output

    output <- self$layer_norm(embedding_output)

    output <- self$dropout(output)
    return(output)
  }
)
