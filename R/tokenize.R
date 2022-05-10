#' @export
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
        token_ids_matrix = simplify_bert_token_list(
          token_ids_list = tokenized_text,
          n_tokens = n_tokens
        ),
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

#' @export
simplify_bert_token_list <- function(token_ids_list,
                                     n_tokens = length(token_ids_list[[1]])) {
  # Since we're guaranteed that each token vector has length == n_tokens, we can
  # simply flatten the list and convert to matrix. We intenionally return a
  # matrix with rows = n_tokens and columns = N to match the dimensions expected
  # in torch::nn_multihead_attention
  return(
    matrix(
      # Add 1 for torch!
      unlist(token_ids_list) + 1L,
      nrow = n_tokens
    )
  )
}
