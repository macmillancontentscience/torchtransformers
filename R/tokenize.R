#' Prepare Text for a BERT Model
#'
#' To be used in a BERT-style model, text must be tokenized. In addition, text
#' is optionally preceded by a \code{cls_token}, and segments are ended with a
#' \code{sep_token}. Finally each example must be padded with a
#' \code{pad_token}, or truncated if necessary (preserving the wrapper tokens).
#' Many use cases use a matrix of tokens x examples, which can be extracted
#' directly with the \code{simplify} argument.
#'
#' @param text Character or list of characters; the text to prepare. Right now
#'   only character or lists of length-1 characters are supported, but we will
#'   soon also allow the text to be provided as a list of length-N character
#'   vectors (usually 1 or 2), which will be combined but separated with
#'   \code{sep_token}.
#' @param n_tokens Integer scalar; the number of tokens expected for each
#'   example.
#' @param simplify Logical scalar; whether to return the result as a list
#'   (\code{FALSE}), or as a matrix. The matrix returned is currently
#'   \code{n_tokens} rows by \code{length(text)} columns, but we plan to
#'   transpose that in an upcoming change to the overall package API.
#' @param pad_token Character scalar; the token to use for padding. Must be
#'   present in the supplied vocabulary.
#' @param cls_token Character scalar; the token to use at the start of each
#'   example. Must be present in the supplied vocabulary, or \code{NULL}.
#' @param sep_token Character scalar; the token to use at the end of each
#'   segment within each example. Must be present in the supplied vocabulary, or
#'   \code{NULL}.
#' @param tokenizer The tokenizer function to use to break up the text. It must
#'   have a \code{vocab} argument.
#' @param vocab The vocabulary to use to tokenize the text.
#' @param ... Additional arguments passed on to the tokenizer.
#'
#' @return A list of token indices, or a matrix.
#' @export
#'
#' @examples
#' tokenize_bert(c("A first example.", "Another one."))
tokenize_bert <- function(text,
                          n_tokens = 64L,
                          simplify = FALSE,
                          pad_token = "[PAD]",
                          cls_token = "[CLS]",
                          sep_token = "[SEP]",
                          tokenizer = wordpiece::wordpiece_tokenize,
                          vocab = wordpiece.data::wordpiece_vocab(),
                          ...) {
  UseMethod("tokenize_bert", text)
}

#' @export
tokenize_bert.default <- function(text,
                                  n_tokens = 64L,
                                  simplify = FALSE,
                                  pad_token = "[PAD]",
                                  cls_token = "[CLS]",
                                  sep_token = "[SEP]",
                                  tokenizer = wordpiece::wordpiece_tokenize,
                                  vocab = wordpiece.data::wordpiece_vocab(),
                                  ...) {
  stop("text must be a character vector or a list of character vectors.")
}

#' @export
tokenize_bert.list <- function(text,
                               n_tokens = 64L,
                               simplify = FALSE,
                               pad_token = "[PAD]",
                               cls_token = "[CLS]",
                               sep_token = "[SEP]",
                               tokenizer = wordpiece::wordpiece_tokenize,
                               vocab = wordpiece.data::wordpiece_vocab(),
                               ...) {
  if (all(lengths(text) == 1)) {
    tokenize_bert(
      unlist(text),
      n_tokens,
      simplify,
      pad_token,
      cls_token,
      sep_token,
      tokenizer,
      vocab,
      ...
    )
  } else {
    stop("We have not yet implemented this for multiple sequences.")
  }
}

#' @export
tokenize_bert.character <- function(text,
                                    n_tokens = 64L,
                                    simplify = FALSE,
                                    pad_token = "[PAD]",
                                    cls_token = "[CLS]",
                                    sep_token = "[SEP]",
                                    tokenizer = wordpiece::wordpiece_tokenize,
                                    vocab = wordpiece.data::wordpiece_vocab(),
                                    ...) {
  # We 0-index to match python implementations. Later we add 1 across the board
  # for {torch}, but at first we match the 0-indexed vocabulary.
  pad_index <- fastmatch::fmatch(pad_token, vocab) - 1L
  names(pad_index) <- pad_token
  cls_index <- fastmatch::fmatch(cls_token, vocab) - 1L
  names(cls_index) <- cls_token
  sep_index <- fastmatch::fmatch(sep_token, vocab) - 1L
  names(sep_index) <- sep_token

  # If any of those are NA, that means they aren't in the supplied vocab. I'm
  # lumping these together for now but eventually make prettier errors with
  # rlang.
  if (
    any(
      is.na(pad_index),
      !length(pad_index),
      is.na(cls_index),
      is.na(sep_index)
    )
  ) {
    stop("The pad_token, cls_token, and sep_token must be in vocab.")
  }

  tokenized_text <- tokenizer(text, vocab = vocab, ...)

  # Add cls_index to the start of each entry.
  tokenized_text <- purrr::map(tokenized_text, ~c(cls_index, .x))

  sep_length <- length(sep_index) * lengths(text)
  length_without_seps <- n_tokens - sep_length
  # TODO: Technically we should error if any of them have more sequences than
  # n_tokens.
  to_truncate <- lengths(tokenized_text) > length_without_seps
  if (any(to_truncate)) {
    # Truncate the ones that don't have room for sep.
    tokenized_text[to_truncate] <- purrr::map2(
      tokenized_text[to_truncate],
      length_without_seps[to_truncate],
      ~.x[1:.y]
    )
  }

  # Add sep to the end of each sequence.
  # Only implemented for single sequence right now.
  tokenized_text <- purrr::map(tokenized_text, ~c(.x, sep_index))

  # Add padding to short sequences.
  differences <- n_tokens - lengths(tokenized_text)
  tokenized_text <- purrr::map2(
    tokenized_text,
    differences,
    ~c(.x, rep(pad_index, .y))
  )

  # For this case, token_types are all 1L (there's only one sequence). Use the
  # same rows = n_tokens/cols = N rule that we inherit from
  # torch::nn_multihead_attention
  token_types <- matrix(
    1L,
    nrow = n_tokens,
    ncol = length(text)
  )

  if (simplify) {
    return(
      list(
        token_ids_matrix = simplify_bert_token_list(tokenized_text),
        token_type_ids = token_types
      )
    )
  } else {
    return(
      list(
        token_ids_list = tokenized_text,
        token_type_ids = token_types
      )
    )
  }
}

#' Simplify Token ID List to Matrix
#'
#' BERT-like models expect a matrix of tokens for each example. This function
#' currently supplies a matrix with \code{n_tokens} rows and
#' \code{length(token_ids_list)} columns, but we plan to transpose those in an
#' upcoming change to this API.
#'
#' @param token_ids_list A list of integer vectors.
#' @param for_torch Logical; if TRUE, add 1L to all token ids to convert from
#'   the Python-based 0-indexed standard to the torch standard.
#'
#' @return A matrix of token ids.
#' @export
#'
#' @examples
#' simplify_bert_token_list(
#'   list(
#'     1:5,
#'     2:6,
#'     3:7
#'   )
#' )
simplify_bert_token_list <- function(token_ids_list, for_torch = TRUE) {
  n_tokens = length(token_ids_list[[1]])

  stopifnot(
    all(lengths(token_ids_list) == n_tokens),
    is.logical(for_torch),
    length(for_torch) == 1
  )

  # Since we're guaranteed that each token vector has length == n_tokens, we can
  # simply flatten the list and convert to matrix. We intentionally return a
  # matrix with rows = n_tokens and columns = N to match the dimensions expected
  # in torch::nn_multihead_attention
  return(
    matrix(
      # Add 1 for torch!
      unlist(token_ids_list) + as.integer(for_torch),
      nrow = n_tokens
    )
  )
}
