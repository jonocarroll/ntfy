test_that("informative error if topic not set", {
  Sys.setenv("NTFY_TOPIC" = "")
  expect_snapshot(ntfy_topic(), error = TRUE)
})
