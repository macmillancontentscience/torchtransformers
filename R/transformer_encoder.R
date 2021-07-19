

# transformer_encoder_single ----------------------------------------------


#' Single Transformer Layer
#'
#' Build a single layer of a BERT-style attention-based transformer.
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
#' model <- transformer_encoder_single_bert(embedding_size = emb_size,
#'                                     n_head = n_head)
#' # get random values for input
#' input <- array(sample(-10:10,
#'                       size = batch_size * seq_len * emb_size,
#'                       replace = TRUE) / 10,
#'                dim = c(seq_len, batch_size, emb_size))
#' input <- torch::torch_tensor(input)
#' model(input)
#' @export
transformer_encoder_single_bert <- torch::nn_module(
  "transformer_encoder_single",
  initialize = function(embedding_size,
                        intermediate_size = 4 * embedding_size,
                        n_head,
                        hidden_dropout = 0.1,
                        attention_dropout = 0.1) {
    self$attention <- attention_bert(embedding_size = embedding_size,
                                     n_head = n_head,
                                     attention_dropout = attention_dropout)
    # https://github.com/macmillancontentscience/torchtransformers/issues/4
    self$intermediate <- torch::nn_linear(embedding_size, intermediate_size)

    self$projector <- proj_add_norm(input_size = intermediate_size,
                                    output_size = embedding_size,
                                    hidden_dropout = hidden_dropout)
  },

  forward = function(input, mask = NULL) {
    attention_output_and_probs <- self$attention(input, mask)
    attention_output <- attention_output_and_probs$embeddings
    attention_probs <- attention_output_and_probs$weights

    intermediate_output <- self$intermediate(attention_output)
    intermediate_output <- torch::nnf_gelu(intermediate_output)

    layer_output <- self$projector(input = intermediate_output,
                                   residual = attention_output)

    return(list("embeddings" = layer_output, "weights" = attention_probs))
  }
)


# transformer_encoder -----------------------------------------------------


#'Transformer Stack
#'
#'Build a BERT-style multi-layer attention-based transformer.
#'
#' @inheritParams model_bert
#'
#'@section Shape:
#'
#'  Inputs:
#'
#' With each input token list of length `sequence_length`:
#'
#'  - input: \eqn{(sequence_length, *, embedding_size)}
#'
#'  - optional mask: \eqn{(*, sequence_length)}
#'
#'  Output:
#'
#'  - embeddings: list of \eqn{(sequence_length, *, embedding_size)} for each
#'  transformer layer.
#'
#'  - weights: list of \eqn{(*, n_head, sequence_length, sequence_length)} for
#'  each transformer layer.
#'
#' @examples
#' emb_size <- 4L
#' seq_len <- 3L
#' n_head <- 2L
#' n_layer <- 5L
#' batch_size <- 2L
#'
#' model <- transformer_encoder_bert(embedding_size = emb_size,
#'                              n_head = n_head,
#'                              n_layer = n_layer)
#' # get random values for input
#' input <- array(sample(-10:10,
#'                       size = batch_size * seq_len * emb_size,
#'                       replace = TRUE) / 10,
#'                dim = c(seq_len, batch_size, emb_size))
#' input <- torch::torch_tensor(input)
#' model(input)
#' @export
transformer_encoder_bert <- torch::nn_module(
  "transformer_encoder",
  initialize = function(embedding_size,
                        intermediate_size = 4 * embedding_size,
                        n_layer,
                        n_head,
                        hidden_dropout = 0.1,
                        attention_dropout = 0.1) {
    self$layer_indices <- seq_len(n_layer)

    self$encoder_layers <- torch::nn_module_list()

    for (layer_index in self$layer_indices) {
      # Right now we use default naming. Might want to give explicit names.
      encoder_layer <- transformer_encoder_single_bert(
        embedding_size = embedding_size,
        intermediate_size = intermediate_size,
        n_head = n_head,
        hidden_dropout = hidden_dropout,
        attention_dropout = attention_dropout)
      self$encoder_layers$append(encoder_layer)
    }
  },

  forward = function(input, mask = NULL) {
    layer_output <- input # output from the *previous* layer
    layer_output_all <- list()
    attention_probs_all <- list()
    for (layer_index in self$layer_indices) {
      encoder_layer <- self$encoder_layers[[layer_index]]
      layer_input <- layer_output
      layer_output_and_probs <- encoder_layer(layer_input, mask)
      layer_output <- layer_output_and_probs$embeddings
      attention_probs <- layer_output_and_probs$weights
      # These will be 1-indexed.
      layer_output_all[[layer_index]] <- layer_output
      attention_probs_all[[layer_index]] <- attention_probs
    }

    # It's probably best to just always return all the layers.
    final_output <- list("embeddings" = layer_output_all,
                         "weights" = attention_probs_all)

    return(final_output)
  }
)
