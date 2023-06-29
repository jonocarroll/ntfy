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
#' @param message text to send as notification
#' @param title title of notification. See \url{https://docs.ntfy.sh/publish/#message-title}
#' @param tags text tags or emoji shortcodes from \url{https://docs.ntfy.sh/emojis/},
#'     provided as a list
#' @param priority Message priority with 1=min, 3=default and 5=max. See \url{https://docs.ntfy.sh/publish/#message-priority}
#' @param actions Custom user action buttons for notifications. See \url{https://docs.ntfy.sh/publish/#action-buttons}
#' @param click Website opened when notification is clicked. See \url{https://docs.ntfy.sh/publish/#click-action}
#' @param attach URL of an attachment, see attach via URL. See \url{https://docs.ntfy.sh/publish/#attach-file-from-url}
#' @param filename File name of the attachment
#' @param delay Timestamp or duration for delayed delivery
#' @param email E-mail address for e-mail notifications??
#' @param topic subscribed topic to which to send notification
#' @param server ntfy server
#' @param ... other options passed to [httr::POST()]
#'
#' @return a [httr::response()] object (from [httr::POST()])
#' @export
ntfy_send <- function(message  = "test",
                      title    = NULL,
                      tags     = NULL, 
                      priority = 3,
                      actions  = NULL,
                      click    = NULL,
                      attach   = NULL,
                      filename = NULL,
                      delay    = NULL,
                      email    = NULL,
                      topic    = ntfy_topic(),
                      server   = ntfy_server(),
                      ...) {

  payload <- list(
    topic    = topic,
    message  = message,
    priority = priority,
    title    = title,
    tags     = as.list(tags),
    actions  = actions,
    click    = click,
    attach   = attach,
    filename = filename,
    delay    = delay,
    email    = email
  )
  
  payload <- Filter(Negate(is.null), payload)

  httr::POST(url = server,
             body = payload,
             encode = "json",
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
                      message = paste0("Process completed at ", Sys.time()),
                      title = "ntfy_done()",
                      tags = "white_check_mark",
                      server = ntfy_server(),
                      ...) {
  ntfy_send(topic = topic, message = message, server = server, title = title, tags = tags, ...)
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
                                  message = paste0("Process completed in ", time_result, "s"),
                                  title = "ntfy_done_with_timing()",
                                  tags = "stopwatch",
                                  server = ntfy_server(),
                             ...) {
  time_result <- system.time(res <- force(x))[3]
  ntfy_done(res, topic = topic, message = message, server = server, title = title, tags = tags,  ...)
}

