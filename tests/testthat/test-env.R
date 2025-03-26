test_that("informative error if topic not set", {
  expect_snapshot(ntfy_topic(), error = TRUE)
})
