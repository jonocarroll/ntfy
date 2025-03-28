# Make a test plot
example_plot <- ggplot2::ggplot(
  data.frame(x = rbeta(500, sample(1:10, 1), 10)), ggplot2::aes(x = x)
) +
  ggplot2::geom_histogram(
    binwidth = 0.05, boundary = 0,
    color = "white", fill = "#DA413E"
  ) +
  ggplot2::theme_void()

slow_process <- function(x) {
  Sys.sleep(2) # sleep for 2 seconds
  x
}

# topic for testing
Sys.setenv("NTFY_SERVER" = "https://ntfy.andrewheiss.com")
Sys.setenv("NTFY_USERNAME" = "example")
Sys.setenv("NTFY_PASSWORD" = "super-secret-password")
TEST_TOPIC <- "r-testing"
RANDOM_STRING <- jsonlite::base64url_enc(paste0("private", as.character(Sys.time())))

test_that("no auth and bad auth fail", {
  skip_on_cran()
  # with topic argument
  expect_error(ntfy_send("Basic test message", topic = TEST_TOPIC), regex = "HTTP 403 Forbidden")
  expect_error(ntfy_send("Basic test message", auth = TRUE, username = "q", password = "z", topic = TEST_TOPIC), regex = "HTTP 401 Unauthorized")
  expect_error(ntfy_history(topic = TEST_TOPIC), regex = "HTTP 403 Forbidden")

  # with env var topic
  Sys.setenv(NTFY_TOPIC = TEST_TOPIC)
  expect_error(ntfy_send("Basic test message"), regex = "HTTP 403 Forbidden")
  expect_error(ntfy_send("Basic test message", auth = TRUE, username = "q", password = "z"), regex = "HTTP 401 Unauthorized")
  expect_error(ntfy_history(), regex = "HTTP 403 Forbidden")
})

test_that("basic message sending works", {
  skip_on_cran()
  # with topic argument
  Sys.setenv(NTFY_TOPIC = "")
  expect_silent(ntfy_send("Basic test message, topic arg", topic = TEST_TOPIC, auth = TRUE))
  expect_silent(ntfy_send("Basic test message, topic arg", title = "Testing", topic = TEST_TOPIC, auth = TRUE))

  # with env var topic
  Sys.setenv(NTFY_TOPIC = TEST_TOPIC)
  expect_silent(ntfy_send("Basic test message", auth = TRUE))
  expect_silent(ntfy_send("Basic test message", title = "Testing", auth = TRUE))
  expect_silent(ntfy_send("Basic test message", title = "Testing", tags = c("partying_face", "+1"), auth = TRUE))
  expect_true({
    httr2::resp_status(
      ntfy_send(
        "Message with an image",
        title = "Testing",
        tags = c("partying_face", "+1"),
        image = example_plot,
        auth = TRUE
      )) == 200
  })
  expect_silent(ntfy_send(RANDOM_STRING, title = "Testing with identifier", tags = "eye", auth = TRUE))

  # with env var auth
  Sys.setenv(NTFY_AUTH = "TRUE")
  expect_silent(ntfy_send("Basic test message"))
  Sys.setenv(NTFY_AUTH = "")

})

test_that("server history works", {
  skip_on_cran()
  # with topic argument
  Sys.setenv(NTFY_TOPIC = "")
  expect_silent(ntfy_send(topic = TEST_TOPIC, RANDOM_STRING, title = "Testing with identifier", tags = "eye", auth = TRUE))
  expect_silent(ntfy_history(topic = TEST_TOPIC, auth = TRUE))
  expect_silent(history <- ntfy_history(since = "20m", topic = TEST_TOPIC, auth = TRUE))
  expect_s3_class(history, "data.frame")
  expect_equal(unique(history$topic), TEST_TOPIC)
  expect_true(RANDOM_STRING %in% history$message)

  # with env var topic
  Sys.setenv(NTFY_TOPIC = TEST_TOPIC)
  expect_silent(ntfy_send(topic = TEST_TOPIC, RANDOM_STRING, title = "Testing with identifier", tags = "eye", auth = TRUE))
  expect_silent(ntfy_history(auth = TRUE))
  expect_silent(history <- ntfy_history(since = "20m", auth = TRUE))
  expect_s3_class(history, "data.frame")
  expect_equal(unique(history$topic), TEST_TOPIC)
  expect_true(RANDOM_STRING %in% history$message)

  # with env var auth
  Sys.setenv(NTFY_AUTH = "TRUE")
  expect_silent(ntfy_history())
  Sys.setenv(NTFY_AUTH = "")
})

test_that("done and friends work", {
  skip_on_cran()
  # with topic argument
  Sys.setenv(NTFY_TOPIC = "")
  expect_silent({
    mtcars |>
      head() |>
      ntfy_done(topic = TEST_TOPIC, auth = TRUE)
  })
  expect_silent({
    mtcars |>
      head() |>
      slow_process() |>
      ntfy_done_with_timing(topic = TEST_TOPIC, auth = TRUE)
  })

  Sys.setenv(NTFY_TOPIC = TEST_TOPIC)
  expect_silent({
    mtcars |>
      head() |>
      ntfy_done(auth = TRUE)
  })
  expect_silent({
    mtcars |>
      head() |>
      slow_process() |>
      ntfy_done_with_timing(auth = TRUE)
  })
})

