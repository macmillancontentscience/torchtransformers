% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/transformer_encoder.R
\name{transformer_encoder_single_bert}
\alias{transformer_encoder_single_bert}
\title{Single Transformer Layer}
\usage{
transformer_encoder_single_bert(
  embedding_size,
  intermediate_size = 4 * embedding_size,
  n_head,
  hidden_dropout = 0.1,
  attention_dropout = 0.1
)
}
\arguments{
\item{embedding_size}{Integer; the dimension of the embedding vectors.}

\item{intermediate_size}{Integer; size of dense layers applied after
attention mechanism.}

\item{n_head}{Integer; the number of attention heads per layer.}

\item{hidden_dropout}{Numeric; the dropout probability to apply to dense
layers.}

\item{attention_dropout}{Numeric; the dropout probability to apply in
attention.}
}
\description{
Build a single layer of a BERT-style attention-based transformer.
}
\section{Shape}{


Inputs:
\itemize{
\item input: \eqn{(*, sequence_length, embedding_size)}
\item optional mask: \eqn{(*, sequence_length)}
}

Output:
\itemize{
\item embeddings: \eqn{(*, sequence_length, embedding_size)}
\item weights: \eqn{(*, n_head, sequence_length, sequence_length)}
}
}

\examples{
emb_size <- 4L
seq_len <- 3L
n_head <- 2L
batch_size <- 2L

model <- transformer_encoder_single_bert(
  embedding_size = emb_size,
  n_head = n_head
)
# get random values for input
input <- array(
  sample(
    -10:10,
    size = batch_size * seq_len * emb_size,
    replace = TRUE
  ) / 10,
  dim = c(batch_size, seq_len, emb_size)
)
input <- torch::torch_tensor(input)
model(input)
}
