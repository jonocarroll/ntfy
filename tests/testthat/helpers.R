example_plot <- function() {
  df <- data.frame(x = 1:5, y = 1:5)
  ggplot2::ggplot(df, ggplot2::aes(x, y)) +
    ggplot2::geom_point() +
    ggplot2::theme_void()
}

slow_process <- function(x) {
  Sys.sleep(0.5)
  x
}
