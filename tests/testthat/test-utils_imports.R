tar_test("hash_imports() on an empty envir", {
  out <- hash_imports(emptyenv())
  expect_true(is.data.frame(out))
  expect_equal(nrow(out), 0L)
  expect_equal(ncol(out), 3L)
  expect_equal(sort(colnames(out)), sort(c("name", "type", "data")))
})

tar_test("hash_imports() types", {
  envir <- new.env(parent = emptyenv())
  envir$f <- function(x) g(x) + h(x)
  envir$g <- function(x) dne + x
  envir$h <- function(x) i(x)
  envir$i <- function(x) x + a
  envir$a <- "x"
  envir$b <- 2L
  hashes <- hash_imports(envir)
  expect_equal(hashes$type[hashes$name == "a"], "object")
  expect_equal(hashes$type[hashes$name == "f"], "function")
})

tar_test("hash_imports() with a changed orphan object", {
  envir <- new.env(parent = emptyenv())
  envir$f <- function(x) g(x) + h(x)
  envir$g <- function(x) dne + x
  envir$h <- function(x) i(x)
  envir$i <- function(x) x + a
  envir$a <- "x"
  envir$b <- 2L
  hashes1 <- hash_imports(envir)
  envir$b <- envir$b + 1L
  hashes2 <- hash_imports(envir)
  expect_equal(hashes1$name, hashes2$name)
  expect_equal(hashes1$name[hashes1$data != hashes2$data], "b")
})

tar_test("hash_imports() with a changed dependency object", {
  envir <- new.env(parent = emptyenv())
  envir$f <- function(x) g(x) + h(x)
  envir$g <- function(x) dne + x
  envir$h <- function(x) i(x)
  envir$i <- function(x) x + a
  envir$a <- "x"
  envir$b <- 2L
  hashes1 <- hash_imports(envir)
  envir$a <- 1L
  hashes2 <- hash_imports(envir)
  out <- sort(hashes1$name[hashes1$data != hashes2$data])
  exp <- sort(c("a", "f", "h", "i"))
  expect_equal(out, exp)
})

tar_test("hash_imports() with a changed function", {
  envir <- new.env(parent = emptyenv())
  envir$f <- function(x) g(x) + h(x)
  envir$g <- function(x) dne + x
  envir$h <- function(x) i(x)
  envir$i <- function(x) x + a
  envir$a <- "x"
  envir$b <- 2L
  hashes1 <- hash_imports(envir)
  envir$g <- function(x) {
    dne + x + 1
  }
  hashes2 <- hash_imports(envir)
  out <- sort(hashes1$name[hashes1$data != hashes2$data])
  exp <- sort(c("f", "g"))
  expect_equal(out, exp)
})


tar_test("define a dependency object that was missing before", {
  envir <- new.env(parent = emptyenv())
  envir$f <- function(x) g(x) + h(x)
  envir$g <- function(x) dne + x
  envir$h <- function(x) i(x)
  envir$i <- function(x) x + a
  envir$a <- "x"
  envir$b <- 2L
  hashes1 <- hash_imports(envir)
  envir$dne <- 1L
  hashes2 <- hash_imports(envir)
  expect_equal(setdiff(hashes2$name, hashes1$name), "dne")
  hashes2 <- hashes2[hashes2$name != "dne", ]
  hashes2 <- hashes2[order(hashes2$name), ]
  hashes1 <- hashes1[order(hashes1$name), ]
  out <- sort(hashes2$name[hashes1$data != hashes2$data])
  exp <- sort(c("f", "g"))
  expect_equal(out, exp)
})

tar_test("hash_imports() after trivial formatting change", {
  envir <- new.env(parent = emptyenv())
  envir$f <- function(x) g(x) + h(x)
  envir$g <- function(x) dne + x
  envir$h <- function(x) i(x)
  envir$i <- function(x) x + a
  envir$a <- "x"
  envir$b <- 2L
  hashes1 <- hash_imports(envir)
  envir$g <- function(x)  dne +               x
  hashes2 <- hash_imports(envir)
  hashes1 <- hashes1[order(hashes1$name), ]
  hashes2 <- hashes2[order(hashes2$name), ]
  expect_equivalent(hashes1, hashes2)
})
