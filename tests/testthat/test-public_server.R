# Make a test plot
example_ggplot <- ggplot2::ggplot(
  data.frame(x = rbeta(500, sample(1:10, 1), 10)), ggplot2::aes(x = x)
) +
  ggplot2::geom_histogram(
    binwidth = 0.05, boundary = 0,
    color = "white", fill = "#DA413E"
  ) +
  ggplot2::theme_void()

rect_grob <- grid::rectGrob(
  x = 0.5, y = 0.5,
  width = 0.3, height = 0.3,
  gp = grid::gpar(fill = "lightblue", col = "navy")
)

circle_grob <- grid::circleGrob(
  x = 0.5, y = 0.5, r = 0.15,
  gp = grid::gpar(fill = "pink", col = "red")
)

text_grob <- grid::textGrob(
  "Hello Grid!",
  x = 0.5, y = 0.8,
  gp = grid::gpar(fontsize = 16, fontface = "bold")
)

# Combine all grobs into a single grob object
example_grob <- grid::gTree(children = grid::gList(rect_grob, circle_grob, text_grob))

slow_process <- function(x) {
  Sys.sleep(2) # sleep for 2 seconds
  x
}

# topic for testing
Sys.setenv("NTFY_SERVER" = "https://ntfy.sh")
Sys.setenv("NTFY_USERNAME" = "")
Sys.setenv("NTFY_PASSWORD" = "")
TEST_TOPIC <- "vNdqEO7AXxLKVUim"
RANDOM_STRING <- jsonlite::base64url_enc(as.character(Sys.time()))

test_that("auth on public fails", {
  skip_on_cran()
  expect_error(ntfy_send("this should fail", auth = TRUE), class = "httr2_http_401")
})

test_that("basic message sending works", {
  skip_on_cran()
  # with topic argument
  Sys.setenv(NTFY_TOPIC = "")
  expect_silent(ntfy_send("Basic test message, topic arg", topic = TEST_TOPIC))
  expect_silent(ntfy_send("Basic test message, topic arg", title = "Testing", topic = TEST_TOPIC))

  # with env var topic
  Sys.setenv(NTFY_TOPIC = TEST_TOPIC)
  expect_silent(ntfy_send("Basic test message"))
  expect_silent(ntfy_send("Basic test message", title = "Testing"))
  expect_silent(ntfy_send("Basic test message", title = "Testing", tags = c("partying_face", "+1")))
  expect_true({
    httr2::resp_status(
      ntfy_send(
        "Message with a ggplot2 image",
        title = "Testing ggplot2",
        tags = c("partying_face", "+1"),
        image = example_ggplot
      )) == 200
  })
  expect_true({
    httr2::resp_status(
      ntfy_send(
        "Message with a grob image",
        title = "Testing grob",
        tags = c("partying_face", "+1"),
        image = example_grob
      )) == 200
  })
  expect_true({
    httr2::resp_status(
      ntfy_send(
        "Message with a stored image",
        title = "Testing file",
        tags = c("partying_face", "+1"),
        image = file.path(testthat::test_path("testdata"), "test.png")
      )) == 200
  })
  # plot(1:10, 1:10)
  # expect_true({
  #   httr2::resp_status(
  #     ntfy_send(
  #       "Message with a recorded image",
  #       title = "Testing file",
  #       tags = c("partying_face", "+1"),
  #       image = recordPlot()
  #     )) == 200
  # })
  expect_silent(ntfy_send(RANDOM_STRING, title = "Testing with identifier", tags = "eye"))
})

test_that("server history works", {
  skip_on_cran()
  # with topic argument
  Sys.setenv(NTFY_TOPIC = "")
  expect_silent(ntfy_send(topic = TEST_TOPIC, RANDOM_STRING, title = "Testing with identifier", tags = "eye"))
  expect_silent(ntfy_history(topic = TEST_TOPIC))
  expect_silent(history <- ntfy_history(since = "20m", topic = TEST_TOPIC))
  expect_s3_class(history, "data.frame")
  expect_equal(unique(history$topic), TEST_TOPIC)
  expect_true(RANDOM_STRING %in% history$message)

  # with env var topic
  Sys.setenv(NTFY_TOPIC = TEST_TOPIC)
  expect_silent(ntfy_send(RANDOM_STRING, title = "Testing with identifier", tags = "eye"))
  expect_silent(ntfy_history())
  expect_silent(history <- ntfy_history(since = "20m"))
  expect_s3_class(history, "data.frame")
  expect_equal(unique(history$topic), TEST_TOPIC)
  expect_true(RANDOM_STRING %in% history$message)
})

test_that("done and friends work", {
  skip_on_cran()
  # with topic argument
  Sys.setenv(NTFY_TOPIC = "")
  expect_silent({mtcars |>
      head() |>
      ntfy_done(topic = TEST_TOPIC)
  })
  expect_silent({
    mtcars |>
      head() |>
      slow_process() |>
      ntfy_done_with_timing(topic = TEST_TOPIC)
  })

  Sys.setenv(NTFY_TOPIC = TEST_TOPIC)
  expect_silent({
    mtcars |>
      head() |>
      ntfy_done()
  })
  expect_silent({
    mtcars |>
      head() |>
      slow_process() |>
      ntfy_done_with_timing()
  })
})
