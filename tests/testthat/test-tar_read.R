tar_test("tar_read() on missing builder", {
  pipeline <- pipeline_init(list(target_init("x", quote(1L))))
  algorithm_init("local", pipeline = pipeline)$run()
  expect_error(tar_read(y), class = "condition_validate")
})

tar_test("tar_read() works on builders", {
  pipeline <- pipeline_init(list(target_init("x", quote(1L))))
  algorithm_init("local", pipeline = pipeline)$run()
  expect_equal(tar_read(x), 1L)
})

tar_test("tar_read() works on a dynamic file", {
  saveRDS("contents", "data_file")
  x <- target_init("x", quote("data_file"), format = "file")
  pipeline <- pipeline_init(list(x))
  local <- algorithm_init("local", pipeline = pipeline)
  local$run()
  expect_equal(tar_read(x), "data_file")
  expect_equal(list.files(file.path("_targets", "objects")), character(0))
})

tar_test("tar_read() on patterns with vector iteration", {
  pipeline <- pipeline_init(
    list(
      target_init("x", quote(letters[seq_len(4L)])),
      target_init("y", quote(x), pattern = quote(map(x)), iteration = "vector")
    )
  )
  algorithm_init("local", pipeline = pipeline)$run()
  expect_equal(tar_read(y), letters[seq_len(4L)])
  out <- tar_read(y, branches = c(2L, 3L))
  expect_equal(out, letters[c(2L, 3L)])
  expect_error(tar_read(y, branches = 99L), error = "condition_validate")
})

tar_test("tar_read() on patterns with list iteration", {
  pipeline <- pipeline_init(
    list(
      target_init("x", quote(letters[seq_len(4L)])),
      target_init("y", quote(x), pattern = quote(map(x)), iteration = "list")
    )
  )
  algorithm_init("local", pipeline = pipeline)$run()
  expect_equal(tar_read(y), as.list(letters[seq_len(4L)]))
})
