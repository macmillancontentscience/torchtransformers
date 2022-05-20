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
#' @param increment_index Logical; if TRUE, add 1L to all token ids to convert
#'   from the Python-inspired 0-indexed standard to the torch 1-indexed
#'   standard.
#' @param pad_token Character scalar; the token to use for padding. Must be
#'   present in the supplied vocabulary.
#' @param cls_token Character scalar; the token to use at the start of each
#'   example. Must be present in the supplied vocabulary, or \code{NULL}.
#' @param sep_token Character scalar; the token to use at the end of each
#'   segment within each example. Must be present in the supplied vocabulary, or
#'   \code{NULL}.
#' @param tokenizer The tokenizer function to use to break up the text. It must
#'   have a \code{vocab} argument.
#' @param vocab The vocabulary to use to tokenize the text. This vocabulary must
#'   include the \code{pad_token, cls_token, and sep_token}.
#' @param ... Additional arguments passed on to the tokenizer.
#'
#' @return A list containing a list or matrix of token ids, and a list or matrix
#'   of token type ids.
#' @export
#'
#' @examples
#' tokenize_bert(c("A first example.", "Another one."))
tokenize_bert <- function(text,
                          n_tokens = 64L,
                          simplify = TRUE,
                          increment_index = TRUE,
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
                                  simplify = TRUE,
                                  increment_index = TRUE,
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
                               simplify = TRUE,
                               increment_index = TRUE,
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

  # TODO when we actually implement this: Technically we should error if any of
  # them have more segments than n_tokens.
}

#' @export
tokenize_bert.character <- function(text,
                                    n_tokens = 64L,
                                    simplify = TRUE,
                                    increment_index = TRUE,
                                    pad_token = "[PAD]",
                                    cls_token = "[CLS]",
                                    sep_token = "[SEP]",
                                    tokenizer = wordpiece::wordpiece_tokenize,
                                    vocab = wordpiece.data::wordpiece_vocab(),
                                    ...) {
  # We need to have room for at least 1 token from each sequence.
  stopifnot(n_tokens > length(sep_token) + length(cls_token))

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

  # Note: The length here is to allow this to still work when sep_index is NULL.
  # Since this method is for character vectors, everything has the same number
  # of SEP tokens, so we don't need to produce this as a vector. It will be
  # different for lists.
  length_without_seps <- n_tokens - length(sep_index)

  to_truncate <- lengths(tokenized_text) > length_without_seps
  if (any(to_truncate)) {
    # Truncate the ones that don't have room for sep. Note: This ONLY works for
    # single-segment sequences.
    tokenized_text[to_truncate] <- purrr::map(
      tokenized_text[to_truncate],
      ~.x[1:length_without_seps]
    )
  }

  # Add sep to the end of each segment.
  # Only implemented for single segment right now.
  tokenized_text <- purrr::map(tokenized_text, ~c(.x, sep_index))

  # Add padding to short sequences.
  differences <- n_tokens - lengths(tokenized_text)
  tokenized_text <- purrr::map2(
    tokenized_text,
    differences,
    ~c(.x, rep(pad_index, .y))
  )

  # For this case, token_types are all 1L (there's only one sequence).
  token_types <- purrr::map(
    tokenized_text,
    ~rep(1L, length(.x))
  )

  # The return process is the same from here on out regardless of which method
  # was used, so we call a function to deal with the remaining bits.
  return(
    .finalize_bert_tokens(
      tokenized_text = tokenized_text,
      token_types = token_types,
      increment_index = increment_index,
      simplify = simplify
    )
  )

}

#' Clean and Return BERT Tokens
#'
#' @param tokenized_text A list of integer vectors of token ids.
#' @param token_types A list of integer vectors indicating which segment tokens
#'   belong to.
#' @inherit tokenize_bert return params
#' @keywords internal
.finalize_bert_tokens <- function(tokenized_text,
                                  token_types,
                                  increment_index,
                                  simplify) {
  # Add 1 when necessary.
  if (increment_index) {
    tokenized_text <- increment_list_index(tokenized_text)
  }

  if (simplify) {
    return(
      list(
        token_ids = simplify_bert_token_list(tokenized_text),
        token_type_ids = simplify_bert_token_list(token_types)
      )
    )
  } else {
    return(
      list(
        token_ids = tokenized_text,
        token_type_ids = token_types
      )
    )
  }
}

#' Simplify Token ID List to Matrix
#'
#' BERT-like models expect a matrix of tokens for each example. This function
#' converts a list of equal-length integer vectors (such as a padded list of
#' tokens) into such a matrix.
#'
#' @param list_of_integers A list of integer vectors. Each integer should have
#'   the same length.
#'
#' @return A matrix of token ids. Rows are text sequences, and columns are
#'   tokens.
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
simplify_bert_token_list <- function(list_of_integers) {
  stopifnot(
    is.list(list_of_integers),
    purrr::every(list_of_integers, is.integer)
  )
  n_tokens = length(list_of_integers[[1]])

  stopifnot(
    all(lengths(list_of_integers) == n_tokens)
  )

  # Since we're guaranteed that each token vector has length == n_tokens, we can
  # simply flatten the list and convert to matrix.
  return(
    t(
      matrix(
        unlist(list_of_integers),
        nrow = n_tokens
      )
    )
  )
}

#' Convert from Python Standard to torch
#'
#' The torch R package uses the R standard of starting counts at 1. Many
#' tokenizers use the Python standard of starting counts at 0. This function
#' converts a list of token ids provided by such a tokenizer to torch-friendly
#' values (by adding 1 to each id).
#'
#' @inheritParams simplify_bert_token_list
#'
#' @return The list of integers, with 1 added to each integer.
#' @export
#'
#' @examples
#' increment_list_index(
#'   list(
#'     1:5,
#'     2:6,
#'     3:7
#'   )
#' )
increment_list_index <- function(list_of_integers) {
  stopifnot(
    is.list(list_of_integers),
    purrr::every(list_of_integers, is.integer)
  )
  return(
    purrr::map(
      list_of_integers,
      ~.x + 1L
    )
  )
}
