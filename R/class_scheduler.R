scheduler_init <- function(
  pipeline = pipeline_init(),
  queue = "parallel",
  reporter = "verbose"
) {
  edges <- pipeline_upstream_edges(pipeline, targets_only = TRUE)
  graph <- graph_init(remove_loops(edges))
  igraph <- igraph::simplify(igraph::graph_from_data_frame(edges))
  priorities <- pipeline_get_priorities(pipeline)
  names <- scheduler_topo_sort(igraph, priorities, queue)
  queue <- queue_init(queue, names, initial_ranks(names, graph, priorities))
  queued <- counter_init(names)
  progress <- progress_init(queued = queued)
  reporter <- reporter_init(reporter)
  scheduler_new(graph, queue, progress, reporter)
}

scheduler_topo_sort <- function(igraph, priorities, queue) {
  trn(
    queue == "parallel",
    igraph::V(igraph)$name,
    topo_sort_custom(igraph, priorities)
  )
}

initial_ranks <- function(names, graph, priorities) {
  graph$produce_degrees(names, "upstream") + rank_offset(priorities[names])
}

rank_offset <- function(priorities) {
  - priorities / 2
}

scheduler_new <- function(
  graph = NULL,
  queue = NULL,
  progress = NULL,
  reporter = NULL
) {
  scheduler_class$new(graph, queue, progress, reporter)
}

scheduler_class <- R6::R6Class(
  classname = "tar_scheduler",
  class = FALSE,
  portable = FALSE,
  cloneable = FALSE,
  public = list(
    graph = NULL,
    queue = NULL,
    progress = NULL,
    reporter = NULL,
    initialize = function(
      graph = NULL,
      queue = NULL,
      progress = NULL,
      reporter = NULL
    ) {
      self$graph <- graph
      self$queue <- queue
      self$progress <- progress
      self$reporter <- reporter
    },
    count_unfinished_deps = function(name) {
      deps <- self$graph$produce_upstream(name)
      deps_queued <- counter_filter_exists(
        self$progress$queued,
        deps
      )
      deps_running <- counter_filter_exists(
        self$progress$running,
        deps
      )
      length(deps_queued) + length(deps_running)
    },
    validate = function() {
      self$graph$validate()
      self$queue$validate()
      self$progress$validate()
      self$reporter$validate()
    }
  )
)
