# Copyright 2021 Bedford Freeman & Worth Pub Grp LLC DBA Macmillan Learning.
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

#' BERT-Style Attention
#'
#' Takes in an input tensor (e.g. sequence of token embeddings), applies an
#' attention layer and layer-norms the result. Returns both the attention
#' weights and the output embeddings.
#'
#' @inheritParams model_bert
#'
#' @section Shape:
#'
#' Inputs:
#'
#' - input: \eqn{(sequence_length, *, embedding_size)}
#'
#' - optional mask: \eqn{(*, sequence_length)}
#'
#' Output:
#'
#' - embeddings: \eqn{(sequence_length, *, embedding_size)}
#'
#' - weights: \eqn{(*, n_head, sequence_length, sequence_length)}
#'
#' @examples
#' emb_size <- 4L
#' seq_len <- 3L
#' n_head <- 2L
#' batch_size <- 2L
#'
#' model <- attention_bert(embedding_size = emb_size,
#'                         n_head = n_head)
#' # get random values for input
#' input <- array(sample(-10:10,
#'                       size = batch_size * seq_len * emb_size,
#'                       replace = TRUE) / 10,
#'                dim = c(seq_len, batch_size, emb_size))
#' input <- torch::torch_tensor(input)
#' model(input)
#' @export
attention_bert <- torch::nn_module(
  "attention",
  initialize = function(embedding_size, n_head, attention_dropout = 0.1) {
    if (embedding_size %% n_head != 0) {
      stop("embedding_size should be a multiple of n_head.")
    }
    # model variable name! ("self" attention)
    self$self <- torch::nn_multihead_attention(embed_dim = embedding_size,
                                               num_heads = n_head,
                                               dropout = attention_dropout)
    # The built-in attention module already does a projection on the output, so
    # we just want to add residual and normalize.
    # model variable name!
    self$output.layer_norm <-  torch::nn_layer_norm(
      normalized_shape = embedding_size,
      eps = 1e-12 # cf BERT
    )
  },

  forward = function(input, mask = NULL) {
    # pass along the mask here. TRUE means ignore..
    output <- self$self(input, input, input,
                        key_padding_mask = mask,
                        avg_weights = FALSE)
    att_wts <- output[[2]]
    output <- self$output.layer_norm(output[[1]] + input)
    return(list("embeddings" = output,
                "weights" = att_wts))
  }
)
