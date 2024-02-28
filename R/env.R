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

#' Get the ntfy username
#'
#' @param var environment variable in which the username is stored
#'
#' @return the username with access to the protected ntfy topic
#' @export
ntfy_username <- function(var = "NTFY_USERNAME") {
  Sys.getenv(var)
}

#' Get the ntfy password
#'
#' @param var environment variable in which the password is stored
#'
#' @return the password for the username with access to the protected ntfy topic
#' @export
ntfy_password <- function(var = "NTFY_PASSWORD") {
  Sys.getenv(var)
}

#' Get the ntfy authorization indicator
#'
#' @param var environment variable in which the ntfy authorization indicator is stored
#'
#' @return a logical that indicates if password authorization is used
#' @export
ntfy_auth <- function(var = "NTFY_AUTH") {
  toupper(Sys.getenv(var)) == "TRUE"
}
