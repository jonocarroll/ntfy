# Make a test plot
example_plot <- ggplot2::ggplot(
  data.frame(x = rbeta(500, sample(1:10, 1), 10)), ggplot2::aes(x = x)
) +
  ggplot2::geom_histogram(
    binwidth = 0.05, boundary = 0,
    color = "white", fill = "#DA413E"
  ) +
  ggplot2::theme_void()

# topic for testing
Sys.setenv("NTFY_SERVER" = "https://ntfy.sh")
Sys.setenv("NTFY_USERNAME" = "")
Sys.setenv("NTFY_PASSWORD" = "")
TEST_TOPIC <- "vNdqEO7AXxLKVUim"
RANDOM_STRING <- jsonlite::base64url_enc(as.character(Sys.time()))

test_that("auth on public fails", {
  expect_error(ntfy_send("this should fail", auth = TRUE), regex = "HTTP 401 Unauthorized")
})

test_that("basic message sending works", {
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
        "Message with an image", 
        title = "Testing", 
        tags = c("partying_face", "+1"),
        image = example_plot
      )) == 200
  })
  expect_silent(ntfy_send(RANDOM_STRING, title = "Testing with identifier", tags = "eye"))
})

test_that("server history works", {
  # with topic argument
  Sys.setenv(NTFY_TOPIC = "")
  expect_silent(ntfy_history(topic = TEST_TOPIC))
  expect_silent(history <- ntfy_history(since = "20m", topic = TEST_TOPIC))
  expect_s3_class(history, "data.frame")
  expect_equal(unique(history$topic), TEST_TOPIC)
  expect_true(RANDOM_STRING %in% history$message)
  
  # with env var topic
  Sys.setenv(NTFY_TOPIC = TEST_TOPIC)
  expect_silent(ntfy_history())
  expect_silent(history <- ntfy_history(since = "20m"))
  expect_s3_class(history, "data.frame")
  expect_equal(unique(history$topic), TEST_TOPIC)
  expect_true(RANDOM_STRING %in% history$message)
})

test_that("done and friends work", {
  # with topic argument
  Sys.setenv(NTFY_TOPIC = "")
  expect_silent({mtcars |> 
    head() |> 
    ntfy_done(topic = TEST_TOPIC)
  })
  expect_silent({  
  mtcars |> 
    head() |> 
    ntfy_done_with_timing(topic = TEST_TOPIC)
  })

  Sys.setenv(NTFY_TOPIC = TEST_TOPIC)
  expect_silent({mtcars |> 
    head() |> 
    ntfy_done()
  })
  expect_silent({  
  mtcars |> 
    head() |> 
    ntfy_done_with_timing()
  })
})
  
  # # Try all of this on a custom server with a password-protected topic
  # Sys.setenv("NTFY_SERVER" = "https://ntfy.andrewheiss.com")
  # Sys.setenv("NTFY_TOPIC" = "r-testing")
  # Sys.setenv("NTFY_USERNAME" = "example")
  # Sys.setenv("NTFY_PASSWORD" = "super-secret-password")
  # 
  # # Doesn't work because it's not authorized
  # ntfy_send("Basic test message")
  # 
  # # Send username and password
  # ntfy_send("Basic test message", auth = TRUE)
  # 
  # # Send wrong username and password
  # ntfy_send("Basic test message", auth = TRUE, username = "q", password = "z")
  # 
  # # Send image to password-protected server
  # ntfy_send(
  #   "Message with an image", 
  #   title = "Testing", 
  #   tags = c("partying_face", "+1"),
  #   image = example_plot,
  #   auth = TRUE
  # )
  # 
  # # Get history
  # ntfy_history(auth = TRUE)
  # 
  # # ntfy_done() and friends
  # mtcars |> 
  #   head() |> 
  #   ntfy_done(auth = TRUE)
  # 
  # mtcars |> 
  #   head() |> 
  #   ntfy_done_with_timing(auth = TRUE)
  # 
  # 
  # # Use auth automatically with an environment variable
  # Sys.setenv("NTFY_AUTH" = "TRUE")
  # 
  # # This should go to the password-protected topic
  # ntfy_send("Basic test message")
  # 
  # # This is the history of the password-protected topic
  # ntfy_history()
  # 
  # # ntfy_done() and friends
  # mtcars |> 
  #   head() |> 
  #   ntfy_done()
  # 
  # mtcars |> 
  #   head() |> 
  #   ntfy_done_with_timing()
  # 
