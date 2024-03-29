#' Add basic authorization headers if `auth = TRUE`
#' @keywords internal
req_add_auth_if_needed <- function(req, auth, username, password) {
  if (is.null(auth) || !auth) { return(req) }
  httr2::req_auth_basic(req, username, password)
}

#' Add image to the request body if `image` is present
#' @keywords internal
req_add_image_if_needed <- function(req, image) {
  if (is.null(image)) { return(req) }
  httr2::req_body_file(req, get_image_path(image))
}

#' Determine filename of a given image file or ggplot object
#' @keywords internal
get_image_path <- function(image) {
  if (inherits(image, "ggplot")) {
    requireNamespace("ggplot2", quietly = FALSE)
    filename <- tempfile(pattern = "gg", fileext = ".png")
    ggplot2::ggsave(filename, image)
  } else if (is.character(image)) {
    stopifnot(file.exists(image))
    filename <- image
  }
  
  return(filename)
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
#' @return a [httr2::response()] object
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
  
  resp <- httr2::request(server) |> 
    httr2::req_url_path_append(topic) |> 
    httr2::req_method("POST") |> 
    httr2::req_user_agent("ntfy (https://github.com/jonocarroll/ntfy)") |> 
    req_add_auth_if_needed(auth, username, password) |>  
    httr2::req_headers(!!!payload) |> 
    req_add_image_if_needed(image) |> 
    httr2::req_perform()
  
  return(resp)
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
  
  resp <- httr2::request(server) |> 
    httr2::req_url_path_append(topic) |> 
    httr2::req_url_path_append("json") |> 
    httr2::req_url_query(!!!query) |> 
    httr2::req_method("GET") |> 
    httr2::req_user_agent("ntfy (https://github.com/jonocarroll/ntfy)") |> 
    req_add_auth_if_needed(auth, username, password) |>
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


#' Notify Completion of a Process
#'
#' @inheritParams ntfy_send
#' @param x a result (ignored)
#' @param ... other arguments passed to [ntfy::ntfy_send()]
#'
#' @return the input x (for further piping) plus a notification will be sent
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

#' Notify Completion of a Process with Timing
#'
#' @inheritParams ntfy_done
#' @param x expression to be evaluated and timed
#' @param ... other arguments passed to [ntfy::ntfy_send()]
#'
#' @return the result of evaluating x (for further piping) plus a notification will be sent
#'
#' @export
ntfy_done_with_timing <- function(x,
                                  message = paste0("Process completed in ", time_result, "s"),
                                  title = "ntfy_done_with_timing()",
                                  tags = "stopwatch",
                                  topic = ntfy_topic(),
                                  server = ntfy_server(),
                                  auth = ntfy_auth(),
                                  username = ntfy_username(),
                                  password = ntfy_password(),
                                  ...) {
  time_result <- system.time(res <- force(x))[3]
  ntfy_send(
    message = message, title = title, tags = tags, 
    topic = topic, server = server, 
    username = username, password = password, auth = auth,
    ...)
  x
}
