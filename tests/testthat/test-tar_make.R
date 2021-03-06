tar_test("empty tar_make() works even with names", {
  tar_script(tar_pipeline())
  expect_silent(
    tar_make(
      names = x,
      reporter = "silent",
      callr_function = NULL
    )
  )
})

tar_test("tar_make() works", {
  tar_script(
    tar_pipeline(
      tar_target(y1, 1L + 1L),
      tar_target(y2, 1L + 1L),
      tar_target(z, y1 + y2)
    )
  )
  tar_make(
    reporter = "silent",
    callr_arguments = list(show = FALSE)
  )
  out <- readRDS(file.path("_targets", "objects", "z"))
  expect_equal(out, 4L)
})

tar_test("tar_make() deduplicates metadata", {
  tar_script({
    tar_options(envir = new.env(parent = baseenv()))
    tar_pipeline(tar_target(x, 1L, cue = tar_cue(mode = "always")))
  })
  for (index in seq_len(3L)) {
    tar_make(callr_function = NULL)
  }
  out <- meta_init()$database$read_data()
  expect_equal(nrow(out), 2L)
})

tar_test("tar_make() can use tidyselect", {
  tar_script(
    tar_pipeline(
      tar_target(y1, 1 + 1),
      tar_target(y2, 1 + 1),
      tar_target(z, y1 + y2)
    )
  )
  tar_make(
    names = starts_with("y"),
    reporter = "silent",
    callr_arguments = list(show = FALSE)
  )
  out <- sort(list.files(file.path("_targets", "objects")))
  expect_equal(out, sort(c("y1", "y2")))
})

tar_test("tar_make() finds the correct environment", {
  tar_script({
    f <- function(x) {
      g(x) + 1L
    }
    g <- function(x) {
      x + 1L
    }
    a <- 1L
    tar_pipeline(tar_target(y, f(!!a), tidy_eval = TRUE))
  })
  tar_make(
    reporter = "silent",
    callr_arguments = list(show = FALSE)
  )
  out <- readRDS(file.path("_targets", "objects", "y"))
  expect_equal(out, 3L)
})
