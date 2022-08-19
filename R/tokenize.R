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

#' Shortcut to make sure we're using wordpiece
#'
#' @param vocab
#'
#' @return The vocab or wordpiece_vocab.
#' @keywords internal
.default_vocab <- function(vocab) {
  return(vocab %||% wordpiece.data::wordpiece_vocab())
}

#' Shortcut to make sure we're using wordpiece
#'
#' @param tokenizer
#'
#' @return The vocab or wordpiece_tokenize.
#' @keywords internal
.default_tokenizer <- function(tokenizer) {
  return(tokenizer %||% wordpiece::wordpiece_tokenize)
}

#' Tokenize a single vector of text
#'
#' @param text A character vector, or a list of length-1 character vectors.
#' @inherit tokenize_bert return params
#' @keywords internal
.tokenize_bert_single <- function(text,
                                  n_tokens = 64L,
                                  increment_index = TRUE,
                                  pad_token = "[PAD]",
                                  cls_token = "[CLS]",
                                  sep_token = "[SEP]",
                                  tokenizer = wordpiece::wordpiece_tokenize,
                                  vocab = wordpiece.data::wordpiece_vocab(),
                                  tokenizer_options = NULL) {
  UseMethod(".tokenize_bert_single", text)
}

#' @export
.tokenize_bert_single.default <- function(text,
                                          n_tokens = 64L,
                                          increment_index = TRUE,
                                          pad_token = "[PAD]",
                                          cls_token = "[CLS]",
                                          sep_token = "[SEP]",
                                          tokenizer = wordpiece::wordpiece_tokenize,
                                          vocab = wordpiece.data::wordpiece_vocab(),
                                          tokenizer_options = NULL) {
  rlang::abort(
    message = "text must be a character vector or a list of character vectors.",
    class = "bad_text_to_tokenize"
  )
}

#' @export
.tokenize_bert_single.list <- function(text,
                                       n_tokens = 64L,
                                       increment_index = TRUE,
                                       pad_token = "[PAD]",
                                       cls_token = "[CLS]",
                                       sep_token = "[SEP]",
                                       tokenizer = wordpiece::wordpiece_tokenize,
                                       vocab = wordpiece.data::wordpiece_vocab(),
                                       tokenizer_options = NULL) {
  # TODO: Ideally we should convert a list to parallel vectors, and then call
  # tokenize_bert. Even if segment lengths are uneven, it should deal with that
  # as long as we put in NAs.
  if (all(lengths(text) == 1)) {
    .tokenize_bert_single(
      unlist(text),
      n_tokens = n_tokens,
      pad_token = pad_token,
      cls_token = cls_token,
      sep_token = sep_token,
      tokenizer = tokenizer,
      vocab = vocab,
      tokenizer_options = tokenizer_options
    )
  } else {
    rlang::abort(
      message = paste(
        "We have not yet implemented tokenization for lists of sequences.",
        "Provide each sequence as a separate argument to tokenize_bert.",
        sep = "\n"
      ),
      class = "tokenize_list_of_sequences"
    )
  }

  # TODO when we actually implement this: Technically we should error if any of
  # them have more segments than n_tokens.
}

#' @export
.tokenize_bert_single.character <- function(text,
                                            n_tokens = 64L,
                                            increment_index = TRUE,
                                            pad_token = "[PAD]",
                                            cls_token = "[CLS]",
                                            sep_token = "[SEP]",
                                            tokenizer = wordpiece::wordpiece_tokenize,
                                            vocab = wordpiece.data::wordpiece_vocab(),
                                            tokenizer_options = NULL) {
  # We 0-index to match python implementations. Later we add 1 across the board
  # for {torch}, but at first we match the 0-indexed vocabulary.
  pad_index <- fastmatch::fmatch(pad_token, vocab) - 1L
  names(pad_index) <- pad_token
  cls_index <- fastmatch::fmatch(cls_token, vocab) - 1L
  names(cls_index) <- cls_token
  sep_index <- fastmatch::fmatch(sep_token, vocab) - 1L
  names(sep_index) <- sep_token

  tokenized_text <- do.call(
    tokenizer,
    c(
      list(
        text,
        vocab = vocab
      ),
      tokenizer_options
    )
  )

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
      increment_index = increment_index
    )
  )
}

#' Clean and Return BERT Tokens
#'
#' @param tokenized_text A list of integer vectors of token ids.
#' @param token_types A list of integer vectors indicating which segment tokens
#'   belong to.
#' @inherit .tokenize_bert_single return params
#' @keywords internal
.finalize_bert_tokens <- function(tokenized_text,
                                  token_types,
                                  increment_index) {
  # Add 1 when necessary.
  if (increment_index) {
    tokenized_text <- increment_list_index(tokenized_text)
  }

  token_names <- purrr::map(tokenized_text, names)

  return(
    list(
      token_ids = simplify_bert_token_list(tokenized_text),
      token_type_ids = simplify_bert_token_list(token_types),
      token_names = simplify_bert_token_list(token_names)
    )
  )
}

#' Simplify Token List to Matrix
#'
#' BERT-like models expect a matrix of tokens for each example. This function
#' converts a list of equal-length vectors (such as a padded list of tokens)
#' into such a matrix.
#'
#' @param token_list A list of vectors. Each vector should have the same length.
#'
#' @return A matrix of tokens. Rows are text sequences, and columns are tokens.
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
simplify_bert_token_list <- function(token_list) {
  stopifnot(
    is.list(token_list)
  )
  n_tokens <- length(token_list[[1]])

  stopifnot(
    all(lengths(token_list) == n_tokens)
  )

  # Since we're guaranteed that each token vector has length == n_tokens, we can
  # simply flatten the list and convert to matrix.
  return(
    t(
      matrix(
        unlist(token_list),
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

#' Prepare Text for a BERT Model
#'
#' To be used in a BERT-style model, text must be tokenized. In addition, text
#' is optionally preceded by a \code{cls_token}, and segments are ended with a
#' \code{sep_token}. Finally each example must be padded with a
#' \code{pad_token}, or truncated if necessary (preserving the wrapper tokens).
#' Many use cases use a matrix of tokens x examples, which can be extracted
#' directly with the \code{simplify} argument.
#'
#' @param ... One or more character vectors or lists of character vectors.
#'   Currently we support a single character vector, two parallel character
#'   vectors, or a list of length-1 character vectors. If two vectors are
#'   supplied, they are combined pairwise and separated with \code{sep_token}.
#' @param n_tokens Integer scalar; the number of tokens expected for each
#'   example.
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
#' @param tokenizer_options A named list of additional arguments to pass on to
#'   the tokenizer.
#'
#' @return An object of class "bert_tokens", which is a list containing a matrix
#'   of token ids, a matrix of token type ids, and a matrix of token names.
#' @export
#'
#' @examples
#' tokenize_bert(
#'   c("The first premise.", "The second premise."),
#'   c("The first hypothesis.", "The second hypothesis.")
#' )
tokenize_bert <- function(...,
                          n_tokens = 64L,
                          increment_index = TRUE,
                          pad_token = "[PAD]",
                          cls_token = "[CLS]",
                          sep_token = "[SEP]",
                          tokenizer = wordpiece::wordpiece_tokenize,
                          vocab = wordpiece.data::wordpiece_vocab(),
                          tokenizer_options = NULL) {
  # Use uncased wordpiece if they aren't specific.
  tokenizer <- .default_tokenizer(tokenizer)
  vocab <- .default_vocab(vocab)

  dots <- list(...)

  # Fail if the inputs aren't the same length as each other. Eventually this
  # error message should explain how to deal with different segment lengths,
  # although I'm not sure if there's any real-world use for that.
  stopifnot(
    length(unique(lengths(dots))) == 1
  )

  n_segments <- length(dots)

  # We need to have room for at least 1 token from each segment in each
  # sequence. The 1L is to account for having at least one actual token *per
  # segment.*
  stopifnot(
    n_tokens >= n_segments * (length(sep_token) + 1L) + length(cls_token)
  )

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

  # TODO: Pass those through to .tokenize_bert_single so we don't duplicate
  # code.

  if (n_segments == 1) {
    # This is the simple case I mostly already dealt with. There are some cases
    # where they might come back here, though (if the one thing they pass in is
    # a structure list).
    return(
      .tokenize_bert_single(
        text = dots[[1]],
        n_tokens = n_tokens,
        increment_index = increment_index,
        pad_token = pad_token,
        cls_token = cls_token,
        sep_token = sep_token,
        tokenizer = tokenizer,
        vocab = vocab,
        tokenizer_options = tokenizer_options
      )
    )
  } else if (n_segments > 2) {
    msg <- paste(
      "Right now we support at most 2 segments.",
      "We can add the ability to support more segments rapidly if needed.",
      "Please file an issue if you need this feature.",
      sep = "\n"
    )
    stop(msg)
  }

  # Everything below here assumes there are two segments. It can almost
  # definitely be generalized, and much of it already is.

  # Tokenize everything.
  tokenized_segments <- purrr::map(
    dots,
    function(this_dot, vocab, tokenizer_options) {
      do.call(
        tokenizer,
        c(
          list(
            this_dot,
            vocab = vocab
          ),
          tokenizer_options
        )
      )
    },
    vocab = vocab,
    tokenizer_options = tokenizer_options
  )

  # We could use this information to split the problem (truncate ones that are
  # too long, just merge ones that aren't) but I'm not sure it's worthwhile. Not
  # deleting this code quite yet because it feels like it's PROBABLY worth it;
  # generally you want to set the limits such that most things don't get
  # truncated.
  # segment_lengths <- purrr::map(tokenized_segments, lengths)
  # tokenized_text_lengths <- purrr::pmap_int(segment_lengths, sum)
  # n_text <- length(tokenized_text_lengths)
  # text_and_types <- vector(mode = "list", length = n_text)

  # Process each "row" of tokens to combine the segments.
  text_and_types <- purrr::pmap(
    tokenized_segments,
    .combine_segments,
    cls_index = cls_index,
    sep_index = sep_index,
    pad_index = pad_index,
    n_tokens = n_tokens
  )

  token_ids <- purrr::map(text_and_types, ~.x$token_ids)
  token_type_ids <- purrr::map(text_and_types, ~.x$token_type_ids)

  # The return process is the same from here on out regardless of which method
  # was used, so we call a function to deal with the remaining bits.
  to_return <- .finalize_bert_tokens(
    tokenized_text = token_ids,
    token_types = token_type_ids,
    increment_index = increment_index
  )
  return(
    structure(to_return,
              # TODO: include metadata: tokenizer, vocab, options
              "class" = c("bert_tokens", class(to_return)))
  )
}

#' Combine a pair of segments
#'
#' @param ... Two lists of tokenized segments. In the future we will support any
#'   number of lists.
#' @param cls_index,sep_index,pad_index Named integer vectors for the special
#'   characters.
#' @inheritParams tokenize_bert
#'
#' @return A list with two components: token_ids and token_type_ids.
#' @keywords internal
.combine_segments <- function(...,
                              cls_index,
                              sep_index,
                              pad_index,
                              n_tokens) {
  these_segments <- list(...)

  # TODO: Get rid of any segments that are NULL, "", character(0), or NA.

  these_lengths <- lengths(these_segments)
  n_these_tokens <- sum(these_lengths)
  # This is always 2 right now and the code below assumes that fact, but it's
  # moving toward generalizability.
  n_segments <- length(these_segments)

  n_special_tokens <- n_segments * length(sep_index) + length(cls_index)
  max_real_tokens <- n_tokens - n_special_tokens

  # Strategy: Do any necessary trimming first. After that, adding cls, sep, and
  # padding is the same for whatever is left.
  if (n_these_tokens > max_real_tokens) {
    # This could happen (n_segments - 1) times but I just do it without a loop
    # since we know there are 2 segments at this point. I feel like there's
    # probably a way to do it in a single step but I haven't solved it yet.
    segments_to_fix <- seq_along(these_segments)
    per_segment <- max_real_tokens/length(these_segments)

    # Any segments that are less than that are ok as-is. When this is fully
    # implemented, remove their tokens from the available count and remove these
    # from the list to fix, then iterate.
    is_fixed <- these_lengths[segments_to_fix] <= per_segment

    # If any are fixed already, subtract their length from the the total.
    remaining_tokens <- max_real_tokens - sum(these_lengths[is_fixed])

    # Now we divide that total by however many are left (1 or 2 right now). Here
    # we'd need to iterate if there were more than 2 total, and deal with any
    # that are already below each new limit.
    per_segment <- remaining_tokens/sum(!is_fixed)

    # The first one gets any remainder in that.
    kept_tokens <- seq_len(ceiling(per_segment))
    these_segments[!is_fixed][[1]] <- these_segments[!is_fixed][[1]][kept_tokens]
    is_fixed[[1]] <- TRUE

    # Now deal with any remaining ones.
    if (any(!is_fixed)) {
      kept_tokens <- seq_len(floor(per_segment))
      these_segments[!is_fixed] <- purrr::map(
        these_segments[!is_fixed],
        ~.x[kept_tokens]
      )
    }
  }

  # Now add the specials and merge and pad. Recalculate now that things have
  # been corrected.
  these_lengths <- lengths(these_segments)
  n_these_tokens <- sum(these_lengths)

  # Before sorting out token types, add the specials.
  these_segments[[1]] <- c(cls_index, these_segments[[1]])
  these_segments <- purrr::map(these_segments, ~c(.x, sep_index))
  these_segments[[length(these_segments)]] <- c(
    these_segments[[length(these_segments)]],
    rep(pad_index, max_real_tokens - n_these_tokens)
  )

  # Figure out token_types, we'll return those at the same time.
  token_types <- unlist(purrr::map2(
    seq_along(these_segments),
    lengths(these_segments),
    ~rep(.x, .y)
  ))

  return(
    list(
      token_ids = unlist(these_segments),
      token_type_ids = token_types
    )
  )
}
