TEST_TOPIC <- "vNdqEO7AXxLKVUim"

example_plot <- function() {
  df <- data.frame(x = 1:5, y = 1:5)
  ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    ggplot2::theme_void()
}

local_ntfy_reset <- function(frame = parent.frame()) {
  withr::local_envvar(
    NTFY_SERVER = "https://ntfy.sh",
    NTFY_USERNAME = NA,
    NTFY_PASSWORD = NA,
    NTFY_TOPIC = NA,
    .local_envir = frame
  )
}

random_string <- function() {
  jsonlite::base64url_enc(as.character(Sys.time()))
}
