

#' Project, Add, and Normalize
#'
#' Takes in two tensors, an "input" and a "residual". Applies a linear projector
#' to the input (changing the size to match residual), performs dropout, adds
#' the result to the residual, then applies layer normalization to the sum.
#'
#' @param input_size Integer; the size of input tensor.
#' @param output_size Integer; the size of output tensor (must match residual).
#' @param p_dropout Numeric; dropout probability applied after projection.
#'
#' @section Shape:
#'
#' Make this right.
#' - Input: \eqn{(N, *)}
#' - Output: \eqn{(N, *)} (same shape as input)
#'
#' @examples
#'
#' @export
proj_add_norm <- torch::nn_module(
  "proj_add_norm",
  # find better names for dimensions here
  initialize = function(input_size, output_size, p_dropout = 0.1) {
    self$dense <- torch::nn_linear(input_size, output_size)
    self$dropout <- torch::nn_dropout(p = p_dropout)
    # self$layer_norm <- custom_layer_norm(hidden_size)
    self$layer_norm <- torch::nn_layer_norm(
      normalized_shape = output_size,
      eps = 1e-12 # cf BERT
    )
  },

  forward = function(input, residual) {
    output <- self$dense(input)
    output <- self$dropout(output)
    output <- self$layer_norm(output + residual)
    return(output)
  }
)