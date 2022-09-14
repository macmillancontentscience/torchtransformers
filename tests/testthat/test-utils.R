test_that("Alert filtering works.", {
  expect_message(
    .maybe_alert(TRUE, "Alert"),
    "Alert"
  )
  expect_message(
    .maybe_alert(FALSE, "Alert"),
    NA
  )
})
