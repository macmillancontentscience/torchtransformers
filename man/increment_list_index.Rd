% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/tokenize.R
\name{increment_list_index}
\alias{increment_list_index}
\title{Convert from Python Standard to torch}
\usage{
increment_list_index(list_of_integers)
}
\value{
The list of integers, with 1 added to each integer.
}
\description{
The torch R package uses the R standard of starting counts at 1. Many
tokenizers use the Python standard of starting counts at 0. This function
converts a list of token ids provided by such a tokenizer to torch-friendly
values (by adding 1 to each id).
}
\examples{
increment_list_index(
  list(
    1:5,
    2:6,
    3:7
  )
)
}
