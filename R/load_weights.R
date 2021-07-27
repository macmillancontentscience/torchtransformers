# we need the following...
# functions to download/cache the weights (use dlr later for this)
# functions to load the weights into a model.
#  ultimately we want the UI to be something like this:
# pt_bert_model <- load_pretrained("bert_base_uncased")
# ... and either same or different function that can load weights into bert modules
# that's part of large models.

# ok, specific order of things to do:
# make internal variable mapping model names (e.g. "bert_base_uncased") to
# urls of dicts. (done)
# write function to take in url and output R ... thing ... with names/values.
# (this will eventually be improved/cached with dlr)
# write (internal) functions to map weight names...? This might also be something
# that is saved as package data. Decide when I get here.
# to do this, first rename module variables to match standards as much as
# possible. Then any other name mapping that needs to be done should be saved
# with sysdata.


# this is a placeholder for something using dlr.
.download_weights <- function(model_name = "bert_base_uncased") {
  url <- weights_url_map[model_name]
  file <- tempfile(pattern = model_name, fileext = ".pt")

  status <- utils::download.file(
    url = url,
    destfile = file,
    method = "libcurl"
  )
  if (status != 0) {
    stop("Checkpoint download failed.")  # nocovr
  }
  state_dict <- torch::load_state_dict(file)

}

# the torch attention module puts the weight/bias values for the q,k,v tensors
# into a single tensor, rather than three separate ones. We do the concatenation
# so that we can load into our models...
.concatenate_qkv_weights <- function(state_dict) {
  # will have to do this for every layer.
  # thinking... look for (say) "query.weight" and "query.bias" and create
  # entries with same names, but with "in_proj_weight" and "in_proj_bias"...
  # Then give these values resulting from appropriate concatenation...
  w_names <- names(state_dict)
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
    # now do the actual concatenation. If stuff doesn't work out, try
    # transposing these. If it does, delete this comment. :)
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
