#' Filter Alerts through a Verbose Flag
#'
#' @param verbose A logical scalar indicating whether to show the alert.
#' @param ... Additional parameters passed on to [cli::cli_alert()].
#'
#' @keywords internal
.maybe_alert <- function(verbose = TRUE, ...) {
  if (verbose) {
    cli::cli_alert(..., .envir = rlang::caller_env())
  }
}
