#' Create Position Embeddings
#'
#' Position embeddings are how BERT-like language models represent the order of
#' input tokens. Each token gets a position embedding vector which is completely
#' determined by its position index. Because these embeddings don't depend on
#' the actual input, it is implemented by simply initializing a matrix of
#' weights.
#'
#' @param embedding_size Integer; the size of the embedding space.
#' @param max_position_embeddings Integer; the maximum number of positions
#'   supported.
#'
#' @section Shape:
#'
#'   Inputs:
#'
#'   No input tensors. Optional input parameter to limit number of positions...
#'
#'   Output:
#'
#'   - \eqn{(max_position_embeddings, *, embedding_size)}
#'
#' @examples
#'
#' @export
position_embedding <- torch::nn_module(
  "position_embedding",
  initialize = function(embedding_size, max_position_embeddings) {
    # promote this to proper param?
    std <- 0.02
    # todo on GPU: check that device is set properly!
    self$pos_emb <- torch::torch_empty(max_position_embeddings,
                             embedding_size)
    torch::nn_init_trunc_normal_(self$pos_emb, std = std, a = -2*std, b = 2*std)
    torch::nn_parameter(self$pos_emb)
  },

  forward = function(seq_len_cap = NULL) {
    # When the embedding layer is actually called, we can restrict number of
    # positions to be smaller than the initialized size. (e.g. if you know you
    # only need length-20 sequences, you can save a lot of time.)
    pe <- self$pos_emb

    if (!is.null(seq_len_cap)) {
      mpe <- pos_emb$shape[[1]]
      if (seq_len_cap <= mpe) {
        pe <- self$pos_emb[1:seq_len_cap, ]
      } else {
        message("seq_len_cap (", seq_len_cap,
                ") is bigger than max_position_embeddings (",
                max_position_embeddings, "), and will be ignored.")
      }
    }

    # We'll need to broadcast the embeddings to every example in the batch, so
    # unsqueeze that dimension. (Is this always the second dimension?)
    return(pe$unsqueeze(2))
  }
)

