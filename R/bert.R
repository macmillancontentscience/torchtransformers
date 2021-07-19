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
#'   - token_ids: \eqn{(sequence_length, *)}
#'
#'   - token_type_ids: \eqn{(sequence_length, *)}
#'
#'   Output:
#'
#'   - initial_embeddings: \eqn{(sequence_length, *, embedding_size)}
#'
#'   - output_embeddings: list of \eqn{(sequence_length, *, embedding_size)} for
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
#' model <- model_bert(embedding_size = emb_size,
#'               n_layer = n_layer,
#'               n_head = n_head,
#'               max_position_embeddings = mpe,
#'               vocab_size = vocab_size)
#'
#' n_inputs <- 2
#' n_token_max <- 128L
#' # get random "ids" for input
#' t_ids <- matrix(sample(2:vocab_size, size = n_token_max * n_inputs,
#'                       replace = TRUE),
#'                nrow = n_token_max, ncol = n_inputs)
#' ttype_ids <- matrix(rep(1L, n_token_max * n_inputs),
#'                nrow = n_token_max, ncol = n_inputs)
#' model(torch::torch_tensor(t_ids),
#'       torch::torch_tensor(ttype_ids))
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
      hidden_dropout = hidden_dropout)

    self$encoder <- transformer_encoder_bert(
      embedding_size = embedding_size,
      intermediate_size = intermediate_size,
      n_layer = n_layer,
      n_head = n_head,
      hidden_dropout = hidden_dropout,
      attention_dropout = attention_dropout)
  },
  forward = function(token_ids, token_type_ids) {
    mask <- torch::torch_transpose(token_ids == 1, 1, 2)

    emb_out <- self$embeddings(token_ids, token_type_ids)
    output <- self$encoder(emb_out, mask)

    return(list("initial_embeddings" = emb_out,
                "output_embeddings" = output$embeddings,
                "attention_weights" = output$weights))
  }
)

