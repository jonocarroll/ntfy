#' Get ntfy topics from environment variables
#'
#' * `ntfy_topic()` uses the `NTFY_TOPIC` env var to set the default topic.
#' * `ntfy_server()` uses the `NTFY_SERVER` env var to set the default server.
#' * `ntfy_auth()` uses the `NTFY_AUTH` env var to determine is authentication should be used.
#' * `ntfy_username()` uses the `NTFY_USERNAME` env var to set the default username.
#' * `ntfy_password()` uses the `NTFY_PASSWORD` env var to set the default password.
#'
#' @keywords internal
#' @export
ntfy_topic <- function() {
  topic <- Sys.getenv("NTFY_TOPIC")

  if (topic == "") {
    stop(
      "`topic` not set.\n",
      "* Either provide `topic` argument.\n",
      "* Or set `NTFY_TOPIC` environment variable.\n"
    )
  }

  topic
}

#' @rdname ntfy_topic
#' @export
ntfy_server <- function() {
  Sys.getenv("NTFY_SERVER", "https://ntfy.sh")
}

#' @rdname ntfy_topic
#' @export
ntfy_username <- function() {
  Sys.getenv("NTFY_USERNAME")
}

#' @rdname ntfy_topic
#' @export
ntfy_password <- function() {
  Sys.getenv("NTFY_PASSWORD")
}

#' @rdname ntfy_topic
#' @export
ntfy_auth <- function() {
  toupper(Sys.getenv("NTFY_AUTH")) == "TRUE"
}
