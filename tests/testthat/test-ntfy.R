test_that("auth on public fails", {
  local_ntfy_reset()
  skip_on_cran()

  expect_error(
    ntfy_send("this should fail", auth = TRUE, topic = "test"),
    class = "httr2_http_401"
  )
})

test_that("no auth and bad auth fail on private server", {
  skip_on_cran()
  local_ntfy_reset()
  withr::local_envvar(
    NTFY_SERVER = "https://ntfy.andrewheiss.com",
    NTFY_USERNAME = "example",
    NTFY_PASSWORD = "super-secret-password"
  )
  TEST_TOPIC <- "r-testing"

  # with topic argument
  expect_error(
    ntfy_send("Basic test message", topic = TEST_TOPIC),
    class = "httr2_http_403"
  )
  expect_error(
    ntfy_send(
      "Basic test message",
      auth = TRUE,
      username = "q",
      password = "z",
      topic = TEST_TOPIC
    ),
    class = "httr2_http_401"
  )
  expect_error(
    ntfy_history(topic = TEST_TOPIC),
    class = "httr2_http_403"
  )
})

test_that("basic message sending works", {
  skip_on_cran()
  local_ntfy_reset()

  resp <- ntfy_send("Test message", topic = TEST_TOPIC)
  body <- httr2::resp_body_json(resp)
  expect_equal(body$topic, TEST_TOPIC)
  expect_equal(body$message, "Test message")
})

test_that("can retrieve topic from env var", {
  withr::local_envvar(NTFY_TOPIC = TEST_TOPIC)

  resp <- ntfy_send("Basic test message, topic arg")
  body <- httr2::resp_body_json(resp)
  expect_equal(body$topic, TEST_TOPIC)
})

test_that("can set title, tags, and image", {
  skip_on_cran()
  local_ntfy_reset()

  resp <- ntfy_send(
    message = "Message with an image",
    title = "Testing",
    tags = c("partying_face", "+1"),
    image = example_plot(),
    topic = TEST_TOPIC
  )
  body <- httr2::resp_body_json(resp)
  expect_equal(body$title, "Testing")
  expect_equal(body$tags, list("partying_face", "+1"))
  expect_equal(body$attachment$type, "image/png")
})

test_that("can retrieve server history", {
  skip_on_cran()
  local_ntfy_reset()

  topic <- random_string()
  expect_snapshot(history <- ntfy_history(topic = topic))
  expect_equal(history, data.frame())

  ntfy_send("message 1", topic = topic)
  ntfy_send("message 2", topic = topic)
  ntfy_send("message 3", topic = topic)

  Sys.sleep(3) # give it a beat

  history <- ntfy_history(topic = topic)
  expect_equal(history$message, c("message 1", "message 2", "message 3"))
})

test_that("ntfy_done works", {
  local_ntfy_reset()
  skip_on_cran()

  topic <- random_string()
  out <- ntfy_done(head(mtcars), topic = topic)
  expect_equal(out, head(mtcars))

  resp <- httr2::last_response()
  body <- httr2::resp_body_json(resp)
  expect_equal(body$topic, topic)
  expect_match(body$message, "Process completed at")
  expect_equal(body$tags, list("white_check_mark"))
})

test_that("ntfy_done_with_timing works", {
  local_ntfy_reset()
  skip_on_cran()

  topic <- random_string()
  out <- ntfy_done_with_timing(
    {
      Sys.sleep(0.5)
      10
    },
    topic = topic
  )
  expect_equal(out, 10)

  resp <- httr2::last_response()
  body <- httr2::resp_body_json(resp)
  expect_equal(body$topic, topic)
  expect_match(body$message, "Process completed in")
  expect_equal(body$tags, list("stopwatch"))
})
