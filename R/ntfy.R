#' Get the ntfy topic
#'
#' @param var environment variable in which the topic is stored
#'
#' @return the ntfy topic to which the user should be subscribed
#' @export
ntfy_topic <- function(var = "NTFY_TOPIC") {
  Sys.getenv("NTFY_TOPIC")
}

#' Get the ntfy server
#'
#' @param var environment variable in which the server URL is stored
#'
#' @return the ntfy server URL
#' @export
ntfy_server <- function(var = "NTFY_SERVER") {
  Sys.getenv(var)
}

#' Send a Notification
#'
#' @param body text to send as notification
#' @param topic subscribed topic to which to send notification
#' @param server ntfy server
#' @param capture function to use to capture the output, e.g. `shQuote`, `capture.output`
#' @param ... other options passed to [httr::POST()]
#'
#' @return the returned value from [httr::POST()]
#' @export
ntfy_send <- function(body = "test",
                      topic = ntfy_topic(),
                      server = ntfy_server(),
                      capture = shQuote,
                      ...) {
  httr::POST(url = paste(server, topic, sep = "/"),
             body = capture(body),
             ...
  )
}

#' Retrieve History of Notifications
#'
#' @param all return all results?
#' @param since duration (e.g. `"10m"` or `"30s"`), a Unix timestamp (e.g.
#'   `"1635528757"`), a message ID (e.g. `"nFS3knfcQ1xe"`), or `"all"` (all cached
#'   messages)
#' @inheritParams ntfy_send
#' @param ... any other (named) query parameters to add to the request
#'
#' @return a [data.frame()] with one row per notification, with columns as
#'   described in the documentation
#'
#' @seealso \url{https://ntfy.sh/docs/subscribe/api/#json-message-format}
#'
#' @export
ntfy_history <- function(since = "all",
                         topic = ntfy_topic(),
                         server = ntfy_server(),
                         ...) {
  qry <- list(poll = 1, since = since, ...)
  resp <- httr::GET(url = paste(server, topic, "json", sep = "/"), query = qry)
  resp <- httr::content(resp, "text")
  resp <- gsub("\\n", "DBL_NEWLINE", resp, fixed = TRUE)
  resp <- strsplit(resp, "\\n")[[1]]
  res <- Reduce(rbind, lapply(resp, unjson))
  non_missing_cols <- apply(res, 2, function(x) any(!is.na(x)))
  res[, non_missing_cols]
}

#' unJSON edited string
#' @keywords internal
unjson <- function(x) {
  x <- gsub("DBL_NEWLINE", "\\n", x, fixed = TRUE)
  y <- list2DF(jsonlite::fromJSON(x))
  for (col in c("id", "time", "event", "topic", "title", "message",
                "priority", "tags", "click", "actions", "attachment")) {
    if (!utils::hasName(y, col)) {
      y[[col]] <- NA
    }
  }
  y
}

#' Notify Completion of a Process
#'
#' @inheritParams ntfy_send
#' @param x a result (ignored)
#'
#' @return the input x (for further piping) plus a notification will be sent
#' @export
ntfy_done <- function(x,
                 topic = ntfy_topic(),
                 body = paste0("Process completed at ", Sys.time()),
                 server = ntfy_server(),
                 ...) {
  ntfy_send(topic = topic, body = body, server = server, ...)
  x
}

#' Notify Completion of a Process with Timing
#'
#' @inheritParams ntfy_done
#' @param x expression to be evaluated and timed
#'
#' @return the result of evaluating x (for further piping) plus a notification will be sent
#'
#' @export
ntfy_done_with_timing <- function(x,
                                  topic = ntfy_topic(),
                                  body = paste0("Process completed in ", time_result, "s"),
                                  server = ntfy_server(),
                             ...) {
  time_result <- system.time(res <- force(x))[3]
  ntfy_done(res, topic = topic, body = body, server = server, ...)
}

