#' BERT-Style Attention
#'
#' Takes in an input tensor (e.g. sequence of token embeddings), applies an
#' attention layer and layer-norms the result. Returns both the attention
#' weights and the output embeddings.
#'
#' @inheritParams BERT
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
#' model <- bert_attention(embedding_size = emb_size,
#'                         n_head = n_head)
#' # get random values for input
#' input <- array(sample(-10:10,
#'                       size = batch_size * seq_len * emb_size,
#'                       replace = TRUE) / 10,
#'                dim = c(seq_len, batch_size, emb_size))
#' input <- torch::torch_tensor(input)
#' model(input)
#' @export
bert_attention <- torch::nn_module(
  "attention",
  initialize = function(embedding_size, n_head, attention_dropout = 0.1) {
    if (embedding_size %% n_head != 0) {
      stop("embedding_size should be a multiple of n_head.")
    }
    self$attention <- torch::nn_multihead_attention(embed_dim = embedding_size,
                                                    num_heads = n_head,
                                                    dropout = attention_dropout)
    # The built-in attention module already does a projection on the output, so
    # we just want to add residual and normalize.
    self$layernorm <-  torch::nn_layer_norm(
      normalized_shape = embedding_size,
      eps = 1e-12 # cf BERT
    )
  },

  forward = function(input, mask = NULL) {
    # pass along the mask here. TRUE means ignore..
    output <- self$attention(input, input, input,
                             key_padding_mask = mask,
                             avg_weights = FALSE)
    att_wts <- output[[2]]
    output <- self$layernorm(output[[1]] + input)
    return(list("embeddings" = output,
                "weights" = att_wts))
  }
)

