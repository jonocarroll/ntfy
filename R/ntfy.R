ntfy_request <- function(server, auth, username, password) {
  req <- httr2::request(server) |>
    httr2::req_user_agent("ntfy (https://github.com/jonocarroll/ntfy)")

  if (isTRUE(auth)) {
    req <- httr2::req_auth_basic(req, username, password)
  }

  req
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
#' @param image Image to include in the body of the notification. Either a `ggplot` object or a filename.
#' @param attach URL of an attachment, see attach via URL. See \url{https://docs.ntfy.sh/publish/#attach-file-from-url}
#' @param filename File name of the attachment
#' @param delay Timestamp or duration for delayed delivery
#' @param email E-mail address for e-mail notifications??
#' @param topic subscribed topic to which to send notification
#' @param server ntfy server
#' @param auth logical indicating if the topic requires password authorization
#' @param username username with access to a protected topic.
#' @param password password with access to a protected topic.
#'
#' @return a [httr2::response()] object, invisibly.
#'
#' @examplesIf interactive()
#' # send a message to the default topic ('mytopic')
#' ntfy_send("test from R!")
#'
#' # can use tags (emoji)
#' ntfy_send(message = "sending with tags!",
#'           tags = c(tags$cat, tags$dog)
#' )
#'
#' @export
ntfy_send <- function(message  = "test",
                      title    = NULL,
                      tags     = NULL,
                      priority = 3,
                      actions  = NULL,
                      click    = NULL,
                      image    = NULL,
                      attach   = NULL,
                      filename = NULL,
                      delay    = NULL,
                      email    = NULL,
                      topic    = ntfy_topic(),
                      server   = ntfy_server(),
                      auth     = ntfy_auth(),
                      username = ntfy_username(),
                      password = ntfy_password()) {

  payload <- list(
    message  = message,
    priority = priority,
    title    = title,
    tags     = toString(as.list(tags)),
    actions  = actions,
    click    = click,
    attach   = attach,
    filename = filename,
    delay    = delay,
    email    = email
  )
  payload <- Filter(Negate(is.null), payload)

  req <- ntfy_request(server, auth, username, password) |>
    httr2::req_url_path_append(topic) |>
    httr2::req_method("POST") |>
    httr2::req_headers(!!!payload)

  if (!is.null(image)) {
    if (inherits(image, "ggplot")) {
      path <- tempfile(pattern = "gg", fileext = ".png")
      on.exit(unlink(path), add = TRUE)
      ggplot2::ggsave(path, image, width = 5, height = 5)
    } else if (is.character(image)) {
      stopifnot(file.exists(image))
      filename <- path
    }
    req <- httr2::req_body_file(req, path)
  }

  resp <- httr2::req_perform(req)
  return(invisible(resp))
}


#' Retrieve History of Notifications
#'
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
#' @examplesIf interactive()
#' # get the last hour of notifications
#' ntfy_history(since = "1h")
#'
#' @export
ntfy_history <- function(since    = "all",
                         topic    = ntfy_topic(),
                         server   = ntfy_server(),
                         auth     = ntfy_auth(),
                         username = ntfy_username(),
                         password = ntfy_password(),
                         ...) {
  query <- list(
    poll = 1,
    since = since,
    ...
  )

  resp <- ntfy_request(server, auth, username, password) |>
    httr2::req_url_path_append(topic, "json") |>
    httr2::req_url_query(!!!query) |>
    httr2::req_method("GET") |>
    httr2::req_perform()

  if (httr2::resp_has_body(resp)) {
    # ntfy returns NDJSON (newline delimited), which has to be handled with
    # jsonlite::stream_in(), which requires it to be a connection object
    con <- resp |>
      httr2::resp_body_raw() |>
      rawConnection()
    on.exit(close(con))

    res <-
      jsonlite::stream_in(con, simplifyDataFrame = TRUE, verbose = FALSE) |>
      as.data.frame()
  } else {
    message("Server did not return any history.")
    res <- data.frame()
  }

  return(res)
}


#' Notify on Completion of a Process
#'
#' `ntfy_done()` tells you when the code completed, and
#' `ntfy_done_with_timing()` tells you how long it took.
#'
#' @inheritParams ntfy_send
#' @param x a result (ignored)
#' @param ... other arguments passed to [ntfy::ntfy_send()]
#'
#' @return
#' The input `x` (for further piping). A notification will be sent as a
#' side-effect.
#'
#' @examplesIf interactive()
#' # report that a process has completed
#' Sys.sleep(3) |> ntfy_done("Woke up")
#'
#' # report that a process has completed, and how long it took
#' Sys.sleep(3) |> ntfy_done_with_timing()
#' @export
ntfy_done <- function(x,
                      message  = paste0("Process completed at ", Sys.time()),
                      title    = "ntfy_done()",
                      tags     = "white_check_mark",
                      topic    = ntfy_topic(),
                      server   = ntfy_server(),
                      auth     = ntfy_auth(),
                      username = ntfy_username(),
                      password = ntfy_password(),
                      ...) {
  ntfy_send(
    message = message, title = title, tags = tags,
    topic = topic, server = server,
    username = username, password = password, auth = auth,
    ...)
  x
}

#' @export
#' @rdname ntfy_done
ntfy_done_with_timing <- function(x,
                                  message = NULL,
                                  title = "ntfy_done_with_timing()",
                                  tags = "stopwatch",
                                  topic = ntfy_topic(),
                                  server = ntfy_server(),
                                  auth = ntfy_auth(),
                                  username = ntfy_username(),
                                  password = ntfy_password(),
                                  ...) {
  time_result <- system.time(res <- force(x))[3]

  message <- message %||% paste0("Process completed in ", format(time_result), "s")
  ntfy_send(
    message = message, title = title, tags = tags,
    topic = topic, server = server,
    username = username, password = password, auth = auth,
    ...)
  x
}
