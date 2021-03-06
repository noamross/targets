test_that("keras and future with local storage and retrieval", {
  # Requires Python TensorFlow and Keras.
  # Cannot test inside the RStudio IDE.
  unlink("_targets", recursive = TRUE)
  on.exit(unlink("_targets", recursive = TRUE))
  skip_if_not_installed("future")
  skip_if_not_installed("keras")
  on.exit(future::plan(future::sequential), add = TRUE)
  future::plan(future::multisession)
  envir <- new.env(parent = globalenv())
  envir$f <- function() {
    model <- keras::keras_model_sequential() %>%
      keras::layer_conv_2d(
        filters = 32,
        kernel_size = c(3, 3),
        activation = "relu",
        input_shape = c(28, 28, 1)
      ) %>%
      keras::layer_conv_2d(
        filters = 64,
        kernel_size = c(3, 3),
        activation = "relu"
      ) %>%
      keras::layer_max_pooling_2d(pool_size = c(2, 2)) %>%
      keras::layer_dropout(rate = 0.25) %>%
      keras::layer_flatten() %>%
      keras::layer_dense(units = 128, activation = "relu") %>%
      keras::layer_dropout(rate = 0.5) %>%
      keras::layer_dense(units = 10, activation = "softmax")
    keras::compile(
      model,
      loss = "categorical_crossentropy",
      optimizer = keras::optimizer_adadelta(),
      metrics = "accuracy"
    )
    model
  }
  x <- target_init(
    name = "abc",
    expr = quote(f()),
    format = "keras",
    envir = envir
  )
  pipeline <- pipeline_init(list(x))
  cmq <- algorithm_init("future", pipeline)
  cmq$run()
  expect_true(
    inherits(
      target_read_value(pipeline_get_target(pipeline, "abc"))$object,
      "keras.engine.training.Model"
    )
  )
})

test_that("keras and future with remote storage and retrieval", {
  # Requires Python TensorFlow and Keras.
  # Start up a new process for this one.
  # Also cannot test inside the RStudio IDE.
  unlink("_targets", recursive = TRUE)
  on.exit(unlink("_targets", recursive = TRUE))
  skip_if_not_installed("future")
  skip_if_not_installed("keras")
  on.exit(future::plan(future::sequential), add = TRUE)
  future::plan(future::multisession)
  envir <- new.env(parent = globalenv())
  envir$f <- function() {
    model <- keras::keras_model_sequential() %>%
      keras::layer_conv_2d(
        filters = 32,
        kernel_size = c(3, 3),
        activation = "relu",
        input_shape = c(28, 28, 1)
      ) %>%
      keras::layer_conv_2d(
        filters = 64,
        kernel_size = c(3, 3),
        activation = "relu"
      ) %>%
      keras::layer_max_pooling_2d(pool_size = c(2, 2)) %>%
      keras::layer_dropout(rate = 0.25) %>%
      keras::layer_flatten() %>%
      keras::layer_dense(units = 128, activation = "relu") %>%
      keras::layer_dropout(rate = 0.5) %>%
      keras::layer_dense(units = 10, activation = "softmax")
    keras::compile(
      model,
      loss = "categorical_crossentropy",
      optimizer = keras::optimizer_adadelta(),
      metrics = "accuracy"
    )
    model
  }
  x <- target_init(
    name = "abc",
    expr = quote(f()),
    format = "keras",
    storage = "remote",
    retrieval = "remote",
    envir = envir
  )
  pipeline <- pipeline_init(list(x))
  cmq <- algorithm_init("future", pipeline)
  cmq$run()
  expect_true(
    inherits(
      target_read_value(pipeline_get_target(pipeline, "abc"))$object,
      "keras.engine.training.Model"
    )
  )
})
