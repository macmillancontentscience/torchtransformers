
# make_and_load_bert ------------------------------------------------------


#' Pretrained BERT Model
#'
#' Construct a BERT model and load pretrained weights.
#'
#' @param model_name Character; which flavor of BERT to use.
#'
#' @return The model with pretrained weights loaded.
#' @export
make_and_load_bert <- function(model_name = "bert_tiny_uncased") {
  recognized_models <- bert_configs$model_name
  if (! model_name %in% recognized_models) {
    stop("model_name should be one of: ",
         paste0(recognized_models, collapse = ", "))
  }
  params <- bert_configs[bert_configs$model_name == model_name, ]

  model <- model_bert(embedding_size = params$embedding_size,
                      n_layer = params$n_layer,
                      n_head = params$n_head,
                      max_position_embeddings = params$max_tokens,
                      vocab_size = params$vocab_size)
  .load_weights(model, model_name)
  return(model)
}


# utils -------------------------------------------------------------------


# this is a placeholder for something more sophisticated using dlr.
# once the cache is set up, we should usually just be fetching from there
.download_weights <- function(model_name = "bert_tiny_uncased") {
  url <- weights_url_map[model_name]
  file <- tempfile(pattern = model_name, fileext = ".pt")

  # clean up temp file when we're done.
  on.exit(unlink(file))

  status <- utils::download.file(
    url = url,
    destfile = file,
    method = "libcurl"
  )
  if (status != 0) {
    stop("Checkpoint download failed.")  # nocovr
  }
  state_dict <- torch::load_state_dict(file)
  # I think we always want to do the concatenation and name fixing, so just do
  # that here.
  state_dict <- .concatenate_qkv_weights(state_dict)
  state_dict <- .rename_state_dict_variables(state_dict)
  # not sure if {dlr} supports this case yet, but it makes sense to save the
  # cached file at this point, after the name clean-up.
  return(state_dict)
}

#' Concatenate Attention Weights
#'
#' Concatenate weights to format attention parameters appropriately for loading
#' into BERT models. The torch attention module puts the weight/bias values for
#' the q,k,v tensors into a single tensor, rather than three separate ones. We
#' do the concatenation so that we can load into our models.
#'
#' @param state_dict A state_dict of pretrained weights, probably loaded from a
#'  file.
#'
#' @return The state_dict with query, key, value weights concatenated.
#' @keywords internal
.concatenate_qkv_weights <- function(state_dict) {
  w_names <- names(state_dict)
  # Find parameters with "query" in the name. *Assume* there will be
  # corresponding "key" and "value" parameters. *Construct* corresponding
  # "in_proj" variable.
  trigger_pattern <- "query\\."
  query_names <- w_names[stringr::str_detect(string = w_names,
                                             pattern = trigger_pattern)]

  for (qn in query_names) {
    kn <- stringr::str_replace(string = qn,
                               pattern = trigger_pattern,
                               replacement = "key.")
    vn <- stringr::str_replace(string = qn,
                               pattern = trigger_pattern,
                               replacement = "value.")
    ipn <- stringr::str_replace(string = qn,
                                pattern = trigger_pattern,
                                replacement = "in_proj_")
    combined <- torch::torch_cat(list(state_dict[[qn]],
                                      state_dict[[kn]],
                                      state_dict[[vn]]))
    state_dict[[ipn]] <- combined
    state_dict[[qn]] <- NULL
    state_dict[[kn]] <- NULL
    state_dict[[vn]] <- NULL
  }
  return(state_dict)
}

#' Clean up Parameter Names
#'
#' There are some hard-to-avoid differences between the variable names in BERT
#' models constructed using this package and the standard variable names used in
#' the Huggingface saved weights. This function changes the names from the
#' Huggingface saves to match package usage.
#'
#' @param state_dict A state_dict of pretrained weights, probably loaded from a
#'  file.
#'
#' @return The state_dict with the names normalized.
#' @keywords internal
.rename_state_dict_variables <- function(state_dict) {
  rep_rules <- variable_names_replacement_rules
  w_names <- names(state_dict)
  w_names <- stringr::str_replace_all(string = w_names,
                                      pattern = stringr::fixed(rep_rules))
  names(state_dict) <- w_names
  return(state_dict)
}


#' Load Pretrained Weights into a BERT Model
#'
#' There are some hard-to-avoid differences between the variable names in BERT
#' models constructed using this package and the standard variable names used in
#' the Huggingface saved weights. This function changes the names from the
#' Huggingface saves to match package usage.
#'
#' @param model a BERT-type model, constructed using `model_bert`.
#' @param model_name Character; which flavor of BERT to use. Must be compatible
#'   with `model`!
#'
#' @return The number of model parameters updated. (This is to enable error
#'   checks; the function is called for side effects.)
#' @keywords internal
.load_weights <- function(model, model_name = "bert_base_uncased") {
  # once the cache is set up, this should usually just be fetching from there
  sd <- .download_weights(model_name = model_name)

  my_sd <- model$state_dict()
  my_weight_names <- names(my_sd)
  saved_weight_names <- names(sd)
  names_in_common <- intersect(my_weight_names, saved_weight_names)
  if (length(names_in_common) > 0) {
    my_sd[names_in_common] <- sd[names_in_common]
  } else {
    warning("No matching weight names found.") # nocov
  }
  model$load_state_dict(my_sd)
  return(length(names_in_common)) #maybe? This function is for side effects.
}



