#' Get information on a graph series
#' @description Obtain a data frame with information
#' on the graphs within a graph series.
#' @param graph_series a graph series object of type
#' \code{dgr_graph_1D}.
#' @return a data frame containing information on the
#' graphs within the supplied graph series.
#' @examples
#' # Create three graphs
#' graph_1 <-
#'   create_graph() %>%
#'   add_n_nodes(3) %>%
#'   add_edges_w_string(
#'     "1->3 1->2 2->3")
#'
#' graph_2 <-
#'   graph_1 %>%
#'   add_node %>%
#'   add_edge(4, 3)
#'
#' graph_3 <-
#'   graph_2 %>%
#'   add_node %>%
#'   add_edge(5, 2)
#'
#' # Create an empty graph series and add
#' # the graphs
#' series <-
#'   create_series() %>%
#'   add_to_series(graph_1, .) %>%
#'   add_to_series(graph_2, .) %>%
#'   add_to_series(graph_3, .)
#'
#' # Get information on the graphs in the series
#' series_info(series)
#' #>   graph name date_time   tz nodes edges directed
#' #> 1     1 <NA>      <NA> <NA>     3     3     TRUE
#' #> 2     2 <NA>      <NA> <NA>     4     4     TRUE
#' #> 3     3 <NA>      <NA> <NA>     5     5     TRUE
#' @export series_info

series_info <- function(graph_series) {

  graphs_in_series <-
    graph_count(graph_series)

  series_properties <-
    as.data.frame(
      mat.or.vec(nr = graphs_in_series, nc = 7))

  colnames(series_properties) <-
    c("graph", "name", "date_time", "tz",
      "nodes", "edges", "directed")

  series_properties[,1] <-
    as.numeric(series_properties[,1])

  series_properties[,2] <-
    as.character(series_properties[,2])

  series_properties[,3] <-
    as.character(series_properties[,3])

  series_properties[,4] <-
    as.character(series_properties[,4])

  series_properties[,5] <-
    as.numeric(series_properties[,5])

  series_properties[,6] <-
    as.numeric(series_properties[,6])

  series_properties[,7] <-
    as.logical(series_properties[,7])

  if (graphs_in_series == 0) {
    return(series_properties)
  }

  for (i in 1:graphs_in_series) {
    series_properties[i, 1] <- i

    if (!is.null(graph_series$graphs[[i]]$graph_name)) {
      series_properties[i, 2] <-
        graph_series$graphs[[i]]$graph_name
    } else {
      series_properties[i, 2] <- NA
    }

    if (!is.null(graph_series$graphs[[i]]$graph_time)) {
      series_properties[i, 3] <-
        graph_series$graphs[[i]]$graph_time
    } else {
      series_properties[i, 3] <- NA
    }

    if (!is.null(graph_series$graphs[[i]]$graph_tz)) {
      series_properties[i, 4] <-
        graph_series$graphs[[i]]$graph_tz
    } else {
      series_properties[i, 4] <- NA
    }

    series_properties[i, 5] <-
      ifelse(!is.null(nrow(graph_series$graphs[[i]]$nodes_df)),
             nrow(graph_series$graphs[[i]]$nodes_df), 0)

    series_properties[i, 6] <-
      ifelse(!is.null(nrow(graph_series$graphs[[i]]$edges_df)),
             nrow(graph_series$graphs[[i]]$edges_df), 0)

    series_properties[i, 7] <-
      is_graph_directed(graph_series$graphs[[i]])
  }

  return(series_properties)
}
