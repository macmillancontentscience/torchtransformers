
base_url <- "https://storage.googleapis.com/torchtransformers-models/"

# maybe later store as a tibble with more info, but named vector is ok for now.

weights_url_map <- c(
  "bert_tiny_uncased" = paste0(
    base_url,
    "bert-tiny/v1/weights.pt"
  ),
  "bert_mini_uncased" = paste0(
    base_url,
    "bert-mini/v1/weights.pt"
  ),
  "bert_small_uncased" = paste0(
    base_url,
    "bert-small/v1/weights.pt"
  ),
  "bert_medium_uncased" = paste0(
    base_url,
    "bert-medium/v1/weights.pt"
  ),
  "bert_base_uncased" = paste0(
    base_url,
    "bert-base-uncased/v1/weights.pt"
  ),
  "bert_base_cased" = paste0(
    base_url,
    "bert-base-cased/v1/weights.pt"
  ),
  "bert_large_uncased" = paste0(
    base_url,
    "bert-large-uncased/v1/weights.pt"
  )
)


# There are some hard-to-avoid differences between the variable names in bert
# models constructed using this package and the standard variable names used in
# the huggingface saved weights. Here are some renaming rules that will (almost
# always?) be applied. We modify the *loaded* weights to match the *package*
# weights.

variable_names_replacement_rules <- c(
  "LayerNorm.gamma" = "layer_norm.weight",
  "LayerNorm.beta" = "layer_norm.bias",
  "attention.output.dense" = "attention.self.out_proj",
  "bert." = ""
)

usethis::use_data(
  weights_url_map,
  variable_names_replacement_rules,
  internal = TRUE,
  overwrite = TRUE
)
rm(
  base_url,
  weights_url_map,
  variable_names_replacement_rules
)
