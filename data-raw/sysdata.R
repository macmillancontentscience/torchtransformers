
base_url <- "https://storage.googleapis.com/torchtransformers-models/"

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

# maybe later store as a tibble with more info, but named vector is ok for now.

usethis::use_data(
  weights_url_map,
  internal = TRUE,
  overwrite = TRUE
)
rm(
  base_url,
  weights_url_map
)
