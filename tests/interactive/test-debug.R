tar_test("debug mode does not break tar_make()", {
  tar_script({
    tar_options(debug = "a")
    tar_pipeline(tar_target(a, "a"))
  })
  tar_make(reporter = "silent")
  expect_equal(tar_read(a), "a")
})

tar_test("debug mode starts a browser()", {
  tar_script({
    envir <- new.env(parent = baseenv())
    tar_options(debug = "b", envir = envir, packages = "targets")
    tar_pipeline(tar_target(a, "a"), tar_target(b, a))
  })
  tar_make(callr_function = NULL) # Should launch an interactive debugger.
  # Also print out targets::tar_name() in the debugger. Should be "b".
  # Also print out `a` in the debugger. Should be "a".
})

tar_test("debug mode starts a browser() even with 'never' mode", {
  tar_script({
    envir <- new.env(parent = baseenv())
    cue <- tar_cue(mode = "never")
    tar_options(debug = "b", envir = envir, cue = cue)
    tar_pipeline(tar_target(a, "a", cue = cue), tar_target(b, a, cue = cue))
  })
  tar_make() # Pre-build all targets.
  tar_make(callr_function = NULL) # Should launch an interactive debugger.
  # Also print out targets::tar_name() in the debugger. Should be "b".
  # Also print out `a` in the debugger. Should be "a".
})

tar_test("debug mode works for branches.", {
  # Start without debug mode.
  tar_script({
    envir <- new.env(parent = baseenv())
    tar_options(envir = envir)
    tar_pipeline(tar_target(a, seq_len(2)), tar_target(b, a, pattern = map(a)))
  })
  tar_make() # Look at the branch names.
  # Pick one of the b_* branches branches and
  # assign it to debug in tar_options.
  tar_script({
    envir <- new.env(parent = baseenv(), packages = "targets")
    tar_options(envir = envir, debug = "b_0a91b2ed")
    tar_pipeline(tar_target(a, seq_len(2)), tar_target(b, a, pattern = map(a)))
  })
  # Now verify that we launch a debugger.
  tar_make(callr_function = NULL)
  # Print targets::tar_name(). Should be the branch we picked in debug.
  # Also print out `a`.
  # Should be the value of the bud we are currently branching over.
})

tar_test("debug mode works in tar_make_clustermq()", {
  skip_on_os("windows")
  skip_if_not_installed("clustermq")
  skip_hpc()
  old <- getOption("clustermq.scheduler")
  options(clustermq.scheduler = "multicore")
  on.exit(options(clustermq.scheduler = old))
  tar_script({
    envir <- new.env(parent = baseenv())
    tar_options(debug = "b", envir = envir, packages = "targets")
    tar_pipeline(tar_target(a, "a"), tar_target(b, a))
  })
  # Should launch an interactive debugger.
  tar_make_clustermq(callr_function = NULL)
  # Also print out targets::tar_name() in the debugger. Should be "b".
  # Also print out `a` in the debugger. Should be "a".
})

tar_test("debug mode works in tar_make_future()", {
  skip_on_os("windows")
  skip_if_not_installed("future")
  skip_hpc()
  tar_script({
    envir <- new.env(parent = baseenv())
    tar_options(debug = "b", envir = envir, packages = "targets")
    tar_pipeline(tar_target(a, "a"), tar_target(b, a))
  })
  # Should launch an interactive debugger.
  tar_make_future(callr_function = NULL)
  # Also print out targets::tar_name() in the debugger. Should be "b".
  # Also print out `a` in the debugger. Should be "a".
})
