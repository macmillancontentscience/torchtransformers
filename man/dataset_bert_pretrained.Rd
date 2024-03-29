% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dataset_bert_pretrained.R
\name{dataset_bert_pretrained}
\alias{dataset_bert_pretrained}
\title{BERT Pretrained Dataset}
\usage{
dataset_bert_pretrained(
  x,
  y = NULL,
  bert_type = NULL,
  tokenizer_scheme = NULL,
  n_tokens = NULL
)
}
\arguments{
\item{x}{A data.frame with one or more character predictor columns, or a
list, matrix, or character vector that can be coerced to such a data.frame.}

\item{y}{A factor of outcomes, or a data.frame with a single factor column.
Can be NULL (default).}

\item{bert_type}{A bert_type from \code{\link[=available_berts]{available_berts()}} to use to choose the
other properties. If \code{bert_type} and \code{n_tokens} are set, they overrule this
setting.}

\item{tokenizer_scheme}{A character scalar that indicates vocabulary +
tokenizer.}

\item{n_tokens}{An integer scalar indicating the number of tokens in the
output.}
}
\value{
An initialized \code{\link[torch:dataset]{torch::dataset()}}. If it is not yet tokenized, the
\code{tokenize()} method must be called before the dataset will be usable.
}
\description{
Prepare a dataset for pretrained BERT models.
}
\section{Fields}{

\describe{
\item{\code{input_data}}{\code{(private)} The input predictors (\code{x}) standardized to
a data.frame of character columns, and outcome (\code{y}) standardized to a
factor or \code{NULL}.}

\item{\code{tokenizer_metadata}}{\code{(private)} A list indicating the
\code{tokenizer_scheme} and \code{n_tokens} that have been or will be used to
tokenize the predictors (\code{x}).}

\item{\code{tokenized}}{\code{(private)} A single logical value indicating whether
the data has been tokenized.}
}}

\section{Methods}{

\describe{
\item{\code{initialize}}{Initialize this dataset. This method is called when the
dataset is first created.}
\item{\code{tokenize}}{Tokenize this dataset.}
\item{\code{untokenize}}{Remove any tokenization from this dataset.}
\item{\code{.tokenize_for_model}}{Tokenize this dataset for a particular model.
Generally superseded by instead calling \code{\link[=luz_callback_bert_tokenize]{luz_callback_bert_tokenize()}}.}
\item{\code{.getitem}}{Fetch an individual predictor (and, if available, the
associated outcome). Generally superseded by instead calling \code{.getbatch()}
(or by letting the {luz} modeling process fit automatically).}
\item{\code{.getbatch}}{Fetch specific predictors (and, if available, the
associated outcomes). This function is called automatically by \code{{luz}}
during the fitting process.}
\item{\code{.length}}{Determine the length of the dataset (the number of rows of
predictors). Generally superseded by instead calling \code{\link[=length]{length()}}.}
}
}

