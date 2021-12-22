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

# misc imports ------------------------------------------------------------

#' @importFrom rlang .data
rlang::.data
#' @importFrom rlang .env
rlang::.env

# could also import pipe, and rewrite some of the functions to be more readable.

# token map ---------------------------------------------------------------

#' Figure out Input Segments
#'
#' Given a data frame of input token sequences, add a column giving the segment
#' index.
#'
#' @param token_df A data frame of tokens.
#' @param sep_token The token used to demarcate segments. Defaults to "[SEP]".
#' @param ... Columns to group by. Each group should be a single input sequence.
#'
#' @return The token data frame with a new `segment_index` column.
#' @keywords internal
.infer_segment_index <- function(token_df, sep_token = "[SEP]", ...) {
  return(
    dplyr::ungroup(
      dplyr::select(
        dplyr::mutate(
          dplyr::group_by(
            dplyr::mutate(
              token_df,
              is_sep = .data$token == .env$sep_token
            ),
            ...
          ),
          segment_index = cumsum(.data$is_sep) - .data$is_sep + 1L
        ),
        -.data$is_sep
      )
    )
  )
}

#' Make Token Map
#'
#' Given a list of input token sequences, construct a data frame with explicit
#' index columns.
#'
#' @param tokenized_text A list of tokenized input text. Each element in the
#'   list is expected to be a named integer vector of tokens.
#' @param sep_token The token used to demarcate segments. Defaults to "[SEP]".
#'
#' @return A data frame of the input tokens, with explicit index columns.
#' @keywords internal
.make_token_map <- function(tokenized_text, sep_token = "[SEP]") {
  token_map <- tibble::tibble(
    sequence_index = integer(),
    token_index = integer(),
    segment_index = integer(),
    token = character()
  )
  for (i in seq_along(tokenized_text)) {
    tokens <- names(tokenized_text[[i]])
    token_seq <- seq_along(tokens)
    token_map <- dplyr::bind_rows(
      token_map,
      data.frame(
        sequence_index = as.integer(i),
        token_index = token_seq,
        token = tokens,
        stringsAsFactors = FALSE
      )
    )
  }
  token_map <- .infer_segment_index(token_map, sep_token, .data$sequence_index)

  return(token_map)
}


# tidy attention output ---------------------------------------------------


#' Process Attention
#'
#' Takes the raw output from a BERT model and turns the attention weights matrix
#' into a data frame.
#'
#' @param bert_model_output The raw output from a BERT model.
#'
#' @return The attention weights from a BERT model, as a data frame.
#' @keywords internal
.process_attention_result <- function(bert_model_output) {
  attention_output <- bert_model_output$attention_weights

  # Infer number of tokens in input and construct a sequence of that length.
  token_seq <- seq_len(dim(attention_output[[1]])[[4]])
  layer_indexes_actual <- seq_len(length(attention_output))
  big_attention <- tibble::tibble(
    sequence_index = integer(),
    token_index = integer(),
    segment_index = integer(),
    token = character(),
    layer_index = integer(),
    head_index = integer(),
    attention_token_index = integer(),
    attention_segment_index = integer(),
    attention_token = character(),
    attention_weight = double()
  )

  sequence_attention <- purrr::map_dfr(
    layer_indexes_actual,
    function(this_index) {
      result_i <- torch::as_array(attention_output[[this_index]])
      this_attention <- tidyr::unnest_longer(
        tidyr::unnest_longer(
          tidyr::unnest_longer(
            tibble::enframe(
              purrr::array_tree(
                result_i[, , token_seq, token_seq]
              ),
              name = "sequence_index"
            ),
            .data$value,
            indices_to = "head_index"
          ),
          .data$value,
          indices_to = "token_index"
        ),
        .data$value,
        indices_to = "attention_token_index",
        values_to = "attention_weight"
      )
      this_attention$layer_index <- layer_indexes_actual[[this_index]]
      this_attention
    }
  )
  big_attention <- dplyr::bind_rows(
    big_attention,
    sequence_attention
  )

  return(big_attention)
}

#' Finalize Attention Output
#'
#' Takes the data frame output from `.process_attention_result`, joins on the
#' `token_map` information and filters out the padding tokens.
#'
#' @param processed_attention The output from `.process_attention_result`.
#' @param token_map The output from `.make_token_map`.
#' @param pad_token The token used to pad inputs. Defaults to "[PAD]".
#'
#' @return A tidy version of the attention weights matrix, with one weight value
#'   per row.
#' @keywords internal
.finalize_attention <- function(processed_attention,
                                token_map,
                                pad_token = "[PAD]") {
  to_ret <- dplyr::select(
    dplyr::mutate(
      dplyr::left_join(
        dplyr::select(
          dplyr::mutate(
            dplyr::left_join(
              processed_attention, token_map,
              by = c("sequence_index", "token_index"),
              suffix = c("", "_fill")
            ),
            segment_index = .data$segment_index_fill,
            token = .data$token_fill
          ),
          -dplyr::ends_with("_fill")
        ),
        token_map,
        by = c("sequence_index", "attention_token_index" = "token_index"),
        suffix = c("", "_fill")
      ),
      attention_segment_index = .data$segment_index_fill,
      attention_token = .data$token_fill
    ),
    -dplyr::ends_with("_fill")
  )
  # This is fine.
  return(dplyr::filter(to_ret,
                       .data$token != .env$pad_token,
                       .data$attention_token != .env$pad_token))
}

#' Tidy the Attention Output
#'
#' Given the output from a transformer model, construct a tidy data frame with
#' the attention weights data.
#'
#' @param bert_model_output The output from a BERT model.
#' @param tokenized_input A list of tokenized input text. Each element in the
#'   list is expected to be a named integer vector of tokens.
#' @param pad_token The token used to pad inputs. Defaults to "[PAD]".
#'
#' @return A tidy version of the attention weights matrix, with one weight value
#'   per row.
#' @export
tidy_attention_output <- function(bert_model_output,
                                  tokenized_input,
                                  pad_token = "[PAD]") {
  attention_df <- .process_attention_result(bert_model_output)
  token_map <- .make_token_map(tokenized_input)
  attention_df <- .finalize_attention(attention_df,
                                      token_map,
                                      pad_token = pad_token)

  return(attention_df)
}


# tidy embeddings output --------------------------------------------------

#' Process Embeddings
#'
#' Takes the raw output from a BERT model and turns the embeddings into a data
#' frame.
#'
#' @param bert_model_output The raw output from a BERT model.
#'
#' @return The embedding vectors from a BERT model, as a data frame.
#' @keywords internal
.process_embeddings_result <- function(bert_model_output) {
  embedding_output <- bert_model_output$output_embeddings
  initial_embeddings <- bert_model_output$initial_embeddings
  # Infer number of tokens in input and construct a sequence of that length.
  token_seq <- seq_len(dim(embedding_output[[1]])[[1]])
  # Infer dimensionality.
  n_dimensions <- dim(embedding_output[[1]])[[3]]

  layer_indexes_actual <- seq_len(length(embedding_output))

  big_output <- tibble::tibble(
    sequence_index = integer(),
    segment_index = integer(),
    token_index = integer(),
    token = character(),
    layer_index = integer()
  )
  for (colname in paste0("V", seq_len(n_dimensions))) {
    big_output[[colname]] <- integer()
  }
  layer_indexes_all <- c(0, layer_indexes_actual)

  sequence_outputs <- purrr::map_dfr(
    layer_indexes_all,
    function(this_index) {
      if (this_index == 0) {
        # In {tt}, the initial embeddings are returned as a separate element of
        # of the output. This is how we combine them with the layer output
        # embeddings.
        result_i <- initial_embeddings
      } else {
        result_i <- torch::as_array(embedding_output[[this_index]])
      }

      this_output <- tidyr::unnest_wider(
        tidyr::unnest_longer(
          tibble::enframe(
            purrr::array_tree(
              result_i[token_seq, ,]
            ),
            name = "token_index"
          ),
          .data$value,
          values_to = "V", # for backwards compatibility
          indices_to = "sequence_index"
        ),
        .data$V,
        names_sep = ""
      )

      this_output[["layer_index"]] <- this_index
      this_output
    }
  )
  return(
    dplyr::arrange(
      dplyr::bind_rows(
        big_output,
        sequence_outputs
      ),
      .data$sequence_index
    )
  )

}

#' Finalize Embeddings Output
#'
#' Takes the data frame output from `.process_embeddings_result`, joins on the
#' `token_map` information and filters out the padding tokens.
#'
#' @param processed_embeddings The output from `.process_embeddings_result`.
#' @param token_map The output from `.make_token_map`.
#' @param pad_token The token used to pad inputs. Defaults to "[PAD]".
#'
#' @return A tidy version of the output embeddings, with one embedding vector
#'   per row.
#' @keywords internal
.finalize_embeddings <- function(processed_embeddings,
                                 token_map,
                                 pad_token = "[PAD]") {
  to_ret <- dplyr::select(
    dplyr::mutate(
      dplyr::left_join(
        processed_embeddings, token_map,
        by = c("sequence_index", "token_index"),
        suffix = c("", "_fill")
      ),
      segment_index = .data$segment_index_fill,
      token = .data$token_fill
    ),
    -dplyr::ends_with("_fill")
  )

  return(dplyr::filter(to_ret, .data$token != pad_token))
}

#' Tidy the Embeddings Output
#'
#' Given the output from a transformer model, construct a tidy data frame.
#'
#' @param bert_model_output The output from a BERT model.
#' @param tokenized_input A list of tokenized input text. Each element in the
#'   list is expected to be a named integer vector of tokens.
#' @param pad_token The token used to pad inputs. Defaults to "[PAD]".
#'
#' @return A tidy version of the output embeddings, with one embedding vector
#'   per row.
#' @export
tidy_embeddings_output <- function(bert_model_output,
                                   tokenized_input,
                                   pad_token = "[PAD]") {
  embeddings_df <- .process_embeddings_result(bert_model_output)
  token_map <- .make_token_map(tokenized_input)
  embeddings_df <- .finalize_embeddings(embeddings_df,
                                      token_map,
                                      pad_token = pad_token)

  return(embeddings_df)
}

